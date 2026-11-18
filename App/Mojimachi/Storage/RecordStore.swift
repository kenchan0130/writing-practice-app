import CloudKit
import ContentModel
import CoreData
import Foundation
import RecordKit

/// 学習記録とまちの物を、端末に保存する（D44・D63）。
///
/// - 記録は追加するだけの行。リセットは「リセットの印」の行を足す（行は消さない）。
/// - あとで iCloud の同期（`NSPersistentCloudKitContainer`）に切り替えられる形にしておく:
///   どの項目も既定値を持ち、一意の制約を使わない。行ごとの ID で二重を防ぐ（D63）。
/// - 「データの版」を持ち、データの形は項目の追加だけにする（D63）。
final class RecordStore {
  nonisolated static let dataVersion: Int64 = 1

  let container: NSPersistentContainer
  private var context: NSManagedObjectContext { container.viewContext }

  /// iCloud のコンテナ（D44）。自分の非公開データベースだけ使う（家族の共有は作らない。D148）。
  nonisolated static let cloudContainerID = "iCloud.io.github.kenchan0130.mojimachi"

  /// 同期の出来事を知らせる（保護者用の画面に出す。D63）。
  enum SyncEvent: Equatable {
    case exported(Date)
    case imported(Date)
    case failed(SyncProblem)
    /// 別の iPad の変更が入った。画面の読み直しが要る。
    case remoteChange
    /// iCloud のデータの置き場所が消えていた（ほかの iPad が「iCloud のデータを消す」を使った。D85）。
    case zoneDeleted
  }

  /// 同期の問題の種類（保護者用の画面の文言を決める）。
  enum SyncProblem: Equatable {
    case notSignedIn
    case quotaExceeded
    case other
  }

  /// 確かめ用の起動か（テスト、または `-localOnlyStore YES`）。この起動では iCloud に触れない。
  nonisolated static var isLocalOnlyRun: Bool {
    if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil { return true }
    #if DEBUG
      return UserDefaults.standard.bool(forKey: "localOnlyStore")
    #else
      return false
    #endif
  }

  /// 署名ありのビルドか（Info.plist の `MojimachiCloudKitEnabled` は、ビルド時に
  /// `CODE_SIGNING_ALLOWED` が入る）。署名なしだと iCloud の権利がなく、`CKContainer` や
  /// Core Data の iCloud の準備で落ちるため、使う前にここで確かめる。
  nonisolated static var hasCloudEntitlement: Bool {
    (Bundle.main.object(forInfoDictionaryKey: "MojimachiCloudKitEnabled") as? String) == "YES"
  }

  /// 同期の出来事を受け取る。
  var onSyncEvent: ((SyncEvent) -> Void)?
  /// iCloud の同期が実際に動いているか。
  private(set) var syncing: Bool
  private var observers: [any NSObjectProtocol] = []

  /// この iPad が、これまでに iCloud と同期できたことがあるか（D159）。
  /// 同期をオフにしたとき、「iCloud のデータを消す」のとき、置き場所が消えていたときに消す。
  nonisolated static let syncedBeforeKey = "hasSyncedWithICloud"
  private let defaults: UserDefaults
  /// 起動のとき、iCloud の置き場所があるかの確認を待っている（D159）。
  private var pendingZoneCheck = false

  /// 起動のときに、iCloud の置き場所の確認が要るか（D159）。
  /// 同期がオンで、前に同期できたことがあるときだけ要る。はじめての起動は、確認せずに同期する
  /// （置き場所がまだ無いのが普通なので）。
  nonisolated static func needsZoneCheckAtLaunch(syncOn: Bool, syncedBefore: Bool) -> Bool {
    syncOn && syncedBefore
  }

  nonisolated static func hasSyncedBefore(_ defaults: UserDefaults = .standard) -> Bool {
    defaults.bool(forKey: syncedBeforeKey)
  }

  nonisolated static func setSyncedBefore(_ value: Bool, _ defaults: UserDefaults = .standard) {
    if value {
      defaults.set(true, forKey: syncedBeforeKey)
    } else {
      defaults.removeObject(forKey: syncedBeforeKey)
    }
  }

  /// - Parameters:
  ///   - url: 保存するファイル。nil ならメモリの中だけ（確かめ用。iCloud は使わない）。
  ///   - cloudSync: iCloud と同期するか。サインインしていないときは、標準のしくみが
  ///     同期せずに待つ（保存先は開く）。確かめ用の起動（`isLocalOnlyRun`）では同期しない。
  ///
  /// 前に同期できたことがある iPad は、iCloud の置き場所が消されていないかを CloudKit で
  /// 確かめてから同期を始める（D159）。標準のしくみは、置き場所が消えていても作り直して
  /// 上げ直してしまうため、保存先を開く時点では iCloud につなげない。確認の間は端末の中だけで
  /// 開く（起動を止めない）。置き場所があった、または確かめられなかったときは、同期を始める
  /// （いまの動きのまま）。消えていたときは、同期をオフにして保護者に知らせる。
  init(
    url: URL? = RecordStore.defaultURL, cloudSync: Bool = false,
    defaults: UserDefaults = .standard
  ) {
    self.defaults = defaults
    container = NSPersistentCloudKitContainer(name: "Mojimachi", managedObjectModel: Self.model)
    let description = NSPersistentStoreDescription(url: url ?? URL(fileURLWithPath: "/dev/null"))
    let wantsSync = cloudSync && url != nil && !Self.isLocalOnlyRun && Self.hasCloudEntitlement
    if !cloudSync { Self.setSyncedBefore(false, defaults) }
    let needsCheck = Self.needsZoneCheckAtLaunch(
      syncOn: wantsSync, syncedBefore: Self.hasSyncedBefore(defaults))
    syncing = wantsSync && !needsCheck
    description.cloudKitContainerOptions =
      syncing
      ? NSPersistentCloudKitContainerOptions(containerIdentifier: Self.cloudContainerID) : nil
    description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
    description.setOption(
      true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
    container.persistentStoreDescriptions = [description]
    container.loadPersistentStores { _, error in
      if let error { Self.lastError = error }
    }
    context.automaticallyMergesChangesFromParent = true
    context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    if syncing {
      observeSync()
    } else if needsCheck {
      pendingZoneCheck = true
      Task { await verifyZoneThenStartSync() }
    }
  }

  /// 置き場所があるか確かめてから、同期を始める（D159）。
  private func verifyZoneThenStartSync() async {
    let check = await Self.checkZone()
    // 確認の間に、同期をオフにされていたら始めない。
    guard pendingZoneCheck else { return }
    pendingZoneCheck = false
    switch check {
    case .deleted: onSyncEvent?(.zoneDeleted)
    case .exists, .unknown: startSync()
    }
  }

  /// 端末の中だけで開いている保存先を、iCloud につなげて開き直す。`stopSync` の逆。
  private func startSync() {
    guard !syncing else { return }
    syncing = true
    save()
    let coordinator = container.persistentStoreCoordinator
    for store in coordinator.persistentStores { try? coordinator.remove(store) }
    for description in container.persistentStoreDescriptions {
      description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
        containerIdentifier: Self.cloudContainerID)
    }
    container.loadPersistentStores { _, error in
      if let error { Self.lastError = error }
    }
    observeSync()
  }

  /// 同期の出来事を見張る（D63）。
  private func observeSync() {
    let center = NotificationCenter.default
    observers.append(
      center.addObserver(
        forName: NSPersistentCloudKitContainer.eventChangedNotification, object: container,
        queue: .main
      ) { [weak self] note in
        let event =
          note.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
          as? NSPersistentCloudKitContainer.Event
        let result = event.flatMap(Self.syncResult)
        MainActor.assumeIsolated {
          guard let result else { return }
          switch result {
          case .exported, .imported: self?.markSynced()
          default: break
          }
          self?.onSyncEvent?(result)
        }
      })
    observers.append(
      center.addObserver(
        forName: .NSPersistentStoreRemoteChange, object: container.persistentStoreCoordinator,
        queue: .main
      ) { [weak self] _ in
        MainActor.assumeIsolated { self?.onSyncEvent?(.remoteChange) }
      })
  }

  /// この起動の同期を止める。保存先は開き直し、iCloud とのつながりだけ外す（行は消さない。D85）。
  /// 「iCloud のデータを消す」のあと、動いている同期が置き場所を作り直して上げ直さないようにする。
  func stopSync() {
    pendingZoneCheck = false
    Self.setSyncedBefore(false, defaults)
    guard syncing else { return }
    syncing = false
    for observer in observers { NotificationCenter.default.removeObserver(observer) }
    observers = []
    save()
    let coordinator = container.persistentStoreCoordinator
    for store in coordinator.persistentStores { try? coordinator.remove(store) }
    for description in container.persistentStoreDescriptions {
      description.cloudKitContainerOptions = nil
    }
    container.loadPersistentStores { _, error in
      if let error { Self.lastError = error }
    }
  }

  private func markSynced() {
    Self.setSyncedBefore(true, defaults)
  }

  /// NSPersistentCloudKitContainer が使う、非公開データベースの置き場所の名前。
  nonisolated static let cloudZoneName = "com.apple.coredata.cloudkit.zone"

  /// iCloud の置き場所（ゾーン）をまるごと消す（D85）。端末の中のデータは消さない。
  /// 署名なしのビルドや確かめ用の起動では、CloudKit に触れず何もしない（false を返す）。
  /// 同じ Apple アカウントのどの iPad からでも消せる（共有は作らない。D148）。
  nonisolated static func deleteCloudZone() async throws -> Bool {
    guard hasCloudEntitlement, !isLocalOnlyRun else { return false }
    let database = CKContainer(identifier: cloudContainerID).privateCloudDatabase
    let zoneID = CKRecordZone.ID(
      zoneName: cloudZoneName, ownerName: CKCurrentUserDefaultName)
    let result = try await database.modifyRecordZones(saving: [], deleting: [zoneID])
    for deletion in result.deleteResults.values {
      if case .failure(let error) = deletion {
        // もともと無ければ、消えたのと同じ。
        if (error as? CKError)?.code == .zoneNotFound { continue }
        throw error
      }
    }
    return true
  }

  /// 置き場所の確認の結果（D159）。
  enum ZoneCheck: Equatable {
    case exists
    case deleted
    /// 確かめられなかった（オフラインなど）。いまの動きのまま同期を始める。
    case unknown
  }

  /// iCloud の置き場所があるか、CloudKit で確かめる。署名なしのビルドや確かめ用の起動では、
  /// CloudKit に触れず `.unknown` を返す。
  nonisolated static func checkZone() async -> ZoneCheck {
    guard hasCloudEntitlement, !isLocalOnlyRun else { return .unknown }
    let database = CKContainer(identifier: cloudContainerID).privateCloudDatabase
    let zoneID = CKRecordZone.ID(zoneName: cloudZoneName, ownerName: CKCurrentUserDefaultName)
    do {
      _ = try await database.recordZone(for: zoneID)
      return .exists
    } catch {
      return isZoneDeletedError(error) ? .deleted : .unknown
    }
  }

  /// 置き場所が無い（消された）ことを表すエラーか。一番上のエラーだけでなく、
  /// 部分的な失敗（`partialErrorsByItemID`）の中や、元のエラー（underlying）の中も見る。
  /// 取り込みは `partialFailure` に包まれて「Zone Not Found」が入って届くため（D159）。
  nonisolated static func isZoneDeletedError(_ error: Error, depth: Int = 0) -> Bool {
    guard depth < 5 else { return false }
    let nsError = error as NSError
    if nsError.domain == CKErrorDomain {
      let code = CKError.Code(rawValue: nsError.code)
      if code == .zoneNotFound || code == .userDeletedZone { return true }
      if let partial = nsError.userInfo[CKPartialErrorsByItemIDKey] as? [AnyHashable: Error],
        partial.values.contains(where: { isZoneDeletedError($0, depth: depth + 1) })
      {
        return true
      }
    }
    if let underlying = nsError.userInfo[NSUnderlyingErrorKey] as? Error,
      isZoneDeletedError(underlying, depth: depth + 1)
    {
      return true
    }
    if let list = nsError.userInfo["NSUnderlyingErrors"] as? [Error],
      list.contains(where: { isZoneDeletedError($0, depth: depth + 1) })
    {
      return true
    }
    return false
  }

  /// 同期のエラーを、保護者用の画面向けの出来事にする。
  nonisolated static func syncEvent(forError error: Error) -> SyncEvent {
    if isZoneDeletedError(error) { return .zoneDeleted }
    switch (error as? CKError)?.code {
    case .notAuthenticated?, .accountTemporarilyUnavailable?: return .failed(.notSignedIn)
    case .quotaExceeded?: return .failed(.quotaExceeded)
    default: return .failed(.other)
    }
  }

  /// 終わった出来事だけを、保護者用の画面向けの形にする。
  private nonisolated static func syncResult(_ event: NSPersistentCloudKitContainer.Event)
    -> SyncEvent?
  {
    guard let end = event.endDate else { return nil }
    if let error = event.error { return syncEvent(forError: error) }
    switch event.type {
    case .export: return .exported(end)
    case .import: return .imported(end)
    default: return nil
    }
  }

  /// 保存に失敗したときの最後のエラー（子どもには見せず、保護者用の画面にだけ出す。D117）。
  nonisolated(unsafe) static var lastError: Error?

  static var defaultURL: URL {
    let folder = URL.applicationSupportDirectory
    try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    return folder.appendingPathComponent("Mojimachi.sqlite")
  }

  /// 最後に保存した時刻。
  private(set) var lastSaved: Date?

  // MARK: - 読む

  /// 子ども1人ぶんの学習記録（D16）。
  func loadLog(profile: UUID) -> LearningLog {
    let resets = fetch("ResetMarker", profile: profile).count
    let characters = fetch("CharacterRecordRow", profile: profile).compactMap(Self.characterRecord)
    let words = fetch("WordRecordRow", profile: profile).compactMap { row -> WordRecord? in
      guard let id = row.value(forKey: "id") as? UUID, let date = row.value(forKey: "date") as? Date
      else { return nil }
      return WordRecord(
        id: id, date: date, word: row.value(forKey: "word") as? String ?? "",
        generation: Int(row.value(forKey: "generation") as? Int64 ?? 0))
    }
    return LearningLog(
      characters: dedupe(characters), words: dedupe(words), generation: resets)
  }

  func loadPlaced(profile: UUID) -> [PlacedObject] {
    fetch("PlacedObjectRow", profile: profile)
      .sorted {
        ($0.value(forKey: "date") as? Date ?? .distantPast)
          < ($1.value(forKey: "date") as? Date ?? .distantPast)
      }
      .compactMap { row in
        guard let id = row.value(forKey: "id") as? UUID else { return nil }
        return PlacedObject(
          id: id, word: row.value(forKey: "word") as? String ?? "",
          symbol: row.value(forKey: "symbol") as? String ?? "",
          // 古い行には種類がない。乗り物として読む。
          kind: (row.value(forKey: "kind") as? String).flatMap(WordKind.init(rawValue:))
            ?? .vehicle)
      }
  }

  /// 全員のおねがい（D160）。まとめるのは `WishNotice.notices`。
  func loadWishes() -> [Wish] {
    fetch("WishRow").compactMap { row in
      guard let id = row.value(forKey: "id") as? UUID,
        let profile = row.value(forKey: "profileID") as? UUID,
        let date = row.value(forKey: "date") as? Date,
        let item = row.value(forKey: "item") as? String, !item.isEmpty
      else { return nil }
      return Wish(id: id, profileID: profile, item: item, date: date)
    }
  }

  /// 保存している行の数（保護者用の画面の「学習記録の管理」に出す）。
  func rowCount() -> Int {
    [
      "CharacterRecordRow", "WordRecordRow", "PlacedObjectRow", "ResetMarker", "ProfileRow",
      "WishRow",
    ].reduce(
      0
    ) {
      $0 + ((try? context.count(for: NSFetchRequest<NSManagedObject>(entityName: $1))) ?? 0)
    }
  }

  // MARK: - 書く

  func append(_ record: CharacterRecord, profile: UUID) {
    let row = NSEntityDescription.insertNewObject(
      forEntityName: "CharacterRecordRow", into: context)
    row.setValue(profile, forKey: "profileID")
    row.setValue(record.id, forKey: "id")
    row.setValue(record.date, forKey: "date")
    row.setValue(record.characterID, forKey: "characterID")
    row.setValue(record.stage.rawValue, forKey: "stage")
    row.setValue(record.passed, forKey: "passed")
    row.setValue(record.rescued, forKey: "rescued")
    row.setValue(record.reasons.map(\.rawValue).joined(separator: ","), forKey: "reasons")
    row.setValue(record.word, forKey: "word")
    row.setValue(
      record.strokes.flatMap { try? JSONEncoder().encode($0) }, forKey: "strokes")
    row.setValue(Int64(record.generation), forKey: "generation")
    row.setValue(Self.dataVersion, forKey: "dataVersion")
    save()
  }

  func append(_ record: WordRecord, profile: UUID) {
    let row = NSEntityDescription.insertNewObject(forEntityName: "WordRecordRow", into: context)
    row.setValue(profile, forKey: "profileID")
    row.setValue(record.id, forKey: "id")
    row.setValue(record.date, forKey: "date")
    row.setValue(record.word, forKey: "word")
    row.setValue(Int64(record.generation), forKey: "generation")
    row.setValue(Self.dataVersion, forKey: "dataVersion")
    save()
  }

  func append(_ object: PlacedObject, profile: UUID) {
    let row = NSEntityDescription.insertNewObject(forEntityName: "PlacedObjectRow", into: context)
    row.setValue(profile, forKey: "profileID")
    row.setValue(object.id, forKey: "id")
    row.setValue(Date(), forKey: "date")
    row.setValue(object.word, forKey: "word")
    row.setValue(object.symbol, forKey: "symbol")
    row.setValue(object.kind.rawValue, forKey: "kind")
    row.setValue(Self.dataVersion, forKey: "dataVersion")
    save()
  }

  /// 子どもの「おねがい」を1行足す（D160）。押すたびに足し、まとめるのは読むときに行う。
  func append(_ wish: Wish) {
    let row = NSEntityDescription.insertNewObject(forEntityName: "WishRow", into: context)
    row.setValue(wish.profileID, forKey: "profileID")
    row.setValue(wish.id, forKey: "id")
    row.setValue(wish.date, forKey: "date")
    row.setValue(wish.item, forKey: "item")
    row.setValue(Self.dataVersion, forKey: "dataVersion")
    save()
  }

  /// 保護者が「確認した」を押したとき、その子のそのものの おねがいを消す（D160）。
  func deleteWishes(profile: UUID, item: String) {
    for row in fetch("WishRow", profile: profile) where row.value(forKey: "item") as? String == item
    {
      context.delete(row)
    }
    save()
  }

  /// 「記録だけリセット」（§6.3）。リセットの印を1行足す。
  func appendReset(profile: UUID) {
    let row = NSEntityDescription.insertNewObject(forEntityName: "ResetMarker", into: context)
    row.setValue(profile, forKey: "profileID")
    row.setValue(UUID(), forKey: "id")
    row.setValue(Date(), forKey: "date")
    row.setValue(Self.dataVersion, forKey: "dataVersion")
    save()
  }

  // MARK: - プロフィール（D16・D19）

  func loadProfiles() -> [Profile] {
    fetch("ProfileRow")
      .sorted {
        ($0.value(forKey: "date") as? Date ?? .distantPast)
          < ($1.value(forKey: "date") as? Date ?? .distantPast)
      }
      .compactMap { row in
        guard let id = row.value(forKey: "id") as? UUID else { return nil }
        return Profile(
          id: id, name: row.value(forKey: "name") as? String ?? "",
          honorific: Profile.Honorific(rawValue: row.value(forKey: "honorific") as? String ?? "")
            ?? .none,
          face: row.value(forKey: "face") as? String ?? "",
          handedness: Profile.Handedness(
            rawValue: row.value(forKey: "handedness") as? String ?? "") ?? .right,
          dailyGoal: Int(row.value(forKey: "dailyGoal") as? Int64 ?? 5),
          penColor: (row.value(forKey: "penColor") as? String).flatMap(PenColor.init(rawValue:)))
      }
  }

  /// プロフィールを保存する（あれば直し、なければ足す）。
  func save(_ profile: Profile) {
    let row: NSManagedObject
    if let existing = fetch("ProfileRow").first(where: {
      $0.value(forKey: "id") as? UUID == profile.id
    }) {
      row = existing
    } else {
      row = NSEntityDescription.insertNewObject(forEntityName: "ProfileRow", into: context)
      row.setValue(profile.id, forKey: "id")
      row.setValue(Date(), forKey: "date")
      row.setValue(Self.dataVersion, forKey: "dataVersion")
    }
    row.setValue(profile.name, forKey: "name")
    row.setValue(profile.honorific.rawValue, forKey: "honorific")
    row.setValue(profile.face, forKey: "face")
    row.setValue(profile.handedness.rawValue, forKey: "handedness")
    row.setValue(Int64(profile.dailyGoal), forKey: "dailyGoal")
    row.setValue(profile.penColor?.rawValue, forKey: "penColor")
    save()
  }

  /// プロフィールと、その子の記録・まちの物をすべて消す（取り返しのつかない操作。§5.3）。
  func deleteProfile(_ id: UUID) {
    for entity in [
      "CharacterRecordRow", "WordRecordRow", "PlacedObjectRow", "ResetMarker", "WishRow",
    ] {
      for row in fetch(entity, profile: id) { context.delete(row) }
    }
    for row in fetch("ProfileRow") where row.value(forKey: "id") as? UUID == id {
      context.delete(row)
    }
    save()
  }

  private func save() {
    guard context.hasChanges else { return }
    do {
      try context.save()
      lastSaved = Date()
    } catch {
      Self.lastError = error
      context.rollback()
    }
  }

  private func fetch(_ entity: String, profile: UUID? = nil) -> [NSManagedObject] {
    let request = NSFetchRequest<NSManagedObject>(entityName: entity)
    if let profile {
      request.predicate = NSPredicate(format: "profileID == %@", profile as CVarArg)
    }
    return (try? context.fetch(request)) ?? []
  }

  /// 同じ ID の行は1つにする（2台から同じ行が届いたとき。D63）。
  private func dedupe<T: Identifiable>(_ items: [T]) -> [T] where T.ID == UUID {
    var seen = Set<UUID>()
    return items.filter { seen.insert($0.id).inserted }
  }

  private static func characterRecord(_ row: NSManagedObject) -> CharacterRecord? {
    guard let id = row.value(forKey: "id") as? UUID,
      let date = row.value(forKey: "date") as? Date,
      let stage = CharacterRecord.Stage(rawValue: row.value(forKey: "stage") as? String ?? "")
    else { return nil }
    let reasons = (row.value(forKey: "reasons") as? String ?? "")
      .split(separator: ",").compactMap { CharacterRecord.Reason(rawValue: String($0)) }
    let strokes = (row.value(forKey: "strokes") as? Data).flatMap {
      try? JSONDecoder().decode([[[Double]]].self, from: $0)
    }
    return CharacterRecord(
      id: id, date: date, characterID: row.value(forKey: "characterID") as? String ?? "",
      stage: stage, passed: row.value(forKey: "passed") as? Bool ?? false,
      rescued: row.value(forKey: "rescued") as? Bool ?? false, reasons: reasons,
      word: row.value(forKey: "word") as? String, strokes: strokes,
      generation: Int(row.value(forKey: "generation") as? Int64 ?? 0))
  }

  // MARK: - データの形

  /// コードで作るデータの形（`.xcdatamodeld` を使わない）。
  static let model: NSManagedObjectModel = {
    func attribute(
      _ name: String, _ type: NSAttributeDescription.AttributeType, optional: Bool = true,
      defaultValue: Any? = nil
    ) -> NSAttributeDescription {
      let a = NSAttributeDescription()
      a.name = name
      a.type = type
      a.isOptional = optional
      a.defaultValue = defaultValue
      if type == .binaryData { a.allowsExternalBinaryDataStorage = true }
      return a
    }
    func entity(_ name: String, _ attributes: [NSAttributeDescription]) -> NSEntityDescription {
      let e = NSEntityDescription()
      e.name = name
      e.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
      e.properties =
        attributes + [
          attribute("id", .uuid), attribute("date", .date),
          attribute("dataVersion", .integer64, optional: false, defaultValue: dataVersion),
          // どの子の行か（D16）。プロフィールの行では使わない。
          attribute("profileID", .uuid),
        ]
      return e
    }
    let model = NSManagedObjectModel()
    model.entities = [
      entity(
        "CharacterRecordRow",
        [
          attribute("characterID", .string), attribute("stage", .string),
          attribute("passed", .boolean, optional: false, defaultValue: false),
          attribute("rescued", .boolean, optional: false, defaultValue: false),
          attribute("reasons", .string), attribute("word", .string),
          attribute("strokes", .binaryData),
          attribute("generation", .integer64, optional: false, defaultValue: 0),
        ]),
      entity(
        "WordRecordRow",
        [
          attribute("word", .string),
          attribute("generation", .integer64, optional: false, defaultValue: 0),
        ]),
      entity(
        "PlacedObjectRow",
        [
          attribute("word", .string), attribute("symbol", .string), attribute("kind", .string),
        ]),
      entity("ResetMarker", []),
      // 子どもの「おねがい」（D160）。何をやりたがったか（`item`）と、押した日（`date`）。
      entity("WishRow", [attribute("item", .string)]),
      entity(
        "ProfileRow",
        [
          attribute("name", .string), attribute("honorific", .string), attribute("face", .string),
          attribute("handedness", .string), attribute("penColor", .string),
          attribute("dailyGoal", .integer64, optional: false, defaultValue: 5),
        ]),
    ]
    return model
  }()
}
