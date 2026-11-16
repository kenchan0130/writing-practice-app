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

  /// - Parameter url: 保存するファイル。nil ならメモリの中だけ（確かめ用）。
  init(url: URL? = RecordStore.defaultURL) {
    container = NSPersistentCloudKitContainer(name: "Mojimachi", managedObjectModel: Self.model)
    let description = NSPersistentStoreDescription(url: url ?? URL(fileURLWithPath: "/dev/null"))
    // iCloud のコンテナを用意するまでは、端末の中だけに保存する（D44）。
    description.cloudKitContainerOptions = nil
    description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
    container.persistentStoreDescriptions = [description]
    container.loadPersistentStores { _, error in
      if let error { Self.lastError = error }
    }
    context.automaticallyMergesChangesFromParent = true
    context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
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
          symbol: row.value(forKey: "symbol") as? String ?? "")
      }
  }

  /// 保存している行の数（保護者用の画面の「iCloud とデータ」に出す）。
  func rowCount() -> Int {
    ["CharacterRecordRow", "WordRecordRow", "PlacedObjectRow", "ResetMarker", "ProfileRow"].reduce(
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
    row.setValue(Self.dataVersion, forKey: "dataVersion")
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
    for entity in ["CharacterRecordRow", "WordRecordRow", "PlacedObjectRow", "ResetMarker"] {
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
      entity("PlacedObjectRow", [attribute("word", .string), attribute("symbol", .string)]),
      entity("ResetMarker", []),
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
