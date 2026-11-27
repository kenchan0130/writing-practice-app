import ContentModel
import Foundation
import JudgeKit
import Observation
import PracticeKit
import RecordKit
import UIKit

/// ことばを書く画面のモデル（試作。D46・D55・D56）。流れは PracticeKit の WordFlow に任せる。
@Observable
final class WordModel {
  /// 選べることば（テーマから入ったらそのテーマのことば。D166）。
  let items: [WordArt.Item]
  private(set) var wordIndex = 0
  private(set) var flow: WordFlow?
  /// いまの字の書いた線（表示用）。
  private(set) var strokes: [[DrawnPoint]] = []
  /// 書き終えた字の線（変身に使う。字ごと、書く場所の座標）。
  private(set) var writtenCharacters: [[[DrawnPoint]]] = []
  private(set) var recorder = StrokeRecorder()
  /// 書いている間と直後は「←」を効かせない（D101）。
  let activity: WritingActivity
  private(set) var hintStroke: Int?
  /// じぶんで で合わなかったときに出す結果（お手本を重ねて見せる。D56）。
  private(set) var missResult: JudgeResult?
  /// ことばが書けた（変身を見せる）。
  private(set) var wordDone = false
  private(set) var highlightsDone = false
  /// 1字書けたときの小さなごほうびのほめ方（D152）。少しのあいだだけ出す。
  private(set) var charPraise: Rating?
  private var praiseTask: Task<Void, Never>?
  /// 途中でペンを離して、続きを待っている線の数（D191）。
  private var pendingPieces = 0
  /// 続けて捨てた、ごく短い接触の数（D191）。
  private var discardedTouches = 0
  /// 続けてまちがえたとき、お手本の画を1回だけ見せる（D191）。
  private(set) var replay: ModelReplay?
  private var replayTask: Task<Void, Never>?

  private let store = ProgressStore.shared
  /// いまの字の書いた線（マス 0〜1000。学習記録に残す）。
  private var lines: [Polyline] = []
  private var judgeTask: Task<Void, Never>?

  var side: Double {
    get { recorder.side }
    set { recorder.side = newValue }
  }

  /// `start` を渡すと、そのことばから始める（字のカードから。D101）。
  init(activity: WritingActivity, start: String? = nil, choices: [String]? = nil) {
    self.activity = activity
    let chosen = choices?.compactMap { text in WordArt.words.first { $0.entry.text == text } }
    items = (chosen?.isEmpty == false ? chosen : nil) ?? WordArt.words
    #if DEBUG
      // 確かめ用: `-word いぬ` でそのことばから始める。
      if let text = UserDefaults.standard.string(forKey: "word"),
        let index = items.firstIndex(where: { $0.entry.text == text })
      {
        wordIndex = index
      }
    #endif
    if let start, let index = items.firstIndex(where: { $0.entry.text == start }) {
      wordIndex = index
    }
    loadWord()
  }

  var word: String { items[wordIndex].entry.text }
  var asset: String { items[wordIndex].asset }
  var kind: WordKind { items[wordIndex].entry.kind }
  var currentCharacter: CharacterData? { flow?.current }
  var mode: PracticeStep? { flow?.mode }
  var progress: Double { flow?.progress ?? 0 }

  func nextWord() {
    wordIndex = (wordIndex + 1) % items.count
    loadWord()
  }

  /// ことばを選ぶ（3つの型をまたいで選べる）。
  func select(_ text: String) {
    guard let index = items.firstIndex(where: { $0.entry.text == text }) else {
      return
    }
    wordIndex = index
    loadWord()
  }

  func restartWord() { loadWord() }

  /// ②③で書けた画の数（続きから書く途中の線は数えない。D191）。
  var completedStrokes: Int {
    mode == .jibunde ? strokes.count : (flow?.strokes.count ?? strokes.count)
  }

  /// 「ひとつ もどす」。いまの字の、いちばん新しい1画を消す。ほかの字は そのまま（D191）。
  func undo() {
    guard !wordDone, !strokes.isEmpty else { return }
    judgeTask?.cancel()
    highlightsDone = false
    missResult = nil
    // 続きから書く途中の線は、まとめて消す。
    let count = max(pendingPieces, 1)
    strokes.removeLast(min(count, strokes.count))
    lines.removeLast(min(count, lines.count))
    pendingPieces = 0
    apply(flow?.handle(.undo) ?? [])
    scheduleJudge()
  }

  /// 「ぜんぶ けす」。いまの字の線をぜんぶ消す。ほかの字と、物の色づきは そのまま（D191）。
  func clearLetter() {
    guard !wordDone, !strokes.isEmpty || missResult != nil else { return }
    judgeTask?.cancel()
    highlightsDone = false
    missResult = nil
    strokes = []
    lines = []
    pendingPieces = 0
    hintStroke = nil
    apply(flow?.handle(.clear) ?? [])
  }

  /// まちに置く（D53 の「動きまわる」型の試作）。
  func placeInTown() {
    // 空のことばは まちに置かない。書いた記録（WordRecord）から、まちの空が しばらく変わる（D172）。
    // 体のことばも置かない。書いた記録から、まちで主人公が その動きを見せる（D175）。
    guard kind != .sky, kind != .bodyAction else { return }
    store.place(PlacedObject(word: word, symbol: asset, kind: kind))
  }

  /// 「できた！」（じぶんで の字。D56）。
  func judgeNow() {
    judgeTask?.cancel()
    highlightsDone = false
    apply(flow?.handle(.doneWriting) ?? [])
  }

  private func loadWord() {
    judgeTask?.cancel()
    praiseTask?.cancel()
    charPraise = nil
    let characters = word.compactMap { PackLibrary.hiragana($0) }
    flow = WordFlow(characters: characters, mastered: store.mastered, preset: store.preset)
    strokes = []
    lines = []
    pendingPieces = 0
    replay = nil
    writtenCharacters = []
    hintStroke = nil
    missResult = nil
    wordDone = false
    highlightsDone = false
  }

  func handle(_ event: StrokeInputEvent, convert: (CGPoint) -> CGPoint) {
    activity.track(event)
    guard !wordDone, flow?.finished == false else { return }
    if case .began = event {
      judgeTask?.cancel()
      highlightsDone = false
      missResult = nil
      if let character = currentCharacter {
        recorder.accidentalTouch = AccidentalTouch(
          character: character, expectedStroke: mode == .jibunde ? nil : flow?.expectedStroke)
      }
    }
    guard let finished = recorder.handle(event, convert: convert) else {
      endedWithoutStroke(event)
      return
    }
    discardedTouches = 0
    strokes.append(finished.drawn)
    lines.append(finished.line)
    apply(flow?.handle(.strokeEnded(finished.line)) ?? [])
    scheduleJudge()
  }

  /// 画にならなかった接触が終わったとき。止めた「書き終わりの合図」をもう一度かけ、
  /// ②③で何度も続くときは、次に書く画の書き始めを光らせる（D191）。
  func endedWithoutStroke(_ event: StrokeInputEvent) {
    switch event {
    case .ended, .cancelled:
      if recorder.lastEndWasDiscarded {
        discardedTouches += 1
        if discardedTouches >= 3, mode != .jibunde, let flow {
          hintStroke = flow.expectedStroke
        }
      }
      scheduleJudge()
    default:
      break
    }
  }

  private func apply(_ effects: [WordEffect]) {
    // 字が進む前の字と段階（学習記録に残すため）。
    let character = currentCharacter
    let stage = mode.flatMap(Self.recordStage)
    for effect in effects {
      switch effect {
      case .keepStroke:
        hintStroke = nil
        replay = nil
        strokes.mergeTail(pieces: pendingPieces) { $0.flatMap { $0 } }
        lines.mergeTail(pieces: pendingPieces) { $0.flatMap { $0 } }
        pendingPieces = 0
        // 1画書けたら、ド→レ→ミと高くなる音（§3.9）。
        SoundPlayer.shared.play(.stroke(max(strokes.count - 1, 0)))
      case .rejectStroke(let hint):
        // 続きから書く途中の線も、まとめて消す（D191）。
        strokes.removeTail(pieces: pendingPieces)
        lines.removeTail(pieces: pendingPieces)
        pendingPieces = 0
        hintStroke = hint
      case .keepPartial:
        pendingPieces += 1
      case .dropPartial:
        strokes.removeBeforeLast(pieces: pendingPieces)
        lines.removeBeforeLast(pieces: pendingPieces)
        pendingPieces = 0
      case .replayModel(let stroke):
        replay = ModelReplay(stroke: stroke, start: Date())
        replayTask?.cancel()
        replayTask = Task { [weak self] in
          try? await Task.sleep(for: .seconds(ModelReplay.duration + 0.3))
          guard !Task.isCancelled else { return }
          self?.replay = nil
        }
      case .showModelAndRetryFaint(let result):
        missResult = result
        record(character, stage: .jibunde, passed: false, rescued: false, issues: result.issues)
        strokes = []
        lines = []
        pendingPieces = 0
      case .characterDone(_, _, let rating, let rescued):
        // 書けなかった字は、ほめない（D191）。
        if !rescued { showPraise(rating) }
        replay = nil
        if let stage {
          record(character, stage: stage, passed: !rescued, rescued: rescued, issues: [])
        }
        writtenCharacters.append(strokes)
        strokes = []
        lines = []
        pendingPieces = 0
        hintStroke = nil
      case .nextCharacter:
        missResult = nil
      case .wordDone:
        wordDone = true
        praiseTask?.cancel()
        charPraise = nil
        SoundPlayer.shared.play(.praise)
        VoicePlayer.shared.speak(word)
        store.record(WordRecord(date: Date(), word: word))
      }
    }
  }

  /// 字ごとの小さなごほうびを、1秒弱だけ出す（ことばが書けたときは変身に任せる。D43・D152）。
  private func showPraise(_ rating: Rating) {
    charPraise = rating
    praiseTask?.cancel()
    #if DEBUG
      if UserDefaults.standard.bool(forKey: "freezeCelebration") { return }
    #endif
    praiseTask = Task { [weak self] in
      try? await Task.sleep(for: .seconds(0.9))
      guard !Task.isCancelled else { return }
      self?.charPraise = nil
    }
  }

  private static func recordStage(_ step: PracticeStep) -> CharacterRecord.Stage? {
    switch step {
    case .miru: nil
    case .nazoru: .nazoru
    case .usuku: .usuku
    case .jibunde: .jibunde
    }
  }

  /// 学習記録に1行足す（D25・§3.8）。
  private func record(
    _ character: CharacterData?, stage: CharacterRecord.Stage, passed: Bool, rescued: Bool,
    issues: [JudgeIssue]
  ) {
    guard let character else { return }
    store.record(
      CharacterRecord(
        date: Date(), characterID: character.id, stage: stage, passed: passed, rescued: rescued,
        reasons: Array(Set(issues.map(RecordMapping.reason))).sorted { $0.rawValue < $1.rawValue },
        word: word, strokes: RecordMapping.strokes(lines)))
  }

  /// じぶんで の字の書き終わりの合図（D77 の試作）。
  private func scheduleJudge() {
    judgeTask?.cancel()
    guard mode == .jibunde, let signal = flow?.endSignal, !strokes.isEmpty else { return }
    judgeTask = Task { [weak self] in
      // 書き終わりの合図（D77）: すべての画に当てはまったら1秒で判定、
      // 足りなければ3秒で「できた！」を光らせ、3画以上多ければすぐ光らせる。
      switch signal {
      case .highlightNow:
        self?.highlightsDone = true
      case .judgeAfterPause:
        try? await Task.sleep(for: .seconds(1))
        guard !Task.isCancelled else { return }
        self?.judgeNow()
      case .highlightAfterPause:
        try? await Task.sleep(for: .seconds(3))
        guard !Task.isCancelled else { return }
        self?.highlightsDone = true
      }
    }
  }

  #if DEBUG
    /// 確かめ用: お手本どおりに全部の字を書いたことにする（`-simulateWord YES`）。
    func simulateWriting() {
      var guardCount = 0
      var colorIndex = 0
      let switching = UserDefaults.standard.bool(forKey: "penSwitch")
      let stopping = UserDefaults.standard.bool(forKey: "penSwitchStop")
      while let flow, !flow.finished, let character = flow.current, guardCount < 50 {
        guardCount += 1
        for (number, stroke) in character.strokes.enumerated() {
          // `-penSwitch YES` で、1画ごとにペンの色を変える（色が線ごとに残る確かめ用。D88）。
          // `-penSwitchStop YES` は、最後の字の最後の画の手前で止める。
          if switching {
            if stopping, flow.index == word.count - 1, number == character.strokes.count - 1 {
              return
            }
            store.setPenColor(PenColor.allCases[colorIndex % PenColor.allCases.count])
            colorIndex += 1
          }
          let line = stroke.centerlinePoints()
          strokes.append(recorder.drawn(line))
          lines.append(line)
          apply(self.flow?.handle(.strokeEnded(line)) ?? [])
        }
        if self.flow?.mode == .jibunde { apply(self.flow?.handle(.doneWriting) ?? []) }
      }
    }
  #endif
}
