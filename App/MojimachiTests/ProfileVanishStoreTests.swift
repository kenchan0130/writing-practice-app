import CoreData
import Foundation
import RecordKit
import Testing

@testable import Mojimachi

/// 使っているあいだにシステムが子の行を消したときの安全（D197）。
@Suite("子の行が消えたとき", .serialized)
@MainActor
struct ProfileVanishStoreTests {
  private func makeStore() -> (ProgressStore, RecordStore) {
    let defaults = UserDefaults(suiteName: "ProfileVanishStoreTests-\(UUID().uuidString)")!
    let records = RecordStore(url: nil, defaults: defaults)
    return (ProgressStore(records: records, defaults: defaults), records)
  }

  /// 名前のある子を1人保存した状態にする。
  private func makeNamedStore() throws -> (ProgressStore, RecordStore, Profile) {
    let (store, records) = makeStore()
    var profile = try #require(store.currentProfile)
    profile.name = "ゆうと"
    store.updateProfile(profile)
    store.record(
      CharacterRecord(date: Date(), characterID: "hira.3042", stage: .nazoru, passed: true))
    return (store, records, profile)
  }

  @Test("行が消えたあとのペンの色の変更で、前の子をよみがえらせない")
  func updateDoesNotResurrect() throws {
    let (store, records, old) = try makeNamedStore()
    records.deleteProfile(old.id)
    store.setPenColor(.red)
    #expect(records.loadProfiles().isEmpty)
    #expect(store.currentProfileID != old.id)
    #expect(store.currentProfile?.name == "")
    #expect(store.currentProfile?.penColor == nil)
    #expect(store.placeholderID == store.currentProfileID)
    #expect(store.accountNotice == .dataMissing)
  }

  @Test("行が消えたあとの記録は、書かない")
  func recordsAreDropped() throws {
    let (store, records, old) = try makeNamedStore()
    records.deleteProfile(old.id)
    store.record(
      CharacterRecord(date: Date(), characterID: "hira.3044", stage: .nazoru, passed: true))
    #expect(records.rowCount() == 0)
    #expect(store.log.characters.isEmpty)
    // 新しい子は、そのあと書けば保存される。
    store.record(
      CharacterRecord(date: Date(), characterID: "hira.3046", stage: .nazoru, passed: true))
    #expect(records.loadProfiles().map(\.id) == [store.currentProfileID])
    #expect(records.loadLog(profile: old.id).characters.isEmpty)
    #expect(records.loadLog(profile: store.currentProfileID).characters.count == 1)
  }

  @Test("読み直しで0人になったら、名前のない新しい子にする")
  func reloadWithNoProfiles() throws {
    let (store, records, old) = try makeNamedStore()
    records.deleteProfile(old.id)
    store.reloadFromStore()
    #expect(store.currentProfileID != old.id)
    #expect(store.currentProfile?.name == "")
    #expect(store.profiles.profiles.count == 1)
    #expect(store.log.characters.isEmpty)
    #expect(store.accountNotice == .dataMissing)
    #expect(records.loadProfiles().isEmpty)
  }

  @Test("最初の子のままなら、0人でも消えたとは言わない")
  func placeholderIsKept() {
    let (store, _) = makeStore()
    let id = store.currentProfileID
    store.reloadFromStore()
    store.checkProfileVanished()
    #expect(store.currentProfileID == id)
    #expect(store.accountNotice == nil)
  }

  @Test("書く画面にいるあいだは切り替えを待ち、出たら切り替える")
  func deferredWhileWriting() throws {
    let (store, records, old) = try makeNamedStore()
    store.setWritingActive(true)
    records.deleteProfile(old.id)
    // 最初に消えたと分かった1回目の操作も、画面の中では効く。
    store.setPenColor(.red)
    #expect(store.vanishPending)
    #expect(store.penColor == .red)
    store.record(
      CharacterRecord(date: Date(), characterID: "hira.3044", stage: .nazoru, passed: true))
    #expect(store.log.characters.count == 2)
    #expect(store.currentProfileID == old.id)
    #expect(records.rowCount() == 0)
    store.setWritingActive(false)
    #expect(!store.vanishPending)
    #expect(store.currentProfileID != old.id)
    #expect(store.currentProfile?.name == "")
    #expect(records.rowCount() == 0)
  }

  @Test("確かめると、消えた子を見つけて切り替える")
  func checkFindsVanished() throws {
    let (store, records, old) = try makeNamedStore()
    store.checkProfileVanished()
    #expect(store.currentProfileID == old.id)
    records.deleteProfile(old.id)
    store.checkProfileVanished()
    #expect(store.currentProfileID != old.id)
  }

  @Test("ほかの子が残っていれば、その子に切り替える")
  func otherProfileRemains() throws {
    let (store, records, old) = try makeNamedStore()
    let other = Profile(name: "みお", face: "cat.fill")
    #expect(store.addProfile(other))
    records.deleteProfile(old.id)
    store.checkProfileVanished()
    #expect(store.currentProfileID == other.id)
    #expect(store.currentProfile?.name == "みお")
  }

  /// 別の背景のコンテキストで、子の行だけを消す（システムが消すのに近い形。記録の行は残る）。
  private func deleteProfileRowInBackground(_ records: RecordStore, id: UUID) throws {
    let context = records.container.newBackgroundContext()
    try context.performAndWait {
      let request = NSFetchRequest<NSManagedObject>(entityName: "ProfileRow")
      request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
      for row in try context.fetch(request) { context.delete(row) }
      try context.save()
    }
  }

  @Test("別のコンテキストで子の行だけが消えても、書かずに切り替える")
  func backgroundDeletion() throws {
    let (store, records, old) = try makeNamedStore()
    try deleteProfileRowInBackground(records, id: old.id)
    #expect(records.loadProfiles().isEmpty)
    #expect(records.loadLog(profile: old.id).characters.count == 1)
    store.setPenColor(.red)
    #expect(records.loadProfiles().isEmpty)
    #expect(store.currentProfileID != old.id)
    store.record(
      CharacterRecord(date: Date(), characterID: "hira.3044", stage: .nazoru, passed: true))
    // 消えた子の記録は増えていない。
    #expect(records.loadLog(profile: old.id).characters.count == 1)
    #expect(records.loadProfiles().allSatisfy { $0.id != old.id })
  }

  @Test("おねがい・ステッカー・おもちゃばこ・リセットも、行が消えたら書かない")
  func otherWritesAreGated() throws {
    let (store, records, old) = try makeNamedStore()
    store.place(PlacedObject(word: "くるま", symbol: "car"))
    let object = try #require(store.placed.first)
    try deleteProfileRowInBackground(records, id: old.id)
    let before = records.rowCount()
    store.takeOut(object.id)
    #expect(records.loadMoves(profile: old.id).isEmpty)
    #expect(records.rowCount() <= before)

    let (store2, records2, old2) = try makeNamedStore()
    records2.deleteProfile(old2.id)
    store2.makeWish(item: "あ")
    #expect(records2.rowCount() == 0)
    #expect(store2.wishes.isEmpty)

    let (store3, records3, old3) = try makeNamedStore()
    records3.deleteProfile(old3.id)
    store3.debugSeedStickers(count: 1)
    #expect(records3.rowCount() == 0)
    #expect(store3.stickerEvents.isEmpty)

    let (store4, records4, old4) = try makeNamedStore()
    records4.deleteProfile(old4.id)
    store4.resetRecords()
    #expect(records4.rowCount() == 0)
    #expect(store4.currentProfileID != old4.id)
  }

  @Test("待っているあいだに行が戻ったら、切り替えない")
  func rowComesBack() throws {
    let (store, records, old) = try makeNamedStore()
    store.setWritingActive(true)
    records.deleteProfile(old.id)
    store.setPenColor(.red)
    #expect(store.vanishPending)
    records.insert(try #require(store.currentProfile))
    store.reloadFromStore()
    #expect(!store.vanishPending)
    store.setWritingActive(false)
    #expect(store.currentProfileID == old.id)
    #expect(store.currentProfile?.name == "ゆうと")
  }

  @Test("保存先が読めないあいだは、消えたと決めない")
  func unreadableIsNotVanished() throws {
    let (store, records, old) = try makeNamedStore()
    let coordinator = records.container.persistentStoreCoordinator
    for persistent in coordinator.persistentStores { try coordinator.remove(persistent) }
    #expect(!records.canRead)
    store.checkProfileVanished()
    store.reloadFromStore()
    store.setPenColor(.red)
    #expect(store.currentProfileID == old.id)
    #expect(!store.vanishPending)
    #expect(store.penColor == .red)
    #expect(store.accountNotice == nil)
  }

  @Test("ほかの子が残っていて、いまの子だけ消えたら、保護者には知らせず、書く画面を出てから切り替える")
  func currentGoneWithOthers() throws {
    let (store, records, old) = try makeNamedStore()
    let other = Profile(name: "みお", face: "cat.fill")
    #expect(store.addProfile(other))
    store.setWritingActive(true)
    records.deleteProfile(old.id)
    store.reloadFromStore()
    #expect(store.currentProfileID == old.id)
    #expect(store.vanishPending)
    #expect(store.accountNotice == nil)
    store.setWritingActive(false)
    #expect(store.currentProfileID == other.id)
  }
}
