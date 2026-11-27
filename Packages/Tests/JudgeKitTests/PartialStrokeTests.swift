import ContentModel
import Foundation
import Testing

@testable import JudgeKit

/// 途中で離した線（続きから書く。D56 ③・D191）の判定。
@Suite("途中で離した線")
struct PartialStrokeTests {
  /// お手本の画の、`from`〜`to`（長さの割合）のところ。
  static func slice(_ data: CharacterData, stroke: Int, from: Double, to: Double) -> Polyline {
    let line = Geometry.polyline(of: data.strokes[stroke], stepsPerSegment: 32)
    let total = Geometry.length(of: line)
    var walked = 0.0
    var result: Polyline = []
    for (a, b) in zip(line, line.dropFirst()) {
      if walked >= total * from, walked <= total * to { result.append(a) }
      walked += a.distance(to: b)
      if walked > total * to { break }
    }
    return result
  }

  @Test("はじめの半分は、続きとして残る。進み具合は半分くらい")
  func halfIsPartial() throws {
    let data = try JudgeTests.character("く")
    let judge = Judge(character: data)
    let half = Self.slice(data, stroke: 0, from: 0, to: 0.5)
    let progress = judge.partialProgress(half, expected: 0, preset: .hajimete)
    #expect(progress != nil)
    #expect(abs((progress ?? 0) - 0.5) < 0.12)
  }

  @Test("短すぎる線・ほかの場所・ぐるぐる書きは、続きにならない")
  func rejectsBadPartials() throws {
    let data = try JudgeTests.character("く")
    let judge = Judge(character: data)
    #expect(
      judge.partialProgress(
        Self.slice(data, stroke: 0, from: 0, to: 0.08), expected: 0, preset: .hajimete) == nil)
    #expect(
      judge.partialProgress([Point(950, 950), Point(990, 990)], expected: 0, preset: .hajimete)
        == nil)
    // ぐるぐる: お手本のはじめの部分を何度も往復する。
    let part = Self.slice(data, stroke: 0, from: 0, to: 0.4)
    let scribble = part + part.reversed() + part + part.reversed() + part
    #expect(judge.partialProgress(scribble, expected: 0, preset: .hajimete) == nil)
    // 書き終わりがお手本から遠い線。
    let far = Self.slice(data, stroke: 0, from: 0, to: 0.4) + [Point(900, 100)]
    #expect(judge.partialProgress(far, expected: 0, preset: .hajimete) == nil)
  }

  @Test("輪のある字（の・あ・ね）でも、途中までは続きとして残る")
  func loopedLetters() throws {
    for char in ["の", "あ", "ね"] as [Character] {
      let data = try JudgeTests.character(char)
      let judge = Judge(character: data)
      for ratio in [0.3, 0.5, 0.7] {
        let line = Self.slice(data, stroke: 0, from: 0, to: ratio)
        #expect(
          judge.partialProgress(line, expected: 0, preset: .hajimete) != nil,
          "\(char) \(ratio)")
      }
    }
  }

  @Test("続きは、前の線の書き終わりの近くから書けばつながる")
  func continuesNearEnd() throws {
    let data = try JudgeTests.character("く")
    let judge = Judge(character: data)
    let first = Self.slice(data, stroke: 0, from: 0, to: 0.5)
    let rest = Self.slice(data, stroke: 0, from: 0.5, to: 1)
    #expect(judge.continues(first, with: rest, expected: 0))
    #expect(judge.joined(first, with: rest, expected: 0) == first + rest)
  }

  @Test("書き始めからやり直した線は、続きにならない")
  func restartIsNotContinuation() throws {
    let data = try JudgeTests.character("く")
    let judge = Judge(character: data)
    let first = Self.slice(data, stroke: 0, from: 0, to: 0.5)
    let again = Self.slice(data, stroke: 0, from: 0, to: 1)
    #expect(!judge.continues(first, with: again, expected: 0))
  }

  @Test("少し戻って（前の線に重なって）書き始めても、つながる。重なった分は切る")
  func overlappingContinuation() throws {
    for char in ["の", "く"] as [Character] {
      let data = try JudgeTests.character(char)
      let judge = Judge(character: data)
      let first = Self.slice(data, stroke: 0, from: 0, to: 0.5)
      let rest = Self.slice(data, stroke: 0, from: 0.42, to: 1)
      let joined = try #require(judge.joined(first, with: rest, expected: 0), "\(char)")
      #expect(joined.count < first.count + rest.count)
      #expect(joined.last == rest.last)
    }
  }
}
