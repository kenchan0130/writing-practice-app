import ContentModel
import Foundation
import Testing

@testable import PracticeKit

@Suite("空が変わる（D172）")
struct SkyWeatherTests {
  let now = Date(timeIntervalSince1970: 1_800_000_000)

  private func record(_ word: String, ago: TimeInterval) -> SkyRecord {
    SkyRecord(word: word, date: now.addingTimeInterval(-ago))
  }

  @Test("空のことばは、どれも見せ方がある。空のことばでなければない")
  func everySkyWordHasAnEffect() {
    let skyWords = WordCatalog.all.filter { $0.kind == .sky }.map(\.text)
    #expect(skyWords.count == 10)
    #expect(Set(skyWords.compactMap(SkyWeather.effect(for:))) == Set(SkyEffect.allCases))
    for entry in WordCatalog.all where entry.kind != .sky {
      #expect(SkyWeather.effect(for: entry.text) == nil, "\(entry.text)")
    }
  }

  @Test("ことばごとの空")
  func effects() {
    #expect(SkyWeather.effect(for: "くも") == .cloudy)
    #expect(SkyWeather.effect(for: "あめ") == .rain)
    #expect(SkyWeather.effect(for: "ゆき") == .snow)
    #expect(SkyWeather.effect(for: "かみなり") == .thunder)
    #expect(SkyWeather.effect(for: "にじ") == .rainbow)
    #expect(SkyWeather.effect(for: "かぜ") == .wind)
    #expect(SkyWeather.effect(for: "たいよう") == .sun)
    #expect(SkyWeather.effect(for: "ほし") == .stars)
    #expect(SkyWeather.effect(for: "つき") == .moon)
    #expect(SkyWeather.effect(for: "うちゅうじん") == .ufo)
  }

  @Test("記録がなければ、空は変わらない")
  func nothing() {
    #expect(SkyWeather.forecast(records: [], now: now) == nil)
    #expect(SkyWeather.forecast(records: [record("くるま", ago: 5)], now: now) == nil)
  }

  @Test("書いてすぐ開くと、40秒の空が見える")
  func justWritten() throws {
    let forecast = try #require(SkyWeather.forecast(records: [record("あめ", ago: 5)], now: now))
    #expect(forecast.effect == .rain)
    #expect(forecast.since == now)
    #expect(forecast.remaining == 40)
  }

  @Test("10分までは見える。10分をすぎると見えない")
  func window() {
    #expect(SkyWeather.forecast(records: [record("ゆき", ago: 599)], now: now)?.effect == .snow)
    #expect(SkyWeather.forecast(records: [record("ゆき", ago: 600)], now: now)?.effect == .snow)
    #expect(SkyWeather.forecast(records: [record("ゆき", ago: 601)], now: now) == nil)
  }

  @Test("いちばん新しい空のことばが選ばれる。そのあとに書いた空でないことばは数えない")
  func latestSkyWord() {
    let records = [
      record("にじ", ago: 300), record("つき", ago: 120), record("くるま", ago: 10),
      record("くも", ago: 200),
    ]
    #expect(SkyWeather.latest(in: records)?.word == "つき")
    #expect(SkyWeather.forecast(records: records, now: now)?.effect == .moon)
  }

  @Test("見せはじめてから40秒たつと、ふつうの空にもどる")
  func fadesBack() throws {
    let records = [record("かぜ", ago: 20)]
    let shown = now.addingTimeInterval(-10)
    let mid = try #require(SkyWeather.forecast(records: records, now: now, shownSince: shown))
    #expect(mid.since == shown)
    #expect(mid.remaining == 30)
    #expect(
      SkyWeather.forecast(
        records: records, now: now.addingTimeInterval(30), shownSince: shown) == nil)
    #expect(
      SkyWeather.forecast(
        records: records, now: now.addingTimeInterval(29.5), shownSince: shown)?.remaining == 0.5)
  }

  @Test("見せたあとに新しく書いたら、はじめから見せる")
  func rewriteShowsAgain() throws {
    let shown = now.addingTimeInterval(-100)
    let records = [record("あめ", ago: 150), record("あめ", ago: 20)]
    // 見せはじめたのは、2回目より前。2回目の記録より新しいので、見せ直す。
    let again = try #require(
      SkyWeather.forecast(records: records, now: now, shownSince: shown))
    #expect(again.since == now)
    #expect(again.remaining == 40)
  }

  @Test("時計がずれて、書いた時刻が先でも見える")
  func futureRecord() {
    let future = SkyRecord(word: "ほし", date: now.addingTimeInterval(30))
    #expect(SkyWeather.forecast(records: [future], now: now)?.effect == .stars)
  }
}
