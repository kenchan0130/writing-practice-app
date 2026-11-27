import JudgeKit

/// ②なぞる・③うすく の1画の途中経過（D56 ③・D191）。
/// 途中でペンを離した線を残し、続きの線をつなげて1画として判定する。
/// 1文字の流れ（PracticeFlow）とことばの流れ（WordFlow）で共通に使う。
struct StrokeTrace: Sendable {
  /// 途中でペンを離した線。続きを待っている。
  private(set) var partial: Polyline?
  private var fraction = 0.0

  enum Outcome: Equatable {
    /// 1画が書けた。`line` はつなげたあとの線。
    case complete(line: Polyline, droppedPartial: Bool)
    /// 途中までは合っている。続きから書ける。
    case partial(droppedPartial: Bool)
    /// 書き直し。
    case miss(droppedPartial: Bool)
  }

  var hasPartial: Bool { partial != nil }

  mutating func reset() {
    partial = nil
    fraction = 0
  }

  /// 続きから書くときの、つづきの印を出す場所（前の線の書き終わり）。
  var continuationPoint: Point? { partial?.last }

  mutating func evaluate(
    _ line: Polyline, judge: Judge, expected: Int, preset: JudgePreset
  ) -> Outcome {
    var candidate = line
    var dropped = false
    var before = 0.0
    if let pending = partial {
      if let joined = judge.joined(pending, with: line, expected: expected) {
        candidate = joined
      } else {
        // 続きではなく、書き始めからの書き直し。途中の線は消して、新しい線を見る。
        dropped = true
        before = fraction
        reset()
      }
    }
    if judge.judgeStroke(candidate, expected: expected, preset: preset) == .ok {
      reset()
      return .complete(line: candidate, droppedPartial: dropped)
    }
    // 前より先まで書けているときだけ、続きとして残す（その場で足踏みする線は書き直し）。
    // 書き直しても前より先に行けないなら、まちがいとして数える（いつまでも続きにならないように）。
    if let progress = judge.partialProgress(candidate, expected: expected, preset: preset),
      progress > max(fraction, before) + 0.02
    {
      partial = candidate
      fraction = progress
      return .partial(droppedPartial: dropped)
    }
    reset()
    return .miss(droppedPartial: dropped)
  }
}
