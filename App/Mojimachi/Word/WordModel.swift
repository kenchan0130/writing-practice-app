import ContentModel
import Foundation
import JudgeKit
import Observation
import PracticeKit
import RecordKit

/// ことばを書く画面のモデル（試作。D46・D55・D56）。流れは PracticeKit の WordFlow に任せる。
@Observable
final class WordModel {
  private(set) var wordIndex = 0
  private(set) var flow: WordFlow?
  /// いまの字の書いた線（表示用）。
  private(set) var strokes: [[DrawnPoint]] = []
  /// 書き終えた字の線（変身に使う。字ごと、書く場所の座標）。
  private(set) var writtenCharacters: [[[DrawnPoint]]] = []
  private(set) var recorder = StrokeRecorder()
  private(set) var hintStroke: Int?
  /// じぶんで で合わなかったときに出す結果（お手本を重ねて見せる。D56）。
  private(set) var missResult: JudgeResult?
  /// ことばが書けた（変身を見せる）。
  private(set) var wordDone = false
  private(set) var highlightsDone = false

  private let store = ProgressStore.shared
  /// いまの字の書いた線（マス 0〜1000。学習記録に残す）。
  private var lines: [Polyline] = []
  private var judgeTask: Task<Void, Never>?

  var side: Double {
    get { recorder.side }
    set { recorder.side = newValue }
  }

  init() {
    loadWord()
  }

  var word: String { PlaceholderArt.vehicleWords[wordIndex].word }
  var symbol: String { PlaceholderArt.vehicleWords[wordIndex].symbol }
  var currentCharacter: CharacterData? { flow?.current }
  var mode: PracticeStep? { flow?.mode }
  var progress: Double { flow?.progress ?? 0 }

  func nextWord() {
    wordIndex = (wordIndex + 1) % PlaceholderArt.vehicleWords.count
    loadWord()
  }

  func restartWord() { loadWord() }

  /// まちに置く（D53 の「動きまわる」型の試作）。
  func placeInTown() {
    store.place(PlacedObject(word: word, symbol: symbol))
  }

  /// 「できた！」（じぶんで の字。D56）。
  func judgeNow() {
    judgeTask?.cancel()
    highlightsDone = false
    apply(flow?.handle(.doneWriting) ?? [])
  }

  private func loadWord() {
    judgeTask?.cancel()
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
      case .characterDone(_, _, _, let rescued):
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
        SoundPlayer.shared.play(.praise)
        VoicePlayer.shared.speak(word)
        store.record(WordRecord(date: Date(), word: word))
      }
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
