import ContentModel
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
}
