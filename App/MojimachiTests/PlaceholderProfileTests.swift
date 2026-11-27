import Foundation
import RecordKit
import Testing

@testable import Mojimachi

/// 最初の子を何かするまで保存しない、保存の安全（D194）。
@Suite("最初の子と保存の安全", .serialized)
@MainActor
struct PlaceholderProfileTests {
  private func makeDefaults() -> UserDefaults {
    UserDefaults(suiteName: "PlaceholderProfileTests-\(UUID().uuidString)")!
  }

  private func makeStore(
    defaults: UserDefaults? = nil, records: RecordStore? = nil
  ) -> (ProgressStore, RecordStore) {
    let defaults = defaults ?? makeDefaults()
    let records = records ?? RecordStore(url: nil, defaults: defaults)
    return (ProgressStore(records: records, defaults: defaults), records)
  }

  @Test("起動しただけでは、最初の子を保存しない")
  func notSavedUntilTouched() {
    let (store, records) = makeStore()
    #expect(store.placeholderID == store.currentProfileID)
    #expect(records.loadProfiles().isEmpty)
  }

  @Test("字を書くと、最初の子を保存する")
  func savedWhenPracticing() {
    let (store, records) = makeStore()
    let id = store.currentProfileID
    store.record(
      CharacterRecord(date: Date(), characterID: "hira.3042", stage: .nazoru, passed: true))
    #expect(store.placeholderID == nil)
    #expect(records.loadProfiles().map(\.id) == [id])
  }

  @Test("呼び名を決めると、最初の子を保存する")
  func savedWhenEditing() throws {
    let (store, records) = makeStore()
    var profile = try #require(store.currentProfile)
    profile.name = "ゆうと"
    store.updateProfile(profile)
    #expect(store.placeholderID == nil)
    #expect(records.loadProfiles().first?.name == "ゆうと")
  }

  @Test("本物の子が届いたら、何もしていない最初の子は捨てて入れ替える")
  func replacedByRemoteProfile() {
    let (store, records) = makeStore()
    let placeholder = store.currentProfileID
    let real = Profile(name: "はると", face: "cat.fill")
    records.save(real)  // iCloud から届いた
    store.reloadFromStore()
    #expect(store.currentProfileID == real.id)
    #expect(store.profiles.profiles.map(\.id) == [real.id])
    #expect(store.placeholderID == nil)
    #expect(store.profiles.profile(placeholder) == nil)
  }

  @Test("すでに何かした最初の子は、届いた子と並べて残す")
  func touchedProfileIsKept() throws {
    let (store, records) = makeStore()
    var mine = try #require(store.currentProfile)
    mine.name = "みお"
    store.updateProfile(mine)
    let real = Profile(name: "はると", face: "cat.fill")
    records.save(real)
    store.reloadFromStore()
    #expect(store.currentProfileID == mine.id)
    #expect(Set(store.profiles.profiles.map(\.id)) == [mine.id, real.id])
  }

  @Test("何も届いていなければ、読み直しても最初の子のまま")
  func emptyReloadKeepsPlaceholder() {
    let (store, _) = makeStore()
    let id = store.currentProfileID
    store.reloadFromStore()
    #expect(store.currentProfileID == id)
    #expect(store.placeholderID == id)
  }

  @Test("前は子がいたのに0人なら、保護者に知らせる")
  func dataMissingNotice() {
    let defaults = makeDefaults()
    defaults.set(true, forKey: ProgressStore.hadProfilesKey)
    let (store, _) = makeStore(defaults: defaults)
    #expect(store.accountNotice == .dataMissing)
    store.dismissAccountNotice()
    #expect(store.accountNotice == nil)
  }

  @Test("はじめての起動では、知らせない")
  func noNoticeOnFirstLaunch() {
    let (store, _) = makeStore()
    #expect(store.accountNotice == nil)
  }

  @Test("一覧には線を入れず、あとから1件ずつ読める")
  func strokesAreLoadedLazily() throws {
    let defaults = makeDefaults()
    let records = RecordStore(url: nil, defaults: defaults)
    let profile = UUID()
    let strokes: [[[Double]]] = [[[0, 0], [100, 100]], [[50, 0], [50, 200]]]
    let record = CharacterRecord(
      date: Date(), characterID: "hira.3042", stage: .jibunde, passed: true, strokes: strokes)
    records.append(record, profile: profile)
    let log = records.loadLog(profile: profile)
    let loaded = try #require(log.characters.first)
    #expect(loaded.id == record.id)
    #expect(loaded.strokes == nil)
    #expect(loaded.hasStrokes)
    // 読み直したあとも、成長アルバムに出る。
    #expect(log.album.map(\.characterID) == ["hira.3042"])
    #expect(records.loadStrokes(recordID: record.id) == strokes)
    #expect(records.loadStrokes(recordID: UUID()) == nil)
  }

  @Test("メモリだけの保存先は、同期をいますぐつなげない")
  func memoryStoreNeverSyncs() {
    let (store, records) = makeStore()
    store.applySyncChoiceNow()
    #expect(!records.syncing)
    #expect(records.openFallback == nil)
  }

  @Test("捨てた最初の子は、保存し直さない")
  func discardedPlaceholderNotResaved() throws {
    let (store, records) = makeStore()
    var old = try #require(store.currentProfile)
    let real = Profile(name: "はると", face: "cat.fill")
    records.save(real)
    store.reloadFromStore()
    old.name = "ゆうと"
    store.updateProfile(old)
    #expect(records.loadProfiles().map(\.id) == [real.id])
  }

  @Test("はじめての流れの途中で入れ替わったら、名前のある本物を守る")
  func onboardingKeepsRealName() throws {
    let (store, records) = makeStore()
    var typed = try #require(store.currentProfile)
    typed.name = "ゆうと"
    records.save(Profile(name: "はると", face: "cat.fill"))
    store.reloadFromStore()
    store.applyOnboardingProfile(typed)
    #expect(store.currentProfile?.name == "はると")
    #expect(records.loadProfiles().count == 1)
  }

  @Test("入れ替わった本物がまだ名前を持たなければ、決めた呼び名を入れる")
  func onboardingFillsNamelessReal() throws {
    let (store, records) = makeStore()
    var typed = try #require(store.currentProfile)
    typed.name = "ゆうと"
    let real = Profile(name: "", face: "cat.fill")
    records.save(real)
    store.reloadFromStore()
    store.applyOnboardingProfile(typed)
    #expect(store.currentProfile?.id == real.id)
    #expect(store.currentProfile?.name == "ゆうと")
    #expect(records.loadProfiles().count == 1)
  }
}
