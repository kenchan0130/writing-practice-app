import ContentModel
import Foundation
import Testing

@testable import PracticeKit

@Suite("主人公が動いて見せる（D175）")
struct BodyActionTests {
  let now = Date(timeIntervalSince1970: 1_800_000_000)

  private func record(_ word: String, ago: TimeInterval) -> BodyRecord {
    BodyRecord(word: word, date: now.addingTimeInterval(-ago))
  }

  @Test("体のことばは、どれも動きがある。体のことばでなければない")
  func everyBodyWordHasAMotion() {
    let words = WordCatalog.all.filter { $0.kind == .bodyAction }.map(\.text)
    #expect(words.count == 8)
    #expect(Set(words.compactMap(BodyAction.motion(for:))) == Set(BodyMotion.allCases))
    for entry in WordCatalog.all where entry.kind != .bodyAction {
      #expect(BodyAction.motion(for: entry.text) == nil, "\(entry.text)")
    }
  }

  @Test("ことばごとの動き")
  func motions() {
    #expect(BodyAction.motion(for: "て") == .wave)
    #expect(BodyAction.motion(for: "あし") == .jump)
    #expect(BodyAction.motion(for: "め") == .look)
    #expect(BodyAction.motion(for: "みみ") == .listen)
    #expect(BodyAction.motion(for: "くち") == .sing)
    #expect(BodyAction.motion(for: "あたま") == .nod)
    #expect(BodyAction.motion(for: "おなか") == .belly)
    #expect(BodyAction.motion(for: "ほっぺ") == .puff)
  }

  @Test("記録がなければ、動かない")
  func nothing() {
    #expect(BodyAction.pending(records: [], now: now) == nil)
    #expect(BodyAction.pending(records: [record("いぬ", ago: 10)], now: now) == nil)
    // 空のことばは、体のことばではない。
    #expect(BodyAction.pending(records: [record("くも", ago: 10)], now: now) == nil)
  }

  @Test("書いてから10分のあいだに開くと動く。10分をすぎたら動かない")
  func window() {
    #expect(BodyAction.pending(records: [record("て", ago: 5)], now: now) == .wave)
    #expect(BodyAction.pending(records: [record("て", ago: 600)], now: now) == .wave)
    #expect(BodyAction.pending(records: [record("て", ago: 601)], now: now) == nil)
  }

  @Test("いちばん新しい体のことばの動きを見せる。ほかのことばを間に書いても、体のことばが新しいほうが優先")
  func latestWins() {
    let records = [record("て", ago: 300), record("あし", ago: 100), record("いぬ", ago: 5)]
    #expect(BodyAction.pending(records: records, now: now) == .jump)
  }

  @Test("同じ記録の動きは1回だけ。書き直すと、また動く")
  func playsOnce() {
    let first = [record("て", ago: 120)]
    #expect(
      BodyAction.pending(records: first, now: now, playedAt: now.addingTimeInterval(-60)) == nil)
    // 見せたあとで書き直した。
    let again = first + [record("て", ago: 30)]
    #expect(
      BodyAction.pending(records: again, now: now, playedAt: now.addingTimeInterval(-60)) == .wave)
  }

  @Test("時計がずれて、書いた時刻が先でも、書いたばかりとして動く")
  func futureRecord() {
    #expect(BodyAction.pending(records: [record("みみ", ago: -30)], now: now) == .listen)
  }
}
