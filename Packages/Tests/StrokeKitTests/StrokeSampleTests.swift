import Foundation
import Testing

@testable import StrokeKit

@Suite("StrokeSample")
struct StrokeSampleTests {
  @Test("線の長さは点どうしの距離の合計")
  func length() {
    let stroke = StrokeSample(
      input: .pencil,
      points: [
        StrokePoint(x: 0, y: 0, time: 0),
        StrokePoint(x: 300, y: 400, time: 0.1),
        StrokePoint(x: 300, y: 1000, time: 0.2),
      ])
    #expect(stroke.length == 1100)
  }

  @Test("点が1つ以下なら長さは0")
  func emptyLength() {
    #expect(StrokeSample(input: .finger, points: []).length == 0)
    #expect(StrokeSample(input: .finger, points: [StrokePoint(x: 1, y: 2, time: 0)]).length == 0)
  }

  @Test("JSON に書き出して読み戻せる")
  func codableRoundTrip() throws {
    let stroke = StrokeSample(
      input: .pencil, points: [StrokePoint(x: 10, y: 20, time: 0, force: 0.5)])
    let data = try JSONEncoder().encode(stroke)
    #expect(try JSONDecoder().decode(StrokeSample.self, from: data) == stroke)
  }
}
