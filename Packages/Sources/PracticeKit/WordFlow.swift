import ContentModel
import JudgeKit

/// ことばを書く流れの出来事。
public enum WordEvent: Sendable {
  /// いまの字の1画を書き終えた（マス 0〜1000）。
  case strokeEnded(Polyline)
  /// いまの字を書き終わった（じぶんで の字の、自動の合図か「できた！」。D77）。
  case doneWriting
}

/// ことばを書く流れの指示。
public enum WordEffect: Sendable, Equatable {
  case keepStroke
  /// 書いた画を消し、書き始めを光らせる（なぞる・うすく。D47）。
  case rejectStroke(hintStroke: Int)
  /// じぶんで で合わなかったので、お手本を重ねて見せてから うすく で1回だけ書く（D56）。
  case showModelAndRetryFaint(JudgeResult)
  /// 1字が書けた。`progress` は物の色づきの進み具合（0〜1。D55）。
  case characterDone(index: Int, progress: Double, rating: Rating, rescued: Bool)
  /// 次の字に進んだ。
  case nextCharacter(index: Int, mode: PracticeStep)
  /// ことばが書けた（物が完成して動きだす。D43）。
  case wordDone
}

/// ことばを書く流れ（D46・D56・D55）。ことばの中では1文字につき1回だけ書く。
/// まだ慣れていない字は なぞる、慣れた字は じぶんで。どの字も行き止まりにしない。
public struct WordFlow: Sendable {
  public let characters: [CharacterData]
  public let preset: JudgePreset
  public private(set) var index = 0
  /// いまの字を書く段階（なぞる・うすく・じぶんで）。
  public private(set) var mode: PracticeStep
  public private(set) var strokes: [Polyline] = []
  /// 字ごとの結果。
  public private(set) var ratings: [Rating] = []
  /// ことばの中の じぶんで で合わなかった字（D56。2回続けば「なぞる」に戻す判断に使う）。
  public private(set) var jibundeMisses: [String] = []
  public private(set) var finished = false

  private let masteredIDs: Set<String>
  private var sameStrokeMisses = 0
  private var judges: [Judge]

  public init(characters: [CharacterData], mastered: Set<String>, preset: JudgePreset) {
    self.characters = characters
    self.preset = preset
    self.masteredIDs = mastered
    self.judges = characters.map { Judge(character: $0) }
    self.mode = Self.mode(for: characters.first, mastered: mastered)
  }

  static func mode(for character: CharacterData?, mastered: Set<String>) -> PracticeStep {
    guard let character else { return .nazoru }
    return mastered.contains(character.id) ? .jibunde : .nazoru
  }

  public var current: CharacterData? {
    characters.indices.contains(index) ? characters[index] : nil
  }
  public var expectedStroke: Int { strokes.count }
  /// じぶんで の字の書き終わりの合図（D77）。
  public var endSignal: Judge.EndSignal {
    judges.indices.contains(index) ? judges[index].endSignal(for: strokes) : .highlightAfterPause
  }
  /// 物の色づきの進み具合（D55）。
  public var progress: Double {
    characters.isEmpty ? 0 : Double(ratings.count) / Double(characters.count)
  }

  public mutating func handle(_ event: WordEvent) -> [WordEffect] {
    guard !finished, let current else { return [] }
    switch (mode, event) {
    case (.nazoru, .strokeEnded(let line)), (.usuku, .strokeEnded(let line)):
      return traceStroke(line, strokeCount: current.strokes.count)
    case (.jibunde, .strokeEnded(let line)):
      strokes.append(line)
      return [.keepStroke]
    case (.jibunde, .doneWriting):
      return judgeWhole()
    default:
      return []
    }
  }

  private mutating func traceStroke(_ line: Polyline, strokeCount: Int) -> [WordEffect] {
    let check = judges[index].judgeStroke(line, expected: expectedStroke, preset: preset)
    guard check == .ok else {
      sameStrokeMisses += 1
      if sameStrokeMisses >= 2 {
        // 行き止まりを作らない。いちばん小さいほめ方で先に進める（D46）。
        return [.rejectStroke(hintStroke: expectedStroke)] + complete(rating: .maru, rescued: true)
      }
      return [.rejectStroke(hintStroke: expectedStroke)]
    }
    sameStrokeMisses = 0
    strokes.append(line)
    guard strokes.count == strokeCount else { return [.keepStroke] }
    return [.keepStroke] + complete(rating: .maru)
  }

  private mutating func judgeWhole() -> [WordEffect] {
    guard !strokes.isEmpty else { return [] }
    let result = judges[index].judge(written: strokes, preset: preset)
    if result.passed, let rating = result.rating {
      return complete(rating: rating)
    }
    // お手本を重ねて見せ、うすく で1回だけ書いて先に進む（D56）。
    if let id = current?.id { jibundeMisses.append(id) }
    mode = .usuku
    strokes = []
    sameStrokeMisses = 0
    return [.showModelAndRetryFaint(result)]
  }

  private mutating func complete(rating: Rating, rescued: Bool = false) -> [WordEffect] {
    ratings.append(rating)
    let done = WordEffect.characterDone(
      index: index, progress: progress, rating: rating, rescued: rescued)
    index += 1
    strokes = []
    sameStrokeMisses = 0
    guard let next = current else {
      finished = true
      return [done, .wordDone]
    }
    mode = Self.mode(for: next, mastered: masteredIDs)
    return [done, .nextCharacter(index: index, mode: mode)]
  }
}
