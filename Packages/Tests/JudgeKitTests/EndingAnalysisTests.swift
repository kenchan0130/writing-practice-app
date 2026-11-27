import ContentModel
import Foundation
import Testing

@testable import JudgeKit

@Suite("とめ・はね・はらい")
struct EndingAnalysisTests {
  /// 縦にまっすぐ 400 の線。`tailSpeed` は終わり 20% の速さ（なかほどを 1 とする）。
  static func vertical(tailSpeed: Double) -> (Polyline, [Double]) {
    var line: Polyline = []
    var times: [Double] = []
    var t = 0.0
    for i in 0...40 {
      let y = 100 + Double(i) * 10
      if i > 0 { t += (i > 32 ? 1 / tailSpeed : 1) * 0.01 }
      line.append(Point(500, y))
      times.append(t)
    }
    return (line, times)
  }

  @Test("終わりで速さを落とした線は とめ")
  func tome() {
    let (line, times) = Self.vertical(tailSpeed: 0.2)
    #expect(EndingAnalysis.classify(line, times: times) == .tome)
  }

  @Test("終わりまで速さを保った線は はらい")
  func harai() {
    let (line, times) = Self.vertical(tailSpeed: 1.1)
    #expect(EndingAnalysis.classify(line, times: times) == .harai)
  }

  @Test("終わりで左上へ折り返した線は はね")
  func hane() {
    var (line, times) = Self.vertical(tailSpeed: 1)
    for i in 1...5 {
      line.append(Point(500 - Double(i) * 8, 500 - Double(i) * 6))
      times.append(times.last! + 0.01)
    }
    #expect(EndingAnalysis.classify(line, times: times) == .hane)
  }

  @Test("中くらいの速さや、短すぎる線は見分けない（ヒントを出さない）")
  func unsure() {
    let (line, times) = Self.vertical(tailSpeed: 0.6)
    #expect(EndingAnalysis.classify(line, times: times) == nil)
    #expect(EndingAnalysis.classify(Array(line.prefix(4)), times: Array(times.prefix(4))) == nil)
  }

  @Test("ヒントは、お手本と違う最初の画に出す。決まっていない画・見分けられない画は見ない")
  func hintStroke() {
    let model: [CharacterData.Ending?] = [.hane, nil, .harai]
    #expect(EndingAnalysis.hintStroke(model: model, written: [.hane, .tome, .tome]) == 2)
    #expect(EndingAnalysis.hintStroke(model: model, written: [nil, .tome, .harai]) == nil)
    #expect(EndingAnalysis.hintStroke(model: model, written: [.tome]) == nil)
    #expect(EndingAnalysis.allMatch(model: model, written: [.hane, .tome, .harai]))
    #expect(!EndingAnalysis.allMatch(model: model, written: [.hane, .tome, nil]))
    #expect(!EndingAnalysis.allMatch(model: [nil], written: [.tome]))
  }

  /// パックのフォルダの字（`hira`・`kata`・`abc`）。
  static func pack(_ name: String) -> [CharacterData] {
    let directory = JudgeTests.packDirectory.deletingLastPathComponent()
      .appendingPathComponent(name)
    let files =
      (try? FileManager.default.contentsOfDirectory(
        at: directory, includingPropertiesForKeys: nil)) ?? []
    return files.filter { $0.lastPathComponent.hasPrefix("\(name).") && $0.pathExtension == "json" }
      .sorted { $0.lastPathComponent < $1.lastPathComponent }
      .compactMap { try? JSONDecoder().decode(CharacterData.self, from: Data(contentsOf: $0)) }
  }

  /// お手本の1画を、その終わり方らしい速さで書いたことにした（線の点と時刻）。
  /// とめは終わり15%で速さを落とし、それ以外は一定の速さ。
  static func written(_ stroke: CharacterData.Stroke) -> (Polyline, [Double]) {
    let line = stroke.centerlinePoints()
    var times = [0.0]
    var walked = 0.0
    let total = zip(line, line.dropFirst()).reduce(0) { $0 + $1.0.distance(to: $1.1) }
    for (a, b) in zip(line, line.dropFirst()) {
      walked += a.distance(to: b)
      let slow = stroke.end == .tome && walked > total * 0.85
      times.append(times.last! + a.distance(to: b) / 1000 * (slow ? 5 : 1))
    }
    return (line, times)
  }

  @Test("お手本の画をそのまま書くと、字のデータに決めてある終わり方に読める（ひらがな）")
  func modelStrokesReadAsTheirOwnEnding() {
    var checked = 0
    for data in Self.pack("hira") {
      for (index, stroke) in data.strokes.enumerated() {
        guard let expected = stroke.end else { continue }
        let (line, times) = Self.written(stroke)
        let actual = EndingAnalysis.classify(line, times: times)
        #expect(
          actual == expected,
          "\(data.char) \(index + 1)画: \(expected) が \(String(describing: actual)) に読めた")
        checked += 1
      }
    }
    #expect(checked >= 50)
  }

  @Test("はねではない画（終わり方が決まっているもの）を、はねと読まない（ひらがな）")
  func noFalseHane() {
    for data in Self.pack("hira") {
      for (index, stroke) in data.strokes.enumerated()
      where stroke.end == .tome || stroke.end == .harai {
        let (line, times) = Self.written(stroke)
        #expect(EndingAnalysis.classify(line, times: times) != .hane, "\(data.char) \(index + 1)画")
      }
    }
  }

  @Test("お手本どおりに書けば、ヒントは出ない（ひらがな・カタカナ）")
  func modelWritingGetsNoHint() {
    for name in ["hira", "kata"] {
      for data in Self.pack(name) {
        let model = data.strokes.map(\.end)
        let written = data.strokes.map { stroke -> CharacterData.Ending? in
          let (line, times) = Self.written(stroke)
          return EndingAnalysis.classify(line, times: times)
        }
        #expect(EndingAnalysis.hintStroke(model: model, written: written) == nil, "\(data.char)")
      }
    }
  }

  @Test("終わり方が決まっていない字（カタカナ）には、ヒントが出ない")
  func noHintWithoutEndingData() {
    for data in Self.pack("kata") {
      let model = data.strokes.map(\.end)
      let written = [CharacterData.Ending?](repeating: .tome, count: model.count)
      #expect(EndingAnalysis.hintStroke(model: model, written: written) == nil, "\(data.char)")
    }
  }
}
