import Foundation
import PracticeKit
import RecordKit
import Testing

@testable import Mojimachi

/// おたのしみ ボックスとステッカーの保存（§3.3・§3.5・D54・D190）。
@Suite("ステッカーの保存", .serialized)
@MainActor
struct StickerStoreTests {
  private func makeStore() -> ProgressStore {
    let defaults = UserDefaults(suiteName: "StickerStoreTests-\(UUID().uuidString)")!
    return ProgressStore(records: RecordStore(url: nil, defaults: defaults), defaults: defaults)
  }

  /// きょうの字を `count` 字、書いたことにする。
  private func practice(_ store: ProgressStore, count: Int, now: Date) {
    for index in 0..<count {
      store.record(
        CharacterRecord(date: now, characterID: "hira.\(index)", stage: .nazoru, passed: true))
    }
  }

  @Test("目標に届くと あけられる。あけると ステッカーが1枚増え、その日は もう あけられない")
  func opensOncePerGoalDay() throws {
    let store = makeStore()
    let now = Date()
    let goal = store.currentProfile?.dailyGoal ?? 5
    #expect(store.treatBoxState(now: now) == .notYet)
    #expect(store.openTreatBox(now: now) == nil)
    practice(store, count: goal - 1, now: now)
    #expect(store.treatBoxState(now: now) == .notYet)
    practice(store, count: goal, now: now)
    #expect(store.treatBoxState(now: now) == .ready)
    let sticker = try #require(store.openTreatBox(now: now))
    #expect(TreatBox.stickers.contains(sticker.sticker))
    #expect(store.stickers.map(\.id) == [sticker.id])
    #expect(store.treatBoxState(now: now) == .opened)
    #expect(store.openTreatBox(now: now) == nil)
    #expect(store.stickers.count == 1)
  }

  @Test("次の日に目標に届けば、また あけられる。まだ持っていないステッカーが出る")
  func nextDayGivesANewSticker() throws {
    let store = makeStore()
    let today = Date()
    let goal = store.currentProfile?.dailyGoal ?? 5
    practice(store, count: goal, now: today)
    let first = try #require(store.openTreatBox(now: today))
    let tomorrow = today.addingTimeInterval(86_400)
    #expect(store.treatBoxState(now: tomorrow) == .notYet)
    practice(store, count: goal, now: tomorrow)
    let second = try #require(store.openTreatBox(now: tomorrow))
    #expect(second.sticker != first.sticker)
    #expect(store.stickers.count == 2)
  }

  @Test("貼る・場所を変える・はがす。持っていないステッカーは貼れない")
  func placeMoveRemove() throws {
    let store = makeStore()
    let now = Date()
    practice(store, count: 10, now: now)
    let sticker = try #require(store.openTreatBox(now: now))
    store.placeSticker(UUID(), on: .town, x: 1, y: 1)
    #expect(store.stickerEvents.count == 1)
    store.placeSticker(sticker.id, on: .town, x: 1.5, y: 0.7)
    #expect(store.stickers[0].placement == StickerPlacement(surface: .town, x: 1.5, y: 0.7))
    // 同じ時刻に続けて動かしても、あとの行が勝つ。
    store.placeSticker(sticker.id, on: .zukan, x: 0.2, y: 0.3, date: now.addingTimeInterval(-99))
    #expect(store.stickers[0].placement == StickerPlacement(surface: .zukan, x: 0.2, y: 0.3))
    store.removeSticker(sticker.id, date: now.addingTimeInterval(-99))
    #expect(store.stickers[0].placement == nil)
    // 貼っていないステッカーを はがしても、行は増えない。
    let rows = store.stickerEvents.count
    store.removeSticker(sticker.id)
    #expect(store.stickerEvents.count == rows)
  }

  @Test("ステッカーは子どもごと。記録だけリセットしても残り、プロフィールを消すと消える")
  func perProfile() throws {
    let store = makeStore()
    let now = Date()
    let first = store.currentProfileID
    practice(store, count: 10, now: now)
    let sticker = try #require(store.openTreatBox(now: now))
    store.placeSticker(sticker.id, on: .town, x: 0.5, y: 0.5)
    store.resetRecords()
    #expect(store.stickers.count == 1)
    #expect(store.treatBoxState(now: now) == .opened)
    let other = Profile(name: "はな", honorific: .chan, face: ProgressStore.faces[1])
    #expect(store.addProfile(other))
    store.switchProfile(to: other.id)
    #expect(store.stickers.isEmpty)
    #expect(store.treatBoxState(now: now) == .notYet)
    store.switchProfile(to: first)
    #expect(store.stickers.first?.placement?.surface == .town)
    let before = store.savedRowCount
    store.deleteProfile(first)
    #expect(store.stickers.isEmpty)
    #expect(store.savedRowCount < before)
  }
}
