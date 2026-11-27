import CoreGraphics
import Foundation
import PracticeKit
import StrokeKit
import Testing

@testable import Mojimachi

/// ごく短い接触（ちょんと触れた）を捨てても、④じぶんで の自動の判定が止まらない（D191）。
@Suite("捨てた接触のあとの自動判定", .serialized)
@MainActor
struct DroppedTouchTests {
  private func point(_ x: Double, _ y: Double, _ time: Double) -> StrokeInputPoint {
    StrokeInputPoint(location: CGPoint(x: x, y: y), time: time, force: nil, estimationIndex: nil)
  }

  @Test("書き終えたあとにちょんと触れても、1秒で自動で判定する")
  func judgesAfterDroppedTap() async throws {
    let model = WritingModel(activity: WritingActivity(), start: "く")
    model.side = 500
    model.simulateModelWriting(until: .jibunde)
    #expect(model.step == .jibunde)
    let character = try #require(model.character)
    let line = character.strokes[0].centerlinePoints().map { point($0.x / 2, $0.y / 2, 0) }
    var time = 100.0
    let convert: (CGPoint) -> CGPoint = { $0 }
    model.handle(
      .began(.finger, point(line[0].location.x, line[0].location.y, time)), convert: convert)
    time += 0.5
    model.handle(
      .moved(
        points: line.dropFirst().map { point($0.location.x, $0.location.y, time) }, predicted: []),
      convert: convert)
    model.handle(.ended, convert: convert)
    #expect(model.strokes.count == 1)
    // 0.3 秒後に、マスの隅をちょんと触れる（画としては数えない）。
    try await Task.sleep(for: .seconds(0.3))
    model.handle(.began(.finger, point(470, 470, time + 1)), convert: convert)
    model.handle(.ended, convert: convert)
    #expect(model.strokes.count == 1)
    try await Task.sleep(for: .seconds(1.6))
    #expect(model.flow?.finished == true)
  }
}
