import ContentModel
import Testing

@testable import PracticeKit

@Suite("きょうの ことば（D35・D54）")
struct DailyWordTests {
  static let words = WordCatalog.all.map(\.text)
  static let summerDay = CalendarDay(year: 2026, month: 7, day: 20)
  static let winterDay = CalendarDay(year: 2026, month: 1, day: 10)

  @Test("同じ子・同じ日は、何度でも同じことば")
  func stable() {
    let first = DailyWord.pick(
      from: Self.words, writtenBeforeToday: [], day: Self.summerDay, childID: "A", isJapan: true)
    for _ in 0..<20 {
      #expect(
        DailyWord.pick(
          from: Self.words, writtenBeforeToday: [], day: Self.summerDay, childID: "A",
          isJapan: true) == first)
    }
  }

  @Test("日が変わると、ことばも変わる（たいていの日）")
  func changesByDay() {
    var picks = Set<String>()
    for day in 1...28 {
      picks.insert(
        DailyWord.pick(
          from: Self.words, writtenBeforeToday: [],
          day: CalendarDay(year: 2026, month: 4, day: day),
          childID: "A", isJapan: false)!)
    }
    #expect(picks.count >= 15)
  }

  @Test("子が違えば、別のことばになる")
  func changesByChild() {
    var picks = Set<String>()
    for id in 0..<30 {
      picks.insert(
        DailyWord.pick(
          from: Self.words, writtenBeforeToday: [], day: Self.summerDay, childID: "child-\(id)",
          isJapan: false)!)
    }
    #expect(picks.count >= 10)
  }

  @Test("まだ書いていないことばを先にする")
  func prefersUnwritten() {
    let written = Set(Self.words.dropLast(3))
    let rest = Set(Self.words.suffix(3))
    for day in 1...28 {
      let pick = DailyWord.pick(
        from: Self.words, writtenBeforeToday: written,
        day: CalendarDay(year: 2026, month: 4, day: day),
        childID: "A", isJapan: false)!
      #expect(rest.contains(pick), "\(pick)")
    }
  }

  @Test("全部書いていたら、どれからでも選ぶ")
  func allWritten() {
    let pick = DailyWord.pick(
      from: Self.words, writtenBeforeToday: Set(Self.words), day: Self.summerDay, childID: "A",
      isJapan: false)
    #expect(pick != nil)
    #expect(
      DailyWord.pick(
        from: [], writtenBeforeToday: [], day: Self.summerDay, childID: "A", isJapan: true) == nil)
  }

  @Test("日本のとき、よその季節のことばは出ない。季節のことばは出る日がある")
  func seasonalInJapan() {
    var summerWords = Set<String>()
    var winterWords = Set<String>()
    for child in 0..<60 {
      let summer = DailyWord.pick(
        from: Self.words, writtenBeforeToday: [], day: Self.summerDay, childID: "c\(child)",
        isJapan: true)!
      let winter = DailyWord.pick(
        from: Self.words, writtenBeforeToday: [], day: Self.winterDay, childID: "c\(child)",
        isJapan: true)!
      summerWords.insert(summer)
      winterWords.insert(winter)
      #expect(WordSeason.season(of: summer).map { $0 == .summer } ?? true, "\(summer)")
      #expect(WordSeason.season(of: winter).map { $0 == .winter } ?? true, "\(winter)")
    }
    #expect(summerWords.contains { WordSeason.season(of: $0) == .summer })
    #expect(winterWords.contains { WordSeason.season(of: $0) == .winter })
  }

  @Test("日本でないときは、季節を見ない")
  func ignoresSeasonOutsideJapan() {
    var sawSummerWordInWinter = false
    for child in 0..<400 {
      let word = DailyWord.pick(
        from: Self.words, writtenBeforeToday: [], day: Self.winterDay, childID: "c\(child)",
        isJapan: false)!
      if WordSeason.season(of: word) == .summer { sawSummerWordInWinter = true }
    }
    #expect(sawSummerWordInWinter)
  }

  @Test("種は、起動しても同じ（決まった値）")
  func seedIsStable() {
    #expect(SeededGenerator.seed(from: "") == 0xCBF2_9CE4_8422_2325)
    #expect(SeededGenerator.seed(from: "a") == 0xAF63_DC4C_8601_EC8C)
    var a = SeededGenerator(seed: 42)
    var b = SeededGenerator(seed: 42)
    #expect((0..<10).map { _ in a.next() } == (0..<10).map { _ in b.next() })
  }
}
