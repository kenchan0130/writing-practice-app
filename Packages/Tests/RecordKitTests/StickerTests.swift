import Foundation
import Testing

@testable import RecordKit

@Suite("ステッカーの記録（§3.3・D54）")
struct StickerTests {
  let now = Date(timeIntervalSince1970: 1_800_000_000)
  var calendar: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
    return calendar
  }

  private func earned(_ sticker: String, ago: TimeInterval, id: UUID = UUID()) -> StickerEvent {
    StickerEvent(id: id, date: now.addingTimeInterval(-ago), action: .earned, sticker: sticker)
  }

  @Test("手に入れた順に並ぶ。貼っていなければ、入れ物の中")
  func ownedInOrder() {
    let events = [earned("hana", ago: 10), earned("hoshi", ago: 100)]
    let owned = StickerBook.owned(events)
    #expect(owned.map(\.sticker) == ["hoshi", "hana"])
    #expect(owned.allSatisfy { $0.placement == nil })
  }

  @Test("貼る・場所を変える・はがす は、いちばん新しい行が勝つ")
  func latestPlacementWins() {
    let star = earned("hoshi", ago: 100)
    let place = StickerEvent(
      date: now.addingTimeInterval(-50), action: .placed, itemID: star.id, surface: .town, x: 1.5,
      y: 0.7)
    let move = StickerEvent(
      date: now.addingTimeInterval(-40), action: .placed, itemID: star.id, surface: .zukan, x: 0.2,
      y: 0.3)
    let remove = StickerEvent(
      date: now.addingTimeInterval(-30), action: .removed, itemID: star.id)
    #expect(
      StickerBook.owned([star, place])[0].placement
        == StickerPlacement(surface: .town, x: 1.5, y: 0.7))
    // 行の並びが ばらばらでも同じ（2台の iPad の行を合わせたとき）。
    #expect(
      StickerBook.owned([move, place, star])[0].placement
        == StickerPlacement(surface: .zukan, x: 0.2, y: 0.3))
    #expect(StickerBook.owned([remove, move, star, place])[0].placement == nil)
    // はがしたあとで貼れば、また貼ってある。
    let again = StickerEvent(
      date: now.addingTimeInterval(-10), action: .placed, itemID: star.id, surface: .town, x: 0.1,
      y: 0.9)
    #expect(StickerBook.owned([remove, again, star])[0].placement?.surface == .town)
  }

  @Test("同じ ID の行は 1つ。知らないステッカーの行は数えない")
  func duplicatesAndUnknown() {
    let star = earned("hoshi", ago: 100)
    let stray = StickerEvent(date: now, action: .placed, itemID: UUID(), surface: .town)
    let owned = StickerBook.owned([star, star, stray])
    #expect(owned.count == 1)
    #expect(owned[0].placement == nil)
  }

  @Test("同じ絵のステッカーを 2枚持てる（別々に貼れる）")
  func twoOfTheSame() {
    let first = earned("hoshi", ago: 200)
    let second = earned("hoshi", ago: 100)
    let place = StickerEvent(
      date: now, action: .placed, itemID: second.id, surface: .town, x: 1, y: 0.5)
    let owned = StickerBook.owned([first, second, place])
    #expect(owned.map(\.id) == [first.id, second.id])
    #expect(owned[0].placement == nil)
    #expect(owned[1].placement != nil)
  }

  @Test("時間が同じ行は、行の ID の順で決まる（どの iPad でも同じ）")
  func tieBreak() {
    let star = earned("hoshi", ago: 100)
    let a = StickerEvent(
      id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, date: now, action: .placed,
      itemID: star.id, surface: .town, x: 1, y: 0.1)
    let b = StickerEvent(
      id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!, date: now, action: .removed,
      itemID: star.id)
    #expect(StickerBook.owned([star, a, b])[0].placement == nil)
    #expect(StickerBook.owned([b, a, star])[0].placement == nil)
  }

  @Test("目標に届いた日に、1回だけ あけられる")
  func boxOncePerGoalDay() {
    let cal = calendar
    #expect(
      StickerBook.boxState(practiced: 2, goal: 3, events: [], now: now, calendar: cal) == .notYet)
    #expect(
      StickerBook.boxState(practiced: 3, goal: 3, events: [], now: now, calendar: cal) == .ready)
    #expect(
      StickerBook.boxState(practiced: 9, goal: 3, events: [], now: now, calendar: cal) == .ready)
    // きょう あけたら、もう あけられない。
    let today = [earned("hoshi", ago: 60)]
    #expect(
      StickerBook.boxState(practiced: 9, goal: 3, events: today, now: now, calendar: cal)
        == .opened)
    // 記録だけリセットして字の数が 0 になっても、きょうは あけたまま。
    #expect(
      StickerBook.boxState(practiced: 0, goal: 3, events: today, now: now, calendar: cal)
        == .opened)
  }

  @Test("きのう あけていても、きょう目標に届けば また あけられる。貼った行は数えない")
  func boxNextDay() {
    let cal = calendar
    let start = cal.startOfDay(for: now)
    let yesterday = StickerEvent(
      date: start.addingTimeInterval(-1), action: .earned, sticker: "hoshi")
    let placedToday = StickerEvent(
      date: now, action: .placed, itemID: yesterday.id, surface: .town, x: 0, y: 0)
    let events = [yesterday, placedToday]
    #expect(!StickerBook.openedToday(events, now: now, calendar: cal))
    #expect(
      StickerBook.boxState(practiced: 5, goal: 5, events: events, now: now, calendar: cal)
        == .ready)
    #expect(
      StickerBook.boxState(practiced: 4, goal: 5, events: events, now: now, calendar: cal)
        == .notYet)
    // 日が変わる ちょうどの行は、きょうの分。
    let midnight = StickerEvent(date: start, action: .earned, sticker: "hana")
    #expect(StickerBook.openedToday([midnight], now: now, calendar: cal))
  }

  @Test("目標が 0 でも、1字は書かないと あけられない")
  func zeroGoal() {
    #expect(
      StickerBook.boxState(practiced: 0, goal: 0, events: [], now: now, calendar: calendar)
        == .notYet)
  }

  @Test("貼る位置は、貼るところの中におさめる")
  func clamp() {
    #expect(StickerBook.clamped(x: -1, y: 2) == (0, 1))
    #expect(StickerBook.clamped(x: 3.5, y: 0.4, maxX: 3) == (3, 0.4))
    #expect(StickerBook.clamped(x: .nan, y: .infinity) == (0, 0))
  }
}
