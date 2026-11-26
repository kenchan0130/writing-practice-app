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

  /// まちに置く（D53 の「動きまわる」型の試作）。
  func placeInTown() {
    // 空のことばは まちに置かない。書いた記録（WordRecord）から、まちの空が しばらく変わる（D172）。
    guard kind != .sky else { return }
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
    }
    guard let finished = recorder.handle(event, convert: convert) else { return }
    strokes.append(finished.drawn)
    lines.append(finished.line)
    apply(flow?.handle(.strokeEnded(finished.line)) ?? [])
    scheduleJudge()
  }

  private func apply(_ effects: [WordEffect]) {
    // 字が進む前の字と段階（学習記録に残すため）。
    let character = currentCharacter
    let stage = mode.flatMap(Self.recordStage)
    for effect in effects {
      switch effect {
      case .keepStroke:
        hintStroke = nil
        // 1画書けたら、ド→レ→ミと高くなる音（§3.9）。
        SoundPlayer.shared.play(.stroke(max(strokes.count - 1, 0)))
      case .rejectStroke(let hint):
        if !strokes.isEmpty { strokes.removeLast() }
        if !lines.isEmpty { lines.removeLast() }
        hintStroke = hint
      case .showModelAndRetryFaint(let result):
        missResult = result
        record(character, stage: .jibunde, passed: false, rescued: false, issues: result.issues)
        strokes = []
        lines = []
      case .characterDone(_, _, let rating, let rescued):
        showPraise(rating)
        if let stage {
          record(character, stage: stage, passed: !rescued, rescued: rescued, issues: [])
        }
        writtenCharacters.append(strokes)
        strokes = []
        lines = []
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
