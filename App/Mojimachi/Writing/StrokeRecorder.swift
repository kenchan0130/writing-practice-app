import Foundation
import JudgeKit
import PracticeKit
import StrokeKit

/// 書く場所への入力を、画面に描く線と記録の線（マス 0〜1000）に直す（D106・D109）。
/// 1文字の練習とことばの画面で共通に使う。
struct StrokeRecorder {
  /// 書いている画（表示用）。
  private(set) var current: [DrawnPoint] = []
  /// 次の位置の予測（表示だけに使い、記録しない）。
  private(set) var predicted: [DrawnPoint] = []
  /// 入力が届いた時刻（遅れの目安を出すため）。
  private(set) var lastInputTime: TimeInterval = 0

  var side: Double = 0
  /// 画として数えない、ごく短い接触の決まり（いまの字に合わせる。D191）。
  var accidentalTouch = AccidentalTouch.none
  /// 直前の接触が、ごく短いので画として数えず捨てられたか（D191）。
  private(set) var lastEndWasDiscarded = false
  var width = StrokeWidth()
  /// 筆圧で線の太さを変えるか（D66。保護者用の画面の「筆圧を使う」）。
  var usesPressure: Bool { ProgressStore.shared.usesPressure }

  private var raw: [StrokePoint] = []
  private var pendingForce: [NSNumber: Int] = [:]

  /// 入力の出来事を受け取る。画が書き終わったら、その画（表示用と記録用）を返す。
  mutating func handle(_ event: StrokeInputEvent, convert: (CGPoint) -> CGPoint)
    -> (drawn: [DrawnPoint], line: Polyline, times: [Double])?
  {
    switch event {
    case .began(_, let point):
      lastEndWasDiscarded = false
      raw = []
      current = []
      pendingForce = [:]
      append(point, convert: convert)
    case .moved(let points, let predictedPoints):
      for point in points { append(point, convert: convert) }
      predicted = predictedPoints.map {
        DrawnPoint(location: convert($0.location), width: current.last?.width ?? width.base)
      }
    case .forceUpdated(let index, let force):
      guard let position = pendingForce[index], position < current.count else { return nil }
      raw[position].force = force
      if usesPressure { current[position].width = width.width(force: force, speed: 0) }
    case .ended:
      defer { reset() }
      guard !current.isEmpty else { return nil }
      let line = raw.map { Point($0.x, $0.y) }
      let times = raw.map(\.time)
      // ちょんと触れただけ・手が当たっただけの接触は、画として数えない（D191）。
      if accidentalTouch.isAccidental(line: line, times: times) {
        lastEndWasDiscarded = true
        return nil
      }
      return (current, line, times)
    case .cancelled:
      reset()
    }
    return nil
  }

  /// マスの座標の線を、画面に描く線にする（確かめ用の書き方などで使う）。
  func drawn(_ line: Polyline) -> [DrawnPoint] {
    let mapping = GridMapping(side: side)
    return line.map {
      let p = mapping.fromGrid(x: $0.x, y: $0.y)
      return DrawnPoint(location: CGPoint(x: p.x, y: p.y), width: width.base)
    }
  }

  private mutating func reset() {
    current = []
    raw = []
    predicted = []
  }

  private mutating func append(_ point: StrokeInputPoint, convert: (CGPoint) -> CGPoint) {
    let location = convert(point.location)
    let speed: Double
    if let last = raw.last, let lastDrawn = current.last, point.time > last.time {
      let dx = Double(location.x - lastDrawn.location.x)
      let dy = Double(location.y - lastDrawn.location.y)
      speed = (dx * dx + dy * dy).squareRoot() / (point.time - last.time)
    } else {
      speed = 0
    }
    let grid = GridMapping(side: side).toGrid(x: Double(location.x), y: Double(location.y))
    if let index = point.estimationIndex { pendingForce[index] = raw.count }
    raw.append(StrokePoint(x: grid.x, y: grid.y, time: point.time, force: point.force))
    current.append(
      DrawnPoint(
        location: location,
        width: width.width(force: usesPressure ? point.force : nil, speed: speed)))
    lastInputTime = point.time
  }
}
