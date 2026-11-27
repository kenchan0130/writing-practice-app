import CloudKit
import ContentModel
import Foundation
import JudgeKit
import Observation
import PracticeKit
import RecordKit

/// 練習の進み具合（D44）。学習記録とまちの物は端末に保存する（RecordStore）。
/// 保護者用の設定は、いまは UserDefaults に置く。
@Observable
final class ProgressStore {
  static let shared = ProgressStore()

  private let records: RecordStore

  /// 子どもたち（D16・D19）。
  private(set) var profiles: ProfileList
  /// いま使っている子。iPad ごとに「いつも使う子」として覚える（D16）。
  private(set) var currentProfileID: UUID
  /// 子どもの切り替えに保護者用の確認を求めるか（§5.3。初期値はオフ）。
  var confirmsProfileSwitch: Bool {
    didSet { defaults.set(confirmsProfileSwitch, forKey: "confirmsProfileSwitch") }
  }

  /// プロフィールの顔（仮の絵）。
  static let faces = [
    "hare.fill", "tortoise.fill", "cat.fill", "dog.fill", "bird.fill", "fish.fill", "ladybug.fill",
    "teddybear.fill",
  ]

  /// いまの子のペンの色（選んでいなければ青。D88）。
  var penColor: PenColor { currentProfile?.penColor ?? .default }
  /// まだペンの色を選んでいない（はじめての起動で1回選ぶ。D88）。
  var needsPenColorChoice: Bool { currentProfile?.penColor == nil }

  func setPenColor(_ color: PenColor) {
    guard var profile = currentProfile else { return }
    profile.penColor = color
    updateProfile(profile)
  }

  var currentProfile: Profile? { profiles.profile(currentProfileID) }

  /// 学習記録（D25）。書き足すのは `record` から。
  private(set) var log: LearningLog
  /// まちに置いた物（D43・D53）。
  private(set) var placed: [PlacedObject]
  /// おもちゃばこの「出した」「しまった」の行（D82・D185）。
  private(set) var moves: [ToyBoxMove] = []
  /// まちと いえに出ている物と、おもちゃばこの中身（行から計算する）。
  var board: ToyBoxBoard { ToyBoxBoard(placed: placed, moves: moves) }
  /// ステッカーの行（手に入れた・貼った・はがした。D190）。
  private(set) var stickerEvents: [StickerEvent] = []
  /// 持っているステッカーと、貼ってある場所（行から計算する）。
  var stickers: [OwnedSticker] { StickerBook.owned(stickerEvents) }
  /// 子どもたちの「おねがい」（D160）。まとめて見せるのは `wishNotices`。
  private(set) var wishes: [Wish] = []
  /// 最後に保存した時刻（保護者用の画面の「学習記録の管理」に出す。D63）。
  private(set) var lastSaved: Date?

  /// ④ に合格した「慣れた字」（D56）。記録から計算する。
  var mastered: Set<String> {
    Set(log.map.filter { $0.value == .wroteAlone }.map(\.key))
  }

  /// 判定のおまかせ設定（D22）。
  var preset: JudgePreset {
    didSet { defaults.set(preset.rawValue, forKey: "preset") }
  }
  /// とめ・はね・はらいのヒントを出す（D145）。
  var showsEndingHints: Bool {
    didSet { defaults.set(showsEndingHints, forKey: "showsEndingHints") }
  }
  /// 保護者用の確認で iPad のパスコードも求める（D64）。
  var requiresDeviceAuth: Bool {
    didSet { defaults.set(requiresDeviceAuth, forKey: "requiresDeviceAuth") }
  }

  // MARK: - 音と表示（§5.3）

  /// お手本（書き順のアニメーション）の速さ。
  enum ModelSpeed: String, CaseIterable {
    case slow
    case normal
    case fast

    /// 1画にかける時間の倍率。
    var factor: Double {
      switch self {
      case .slow: 1.5
      case .normal: 1
      case .fast: 0.65
      }
    }
  }

  var voiceVolume: Double { didSet { defaults.set(voiceVolume, forKey: "voiceVolume") } }
  var bgmVolume: Double { didSet { defaults.set(bgmVolume, forKey: "bgmVolume") } }
  var effectVolume: Double { didSet { defaults.set(effectVolume, forKey: "effectVolume") } }
  /// おとなしモード（声も含めてすべての音を止める。§3.9）。
  var quietMode: Bool { didSet { defaults.set(quietMode, forKey: "quietMode") } }
  /// 字幕（吹き出し）。最初はオン（§3.9）。
  var showsSubtitles: Bool { didSet { defaults.set(showsSubtitles, forKey: "showsSubtitles") } }
  var modelSpeed: ModelSpeed { didSet { defaults.set(modelSpeed.rawValue, forKey: "modelSpeed") } }
  /// マスを大きくする。
  var largeGrid: Bool { didSet { defaults.set(largeGrid, forKey: "largeGrid") } }
  /// 筆圧を使う（D66。最初はオン）。
  var usesPressure: Bool { didSet { defaults.set(usesPressure, forKey: "usesPressure") } }

  // MARK: - iCloud の同期（D63）

  /// iCloud で同期する（最初はオン）。切り替えは、つぎに アプリを ひらいたときから効く
  /// （保存先を開き直す必要があるため。安全で単純な方を選んだ）。
  /// オフでも端末と iCloud のデータは残り、オンに戻すと端末の行がそのまま上がる（行の ID で二重にしない）。
  var syncsWithICloud: Bool {
    didSet {
      defaults.set(syncsWithICloud, forKey: Self.syncKey)
      // オフにしたら「前に同期できた」の印も消す（D159）。
      if !syncsWithICloud { RecordStore.setSyncedBefore(false, defaults) }
    }
  }
  nonisolated static let syncKey = "syncsWithICloud"
  /// この起動で同期が動いている。
  var isSyncRunning: Bool { records.syncing }
  /// さいごに iCloud に ほぞんした じかん（D63）。
  private(set) var lastExported: Date?
  /// さいごに iCloud から とりこんだ じかん。
  private(set) var lastImported: Date?
  /// 同期の問題（保護者用の画面にだけ出す。D117）。
  private(set) var syncProblem: RecordStore.SyncProblem?

  /// iCloud のアカウントの状態（保護者用の画面だけに出す）。
  enum AccountState: Equatable {
    case checking
    case available
    case noAccount
    case restricted
    case temporarilyUnavailable
    /// 確かめられない（署名なしのビルドなど）。
    case unknown
  }
  private(set) var accountState: AccountState = .checking
  private var accountObserver: (any NSObjectProtocol)?

  /// アカウントの状態を確かめる。サインインや切り替えのたびにもう一度確かめる。
  func refreshAccountState() async {
    guard !RecordStore.isLocalOnlyRun, RecordStore.hasCloudEntitlement else {
      accountState = .unknown
      return
    }
    if accountObserver == nil {
      accountObserver = NotificationCenter.default.addObserver(
        forName: .CKAccountChanged, object: nil, queue: .main
      ) { [weak self] _ in
        MainActor.assumeIsolated { Task { await self?.refreshAccountState() } }
      }
    }
    do {
      let status = try await CKContainer(identifier: RecordStore.cloudContainerID).accountStatus()
      switch status {
      case .available: accountState = .available
      case .noAccount: accountState = .noAccount
      case .restricted: accountState = .restricted
      case .temporarilyUnavailable: accountState = .temporarilyUnavailable
      default: accountState = .unknown
      }
    } catch {
      accountState = .unknown
    }
  }

  private func handle(_ event: RecordStore.SyncEvent) {
    switch event {
    case .exported(let date):
      lastExported = date
      syncProblem = nil
    case .imported(let date):
      lastImported = date
      syncProblem = nil
      firstImportWait.importFinished()
      finishFirstImportWaitIfNeeded()
    case .failed(let problem):
      syncProblem = problem
      firstImportWait.importFailed()
      finishFirstImportWaitIfNeeded()
    case .remoteChange: reloadFromStore()
    case .zoneDeleted: handleRemoteZoneDeleted()
    }
  }

  // MARK: - 最初の取り込み待ち（D63）

  /// 2台目の最初の起動で、iCloud からの最初の取り込みを待っている（最大10秒）。
  /// 待っているあいだは、ホームではなく「じゅんびちゅう」の画面を出す。
  private(set) var firstImportWait: FirstImportWait
  /// 待っているあいだ、保存せずに持っておく最初の子。取り込みで子が届かなければ保存する。
  private var pendingFirstProfile: Profile?
  var isWaitingForFirstImport: Bool { firstImportWait.isWaiting }

  /// 待ちが終わっていたら、画面の中身を決める。取り込みで届いた子がいれば、その子を使う。
  private func finishFirstImportWaitIfNeeded() {
    guard !firstImportWait.isWaiting, let pending = pendingFirstProfile else { return }
    pendingFirstProfile = nil
    defaults.set(true, forKey: Self.firstLaunchDoneKey)
    if records.loadProfiles().isEmpty {
      records.save(pending)
      lastSaved = records.lastSaved
    } else {
      reloadFromStore()
    }
  }

  /// 待ちの時間を進める。期限になったら待つのをやめる。
  func tickFirstImportWait(now: Date = Date()) {
    firstImportWait.tick(now: now)
    finishFirstImportWaitIfNeeded()
  }

  /// 待つ残りの時間（画面の待ち時間の計算に使う）。
  func firstImportWaitRemaining(now: Date = Date()) -> TimeInterval {
    firstImportWait.remaining(now: now)
  }

  nonisolated static let firstLaunchDoneKey = "firstLaunchDone"

  // MARK: - はじめての流れ（D23）

  nonisolated static let adultOnboardingDoneKey = "onboardingAdultDone"
  nonisolated static let mainCharacterKey = "mainCharacter"

  /// 前半（おとなの設定）を終えた、または飛ばした。
  private(set) var adultOnboardingDone = false
  /// 後半を「←」で抜けた子（この起動のあいだだけ。次の起動ではまた出る）。
  private var childOnboardingLeft: Set<UUID> = []
  /// 子が選んだ主人公（D8・D39。あとで変えられる）。
  var mainCharacter: MainCharacter {
    didSet { defaults.set(mainCharacter.rawValue, forKey: Self.mainCharacterKey) }
  }

  /// いまの子が1字でも1語でも練習したことがある（「記録だけリセット」のあとは、まだ）。
  var currentHasPractice: Bool {
    !log.currentCharacters.isEmpty || !log.currentWords.isEmpty
  }

  /// はじめての流れのどこから始めるか。出さないときは nil（D23・D63）。
  /// 後半を終えたかどうかは、練習の記録があるかで決まる（最初の1字を書けば記録が残る）。
  var onboardingStage: OnboardingStage? {
    guard let profile = currentProfile else { return nil }
    #if DEBUG
      // 確かめ用: `-skipOnboarding YES` で出さない（`-screen`・`-openParent`・`-mapChar` のときも出さない）。
      if defaults.bool(forKey: "skipOnboarding")
        || ["screen", "openParent", "mapChar"].contains(where: { defaults.string(forKey: $0) != nil })
      {
        return nil
      }
    #endif
    return Onboarding.stage(
      for: Onboarding.Situation(
        adultDone: adultOnboardingDone,
        waitingForFirstImport: isWaitingForFirstImport,
        profileCount: profiles.profiles.count,
        currentHasName: !profile.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
        currentHasPractice: currentHasPractice,
        currentChildDone: childOnboardingLeft.contains(profile.id)))
  }

  func finishAdultOnboarding() {
    adultOnboardingDone = true
    defaults.set(true, forKey: Self.adultOnboardingDoneKey)
  }

  /// 後半を「←」で抜ける。この起動のあいだは、この子には出さない。
  func leaveChildOnboarding() {
    childOnboardingLeft.insert(currentProfileID)
  }

  // MARK: - iCloud のデータを消す（D85）

  enum CloudDeleteState: Equatable {
    case idle
    case deleting
    case done
    case failed
  }
  private(set) var cloudDeleteState: CloudDeleteState = .idle
  /// ほかの iPad が iCloud のデータを消したと知った日時（保護者用の画面にだけ知らせる）。
  private(set) var cloudDeletedNotice: Date?
  nonisolated static let cloudDeletedNoticeKey = "cloudDeletedNotice"

  /// 「iCloud のデータを消す」。先にこの iPad の同期をオフにし、iCloud の置き場所を消す。
  /// この iPad の中のデータは残す。署名なしのビルドなどでは何もしない。
  func deleteICloudData() async {
    guard RecordStore.hasCloudEntitlement, !RecordStore.isLocalOnlyRun,
      accountState == .available, cloudDeleteState != .deleting
    else { return }
    cloudDeleteState = .deleting
    // 先にオフ（次の起動でも上げ直さないよう、保存する）。動いている同期も止める。
    syncsWithICloud = false
    records.stopSync()
    do {
      cloudDeleteState = try await RecordStore.deleteCloudZone() ? .done : .idle
    } catch {
      cloudDeleteState = .failed
    }
  }

  /// ほかの iPad が iCloud のデータを消していた。同期をオフにし、上げ直さず、保護者に知らせる（D159）。
  /// 標準のしくみは、置き場所が消えているのに気づくと作り直して上げ直すことがある。
  /// そのため同期を止めたあと、もう一度置き場所を消して、ほかの iPad の「消す」を勝たせる。
  /// 同期をオフにした保存先は端末の中だけなので、これ以上この出来事は来ず、くり返さない。
  private func handleRemoteZoneDeleted() {
    // 自分で消した直後に届いた出来事や、2度目の出来事は無視する。
    guard syncsWithICloud else { return }
    syncsWithICloud = false
    records.stopSync()
    Task { _ = try? await RecordStore.deleteCloudZone() }
    let now = Date()
    cloudDeletedNotice = now
    defaults.set(now, forKey: Self.cloudDeletedNoticeKey)
  }

  func dismissCloudDeletedNotice() {
    cloudDeletedNotice = nil
    defaults.removeObject(forKey: Self.cloudDeletedNoticeKey)
  }

  /// ほかの iPad の変更を画面に反映する。
  private func reloadFromStore() {
    wishes = records.loadWishes()
    let loaded = records.loadProfiles()
    guard !loaded.isEmpty else { return }
    let list = ProfileList(profiles: loaded)
    profiles = list
    if list.profile(currentProfileID) == nil, let first = list.profiles.first {
      currentProfileID = first.id
    }
    log = records.loadLog(profile: currentProfileID)
    placed = records.loadPlaced(profile: currentProfileID)
    moves = records.loadMoves(profile: currentProfileID)
    stickerEvents = records.loadStickerEvents(profile: currentProfileID)
  }

  private let defaults: UserDefaults

  init(records: RecordStore = ProgressStore.makeRecordStore(), defaults: UserDefaults = .standard) {
    self.records = records
    self.defaults = defaults
    syncsWithICloud = defaults.object(forKey: Self.syncKey) as? Bool ?? true
    var list = ProfileList(profiles: records.loadProfiles())
    // 同期が動いていて、最初の起動で、端末に子がいなければ、最初の取り込みを待つ（D63）。
    var needsWait =
      records.syncing && list.profiles.isEmpty
      && !defaults.bool(forKey: Self.firstLaunchDoneKey)
    #if DEBUG
      // 確かめ用: `-forceFirstImportWait YES` で、同期なしでも待ちの画面を10秒出す。
      if defaults.bool(forKey: "forceFirstImportWait") { needsWait = true }
    #endif
    firstImportWait = FirstImportWait(needed: needsWait, now: Date())
    if list.profiles.isEmpty {
      // はじめての起動では、名前のない子を1人作っておく（呼び名はあとで保護者が決める）。
      // 待っているあいだは保存しない（2台目で、1台目の子と二重にならないように）。
      let first = Profile(name: "", face: Self.faces[0])
      if needsWait {
        pendingFirstProfile = first
      } else {
        records.save(first)
      }
      list.add(first)
    }
    if !needsWait { defaults.set(true, forKey: Self.firstLaunchDoneKey) }
    cloudDeletedNotice = defaults.object(forKey: Self.cloudDeletedNoticeKey) as? Date
    #if DEBUG
      // 確かめ用: `-resetOnboarding YES` で、はじめての流れをもう一度出す。
      if defaults.bool(forKey: "resetOnboarding") {
        defaults.removeObject(forKey: Self.adultOnboardingDoneKey)
      }
    #endif
    adultOnboardingDone = defaults.bool(forKey: Self.adultOnboardingDoneKey)
    mainCharacter =
      defaults.string(forKey: Self.mainCharacterKey).flatMap(MainCharacter.init(rawValue:)) ?? .ton
    #if DEBUG
      // 確かめ用の起動の引数 `-penColor red` で、色を決めておく。
      if let key = defaults.string(forKey: "penColor"), let color = PenColor(rawValue: key),
        var first = list.profiles.first
      {
        first.penColor = color
        list.update(first)
      }
    #endif
    profiles = list
    let preferred = defaults.string(forKey: "currentProfile").flatMap(UUID.init(uuidString:))
    let current = list.current(preferred: preferred)?.id ?? list.profiles[0].id
    currentProfileID = current
    log = records.loadLog(profile: current)
    placed = records.loadPlaced(profile: current)
    moves = records.loadMoves(profile: current)
    stickerEvents = records.loadStickerEvents(profile: current)
    wishes = records.loadWishes()
    confirmsProfileSwitch = defaults.bool(forKey: "confirmsProfileSwitch")
    voiceVolume = defaults.object(forKey: "voiceVolume") as? Double ?? 0.8
    bgmVolume = defaults.object(forKey: "bgmVolume") as? Double ?? 0.5
    effectVolume = defaults.object(forKey: "effectVolume") as? Double ?? 0.7
    quietMode = defaults.bool(forKey: "quietMode")
    showsSubtitles = defaults.object(forKey: "showsSubtitles") as? Bool ?? true
    modelSpeed =
      defaults.string(forKey: "modelSpeed").flatMap(ModelSpeed.init(rawValue:)) ?? .normal
    largeGrid = defaults.bool(forKey: "largeGrid")
    usesPressure = defaults.object(forKey: "usesPressure") as? Bool ?? true
    preset = defaults.string(forKey: "preset").flatMap(JudgePreset.init(rawValue:)) ?? .hajimete
    showsEndingHints = defaults.object(forKey: "showsEndingHints") as? Bool ?? true
    requiresDeviceAuth = defaults.bool(forKey: "requiresDeviceAuth")
    records.onSyncEvent = { [weak self] in self?.handle($0) }
  }

  /// 確かめ用の起動の引数 `-inMemoryStore YES` で、保存しないで動かす。
  static func makeRecordStore() -> RecordStore {
    #if DEBUG
      if UserDefaults.standard.bool(forKey: "inMemoryStore") { return RecordStore(url: nil) }
    #endif
    let sync = UserDefaults.standard.object(forKey: syncKey) as? Bool ?? true
    return RecordStore(cloudSync: sync, defaults: .standard)
  }

  /// 鍵のかかったもので「おねがい」を押した（D160）。記録するだけで、購入は開かない。
  func makeWish(item: String, date: Date = Date()) {
    let wish = Wish(profileID: currentProfileID, item: item, date: date)
    wishes.append(wish)
    records.append(wish)
    lastSaved = records.lastSaved
  }

  /// 保護者用の画面に出す おねがい（買ったものは除く。最新の日だけ。D54・D160）。
  func wishNotices(isOwned: (String) -> Bool) -> [WishNotice] {
    WishNotice.notices(
      from: wishes.filter { wish in profiles.profile(wish.profileID) != nil }, isOwned: isOwned)
  }

  /// 保護者が「確認した」を押した。そのお知らせを消す（D160）。
  func dismissWishes(profile: UUID, item: String) {
    wishes.removeAll { $0.profileID == profile && $0.item == item }
    records.deleteWishes(profile: profile, item: item)
    lastSaved = records.lastSaved
  }

  func record(_ record: CharacterRecord) {
    log.append(record)
    records.append(log.characters.last ?? record, profile: currentProfileID)
    lastSaved = records.lastSaved
  }

  func record(_ record: WordRecord) {
    log.append(record)
    records.append(log.words.last ?? record, profile: currentProfileID)
    lastSaved = records.lastSaved
  }

  func place(_ object: PlacedObject) {
    placed.append(object)
    records.append(object, profile: currentProfileID)
    lastSaved = records.lastSaved
  }

  /// おもちゃばこの物を出す（D74・D82）。出してからいちばん長い物と入れ替わる。行を足すだけ。
  func takeOut(_ id: UUID, date: Date = Date()) {
    let rows = board.takeOut(id, moves: moves, date: date)
    for row in rows {
      moves.append(row)
      records.append(row, profile: currentProfileID)
    }
    if !rows.isEmpty { lastSaved = records.lastSaved }
  }

  // MARK: - おたのしみ ボックスとステッカー（§3.3・§3.5・D54・D190）

  /// おたのしみ ボックスの、きょうの状態。目標に届いた日に、1回だけ あけられる。
  func treatBoxState(now: Date = Date(), calendar: Calendar = .current) -> TreatBoxState {
    StickerBook.boxState(
      practiced: log.today(now: now, calendar: calendar).characters,
      goal: currentProfile?.dailyGoal ?? 5, events: stickerEvents, now: now, calendar: calendar)
  }

  /// おたのしみ ボックスを あける。出たステッカーを返す。あけられないときは nil（何も足さない）。
  @discardableResult
  func openTreatBox(now: Date = Date(), calendar: Calendar = .current) -> OwnedSticker? {
    guard treatBoxState(now: now, calendar: calendar) == .ready,
      let name = TreatBox.nextSticker(
        owned: Set(stickers.map(\.sticker)), day: TodayWord.day(now: now, calendar: calendar),
        childID: currentProfileID.uuidString)
    else { return nil }
    let event = StickerEvent(date: now, action: .earned, sticker: name)
    append(event)
    return OwnedSticker(id: event.id, sticker: name, date: now)
  }

  /// ステッカーを貼る（場所を変えるときも同じ）。行を足すだけ。
  func placeSticker(
    _ id: UUID, on surface: StickerEvent.Surface, x: Double, y: Double, date: Date = Date()
  ) {
    guard stickers.contains(where: { $0.id == id }) else { return }
    append(
      StickerEvent(
        date: laterThanStickerRows(date), action: .placed, itemID: id, surface: surface, x: x, y: y))
  }

  /// ステッカーを はがす（入れ物に もどる）。行を足すだけ。
  func removeSticker(_ id: UUID, date: Date = Date()) {
    guard stickers.contains(where: { $0.id == id && $0.placement != nil }) else { return }
    append(StickerEvent(date: laterThanStickerRows(date), action: .removed, itemID: id))
  }

  /// iPad の時計がずれていても、いちばん新しい行になるようにする。
  private func laterThanStickerRows(_ date: Date) -> Date {
    guard let latest = stickerEvents.map(\.date).max() else { return date }
    return max(date, latest.addingTimeInterval(0.001))
  }

  private func append(_ event: StickerEvent) {
    stickerEvents.append(event)
    records.append(event, profile: currentProfileID)
    lastSaved = records.lastSaved
  }

  #if DEBUG
    /// 確かめ用: ステッカーを `count` 枚、おととい手に入れたことにする（`-seedStickers N`）。
    /// `placed` なら、はじめの何枚かを まちと ずかんの表紙に貼っておく。
    func debugSeedStickers(count: Int, placed: Bool = false) {
      guard stickerEvents.isEmpty else { return }
      let start = Date().addingTimeInterval(-86_400 * 2)
      let town: [(Double, Double)] = [(0.25, 0.86), (0.62, 0.70), (1.05, 0.88), (0.42, 0.50)]
      let cover: [(Double, Double)] = [(0.11, 0.27), (0.87, 0.24), (0.12, 0.74)]
      for (index, name) in TreatBox.stickers.prefix(count).enumerated() {
        let earned = StickerEvent(
          date: start.addingTimeInterval(Double(index)), action: .earned, sticker: name)
        append(earned)
        guard placed else { continue }
        if index < town.count {
          placeSticker(earned.id, on: .town, x: town[index].0, y: town[index].1)
        } else if index < town.count + cover.count {
          let spot = cover[index - town.count]
          placeSticker(earned.id, on: .zukan, x: spot.0, y: spot.1)
        }
      }
    }
  #endif

  /// 「記録だけリセット」（D19・§6.3）。その子の記録だけ。まちの物と設定は残す。
  func resetRecords(of id: UUID? = nil) {
    let id = id ?? currentProfileID
    records.appendReset(profile: id)
    if id == currentProfileID { log.reset() }
    lastSaved = records.lastSaved
  }

  /// 全員の記録のリセット（§5.3）。
  func resetAllRecords() {
    for profile in profiles.profiles { resetRecords(of: profile.id) }
  }

  // MARK: - 子どもたち

  /// 使う子を切り替え、その子の記録とまちを読む。
  func switchProfile(to id: UUID) {
    guard profiles.profile(id) != nil else { return }
    currentProfileID = id
    defaults.set(id.uuidString, forKey: "currentProfile")
    log = records.loadLog(profile: id)
    placed = records.loadPlaced(profile: id)
    moves = records.loadMoves(profile: id)
    stickerEvents = records.loadStickerEvents(profile: id)
  }

  @discardableResult
  func addProfile(_ profile: Profile) -> Bool {
    guard profiles.add(profile) else { return false }
    records.save(profile)
    lastSaved = records.lastSaved
    return true
  }

  func updateProfile(_ profile: Profile) {
    profiles.update(profile)
    records.save(profile)
    lastSaved = records.lastSaved
  }

  /// プロフィールと、その子の記録を消す（最後の1人は消さない）。
  func deleteProfile(_ id: UUID) {
    guard profiles.remove(id) else { return }
    records.deleteProfile(id)
    wishes.removeAll { $0.profileID == id }
    if id == currentProfileID, let first = profiles.profiles.first { switchProfile(to: first.id) }
    lastSaved = records.lastSaved
  }

  /// 保存している行の数。
  var savedRowCount: Int { records.rowCount() }
}

/// まちに置いた物（試作）。
struct PlacedObject: Identifiable, Hashable {
  var id = UUID()
  /// 手に入れた時間（おもちゃばこの計算に使う。D82）。
  var date = Date()
  var word: String
  var symbol: String
  /// ことばの種類（置き方と動きを決める。D53）。
  var kind: WordKind = .vehicle
}
