import Foundation
import Testing

@testable import RecordKit

@Suite("おねがい（D54・D160）")
struct WishTests {
  private var calendar: Calendar {
    var c = Calendar(identifier: .gregorian)
    c.timeZone = TimeZone(identifier: "Asia/Tokyo")!
    return c
  }

  private func date(_ month: Int, _ day: Int, hour: Int = 12) -> Date {
    calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour))!
  }

  private let a = UUID()
  private let b = UUID()

  @Test("何度押しても、同じ子・同じものは いちばん新しい日の1つにまとまる")
  func collapses() {
    let wishes = [
      Wish(profileID: a, item: "katakana", date: date(11, 3)),
      Wish(profileID: a, item: "katakana", date: date(11, 15)),
      Wish(profileID: a, item: "katakana", date: date(11, 9)),
    ]
    let notices = WishNotice.notices(from: wishes)
    #expect(notices.count == 1)
    #expect(notices[0].date == date(11, 15))
  }

  @Test("子やものが違えば別々。新しい日が上")
  func separatesAndSorts() {
    let wishes = [
      Wish(profileID: a, item: "katakana", date: date(11, 3)),
      Wish(profileID: b, item: "katakana", date: date(11, 15)),
      Wish(profileID: a, item: "abc", date: date(11, 9)),
    ]
    let notices = WishNotice.notices(from: wishes)
    #expect(notices.map(\.date) == [date(11, 15), date(11, 9), date(11, 3)])
    #expect(Set(notices.map(\.id)).count == 3)
  }

  @Test("買ったものは出さない")
  func hidesOwned() {
    let wishes = [
      Wish(profileID: a, item: "katakana", date: date(11, 3)),
      Wish(profileID: a, item: "abc", date: date(11, 4)),
    ]
    let notices = WishNotice.notices(from: wishes) { $0 == "katakana" }
    #expect(notices.map(\.item) == ["abc"])
  }

  @Test("おねがいが無ければお知らせも無い")
  func empty() {
    #expect(WishNotice.notices(from: []).isEmpty)
  }

  @Test("日付は「月日」だけ。0 を付けず、時刻は出さない")
  func dateText() {
    #expect(WishNotice.dateText(date(11, 5, hour: 23), calendar: calendar) == "11月5日")
    #expect(WishNotice.dateText(date(1, 15), calendar: calendar) == "1月15日")
  }

  @Test("文には回数を出さず、日付を添える。名前が空なら「お子さま」")
  func text() {
    let notice = WishNotice(profileID: a, item: "katakana", date: date(11, 15))
    #expect(
      notice.text(name: "はなちゃん", itemTitle: "カタカナ", calendar: calendar)
        == "はなちゃんが、カタカナをやりたがっています（11月15日）")
    #expect(
      notice.text(name: " ", itemTitle: "ABC", calendar: calendar)
        == "お子さまが、ABCをやりたがっています（11月15日）")
  }
}
