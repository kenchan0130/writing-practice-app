import Foundation
import Observation
import QuartzCore
import StrokeKit

/// 画面に描く1点（書く場所の座標、ポイント）。
struct DrawnPoint {
  var location: CGPoint
  var width: Double
}

/// 書く画面の仮のモデル（M0 前半）。流れの判断（判定・待ち時間）は、あとで Packages の関数と TCA に移す（D105）。
@Observable
final class WritingModel {
  /// 書き終えた画（表示用）。
  private(set) var strokes: [[DrawnPoint]] = []
  /// 書いている画（表示用）。
  private(set) var current: [DrawnPoint] = []
  /// 次の位置の予測（表示だけに使い、記録しない）。
  private(set) var predicted: [DrawnPoint] = []
  /// 書き終えた画の記録（マスの 0〜1000 の座標。D106）。
  private(set) var samples: [StrokeSample] = []

  /// 入力が届いた時刻（遅れの目安を出すため）。
  private(set) var lastInputTime: TimeInterval = 0

  var side: Double = 0
  var width = StrokeWidth()

  private var currentInput: StrokeInput = .finger
  private var currentRaw: [StrokePoint] = []
  private var pendingForce: [NSNumber: Int] = [:]

  func handle(_ event: StrokeInputEvent, convert: (CGPoint) -> CGPoint) {
    switch event {
    case .began(let input, let point):
      currentInput = input
      currentRaw = []
      current = []
      pendingForce = [:]
      append(point, convert: convert)
    case .moved(let points, let predictedPoints):
      for point in points { append(point, convert: convert) }
      predicted = predictedPoints.map {
        DrawnPoint(location: convert($0.location), width: current.last?.width ?? width.base)
      }
    case .forceUpdated(let index, let force):
      guard let position = pendingForce[index], position < current.count else { return }
      currentRaw[position].force = force
      current[position].width = width.width(force: force, speed: 0)
    case .ended:
      finishStroke()
    case .cancelled:
      current = []
      currentRaw = []
      predicted = []
    }
  }

  /// 「ひとつ もどす」（D56）。
  func undo() {
    guard !strokes.isEmpty else { return }
    strokes.removeLast()
    samples.removeLast()
  }

  /// 「ぜんぶ けす」（D56）。
  func clear() {
    strokes = []
    samples = []
    current = []
    predicted = []
  }

  private func append(_ point: StrokeInputPoint, convert: (CGPoint) -> CGPoint) {
    let location = convert(point.location)
    let speed: Double
    if let last = currentRaw.last, let lastDrawn = current.last, point.time > last.time {
      let dx = Double(location.x - lastDrawn.location.x)
      let dy = Double(location.y - lastDrawn.location.y)
      speed = (dx * dx + dy * dy).squareRoot() / (point.time - last.time)
    } else {
      speed = 0
    }
    let grid = GridMapping(side: side).toGrid(x: Double(location.x), y: Double(location.y))
    if let index = point.estimationIndex { pendingForce[index] = currentRaw.count }
    currentRaw.append(StrokePoint(x: grid.x, y: grid.y, time: point.time, force: point.force))
    current.append(
      DrawnPoint(location: location, width: width.width(force: point.force, speed: speed)))
    lastInputTime = point.time
  }

  private func finishStroke() {
    if !current.isEmpty {
      strokes.append(current)
      samples.append(StrokeSample(input: currentInput, points: currentRaw))
    }
    current = []
    currentRaw = []
    predicted = []
  }
}
