import ContentModel
import Foundation
import JudgeKit
import Testing

@testable import PracticeKit

@Suite("1文字の練習の流れ")
struct PracticeFlowTests {
  static let packDirectory = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .appendingPathComponent("Content/Packs/hira")

  static func character(_ char: Character) throws -> CharacterData {
    let code = String(char.unicodeScalars.first!.value, radix: 16)
    let url = packDirectory.appendingPathComponent("hira.\(code).json")
    return try JSONDecoder().decode(CharacterData.self, from: Data(contentsOf: url))
  }

  static func model(_ data: CharacterData) -> [Polyline] {
    data.strokes.map { $0.centerlinePoints() }
  }

  /// 違う場所の線（どの画とも合わない）。
  static let scribble: Polyline = [Point(950, 950), Point(990, 990)]

  @Test("みる → なぞる → うすく → じぶんで と進み、お手本どおりならはなまるで終わる")
  func happyPath() throws {
    let data = try Self.character("き")
    let lines = Self.model(data)
    var flow = PracticeFlow(character: data, preset: .naretekita)
    #expect(flow.step == .miru)
    #expect(flow.handle(.animationFinished) == [.stepChanged(.nazoru)])
    for (i, line) in lines.enumerated() {
      let effects = flow.handle(.strokeEnded(line))
      #expect(effects.first == .keepStroke)
      if i == lines.count - 1 { #expect(effects.last == .stepChanged(.usuku)) }
    }
    for line in lines { _ = flow.handle(.strokeEnded(line)) }
    #expect(flow.step == .jibunde)
    for line in lines { _ = flow.handle(.strokeEnded(line)) }
    let effects = flow.handle(.doneWriting)
    #expect(effects.last == .finished(rating: .hanamaru, rescued: false))
    #expect(flow.finished)
  }

  @Test("慣れた字は ①② を省いて うすく から始める")
  func masteredSkips() throws {
    let flow = PracticeFlow(character: try Self.character("く"), preset: .hajimete, mastered: true)
    #expect(flow.step == .usuku)
  }

  @Test("なぞる で書き順のちがう画を書くと、消して書き始めを光らせる")
  func wrongStrokeInTrace() throws {
    let data = try Self.character("き")
    var flow = PracticeFlow(character: data, preset: .hajimete)
    _ = flow.handle(.animationFinished)
    let effects = flow.handle(.strokeEnded(Self.model(data)[2]))
    #expect(effects == [.rejectStroke(hintStroke: 0)])
    #expect(flow.expectedStroke == 0)
  }

  @Test("なぞる で同じ画を2回続けて書けなければ、まる で先に進めて にがて に残す（D46）")
  func rescueInTrace() throws {
    var flow = PracticeFlow(character: try Self.character("く"), preset: .hajimete)
    _ = flow.handle(.animationFinished)
    _ = flow.handle(.strokeEnded(Self.scribble))
    let effects = flow.handle(.strokeEnded(Self.scribble))
    #expect(effects.last == .finished(rating: .maru, rescued: true))
    #expect(flow.markedDifficult)
  }

  @Test("うすく で同じ画を3回まちがえたら なぞる に戻る（D47）")
  func backToTrace() throws {
    var flow = PracticeFlow(character: try Self.character("く"), preset: .hajimete, mastered: true)
    _ = flow.handle(.strokeEnded(Self.scribble))
    _ = flow.handle(.strokeEnded(Self.scribble))
    let effects = flow.handle(.strokeEnded(Self.scribble))
    #expect(effects.last == .stepChanged(.nazoru))
  }

  @Test("じぶんで で設定の回数だけ続けてうまくいかなければ うすく に戻る（D47・D76）")
  func backToFaint() throws {
    let data = try Self.character("く")
    var flow = PracticeFlow(character: data, preset: .hajimete, mastered: true)
    _ = flow.handle(.strokeEnded(Self.model(data)[0]))
    #expect(flow.step == .jibunde)
    for attempt in 1...2 {
      _ = flow.handle(.strokeEnded(Self.scribble))
      let effects = flow.handle(.doneWriting)
      if attempt == 2 {
        #expect(effects.last == .stepChanged(.usuku))
      } else {
        #expect(flow.step == .jibunde)
      }
    }
  }

  @Test("しっかり では じぶんで を3回まで試せる（D76）")
  func retryLimitByPreset() throws {
    let flow = PracticeFlow(character: try Self.character("く"), preset: .shikkari)
    #expect(flow.jibundeRetryLimit == 3)
  }

  @Test("じぶんで の「ひとつ もどす」と「ぜんぶ けす」（D56）")
  func undoAndClear() throws {
    let data = try Self.character("き")
    var flow = PracticeFlow(character: data, preset: .hajimete, mastered: true)
    for line in Self.model(data) { _ = flow.handle(.strokeEnded(line)) }
    #expect(flow.step == .jibunde)
    _ = flow.handle(.strokeEnded(Self.scribble))
    _ = flow.handle(.strokeEnded(Self.scribble))
    _ = flow.handle(.undo)
    #expect(flow.strokes.count == 1)
    _ = flow.handle(.clear)
    #expect(flow.strokes.isEmpty)
  }
}
