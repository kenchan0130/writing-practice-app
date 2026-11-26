import ContentModel
import Foundation
import Testing

@testable import JudgeKit

/// アルファベットと数字のパックのデータで、判定を確かめる（D66・D107・D180）。
@Suite("判定（アルファベットと数字）")
struct AbcJudgeTests {
  static let packDirectory = JudgeTests.packDirectory
    .deletingLastPathComponent()
    .appendingPathComponent("abc")

  static let all: [CharacterData] = {
    let files =
      (try? FileManager.default.contentsOfDirectory(
        at: packDirectory, includingPropertiesForKeys: nil)) ?? []
    return
      files
      .filter { $0.pathExtension == "json" && $0.lastPathComponent.hasPrefix("abc.") }
      .sorted { $0.lastPathComponent < $1.lastPathComponent }
      .compactMap { try? JSONDecoder().decode(CharacterData.self, from: Data(contentsOf: $0)) }
  }()

  static func character(_ char: String) throws -> CharacterData {
    try #require(all.first { $0.char == char })
  }

  static func lines(_ strokes: [CharacterData.Stroke]) -> [Polyline] {
    strokes.map { Geometry.polyline(of: $0) }
  }

  @Test("字が4本の線（数字は上下の線）におさまる")
  func fitsGuideLines() throws {
    let top = AbcTable.guideLines[0]
    let middle = AbcTable.guideLines[1]
    let base = AbcTable.guideLines[2]
    let bottom = AbcTable.guideLines[3]
    let descenders: Set<Character> = ["g", "j", "p", "q", "y"]
    for data in Self.all {
      let char = Character(data.char)
      let ys = Self.lines(data.strokes).flatMap { $0.map(\.y) }
      let lo = try #require(ys.min())
      let hi = try #require(ys.max())
      switch AbcTable.page(of: char) {
      case .upper:
        #expect(abs(lo - top) <= 3, "\(char) の上")
        // Q のしっぽだけ、基本の線の少し下に出る。
        #expect(abs(hi - base) <= (char == "Q" ? 40 : 3), "\(char) の下")
      case .lower:
        #expect(lo >= top - 3, "\(char) の上")
        if !"bdfhijklt".contains(char) { #expect(abs(lo - middle) <= 3, "\(char) の上") }
        #expect(abs(hi - (descenders.contains(char) ? bottom : base)) <= 3, "\(char) の下")
      case .digits:
        #expect(abs(lo - AbcTable.digitRange.lowerBound) <= 6, "\(char) の上")
        #expect(abs(hi - AbcTable.digitRange.upperBound) <= 3, "\(char) の下")
      case nil:
        Issue.record("地図にない字: \(char)")
      }
    }
  }

  @Test("62字とも、お手本どおりに書けば、どの設定でも合格ではなまる")
  func modelPasses() {
    #expect(Self.all.count == 62)
    for data in Self.all {
      let judge = Judge(character: data)
      for preset in JudgePreset.allCases {
        let result = judge.judge(written: Self.lines(data.strokes), preset: preset)
        #expect(result.passed, "\(data.char) \(preset): \(result.issues)")
        #expect(result.rating == .hanamaru, "\(data.char) \(preset)")
        #expect(!result.usedAlternate, "\(data.char) \(preset)")
      }
    }
  }

  @Test("よく使われる別の書き順も、どの設定でも合格（D66）")
  func otherOrdersPass() {
    var count = 0
    for data in Self.all {
      let judge = Judge(character: data)
      for order in data.orders.dropFirst() {
        let written = Self.lines(order.map { data.strokes[$0] })
        for preset in JudgePreset.allCases {
          let result = judge.judge(written: written, preset: preset)
          #expect(result.passed, "\(data.char) \(order) \(preset): \(result.issues)")
        }
        count += 1
      }
    }
    #expect(count >= 8)
  }

  @Test("画数や画の分け方がちがう、よく使われる書き方も、どの設定でも合格（D66）")
  func alternatesPass() {
    var count = 0
    for data in Self.all {
      let judge = Judge(character: data)
      for alternate in data.alternates ?? [] {
        for preset in JudgePreset.allCases {
          let result = judge.judge(written: Self.lines(alternate), preset: preset)
          #expect(
            result.passed, "\(data.char) \(alternate.count)画 \(preset): \(result.issues)")
          #expect(result.usedAlternate, "\(data.char) \(alternate.count)画 \(preset)")
        }
        #expect(judge.endSignal(for: Self.lines(alternate)) == .judgeAfterPause, "\(data.char)")
        count += 1
      }
    }
    #expect(count >= 25)
  }

  @Test("正解にない書き順（画を逆の順に書く）は不合格")
  func wrongOrderFails() {
    var count = 0
    for data in Self.all where data.strokes.count >= 2 {
      let reversed = Array(data.strokes.indices.reversed())
      guard !data.orders.contains(reversed) else { continue }
      let written = Self.lines(reversed.map { data.strokes[$0] })
      let result = Judge(character: data).judge(written: written, preset: .shikkari)
      #expect(!result.passed, "\(data.char)")
      count += 1
    }
    #expect(count >= 20)
  }

  @Test("画を逆向きに書くと不合格（始まりと終わりが離れている画）")
  func reversedStrokeFails() {
    var count = 0
    for data in Self.all {
      for index in data.strokes.indices {
        let line = Geometry.polyline(of: data.strokes[index])
        guard let first = line.first, let last = line.last, first.distance(to: last) > 200 else {
          continue
        }
        var written = Self.lines(data.strokes)
        written[index] = line.reversed()
        // 線をつなげて読む設定（はじめて・なれてきた）では、G の横線や N の右の線の逆向きが、
        // 1画少ない別の書き方として合格になる。ここでは、つなげて読まない設定で見る。
        let result = Judge(character: data).judge(written: written, preset: .shikkari)
        #expect(!result.passed, "\(data.char) \(index + 1)画")
        count += 1
      }
    }
    #expect(count >= 60)
  }

  @Test("b を鏡に映した形（d の形）は、b では不合格。p と q も同じ")
  func mirroredFails() throws {
    for char in ["b", "d", "p", "q", "S", "Z", "J", "3", "7"] {
      let data = try Self.character(char)
      let written = Geometry.mirrored(Self.lines(data.strokes))
      let result = Judge(character: data).judge(written: written, preset: .hajimete)
      #expect(!result.passed, "\(char)")
      #expect(result.issues.contains(.mirrored), "\(char): \(result.issues)")
    }
  }

  @Test("画数がちがい、どの書き方にも合わなければ不合格")
  func wrongStrokeCountFails() throws {
    let data = try Self.character("E")
    let written = Array(Self.lines(data.strokes).prefix(2))
    let result = Judge(character: data).judge(written: written, preset: .hajimete)
    #expect(!result.passed)
    #expect(result.issues.contains(.strokeCount(expected: 4, actual: 2)))
  }

  @Test("i の点は、どの向きに書いても合格")
  func dotAnyDirection() throws {
    let data = try Self.character("i")
    for dot in [
      [Point(500, 195), Point(500, 215)], [Point(500, 215), Point(500, 195)],
      [Point(490, 205), Point(510, 205)],
    ] {
      let written = [Geometry.polyline(of: data.strokes[0]), dot]
      let result = Judge(character: data).judge(written: written, preset: .shikkari)
      #expect(result.passed, "\(dot): \(result.issues)")
    }
  }

  @Test("②なぞる の1画ずつの判定: お手本の画は合格、逆向きは向きの間違い")
  func tracing() throws {
    let data = try Self.character("L")
    let judge = Judge(character: data)
    let line = Geometry.polyline(of: data.strokes[0])
    #expect(judge.judgeStroke(line, expected: 0, preset: .shikkari) == .ok)
    #expect(judge.judgeStroke(line.reversed(), expected: 0, preset: .shikkari) == .direction)
  }
}
