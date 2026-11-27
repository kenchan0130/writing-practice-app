import ContentModel
import JudgeKit

/// 1文字の練習の4ステップ（§3.2）。
public enum PracticeStep: String, Sendable, Hashable, Codable {
  /// ① みる: 書き順のアニメーション。
  case miru
  /// ② なぞる: 太いお手本の上に、書き始めの印と矢印。
  case nazoru
  /// ③ うすく: お手本を薄く（点線だけ）。
  case usuku
  /// ④ じぶんで: 何も出さない。
  case jibunde
}

/// 練習の出来事（画面から届く）。
public enum PracticeEvent: Sendable {
  /// ① のアニメーションが終わった。
  case animationFinished
  /// 1画書き終えた（②③④）。座標はマス 0〜1000。
  case strokeEnded(Polyline)
  /// ④ で書き終わった（自動の合図か「できた！」。D77）。
  case doneWriting
  /// 「ひとつ もどす」（④。D56）。
  case undo
  /// 「ぜんぶ けす」（④。D56）。
  case clear
  /// 「やりなおす」（どの段階でも。D154）。いまの段階を最初から書き直す。
  case restartStep
}

/// 練習の指示（画面がすること）。
public enum PracticeEffect: Sendable, Equatable {
  /// 書いた画を残す（②③は「ポン」と鳴らす。§3.2）。
  case keepStroke
  /// 書いた画をふわっと消し、書くべき画の書き始めを光らせて「ここから かいてみよう」（D47）。
  /// 続きから書く途中だったときは、そこまでの線も合わせて消す（D191）。
  case rejectStroke(hintStroke: Int)
  /// 途中でペンを離した線を残す。続きから書けば同じ画になる（D56 ③・D191）。
  case keepPartial
  /// 続きではなく、書き始めからの書き直しだった。残していた途中の線を消す（D191）。
  case dropPartial
  /// 続けてまちがえたので、その画のお手本をもう一度見せる（D191）。
  case replayModel(stroke: Int)
  /// ステップが変わった（戻ったことは子どもに知らせない。§3.2）。
  case stepChanged(PracticeStep)
  /// ④ の判定の結果を出す（違った画のアニメーションなど）。
  case showResult(JudgeResult)
  /// この字の練習が終わった。`rescued` は行き止まりを作らないための救済（D46）。
  case finished(rating: Rating, rescued: Bool)
}

/// 1文字の練習の流れ（D46・D47・D56・D76・D105）。
/// 画面や端末に頼らない「(状態, 出来事) → (次の状態, 指示)」の関数として持つ。
public struct PracticeFlow: Sendable {
  public private(set) var step: PracticeStep
  /// いま書いている画（②③は、次に書く画の番号）。
  public private(set) var strokes: [Polyline] = []
  public private(set) var finished = false
  /// にがてな字として学習記録に残すか（D46）。
  public private(set) var markedDifficult = false

  public let preset: JudgePreset
  /// 「みる → なぞる」だけで終える（はじめての流れの最初の1字。D23・D46）。
  public let nazoruOnly: Bool
  /// ④ で続けてうまくいかなかったら ③ に戻る回数（D76。1〜5回）。
  public let jibundeRetryLimit: Int
  private let judge: Judge
  private var sameStrokeMisses = 0
  private var jibundeFailures = 0
  /// 途中でペンを離した線（続きから書くための記録。②③。D191）。
  private var trace = StrokeTrace()
  /// なぞる で同じ画を続けてまちがえてよい回数。これだけまちがえたら、先に進める（D46・D191）。
  public static let missesBeforeRescue = 3

  /// - Parameter mastered: ④ に合格したことのある「慣れた字」なら、①② を省く（§3.2・D56）。
  public init(
    character: CharacterData, preset: JudgePreset, mastered: Bool = false,
    jibundeRetryLimit: Int? = nil, nazoruOnly: Bool = false
  ) {
    self.judge = Judge(character: character)
    self.preset = preset
    self.nazoruOnly = nazoruOnly
    self.jibundeRetryLimit =
      jibundeRetryLimit ?? (preset == .hajimete || preset == .naretekita ? 2 : 3)
    self.step = mastered ? .usuku : .miru
  }

  /// 次に書く画の番号（②③）。
  public var expectedStroke: Int { strokes.count }
  public var strokeCount: Int { judge.character.strokes.count }
  /// 途中でペンを離して、続きを待っているか（②③。D191）。
  public var hasPartial: Bool { trace.hasPartial }
  /// 続きから書くとき、「ここから つづき」の印を出す場所（マス 0〜1000）。
  public var continuationPoint: Point? { trace.continuationPoint }
  /// ④じぶんで の書き終わりの合図（D77）。
  public var endSignal: Judge.EndSignal { judge.endSignal(for: strokes) }

  public mutating func handle(_ event: PracticeEvent) -> [PracticeEffect] {
    guard !finished else { return [] }
    switch (step, event) {
    case (_, .restartStep):
      // 書いた画と数え直しをなくして、同じ段階をやり直す（学習記録には残さない）。
      strokes = []
      sameStrokeMisses = 0
      trace.reset()
      return [.stepChanged(step)]
    case (.miru, .animationFinished):
      return move(to: .nazoru)
    case (.nazoru, .strokeEnded(let line)), (.usuku, .strokeEnded(let line)):
      return traceStroke(line)
    case (.jibunde, .strokeEnded(let line)):
      strokes.append(line)
      return [.keepStroke]
    case (.jibunde, .undo):
      if !strokes.isEmpty { strokes.removeLast() }
      return []
    case (.jibunde, .clear):
      strokes = []
      return []
    case (.jibunde, .doneWriting):
      return judgeWhole()
    default:
      return []
    }
  }

  /// ②③: 1画ごとにその場で判定する（D47）。
  /// 途中で離した線は、書き始めと形が合っていれば残し、続きから書けるようにする（D56 ③・D191）。
  private mutating func traceStroke(_ line: Polyline) -> [PracticeEffect] {
    let outcome = trace.evaluate(line, judge: judge, expected: expectedStroke, preset: preset)
    switch outcome {
    case .partial(let dropped):
      return (dropped ? [.dropPartial] : []) + [.keepPartial]
    case .miss(let dropped):
      return (dropped ? [.dropPartial] : []) + miss()
    case .complete(let joined, let dropped):
      let effects: [PracticeEffect] = dropped ? [.dropPartial] : []
      sameStrokeMisses = 0
      strokes.append(joined)
      guard strokes.count == strokeCount else { return effects + [.keepStroke] }
      if nazoruOnly, step == .nazoru {
        finished = true
        return effects + [.keepStroke, .finished(rating: .maru, rescued: false)]
      }
      let next: PracticeStep = step == .nazoru ? .usuku : .jibunde
      return effects + [.keepStroke] + move(to: next)
    }
  }

  /// ②③で、書き直しになったとき。
  private mutating func miss() -> [PracticeEffect] {
    sameStrokeMisses += 1
    let reject = PracticeEffect.rejectStroke(hintStroke: expectedStroke)
    if step == .nazoru, sameStrokeMisses >= Self.missesBeforeRescue {
      // なぞる段階でも同じ画を続けてまちがえたら、先に進める（D46・D191）。ほめずに、いっしょに書こうと伝える。
      markedDifficult = true
      finished = true
      return [reject, .finished(rating: .maru, rescued: true)]
    }
    if step == .nazoru, sameStrokeMisses == Self.missesBeforeRescue - 1 {
      // 先に進める前に、その画のお手本を1回だけ見せる（D191）。
      return [reject, .replayModel(stroke: expectedStroke)]
    }
    if step == .usuku, sameStrokeMisses >= 3 {
      // うすく で同じ画を3回まちがえたら なぞる に戻る（D47）。
      return [reject] + move(to: .nazoru)
    }
    return [reject]
  }

  /// ④: 書き終わってから判定する（D47）。
  private mutating func judgeWhole() -> [PracticeEffect] {
    guard !strokes.isEmpty else { return [] }
    let result = judge.judge(written: strokes, preset: preset)
    if result.passed, let rating = result.rating {
      finished = true
      return [.showResult(result), .finished(rating: rating, rescued: false)]
    }
    jibundeFailures += 1
    if jibundeFailures >= jibundeRetryLimit {
      // ④ で続けてうまくいかなければ ③ に戻る（D47・D76）。
      jibundeFailures = 0
      return [.showResult(result)] + move(to: .usuku)
    }
    strokes = []
    return [.showResult(result)]
  }

  private mutating func move(to next: PracticeStep) -> [PracticeEffect] {
    step = next
    strokes = []
    sameStrokeMisses = 0
    trace.reset()
    return [.stepChanged(next)]
  }
}
