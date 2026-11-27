import ContentModel
import Foundation
import JudgeKit
import Testing

@testable import PracticeKit

@Suite("ごく短い接触（D191）")
struct AccidentalTouchTests {
  static func packDirectory(_ pack: String) -> URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent().deletingLastPathComponent()
      .deletingLastPathComponent().deletingLastPathComponent()
      .appendingPathComponent("Content/Packs/\(pack)")
  }

  static func abc(_ hex: String) throws -> CharacterData {
    let url = packDirectory("abc").appendingPathComponent("abc.\(hex).json")
    return try JSONDecoder().decode(CharacterData.self, from: Data(contentsOf: url))
  }

  @Test("ちょんと触れた短い接触は捨てる")
  func discardsTap() throws {
    let rule = AccidentalTouch(character: try PracticeFlowTests.character("あ"))
    #expect(rule.minLength >= 12 && rule.minLength <= 30)
    #expect(rule.isAccidental(length: 0, duration: 0.05))
    #expect(rule.isAccidental(length: 8, duration: 0.2))
  }

  @Test("ふつうに書いた画は捨てない（長さが十分、またはゆっくり動かした）")
  func keepsRealStrokes() throws {
    let rule = AccidentalTouch(character: try PracticeFlowTests.character("あ"))
    #expect(!rule.isAccidental(length: 120, duration: 0.2))
    #expect(!rule.isAccidental(length: 5, duration: 1.5))
  }

  @Test("すべてのかなで、お手本のいちばん短い画の半分の長さの線は捨てない（濁点・半濁点など）")
  func neverDropsHalfModel() throws {
    for pack in ["hira", "kata"] {
      let dir = Self.packDirectory(pack)
      let files = try FileManager.default.contentsOfDirectory(atPath: dir.path)
        .filter { $0.hasSuffix(".json") && $0.hasPrefix(pack + ".") }
      #expect(!files.isEmpty)
      for file in files {
        let data = try JSONDecoder().decode(
          CharacterData.self, from: Data(contentsOf: dir.appendingPathComponent(file)))
        let rule = AccidentalTouch(character: data)
        let shortest = AccidentalTouch.shortestModelLength(of: data)
        #expect(!rule.isAccidental(length: shortest * 0.5, duration: 0.1), "\(file)")
      }
    }
  }

  @Test("i と j の点は、ちょんと打つので何も捨てない")
  func keepsDots() throws {
    #expect(AccidentalTouch(character: try Self.abc("69")) == .none)
    #expect(AccidentalTouch(character: try Self.abc("6a")) == .none)
    #expect(!AccidentalTouch.none.isAccidental(length: 0, duration: 0.05))
  }

  @Test("濁点をちょんと打っても、次に書く画の書き始めの近くなら捨てない（②③）")
  func keepsTapOnNextStroke() throws {
    let data = try PracticeFlowTests.character("が")
    let last = data.strokes.count - 1
    let start = data.strokes[last].centerlinePoints(stepsPerSegment: 1)[0]
    let rule = AccidentalTouch(character: data, expectedStroke: last)
    #expect(!rule.isAccidental(line: [start, start], times: [1.0, 1.05]))
    // 別の場所のちょんは、これまでどおり捨てる。
    let far = Point(start.x > 500 ? 50 : 950, 950)
    #expect(rule.isAccidental(line: [far, far], times: [1.0, 1.05]))
  }

  @Test("④では、濁点・半濁点のような短い画の書き始めの近くを守る")
  func keepsTapOnShortStrokesInJibunde() throws {
    let data = try PracticeFlowTests.character("ぱ")
    let rule = AccidentalTouch(character: data)
    #expect(!rule.protectedStarts.isEmpty)
    let start = rule.protectedStarts[0]
    #expect(!rule.isAccidental(line: [start, start], times: [1.0, 1.05]))
  }

  @Test("点と時刻から見る")
  func fromLine() {
    let rule = AccidentalTouch(minLength: 20)
    #expect(rule.isAccidental(line: [Point(100, 100), Point(103, 102)], times: [1.0, 1.06]))
    #expect(!rule.isAccidental(line: [Point(100, 100), Point(300, 100)], times: [1.0, 1.2]))
  }
}
