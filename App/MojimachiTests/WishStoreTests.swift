import EntitlementKit
import Foundation
import RecordKit
import Testing

@testable import Mojimachi

/// 子どもの「おねがい」の保存（D54・D160）。
@Suite("おねがいの保存", .serialized)
@MainActor
struct WishStoreTests {
  private func makeStore() -> ProgressStore {
    let defaults = UserDefaults(suiteName: "WishStoreTests-\(UUID().uuidString)")!
    return ProgressStore(records: RecordStore(url: nil, defaults: defaults), defaults: defaults)
  }

  @Test("おねがいを押すと、いまの子・もの・日を記録する。何度押しても お知らせは1つ")
  func recordsAndCollapses() {
    let store = makeStore()
    let now = Date()
    store.makeWish(item: Script.katakana.rawValue, date: now.addingTimeInterval(-60))
    store.makeWish(item: Script.katakana.rawValue, date: now)
    #expect(store.wishes.count == 2)
    let notices = store.wishNotices(isOwned: { _ in false })
    #expect(notices.count == 1)
    #expect(notices[0].profileID == store.currentProfileID)
    #expect(notices[0].item == "katakana")
    #expect(notices[0].date == now)
  }

  @Test("買ったものは お知らせに出ない。「確認した」で消せる")
  func ownedAndDismiss() {
    let store = makeStore()
    store.makeWish(item: Script.katakana.rawValue)
    store.makeWish(item: Script.abc.rawValue)
    let owned = store.wishNotices(isOwned: { $0 == "katakana" })
    #expect(owned.map(\.item) == ["abc"])
    store.dismissWishes(profile: store.currentProfileID, item: "abc")
    #expect(store.wishNotices(isOwned: { _ in false }).map(\.item) == ["katakana"])
  }

  @Test("プロフィールを消すと、その子のおねがいも消える")
  func deletedWithProfile() {
    let store = makeStore()
    let other = Profile(name: "はな", honorific: .chan, face: ProgressStore.faces[1])
    #expect(store.addProfile(other))
    let first = store.currentProfileID
    store.makeWish(item: "katakana")
    store.switchProfile(to: other.id)
    store.makeWish(item: "abc")
    store.deleteProfile(first)
    #expect(store.wishNotices(isOwned: { _ in false }).map(\.item) == ["abc"])
    #expect(store.wishes.allSatisfy { $0.profileID == other.id })
  }
}
