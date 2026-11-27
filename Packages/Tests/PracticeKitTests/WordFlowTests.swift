import ContentModel
import Foundation
import JudgeKit
import Testing

@testable import PracticeKit

@Suite("ことばを書く流れ")
struct WordFlowTests {
  static func word(_ text: String) throws -> [CharacterData] {
    try text.map { try PracticeFlowTests.character($0) }
  }

  static func model(_ data: CharacterData) -> [Polyline] {
    data.strokes.map { $0.centerlinePoints() }
  }

  @Test("まだ慣れていない字は なぞる、慣れた字は じぶんで で書く（D46）")
  func modesByMastery() throws {
    let chars = try Self.word("そり")
    let flow = WordFlow(characters: chars, mastered: [chars[1].id], preset: .hajimete)
    #expect(flow.mode == .nazoru)
    var flow2 = flow
    for line in Self.model(chars[0]) { _ = flow2.handle(.strokeEnded(line)) }
    #expect(flow2.index == 1)
    #expect(flow2.mode == .jibunde)
  }

  @Test("1字書くごとに色づきが進み、最後の字でことばが完成する（D55）")
  func progressAndCompletion() throws {
    let chars = try Self.word("うし")
    var flow = WordFlow(characters: chars, mastered: [], preset: .hajimete)
    var effects: [WordEffect] = []
    for line in Self.model(chars[0]) { effects = flow.handle(.strokeEnded(line)) }
    #expect(
      effects.contains(.characterDone(index: 0, progress: 0.5, rating: .maru, rescued: false)))
    for line in Self.model(chars[1]) { effects = flow.handle(.strokeEnded(line)) }
    #expect(effects.last == .wordDone)
    #expect(flow.finished)
    #expect(flow.progress == 1)
  }

  @Test("じぶんで で合わなければ、お手本を見せて うすく で1回だけ書いて先に進む（D56）")
  func jibundeMissThenFaint() throws {
    let chars = try Self.word("くつ")
    var flow = WordFlow(characters: chars, mastered: [chars[0].id], preset: .hajimete)
    _ = flow.handle(.strokeEnded([Point(950, 950), Point(990, 990)]))
    let effects = flow.handle(.doneWriting)
    #expect(
      effects.contains {
        if case .showModelAndRetryFaint = $0 { true } else { false }
      })
    #expect(flow.mode == .usuku)
    #expect(flow.jibundeMisses == [chars[0].id])
    for line in Self.model(chars[0]) { _ = flow.handle(.strokeEnded(line)) }
    #expect(flow.index == 1)
  }

  @Test("なぞる で同じ画を3回続けて書けなくても、行き止まりにせず次の字へ（D46・D191）")
  func noDeadEnd() throws {
    let chars = try Self.word("くつ")
    var flow = WordFlow(characters: chars, mastered: [], preset: .hajimete)
    let scribble: Polyline = [Point(950, 950), Point(990, 990)]
    _ = flow.handle(.strokeEnded(scribble))
    let second = flow.handle(.strokeEnded(scribble))
    #expect(second.contains(.replayModel(stroke: 0)))
    let effects = flow.handle(.strokeEnded(scribble))
    #expect(effects.contains(.nextCharacter(index: 1, mode: .nazoru)))
    #expect(
      effects.contains(.characterDone(index: 0, progress: 0.5, rating: .maru, rescued: true)))
  }

  @Test("途中で離した線は残し、続きから書けば1画になる（D56 ③・D191）")
  func continueFromWhereStopped() throws {
    let chars = try Self.word("くつ")
    var flow = WordFlow(characters: chars, mastered: [], preset: .hajimete)
    let first = PracticeFlowTests.prefix(of: chars[0], stroke: 0, ratio: 0.55)
    #expect(flow.handle(.strokeEnded(first)) == [.keepPartial])
    let rest = PracticeFlowTests.suffix(of: chars[0], stroke: 0, from: 0.55)
    let effects = flow.handle(.strokeEnded(rest))
    #expect(effects.first == .keepStroke)
    #expect(flow.strokes.count == 1 || flow.index == 1)
  }

  @Test("ひとつ もどす・ぜんぶ けす は いまの字だけ。前の字と色づきは そのまま（D191）")
  func undoAndClearCurrentLetter() throws {
    let chars = try Self.word("あき")
    var flow = WordFlow(characters: chars, mastered: Set(chars.map(\.id)), preset: .hajimete)
    // どちらも慣れた字なので じぶんで。
    let lines = Self.model(chars[0])
    for line in lines { _ = flow.handle(.strokeEnded(line)) }
    _ = flow.handle(.doneWriting)
    #expect(flow.index == 1)
    let before = flow.progress
    let next = Self.model(chars[1])
    _ = flow.handle(.strokeEnded(next[0]))
    #expect(flow.strokes.count == 1)
    _ = flow.handle(.undo)
    #expect(flow.strokes.isEmpty)
    #expect(flow.index == 1)
    _ = flow.handle(.strokeEnded(next[0]))
    _ = flow.handle(.clear)
    #expect(flow.strokes.isEmpty)
    #expect(flow.index == 1 && flow.progress == before)
  }

  @Test("続きを待っている途中で「ひとつ もどす」を押すと、途中の線を消して、また最初から書ける（D191）")
  func undoWithPendingPartial() throws {
    let chars = try Self.word("くつ")
    var flow = WordFlow(characters: chars, mastered: [], preset: .hajimete)
    let first = PracticeFlowTests.prefix(of: chars[0], stroke: 0, ratio: 0.5)
    #expect(flow.handle(.strokeEnded(first)) == [.keepPartial])
    #expect(flow.hasPartial)
    _ = flow.handle(.undo)
    #expect(!flow.hasPartial)
    #expect(flow.strokes.isEmpty)
    #expect(flow.handle(.strokeEnded(first)) == [.keepPartial])
  }
}
