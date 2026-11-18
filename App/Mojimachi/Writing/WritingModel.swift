import ContentModel
import EntitlementKit
import Foundation
import JudgeKit
import Observation
import PracticeKit
import QuartzCore
import RecordKit
import StrokeKit

/// 画面に描く1点（書く場所の座標、ポイント）。
struct DrawnPoint {
  var location: CGPoint
  var width: Double
  /// 書いたときのペンの色。あとで色を変えても、この線は変わらない（D88）。
  var color: PenColor = ProgressStore.shared.penColor
}

/// 書く画面の仮のモデル（M0 前半）。4ステップの流れは PracticeKit に任せる（D105）。
/// 画面と流れの状態は、あとで TCA に移す（D105）。
@Observable
final class WritingModel {
  /// 書き終えた画（表示用）。
  private(set) var strokes: [[DrawnPoint]] = []
  /// 入力を、画面に描く線と記録の線に直す。
  private(set) var recorder = StrokeRecorder()
  /// 書いている間と直後は「←」を効かせない（D101）。
  let activity: WritingActivity
  var side: Double {
    get { recorder.side }
    set { recorder.side = newValue }
  }

  /// 練習している字（D78 の M0 の字を順に）。
  private(set) var character: CharacterData?
  private var characterIndex = 0
  /// 順に練習する字（試作では M0 の字。文字の地図から入ったときは、その文字の表の順）。
  private var sequence = PackLibrary.m0Characters
  private(set) var script = KanaScript.hiragana
  /// 1文字の練習の流れ（§3.2）。
  private(set) var flow: PracticeFlow?
  /// ④ の判定の結果（D107）。
  private(set) var result: JudgeResult?
  /// 練習が終わったときのほめ方。
  private(set) var finishedRating: Rating?
  /// 書き始めを光らせる画（②③で違う画を書いたとき。D47）。
  private(set) var hintStroke: Int?
  /// 「できた！」を光らせるか（D77）。
  private(set) var highlightsDone = false
  /// 書いた画ごとの終わり方（D145）。見分けられなかった画は nil。
  private(set) var writtenEndings: [CharacterData.Ending?] = []
  /// 書いた画（マス 0〜1000。学習記録のアルバムと再生に使う。§3.8）。
  private var writtenLines: [Polyline] = []
  /// 直前のステップ（学習記録に、ステップが進んだか戻ったかを残すため）。
  private var lastStep: PracticeStep?
  /// 合格したうえで出す、終わり方のヒント（D145）。
  private(set) var endingHint: EndingHint?
  /// ① の書き順のアニメーションを始めた時刻。
  private(set) var animationStart: Date?
  /// 1字書けたあとのごほうびの演出を出しているか（D152）。
  private(set) var showsCelebration = false
  /// 次の字へ自動で進むまでの秒数（D154）。
  static let autoAdvanceSeconds = 1.5
  private var advanceTask: Task<Void, Never>?
  private var onboardingFinishTask: Task<Void, Never>?
  /// 判定のおまかせ設定（保護者用の画面と共通。D22）。
  var preset: JudgePreset {
    get { store.preset }
    set {
      guard newValue != store.preset else { return }
      store.preset = newValue
      restartCharacter()
    }
  }

  /// ④ に合格した「慣れた字」（試作ではアプリを閉じると消える）。ことばの画面と共通。
  private let store = ProgressStore.shared
  private var judgeTask: Task<Void, Never>?
  private var animationTask: Task<Void, Never>?

  /// ① で1画を描く秒数と、画のあいだの秒数。
  /// 1画のアニメーションの時間（保護者用の画面の「お手本の速さ」で変わる）。
  static var strokeAnimationDuration: Double { 0.9 * ProgressStore.shared.modelSpeed.factor }
  static let strokeAnimationGap = 0.3

  /// はじめての流れの最初の1字（D23・D46）。「みる → なぞる」だけで終え、ごほうびのあとに呼ぶ。
  private let onboardingFinish: (@MainActor () -> Void)?
  var isOnboarding: Bool { onboardingFinish != nil }
  /// はじめての流れで、ごほうびのあと次へ進むまでの秒数。
  static let onboardingAdvanceSeconds = 2.5

  /// `start` を渡すと、その字から始める（文字の地図から。D101）。
  /// `onboardingFinish` を渡すと、その字だけを「みる → なぞる」で練習し、終わったら呼ぶ（D23）。
  init(
    activity: WritingActivity, start: Character? = nil,
    onboardingFinish: (@MainActor () -> Void)? = nil
  ) {
    self.activity = activity
    self.onboardingFinish = onboardingFinish
    if onboardingFinish != nil, let start {
      sequence = [start]
    } else if let start, let startScript = KanaTable.script(of: start) {
      let entitlements = PurchaseStore.shared.entitlements
      script = startScript
      sequence = KanaTable.all(startScript).filter {
        entitlements.canWrite($0, in: startScript.entitlementScript)
      }
      characterIndex = sequence.firstIndex(of: start) ?? 0
    }
    loadCharacter()
  }

  var step: PracticeStep? { flow?.step }

  /// 次の字（鍵のかかった字は飛ばす。D154）。
  func nextCharacter() {
    characterIndex = (characterIndex + 1) % sequence.count
    loadCharacter()
  }

  /// 前の字。
  func previousCharacter() {
    characterIndex = (characterIndex - 1 + sequence.count) % sequence.count
    loadCharacter()
  }

  /// その字へ移る（パネルの行の表から。D154）。鍵のかかった字は移らない。
  func jump(to char: Character) {
    guard let index = sequence.firstIndex(of: char) else { return }
    characterIndex = index
    loadCharacter()
  }

  /// その字に鍵がかかっているか（おためしの字は開いている。D90・D94）。
  func isLocked(_ char: Character) -> Bool {
    !PurchaseStore.shared.entitlements.canWrite(char, in: script.entitlementScript)
  }

  /// いまの字がある行（パネルの小さな表に出す）。
  var currentRow: KanaRow? {
    currentChar.flatMap { KanaTable.row(of: $0, script: script) }
  }

  var currentChar: Character? { character?.char.first }

  /// 前後の字（パネルの矢印に使う。1つしかなければ nil）。
  var hasNeighbors: Bool { sequence.count > 1 }

  /// 画の数と、書けた画の数（画の点に使う。D152）。
  var strokeTotal: Int { character?.strokes.count ?? 0 }
  var strokesDone: Int {
    if finishedRating != nil { return strokeTotal }
    return min(strokes.count, strokeTotal)
  }

  /// パネルのキャラクターが言う短いひとこと（D150）。
  var guidance: String {
    if finishedRating != nil { return "じょうずに かけたね！" }
    if hintStroke != nil { return "ここから かいてみよう" }
    switch step {
    case .miru: return "よく みてね"
    case .nazoru: return "ここから かいてみよう"
    case .usuku: return "おもいだして かいてみよう"
    case .jibunde: return "じぶんで かいてみよう"
    case nil: return "たのしく かこうね！"
    }
  }

  /// 「やりなおす」（どの段階でも。D154）。いまの段階を最初から書き直す。
  /// ④ では「ぜんぶ けす」と同じに、書き終わりの合図の待ちもやり直す。
  func retryStep() {
    guard finishedRating == nil else {
      restartCharacter()
      return
    }
    judgeTask?.cancel()
    animationTask?.cancel()
    animationStart = nil
    highlightsDone = false
    result = nil
    endingHint = nil
    strokes = []
    writtenEndings = []
    writtenLines = []
    hintStroke = nil
    apply(flow?.handle(.restartStep) ?? [])
  }

  /// 自動で次の字へ進むのをやめる（子どもがボタンやごほうびに触ったとき。D154）。
  func cancelAutoAdvance() {
    advanceTask?.cancel()
    advanceTask = nil
    onboardingFinishTask?.cancel()
    onboardingFinishTask = nil
  }

  /// ごほうびの演出を閉じる（自動の移動もやめる）。
  func dismissCelebration() {
    cancelAutoAdvance()
    showsCelebration = false
    finishOnboardingLetter()
  }

  /// はじめての流れ: 最初の1字が終わった。次の画面へ（1回だけ）。
  private func finishOnboardingLetter() {
    guard let finish = onboardingFinish, finishedRating != nil else { return }
    onboardingFinishTask?.cancel()
    onboardingFinishTask = nil
    finish()
  }

  private func scheduleAutoAdvance() {
    cancelAutoAdvance()
    #if DEBUG
      // 確かめ用: `-freezeCelebration YES` で、ごほうびの画面を止めたままにする。
      if UserDefaults.standard.bool(forKey: "freezeCelebration") { return }
    #endif
    if isOnboarding {
      // 最初の1字は、ごほうびを見せたあと次の画面へ（くり返さない）。
      onboardingFinishTask = Task { [weak self] in
        try? await Task.sleep(for: .seconds(Self.onboardingAdvanceSeconds))
        guard !Task.isCancelled else { return }
        self?.finishOnboardingLetter()
      }
      return
    }
    advanceTask = Task { [weak self] in
      try? await Task.sleep(for: .seconds(Self.autoAdvanceSeconds))
      guard !Task.isCancelled, let self else { return }
      self.nextCharacter()
    }
  }

  /// 同じ字を最初からやり直す。
  func restartCharacter() {
    loadCharacter()
  }

  /// 「できた！」（④。D56）。いつでも押せる。
  func judgeNow() {
    judgeTask?.cancel()
    highlightsDone = false
    apply(flow?.handle(.doneWriting) ?? [])
  }

  /// 「ひとつ もどす」（④。D56）。
  func undo() {
    guard step == .jibunde, !strokes.isEmpty else { return }
    strokes.removeLast()
    if !writtenEndings.isEmpty { writtenEndings.removeLast() }
    if !writtenLines.isEmpty { writtenLines.removeLast() }
    apply(flow?.handle(.undo) ?? [])
  }

  /// 「ぜんぶ けす」（④。D56）。
  func clear() {
    guard step == .jibunde else { return }
    strokes = []
    writtenEndings = []
    writtenLines = []
    apply(flow?.handle(.clear) ?? [])
  }

  private func loadCharacter() {
    judgeTask?.cancel()
    animationTask?.cancel()
    cancelAutoAdvance()
    showsCelebration = false
    character = PackLibrary.character(sequence[characterIndex], script: script)
    strokes = []
    writtenEndings = []
    writtenLines = []
    endingHint = nil
    result = nil
    finishedRating = nil
    hintStroke = nil
    highlightsDone = false
    guard let character else {
      flow = nil
      return
    }
    flow = PracticeFlow(
      character: character, preset: preset,
      mastered: !isOnboarding && store.mastered.contains(character.id),
      nazoruOnly: isOnboarding)
    lastStep = flow?.step
    if flow?.step == .miru { startAnimation() }
  }

  /// ① みる: 書き順のアニメーション。終わったら ② に進む。
  private func startAnimation() {
    guard let count = character?.strokes.count else { return }
    animationStart = Date()
    if let char = character?.char { VoicePlayer.shared.speak(char) }
    let total = Double(count) * (Self.strokeAnimationDuration + Self.strokeAnimationGap)
    animationTask = Task { [weak self] in
      try? await Task.sleep(for: .seconds(total))
      guard !Task.isCancelled, let self else { return }
      self.animationStart = nil
      self.apply(self.flow?.handle(.animationFinished) ?? [])
    }
  }

  /// 流れからの指示を画面に映す。
  private func apply(_ effects: [PracticeEffect]) {
    for effect in effects {
      switch effect {
      case .keepStroke:
        hintStroke = nil
        // 1画書けたら、ド→レ→ミと高くなる音（§3.9）。
        SoundPlayer.shared.play(.stroke(max(strokes.count - 1, 0)))
      case .rejectStroke(let hint):
        // 違う画はふわっと消して、書き始めを光らせる（D47）。
        if !strokes.isEmpty { strokes.removeLast() }
        if !writtenEndings.isEmpty { writtenEndings.removeLast() }
        if !writtenLines.isEmpty { writtenLines.removeLast() }
        hintStroke = hint
      case .stepChanged(let step):
        recordStepChange(from: lastStep, to: step)
        lastStep = step
        strokes = []
        writtenEndings = []
        writtenLines = []
        hintStroke = nil
        if step == .miru { startAnimation() }
      case .showResult(let result):
        self.result = result
        if !result.passed { record(stage: .jibunde, passed: false, issues: result.issues) }
      case .finished(let rating, let rescued):
        finishedRating = rating
        showsCelebration = true
        SoundPlayer.shared.play(.praise)
        if let stage = step.flatMap(Self.recordStage) {
          record(stage: stage, passed: !rescued, rescued: rescued, issues: result?.issues ?? [])
        }
        if !rescued, step == .jibunde, let mismatch = endingMismatch() {
          // 終わり方がお手本と違うときは、はなまるにしない（合否は変えない。D145）。
          if rating == .hanamaru { finishedRating = .nijumaru }
          if store.showsEndingHints { endingHint = mismatch }
        }
        // 終わり方のヒントを出すときは、読めるように自動では進まない（D154）。
        if endingHint == nil { scheduleAutoAdvance() }
      }
    }
  }

  #if DEBUG
    /// 確かめ用: お手本の中心線をそのまま書いたことにして、流れを進める（シミュレータでは線を書けないため）。
    /// 起動の引数 `-simulateWriting YES` で最後まで、`-simulateUntil nazoru` などでそのステップまで進める。
    func simulateModelWriting(until target: PracticeStep? = nil) {
      guard let character else { return }
      animationTask?.cancel()
      animationStart = nil
      var guardCount = 0
      while let flow, !flow.finished, flow.step != target, guardCount < 100 {
        guardCount += 1
        if flow.step == .miru {
          apply(self.flow?.handle(.animationFinished) ?? [])
          continue
        }
        for stroke in character.strokes {
          // `-simulateStrokes 2` で、2画まで書いたところで止める（確かめ用）。
          let limit = UserDefaults.standard.integer(forKey: "simulateStrokes")
          if limit > 0, strokes.count >= limit { return }
          let line = stroke.centerlinePoints()
          strokes.append(recorder.drawn(line))
          writtenLines.append(line)
          // `-simulateEndingHint YES` で、どの画も「とめ」で書いたことにする（ヒントの確かめ用）。
          writtenEndings.append(
            UserDefaults.standard.bool(forKey: "simulateEndingHint") ? .tome : nil)
          apply(self.flow?.handle(.strokeEnded(line)) ?? [])
        }
        if self.flow?.step == .jibunde, target != .jibunde {
          apply(self.flow?.handle(.doneWriting) ?? [])
        }
      }
    }
  #endif

  /// 書き終わりの合図（④。D56・D77 の試作）。お手本の画数まで書いて1秒止まったら判定し、
  /// 足りないまま3秒止まったら「できた！」を光らせる。
  private func scheduleJudge() {
    judgeTask?.cancel()
    highlightsDone = false
    guard step == .jibunde, let signal = flow?.endSignal, !strokes.isEmpty else { return }
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

  private static func recordStage(_ step: PracticeStep) -> CharacterRecord.Stage? {
    switch step {
    case .miru: nil
    case .nazoru: .nazoru
    case .usuku: .usuku
    case .jibunde: .jibunde
    }
  }

  /// ステップが進んだら前のステップを合格として、戻ったら書き直しとして残す（§3.8）。
  private func recordStepChange(from old: PracticeStep?, to new: PracticeStep) {
    guard let old, let stage = Self.recordStage(old), old != new else { return }
    let forward = Self.recordStage(new).map { $0 > stage } ?? false
    record(stage: stage, passed: forward, issues: [])
  }

  /// 学習記録に1行足す（D25・D44）。
  private func record(
    stage: CharacterRecord.Stage, passed: Bool, rescued: Bool = false, issues: [JudgeIssue]
  ) {
    guard let character else { return }
    var reasons = issues.map(RecordMapping.reason)
    if passed, endingMismatch() != nil { reasons.append(.ending) }
    store.record(
      CharacterRecord(
        date: Date(), characterID: character.id, stage: stage, passed: passed, rescued: rescued,
        reasons: Array(Set(reasons)).sorted { $0.rawValue < $1.rawValue },
        strokes: RecordMapping.strokes(writtenLines)))
  }

  func handle(_ event: StrokeInputEvent, convert: (CGPoint) -> CGPoint) {
    activity.track(event)
    guard let step, step != .miru, finishedRating == nil else { return }
    if case .began = event {
      judgeTask?.cancel()
      highlightsDone = false
      if result != nil, result?.passed == false {
        // ④ で合わなかったあとに書き始めたら、書き直しとして始める。
        result = nil
        strokes = []
        writtenEndings = []
        writtenLines = []
      }
    }
    guard let finished = recorder.handle(event, convert: convert) else { return }
    strokes.append(finished.drawn)
    writtenEndings.append(EndingAnalysis.classify(finished.line, times: finished.times))
    writtenLines.append(finished.line)
    apply(flow?.handle(.strokeEnded(finished.line)) ?? [])
    scheduleJudge()
  }

  /// ④ で合格したとき、終わり方がお手本と違う最初の画を探す（D145）。
  /// 分けた線・つなげた線は画の対応がずれるので出さない。
  private func endingMismatch() -> EndingHint? {
    guard let character, result?.splitOrJoined != true else { return nil }
    let model = character.strokes.map(\.end)
    guard let index = EndingAnalysis.hintStroke(model: model, written: writtenEndings),
      let expected = model[index]
    else { return nil }
    return EndingHint(stroke: index, expected: expected)
  }
}

/// 終わり方のヒント（D145）。
struct EndingHint: Equatable {
  var stroke: Int
  var expected: CharacterData.Ending

  /// 子どもに見せることば（ひらがな。§3.2）。
  var message: String {
    switch expected {
    case .tome: "ここは ぴたっと とめると きれいだよ"
    case .hane: "ここは ぴょんと はねると きれいだよ"
    case .harai: "ここは すーっと はらうと きれいだよ"
    }
  }
}
