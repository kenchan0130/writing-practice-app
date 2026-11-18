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
  case rejectStroke(hintStroke: Int)
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
  /// ④じぶんで の書き終わりの合図（D77）。
  public var endSignal: Judge.EndSignal { judge.endSignal(for: strokes) }

  public mutating func handle(_ event: PracticeEvent) -> [PracticeEffect] {
    guard !finished else { return [] }
    switch (step, event) {
    case (_, .restartStep):
      // 書いた画と数え直しをなくして、同じ段階をやり直す（学習記録には残さない）。
      strokes = []
      sameStrokeMisses = 0
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
  private mutating func traceStroke(_ line: Polyline) -> [PracticeEffect] {
    let check = judge.judgeStroke(line, expected: expectedStroke, preset: preset)
    guard check == .ok else {
      sameStrokeMisses += 1
      if step == .nazoru, sameStrokeMisses >= 2 {
        // なぞる段階でも同じ画を2回続けて書けなければ、いちばん小さいほめ方で先に進める（D46）。
        markedDifficult = true
        finished = true
        return [.rejectStroke(hintStroke: expectedStroke), .finished(rating: .maru, rescued: true)]
      }
      if step == .usuku, sameStrokeMisses >= 3 {
        // うすく で同じ画を3回まちがえたら なぞる に戻る（D47）。
        return [.rejectStroke(hintStroke: expectedStroke)] + move(to: .nazoru)
      }
      return [.rejectStroke(hintStroke: expectedStroke)]
    }
    sameStrokeMisses = 0
    strokes.append(line)
    guard strokes.count == strokeCount else { return [.keepStroke] }
    if nazoruOnly, step == .nazoru {
      finished = true
      return [.keepStroke, .finished(rating: .maru, rescued: false)]
    }
    let next: PracticeStep = step == .nazoru ? .usuku : .jibunde
    return [.keepStroke] + move(to: next)
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
    return [.stepChanged(next)]
  }
}
