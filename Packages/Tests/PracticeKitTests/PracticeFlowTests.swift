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

  @Test("なぞる で同じ画を3回続けて書けなければ、まる で先に進めて にがて に残す（D46・D191）")
  func rescueInTrace() throws {
    var flow = PracticeFlow(character: try Self.character("く"), preset: .hajimete)
    _ = flow.handle(.animationFinished)
    _ = flow.handle(.strokeEnded(Self.scribble))
    let second = flow.handle(.strokeEnded(Self.scribble))
    // 先に進める前に、その画のお手本を1回だけ見せる。
    #expect(second == [.rejectStroke(hintStroke: 0), .replayModel(stroke: 0)])
    #expect(!flow.finished)
    let effects = flow.handle(.strokeEnded(Self.scribble))
    #expect(effects.last == .finished(rating: .maru, rescued: true))
    #expect(flow.markedDifficult)
  }

  /// お手本の画を、はじめから `ratio` のところまで書いた線。
  static func prefix(of data: CharacterData, stroke: Int, ratio: Double) -> Polyline {
    let line = data.strokes[stroke].centerlinePoints(stepsPerSegment: 32)
    var total = 0.0
    for (a, b) in zip(line, line.dropFirst()) { total += hypot(a.x - b.x, a.y - b.y) }
    var walked = 0.0
    var result = [line[0]]
    for (a, b) in zip(line, line.dropFirst()) {
      walked += hypot(a.x - b.x, a.y - b.y)
      result.append(b)
      if walked >= total * ratio { break }
    }
    return result
  }

  /// お手本の画の、`ratio` のところから終わりまで。
  static func suffix(of data: CharacterData, stroke: Int, from ratio: Double) -> Polyline {
    let line = data.strokes[stroke].centerlinePoints(stepsPerSegment: 32)
    var total = 0.0
    for (a, b) in zip(line, line.dropFirst()) { total += hypot(a.x - b.x, a.y - b.y) }
    var walked = 0.0
    var result: Polyline = []
    for (a, b) in zip(line, line.dropFirst()) {
      if walked >= total * ratio { result.append(a) }
      walked += hypot(a.x - b.x, a.y - b.y)
    }
    result.append(line[line.count - 1])
    return result
  }

  @Test("なぞる で長い画を途中で離しても消さず、続きから書けば1画になる（D56 ③・D191）")
  func continueFromWhereStopped() throws {
    let data = try Self.character("く")
    var flow = PracticeFlow(character: data, preset: .hajimete)
    _ = flow.handle(.animationFinished)
    let first = Self.prefix(of: data, stroke: 0, ratio: 0.55)
    #expect(flow.handle(.strokeEnded(first)) == [.keepPartial])
    #expect(flow.hasPartial)
    #expect(flow.strokes.isEmpty)
    let rest = Self.suffix(of: data, stroke: 0, from: 0.55)
    let effects = flow.handle(.strokeEnded(rest))
    #expect(effects.first == .keepStroke)
    #expect(!flow.hasPartial)
    #expect(flow.strokes.count == 1 || flow.step != .nazoru)
  }

  @Test("途中で離してから、また書き始めからやり直したら、途中の線は消して新しく見る（D191）")
  func restartAfterPartial() throws {
    let data = try Self.character("く")
    var flow = PracticeFlow(character: data, preset: .hajimete)
    _ = flow.handle(.animationFinished)
    _ = flow.handle(.strokeEnded(Self.prefix(of: data, stroke: 0, ratio: 0.5)))
    let effects = flow.handle(.strokeEnded(Self.model(data)[0]))
    #expect(effects.first == .dropPartial)
    #expect(effects.contains(.keepStroke))
  }

  @Test("途中までの線でも、まちがった線は残さない（形が合わない・短すぎる）（D191）")
  func wrongPartialIsRejected() throws {
    let data = try Self.character("く")
    var flow = PracticeFlow(character: data, preset: .hajimete)
    _ = flow.handle(.animationFinished)
    #expect(flow.handle(.strokeEnded(Self.scribble)) == [.rejectStroke(hintStroke: 0)])
    // 画のはじめの 5% しか書いていない線は、続きとして残さない。
    let tiny = Self.prefix(of: data, stroke: 0, ratio: 0.05)
    #expect(
      flow.handle(.strokeEnded(tiny)) == [.rejectStroke(hintStroke: 0), .replayModel(stroke: 0)])
    #expect(!flow.hasPartial)
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

  @Test("やりなおす: どの段階でも、書いた画を消して同じ段階の最初に戻る（D154）")
  func restartStep() throws {
    let data = try Self.character("き")
    let lines = Self.model(data)
    var flow = PracticeFlow(character: data, preset: .naretekita)
    _ = flow.handle(.animationFinished)
    _ = flow.handle(.strokeEnded(lines[0]))
    #expect(flow.expectedStroke == 1)
    #expect(flow.handle(.restartStep) == [.stepChanged(.nazoru)])
    #expect(flow.step == .nazoru)
    #expect(flow.expectedStroke == 0)
    // 最初の画から書き直せる。
    #expect(flow.handle(.strokeEnded(lines[0])).first == .keepStroke)
  }

  @Test("書き始めから途中までを何度くり返しても、まちがいとして数えて、いつかは先へ進める（D191）")
  func repeatedPartialRestartsAreMisses() throws {
    let data = try Self.character("く")
    var flow = PracticeFlow(character: data, preset: .hajimete)
    _ = flow.handle(.animationFinished)
    let part = Self.prefix(of: data, stroke: 0, ratio: 0.4)
    var finished = false
    for _ in 0..<12 where !finished {
      let effects = flow.handle(.strokeEnded(part))
      finished = effects.contains { if case .finished = $0 { true } else { false } }
    }
    #expect(finished)
    #expect(flow.markedDifficult)
  }

  @Test("輪のある字（の・あ・ね）も、途中で離して続きから書ける（D191）")
  func loopedLettersContinue() throws {
    for char in ["の", "あ", "ね"] as [Character] {
      let data = try Self.character(char)
      var flow = PracticeFlow(character: data, preset: .hajimete)
      _ = flow.handle(.animationFinished)
      let first = Self.prefix(of: data, stroke: 0, ratio: 0.5)
      #expect(flow.handle(.strokeEnded(first)) == [.keepPartial], "\(char)")
      let rest = Self.suffix(of: data, stroke: 0, from: 0.5)
      #expect(flow.handle(.strokeEnded(rest)).first == .keepStroke, "\(char)")
    }
  }

  @Test("少し戻って書き始めても、続きとして1画になる（D191）")
  func overlapContinues() throws {
    let data = try Self.character("の")
    var flow = PracticeFlow(character: data, preset: .hajimete)
    _ = flow.handle(.animationFinished)
    #expect(
      flow.handle(.strokeEnded(Self.prefix(of: data, stroke: 0, ratio: 0.5))) == [.keepPartial])
    #expect(flow.continuationPoint != nil)
    let rest = Self.suffix(of: data, stroke: 0, from: 0.42)
    #expect(flow.handle(.strokeEnded(rest)).first == .keepStroke)
    #expect(flow.continuationPoint == nil)
  }
}
