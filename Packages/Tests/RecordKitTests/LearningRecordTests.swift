import Foundation
import Testing

@testable import RecordKit

@Suite("学習記録")
struct LearningRecordTests {
  static let calendar: Calendar = {
    var c = Calendar(identifier: .gregorian)
    c.timeZone = TimeZone(identifier: "Asia/Tokyo")!
    c.firstWeekday = 2  // 月曜はじまり
    return c
  }()

  /// 2026-11-17（火）9:00 から `day` 日後の `hour` 時。
  static func date(day: Int = 0, hour: Int = 9) -> Date {
    let base = calendar.date(from: DateComponents(year: 2026, month: 11, day: 17, hour: hour))!
    return calendar.date(byAdding: .day, value: day, to: base)!
  }

  static let line: [[[Double]]] = [[[100, 100], [900, 900]]]

  @Test("きょう / こんしゅう: 同じ字は1つと数え、練習した日を数える")
  func summaries() {
    var log = LearningLog()
    log.append(
      CharacterRecord(date: Self.date(), characterID: "hira.3042", stage: .nazoru, passed: true))
    log.append(
      CharacterRecord(
        date: Self.date(hour: 10), characterID: "hira.3042", stage: .usuku, passed: true))
    log.append(
      CharacterRecord(
        date: Self.date(day: -1), characterID: "hira.3044", stage: .nazoru, passed: true))
    log.append(
      CharacterRecord(
        date: Self.date(day: -2), characterID: "hira.3046", stage: .nazoru, passed: true))
    log.append(WordRecord(date: Self.date(hour: 11), word: "くるま"))
    let today = log.today(now: Self.date(hour: 20), calendar: Self.calendar)
    #expect(today == PeriodSummary(characters: 1, words: 1, days: 1))
    // 月曜（11/16）からの週。日曜（11/15）は入らない。
    let week = log.thisWeek(now: Self.date(hour: 20), calendar: Self.calendar)
    #expect(week == PeriodSummary(characters: 2, words: 1, days: 2))
  }

  @Test("スタンプカード: 今週の7日に、練習した日だけ印が付く（字でもことばでも）")
  func stampWeek() {
    var log = LearningLog()
    log.append(
      CharacterRecord(
        date: Self.date(day: -1, hour: 8), characterID: "hira.3042", stage: .nazoru, passed: true))
    log.append(WordRecord(date: Self.date(day: 1, hour: 23), word: "くるま"))
    // 先週の日曜は入らない。
    log.append(
      CharacterRecord(
        date: Self.date(day: -2), characterID: "hira.3044", stage: .nazoru, passed: true))
    let week = log.stampWeek(now: Self.date(hour: 20), calendar: Self.calendar)
    #expect(week.count == 7)
    // 月曜（11/16）から日曜（11/22）。
    #expect(week.map(\.stamped) == [true, false, true, false, false, false, false])
    #expect(week.map(\.isToday) == [false, true, false, false, false, false, false])
    #expect(week[0].date == Self.calendar.startOfDay(for: Self.date(day: -1)))
    let days = log.practiceDays(
      in: DateInterval(start: Self.date(day: -3), end: Self.date(day: 3)), calendar: Self.calendar)
    #expect(days.count == 3)
  }

  @Test("もじの地図: まだ → れんしゅうちゅう → なぞって かけた → 何も見ないで かけた")
  func mapStates() {
    var log = LearningLog()
    #expect(log.mapState(of: "a") == .notYet)
    log.append(
      CharacterRecord(
        date: Self.date(), characterID: "a", stage: .nazoru, passed: false, rescued: true))
    #expect(log.mapState(of: "a") == .practicing)
    log.append(
      CharacterRecord(date: Self.date(hour: 10), characterID: "a", stage: .usuku, passed: true))
    #expect(log.mapState(of: "a") == .traced)
    log.append(
      CharacterRecord(date: Self.date(hour: 11), characterID: "a", stage: .jibunde, passed: false))
    #expect(log.mapState(of: "a") == .traced, "下がらない")
    log.append(
      CharacterRecord(date: Self.date(hour: 12), characterID: "a", stage: .jibunde, passed: true))
    #expect(log.mapState(of: "a") == .wroteAlone)
    #expect(log.map == ["a": .wroteAlone])
  }

  @Test("救済で先に進んだ ④ は「何も見ないで かけた」にしない（D46）")
  func rescueIsNotSolo() {
    var log = LearningLog()
    log.append(
      CharacterRecord(
        date: Self.date(), characterID: "a", stage: .jibunde, passed: false, rescued: true))
    #expect(log.mapState(of: "a") == .practicing)
  }

  @Test("にがてな もじ: よく書き直しになる字を、多い順の理由と一緒に出す")
  func weakCharacters() {
    var log = LearningLog()
    for (i, reasons) in [[CharacterRecord.Reason.order], [.order, .shape], [.mirrored]].enumerated()
    {
      log.append(
        CharacterRecord(
          date: Self.date(hour: 9 + i), characterID: "ki", stage: .jibunde, passed: false,
          reasons: reasons))
    }
    log.append(
      CharacterRecord(date: Self.date(hour: 13), characterID: "ki", stage: .jibunde, passed: true))
    // 1回だけ書き直しの字は出さない。
    log.append(
      CharacterRecord(
        date: Self.date(hour: 14), characterID: "so", stage: .jibunde, passed: false,
        reasons: [.shape]))
    log.append(
      CharacterRecord(date: Self.date(hour: 15), characterID: "so", stage: .jibunde, passed: true))
    let weak = log.weakCharacters
    #expect(weak.map(\.characterID) == ["ki"])
    #expect(weak.first?.misses == 3)
    #expect(weak.first?.reasons == [.order, .mirrored, .shape])
    #expect(weak.first?.latestMiss.reasons == [.mirrored])
  }

  @Test("にがてな もじ: 最近たくさん合格していれば外れる")
  func weakRecovers() {
    var log = LearningLog()
    for i in 0..<2 {
      log.append(
        CharacterRecord(date: Self.date(hour: i), characterID: "a", stage: .jibunde, passed: false))
    }
    for i in 0..<8 {
      log.append(
        CharacterRecord(
          date: Self.date(day: 1, hour: i), characterID: "a", stage: .jibunde, passed: true))
    }
    #expect(log.weakCharacters.isEmpty)
  }

  @Test("せいちょう アルバム: はじめての線と、最近のいちばん先の段階の線、④ に初めて合格した日（D83）")
  func album() {
    var log = LearningLog()
    log.append(
      CharacterRecord(
        date: Self.date(), characterID: "a", stage: .nazoru, passed: true, strokes: Self.line))
    log.append(
      CharacterRecord(
        date: Self.date(day: 1), characterID: "a", stage: .jibunde, passed: true, strokes: Self.line
      ))
    log.append(
      CharacterRecord(
        date: Self.date(day: 2), characterID: "a", stage: .usuku, passed: true, strokes: Self.line))
    log.append(
      CharacterRecord(
        date: Self.date(day: 3), characterID: "b", stage: .nazoru, passed: false, rescued: true,
        strokes: Self.line))
    log.append(
      CharacterRecord(date: Self.date(day: 4), characterID: "c", stage: .nazoru, passed: true))
    let album = log.album
    #expect(album.map(\.characterID) == ["a", "b"], "線のない記録は出さない。1回でも書けば出す")
    #expect(album[0].firstWasTraced)
    #expect(album[0].latest.stage == .jibunde)
    #expect(album[0].firstSoloPass == Self.date(day: 1))
    #expect(album[1].firstSoloPass == nil)
  }

  @Test("記録だけリセット: 行は残し、前の行を数えない（D44）")
  func reset() {
    var log = LearningLog()
    log.append(CharacterRecord(date: Self.date(), characterID: "a", stage: .jibunde, passed: true))
    log.reset()
    #expect(log.characters.count == 1)
    #expect(log.mapState(of: "a") == .notYet)
    #expect(log.today(now: Self.date(), calendar: Self.calendar).characters == 0)
    log.append(
      CharacterRecord(date: Self.date(hour: 10), characterID: "a", stage: .nazoru, passed: true))
    #expect(log.mapState(of: "a") == .traced)
  }

  @Test("JSON に書いて読み戻せる")
  func codable() throws {
    var log = LearningLog()
    log.append(
      CharacterRecord(
        date: Self.date(), characterID: "a", stage: .jibunde, passed: false, reasons: [.order],
        word: "あめ", strokes: Self.line))
    log.append(WordRecord(date: Self.date(), word: "あめ"))
    let data = try JSONEncoder().encode(log)
    #expect(try JSONDecoder().decode(LearningLog.self, from: data) == log)
  }
}
