import ContentModel
import Foundation
import Testing

@testable import PracticeKit

@Suite("カタカナのことばと しりとり・きょうの ことば・すうじ あそび（D199）")
struct KatakanaWordTests {
  @Test("カタカナのことばの読みは、ひらがな。長音と小さい字はそのまま")
  func reading() {
    #expect(ShiritoriKana.reading(of: "バス") == "ばす")
    #expect(ShiritoriKana.reading(of: "パトカー") == "ぱとかー")
    #expect(ShiritoriKana.reading(of: "ジュース") == "じゅーす")
    #expect(ShiritoriKana.reading(of: "ねこ") == "ねこ")
  }

  @Test("つなぐ音: 長音はその前の字、小さい字は大きい字")
  func headAndTail() {
    #expect(ShiritoriKana.head(of: "バス") == "ば")
    #expect(ShiritoriKana.tail(of: "バス") == "す")
    #expect(ShiritoriKana.tail(of: "パトカー") == "か")
    #expect(ShiritoriKana.tail(of: "ジュース") == "す")
    #expect(ShiritoriKana.tail(of: "ミルク") == "く")
    #expect(ShiritoriKana.tail(of: "ピアノ") == "の")
    #expect(ShiritoriKana.head(of: "ジュース") == "じ")
    // 「ん」で終わるカタカナのことばは、しりとりで使わない
    #expect(ShiritoriWord("ライオン")?.endsWithN == true)
  }

  @Test("バスは、「す」で始まることばに続き、「ば」で始まることばから続く")
  func chain() {
    let pool = ShiritoriPool(texts: ["バス", "すいか", "ばら", "ねこ", "こバス"])
    let afterBus = pool.usable(startingWith: "す", excluding: [])
    #expect(afterBus.map(\.text) == ["すいか"])
    let toBus = pool.usable(startingWith: "ば", excluding: [])
    #expect(Set(toBus.map(\.text)) == ["バス", "ばら"])
  }

  @Test("鍵のカタカナのことばは、鍵つきで入る")
  func lockedKatakana() {
    let pool = ShiritoriPool(
      texts: ["バス", "パトカー", "ねこ"], isLocked: { $0 == "パトカー" })
    #expect(pool.words.first { $0.text == "パトカー" }?.isLocked == true)
    #expect(pool.words.first { $0.text == "バス" }?.isLocked == false)
  }

  @Test("きょうの ことば: 開いていることばと、まだ書いていないおためしのことば")
  func dailyEligible() {
    let words = ["ねこ", "バス", "パトカー", "cat", "dog"]
    let open: (String) -> Bool = { $0 == "ねこ" }
    let trial: (String) -> Bool = { ["バス", "cat"].contains($0) }
    #expect(
      DailyWord.eligible(words, isOpen: open, isTrial: trial, written: [])
        == ["ねこ", "バス", "cat"])
    // バスを書いたら、もう出さない
    #expect(
      DailyWord.eligible(words, isOpen: open, isTrial: trial, written: ["バス"])
        == ["ねこ", "cat"])
    // 買って開いていれば、書いていても出る
    #expect(
      DailyWord.eligible(words, isOpen: { _ in true }, isTrial: trial, written: ["バス"])
        == words)
  }

  @Test("すうじ あそび: 1〜9 は その数のりんご。0 と数字でない字は出さない")
  func apples() {
    for n in 1...9 {
      #expect(NumberPlay.apples(for: Character(String(n))) == n)
    }
    #expect(NumberPlay.apples(for: "0") == 0)
    #expect(NumberPlay.apples(for: "A") == 0)
    #expect(NumberPlay.apples(for: "あ") == 0)
    #expect(NumberPlay.apples(for: "３") == 0)
    #expect(NumberPlay.apples(for: "三") == 0)
    #expect(NumberPlay.maxApples == 9)
    #expect(
      (0...9).allSatisfy { NumberPlay.apples(for: Character(String($0))) <= NumberPlay.maxApples })
  }

  private static func record(
    _ char: Character, at time: Double, passed: Bool = true, rescued: Bool = false
  ) -> NumberPlay.WriteRecord {
    let code = String(char.unicodeScalars.first!.value, radix: 16)
    return NumberPlay.WriteRecord(
      characterID: "abc.\(code)", date: Date(timeIntervalSince1970: time), passed: passed,
      rescued: rescued)
  }

  @Test("字のデータの ID から数字を取り出す")
  func digitFromID() {
    #expect(NumberPlay.digit(fromCharacterID: "abc.33") == "3")
    #expect(NumberPlay.digit(fromCharacterID: "abc.30") == "0")
    #expect(NumberPlay.digit(fromCharacterID: "abc.41") == nil)
    #expect(NumberPlay.digit(fromCharacterID: "hira.33") == nil)
    #expect(NumberPlay.digit(fromCharacterID: "abc") == nil)
  }

  @Test("かごの りんごは、いちばん新しく書けた数字の数。次の数字を書くまで同じ")
  func latestDigit() {
    #expect(NumberPlay.appleCount(in: []) == 0)
    let records = [Self.record("3", at: 10), Self.record("5", at: 20), Self.record("A", at: 30)]
    #expect(NumberPlay.appleCount(in: records) == 5)
    // 順番が前後して入っていても、日付で決まる
    #expect(NumberPlay.appleCount(in: records.reversed()) == 5)
    #expect(NumberPlay.appleCount(in: records + [Self.record("9", at: 40)]) == 9)
  }

  @Test("0 を書くと、かごは空。書けなかった・助けて進んだ数字は、数を変えない")
  func zeroAndFailed() {
    let base = [Self.record("4", at: 10)]
    #expect(NumberPlay.appleCount(in: base + [Self.record("0", at: 20)]) == 0)
    #expect(NumberPlay.appleCount(in: base + [Self.record("8", at: 20, passed: false)]) == 4)
    #expect(NumberPlay.appleCount(in: base + [Self.record("8", at: 20, rescued: true)]) == 4)
  }

  @Test("おためしでは、あそべるのは「1」だけ。あそべない数字を書いても、数は変わらない")
  func freeDigits() {
    let free: (Character) -> Bool = { $0 == "1" }
    let records = [Self.record("1", at: 10), Self.record("7", at: 20), Self.record("4", at: 30)]
    #expect(NumberPlay.appleCount(in: records, canPlay: free) == 1)
    #expect(NumberPlay.appleCount(in: [Self.record("7", at: 20)], canPlay: free) == 0)
    #expect(NumberPlay.appleCount(in: records) == 4)
  }

  @Test("えいごの ことば: sun・moon・star は、空を変える。ねこ（cat）は空のことばではない")
  func englishSkyWords() {
    #expect(SkyWeather.effect(for: "sun") == .sun)
    #expect(SkyWeather.effect(for: "moon") == .moon)
    #expect(SkyWeather.effect(for: "star") == .stars)
    #expect(SkyWeather.effect(for: "cat") == nil)
    let now = Date(timeIntervalSince1970: 1_000_000)
    let records = [SkyRecord(word: "sun", date: now.addingTimeInterval(-5))]
    let forecast = SkyWeather.forecast(records: records, now: now, shownSince: nil)
    #expect(forecast?.effect == .sun)
    // からだのことばは、英語でも日本語と同じ動き（いまは英語の体のことばはない）
    #expect(BodyAction.motion(for: "cat") == nil)
  }
}
