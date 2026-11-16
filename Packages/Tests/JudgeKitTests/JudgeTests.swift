import ContentModel
import Foundation
import Testing

@testable import JudgeKit

/// ひらがなのパックのデータを使って、判定の基本の動きを確かめる（D107・D145）。
@Suite("判定")
struct JudgeTests {
  static let packDirectory = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()  // JudgeKitTests
    .deletingLastPathComponent()  // Tests
    .deletingLastPathComponent()  // Packages
    .deletingLastPathComponent()  // リポジトリ
    .appendingPathComponent("Content/Packs/hira")

  static func character(_ char: Character) throws -> CharacterData {
    let code = String(char.unicodeScalars.first!.value, radix: 16)
    let url = packDirectory.appendingPathComponent("hira.\(code).json")
    return try JSONDecoder().decode(CharacterData.self, from: Data(contentsOf: url))
  }

  /// お手本の線そのもの（子どもが完璧に書いた場合）。
  static func modelLines(_ data: CharacterData) -> [Polyline] {
    data.strokes.map { Geometry.polyline(of: $0) }
  }

  /// 決まった揺れを足す（手書きのぶれの代わり）。
  static func jittered(_ lines: [Polyline], amplitude: Double) -> [Polyline] {
    lines.enumerated().map { s, line in
      line.enumerated().map { i, p in
        Point(
          p.x + amplitude * sin(Double(i) * 0.9 + Double(s)),
          p.y + amplitude * cos(Double(i) * 1.3 + Double(s)))
      }
    }
  }

  @Test("お手本どおりに書けば、どの設定でも合格ではなまる", arguments: Array("きたほくそる"))
  func perfectWriting(char: Character) throws {
    let data = try Self.character(char)
    let judge = Judge(character: data)
    for preset in JudgePreset.allCases {
      let result = judge.judge(written: Self.modelLines(data), preset: preset)
      #expect(result.passed, "\(char) \(preset): \(result.issues)")
      #expect(result.rating == .hanamaru, "\(char) \(preset)")
    }
  }

  @Test("小さく、ずれた場所に書いても合格（字全体の位置と大きさを合わせる）")
  func scaledAndShifted() throws {
    let data = try Self.character("き")
    let lines = Self.modelLines(data).map { line in
      line.map { Point($0.x * 0.5 + 300, $0.y * 0.5 + 200) }
    }
    #expect(Judge(character: data).judge(written: lines, preset: .shikkari).passed)
  }

  @Test("少しぶれた線は合格")
  func smallJitter() throws {
    let data = try Self.character("た")
    let lines = Self.jittered(Self.modelLines(data), amplitude: 25)
    let result = Judge(character: data).judge(written: lines, preset: .naretekita)
    #expect(result.passed, "\(result.issues)")
  }

  @Test("大きくゆがんだ画は形で不合格")
  func distortedStroke() throws {
    let data = try Self.character("た")
    var lines = Self.modelLines(data)
    lines[0] = lines[0].enumerated().map { i, p in Point(p.x, p.y + Double(i) * 12) }
    let result = Judge(character: data).judge(written: lines, preset: .shikkari)
    #expect(!result.passed)
    #expect(result.issues.contains { if case .shape(model: 0, _) = $0 { true } else { false } })
  }

  @Test("書き順をまちがえると不合格")
  func wrongOrder() throws {
    let data = try Self.character("き")
    var lines = Self.modelLines(data)
    lines.swapAt(0, 1)
    let result = Judge(character: data).judge(written: lines, preset: .hajimete)
    #expect(!result.passed)
    #expect(result.issues.contains(.order(written: 0, model: 1)))
  }

  @Test("画を逆向きに書くと不合格")
  func reversedStroke() throws {
    let data = try Self.character("き")
    var lines = Self.modelLines(data)
    lines[2] = lines[2].reversed()
    let result = Judge(character: data).judge(written: lines, preset: .hajimete)
    #expect(!result.passed)
    #expect(result.issues.contains(.direction(model: 2)))
  }

  @Test("鏡に映した字は不合格")
  func mirroredCharacter() throws {
    let data = try Self.character("く")
    let lines = Geometry.mirrored(Self.modelLines(data))
    let result = Judge(character: data).judge(written: lines, preset: .hajimete)
    #expect(!result.passed)
    #expect(result.issues.contains(.mirrored))
  }

  @Test("画の数が違うと不合格")
  func wrongStrokeCount() throws {
    let data = try Self.character("く")
    let lines = Self.modelLines(data) + Self.modelLines(data)
    let result = Judge(character: data).judge(written: lines, preset: .hajimete)
    #expect(result.issues == [.strokeCount(expected: 1, actual: 2)])
  }

  @Test("設定で書き順を見ないときは、書き順がちがっても合格")
  func orderNotChecked() throws {
    let data = try Self.character("き")
    var lines = Self.modelLines(data).map { Geometry.resample($0) }
    lines.swapAt(0, 1)
    let config = JudgeConfig(shapeTolerance: 150, checksOrder: false)
    let result = Judge(character: data).evaluate(lines, config: config)
    #expect(result.passed, "\(result.issues)")
  }
}

@Suite("線の置き直し")
struct GeometryTests {
  @Test("長さにそって同じ間かくの点に置き直す")
  func resample() {
    let line: Polyline = [Point(0, 0), Point(100, 0), Point(100, 100)]
    let points = Geometry.resample(line, count: 5)
    #expect(points.count == 5)
    #expect(points.first == Point(0, 0))
    #expect(points.last == Point(100, 100))
    #expect(abs(points[2].x - 100) < 1e-9 && abs(points[2].y) < 1e-9)
  }

  @Test("点が1つの線は、その点を並べる")
  func resampleSinglePoint() {
    #expect(Geometry.resample([Point(5, 5)], count: 3) == [Point(5, 5), Point(5, 5), Point(5, 5)])
  }
}
