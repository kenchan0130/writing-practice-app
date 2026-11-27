import StrokeKit
import UIKit
import UIKit.UIGestureRecognizerSubclass

/// 書く画面の入力の1点（窓の座標）。
struct StrokeInputPoint {
  var location: CGPoint
  var time: TimeInterval
  /// 0〜1 の筆圧。取れないときは nil（D66）。
  var force: Double?
  /// 筆圧の確定値があとで届くときの番号。
  var estimationIndex: NSNumber?
}

/// 書く画面の入力の出来事。
enum StrokeInputEvent {
  case began(StrokeInput, StrokeInputPoint)
  case moved(points: [StrokeInputPoint], predicted: [StrokeInputPoint])
  case forceUpdated(index: NSNumber, force: Double)
  case ended
  case cancelled
}

/// ペンと指の入力を受け取る小さな部品（D109）。
/// SwiftUI では取れない「細かい点・次の位置の予測・筆圧・触れた面の大きさ」のためだけに UIKit を使う。
/// 流れの判断はしない。出来事を出すだけ。
final class StrokeInputRecognizer: UIGestureRecognizer {
  var onEvent: ((StrokeInputEvent) -> Void)?
  var palmRejection = PalmRejection()

  private var activeTouch: UITouch?
  private var activeInput: StrokeInput = .finger
  private var activeStartTime: TimeInterval = 0
  private var activeStartLocation: CGPoint = .zero
  private var lastPencilTime: TimeInterval?

  override init(target: Any?, action: Selector?) {
    super.init(target: target, action: action)
    cancelsTouchesInView = false
    delaysTouchesBegan = false
    delaysTouchesEnded = false
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    for touch in touches {
      let input: StrokeInput = touch.type == .pencil ? .pencil : .finger
      let local = touch.location(in: view)
      let candidate = TouchCandidate(
        input: input,
        majorRadius: Double(touch.majorRadius),
        y: Double(local.y),
        areaHeight: Double(view?.bounds.height ?? 0),
        time: touch.timestamp)
      switch palmRejection.decide(
        candidate, lastPencilTime: lastPencilTime,
        activeInput: activeTouch == nil ? nil : activeInput)
      {
      case .reject:
        ignore(touch, for: event)
        continue
      case .replaceActive:
        // 手のひらが先に指の線として始まっていたら、それを取り消して Pencil の線を書く（D191）。
        // 認識の状態は終わらせない（終わらせると、手のひらが触れている間は Pencil を受け取れない）。
        if let palm = activeTouch { ignore(palm, for: event) }
        onEvent?(.cancelled)
        activeTouch = nil
      case .accept:
        break
      }
      activeTouch = touch
      activeInput = input
      activeStartTime = touch.timestamp
      activeStartLocation = local
      if input == .pencil { lastPencilTime = touch.timestamp }
      onEvent?(.began(input, point(from: touch)))
      if state != .began, state != .changed { state = .began }
    }
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
    guard let activeTouch, touches.contains(activeTouch) else { return }
    if palmRejection.shouldCancel(
      input: activeInput,
      majorRadius: Double(activeTouch.majorRadius),
      elapsed: activeTouch.timestamp - activeStartTime,
      travel: Double(
        hypot(
          activeTouch.location(in: view).x - activeStartLocation.x,
          activeTouch.location(in: view).y - activeStartLocation.y)))
    {
      // 手のひらだったので取り消す。手のひらはもう追わないので、手のひらが触れたままでも Pencil を受け取れる（D191）。
      onEvent?(.cancelled)
      ignore(activeTouch, for: event)
      self.activeTouch = nil
      // ほかに追っている接触がないので、終わらせて、次の接触を受けられるようにする（D191）。
      state = .cancelled
      return
    }
    if activeInput == .pencil { lastPencilTime = activeTouch.timestamp }
    let coalesced = event.coalescedTouches(for: activeTouch) ?? [activeTouch]
    let predicted = event.predictedTouches(for: activeTouch) ?? []
    onEvent?(.moved(points: coalesced.map(point(from:)), predicted: predicted.map(point(from:))))
    state = .changed
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
    guard let activeTouch, touches.contains(activeTouch) else { return }
    let coalesced = event.coalescedTouches(for: activeTouch) ?? [activeTouch]
    onEvent?(.moved(points: coalesced.map(point(from:)), predicted: []))
    finish(.ended)
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
    guard let activeTouch, touches.contains(activeTouch) else { return }
    finish(.cancelled)
  }

  override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
    for touch in touches {
      guard let index = touch.estimationUpdateIndex, let force = normalizedForce(touch) else {
        continue
      }
      onEvent?(.forceUpdated(index: index, force: force))
    }
  }

  override func reset() {
    super.reset()
    activeTouch = nil
  }

  private func finish(_ event: StrokeInputEvent) {
    onEvent?(event)
    activeTouch = nil
    state = event.isCancel ? .cancelled : .ended
  }

  private func point(from touch: UITouch) -> StrokeInputPoint {
    StrokeInputPoint(
      location: touch.location(in: nil),
      time: touch.timestamp,
      force: normalizedForce(touch),
      estimationIndex: touch.estimatedPropertiesExpectingUpdates.contains(.force)
        ? touch.estimationUpdateIndex : nil)
  }

  /// Pencil で筆圧を取れるときだけ 0〜1 にする（D66）。指やマウスは nil。
  private func normalizedForce(_ touch: UITouch) -> Double? {
    guard touch.type == .pencil, touch.maximumPossibleForce > 0 else { return nil }
    return Double(touch.force / touch.maximumPossibleForce)
  }
}

extension StrokeInputEvent {
  fileprivate var isCancel: Bool {
    if case .cancelled = self { return true }
    return false
  }
}
