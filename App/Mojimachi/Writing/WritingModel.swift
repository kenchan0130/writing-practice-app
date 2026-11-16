import ContentModel
import Foundation
import JudgeKit
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

  /// 練習している字（D78 の M0 の字を順に）。
  private(set) var character: CharacterData?
  private var characterIndex = 0
  /// 判定の結果（D107）。書き直すと消える。
  private(set) var result: JudgeResult?
  /// 「できた！」を光らせるか（D77）。
  private(set) var highlightsDone = false
  var preset: JudgePreset = .hajimete

  private var judgeTask: Task<Void, Never>?

  init() {
    loadCharacter()
  }

  /// 「つぎの もじ」（試作だけのボタン）。
  func nextCharacter() {
    characterIndex = (characterIndex + 1) % PackLibrary.m0Characters.count
    loadCharacter()
  }

  /// 「できた！」（D56）。いつでも押せる。
  func judgeNow() {
    judgeTask?.cancel()
    guard let character, !samples.isEmpty else { return }
    let written = samples.map { sample in sample.points.map { Point($0.x, $0.y) } }
    result = Judge(character: character).judge(written: written, preset: preset)
    highlightsDone = false
  }

  #if DEBUG
    /// 確かめ用: お手本の中心線をそのまま書いたことにして判定する（シミュレータでは線を書けないため）。
    /// 起動の引数 `-simulateWriting YES` で使う。
    func simulateModelWriting() {
      guard let character else { return }
      clear()
      let mapping = GridMapping(side: side)
      for stroke in character.strokes {
        let points = stroke.centerlinePoints().map { StrokePoint(x: $0.x, y: $0.y, time: 0) }
        samples.append(StrokeSample(input: .pencil, points: points))
        strokes.append(
          points.map {
            let p = mapping.fromGrid(x: $0.x, y: $0.y)
            return DrawnPoint(location: CGPoint(x: p.x, y: p.y), width: width.base)
          })
      }
      judgeNow()
    }
  #endif

  private func loadCharacter() {
    character = PackLibrary.hiragana(PackLibrary.m0Characters[characterIndex])
    clear()
  }

  /// 書き終わりの合図（D56・D77 の試作）。お手本の画数まで書いて1秒止まったら判定し、
  /// 足りないまま3秒止まったら「できた！」を光らせる。分けた線・つなげた線の当てはめは JudgeKit の次の版で足す。
  private func scheduleJudge() {
    judgeTask?.cancel()
    highlightsDone = false
    guard let expected = character?.strokes.count else { return }
    let enough = samples.count >= expected
    judgeTask = Task { [weak self] in
      try? await Task.sleep(for: .seconds(enough ? 1 : 3))
      guard !Task.isCancelled, let self else { return }
      if enough { self.judgeNow() } else { self.highlightsDone = true }
    }
  }

  private var currentInput: StrokeInput = .finger
  private var currentRaw: [StrokePoint] = []
  private var pendingForce: [NSNumber: Int] = [:]

  func handle(_ event: StrokeInputEvent, convert: (CGPoint) -> CGPoint) {
    switch event {
    case .began(let input, let point):
      judgeTask?.cancel()
      highlightsDone = false
      if result != nil {
        // 判定のあとに書き始めたら、書き直しとして始める。
        result = nil
        strokes = []
        samples = []
      }
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
    result = nil
  }

  /// 「ぜんぶ けす」（D56）。
  func clear() {
    judgeTask?.cancel()
    strokes = []
    samples = []
    current = []
    predicted = []
    result = nil
    highlightsDone = false
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
    scheduleJudge()
  }
}
