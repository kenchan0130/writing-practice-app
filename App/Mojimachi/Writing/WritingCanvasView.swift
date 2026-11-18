import ContentModel
import EntitlementKit
import JudgeKit
import PracticeKit
import QuartzCore
import SwiftUI

/// 書く画面（M0 前半の試作。D109）。4ステップ（みる・なぞる・うすく・じぶんで）で練習する（§3.2）。
struct WritingCanvasView: View {
  @State private var model: WritingModel
  @State private var showsLatency = false
  /// 鍵のかかった字を押した（鍵の画面へ。D160）。
  private var onLocked: (Script) -> Void

  /// `onboardingFinish` を渡すと、はじめての流れの最初の1字になる（パネルなし。みる → なぞる だけ。D23・D46）。
  init(
    activity: WritingActivity = WritingActivity(), start: Character? = nil,
    onboardingFinish: (@MainActor () -> Void)? = nil,
    onLocked: @escaping (Script) -> Void = { _ in }
  ) {
    self.onLocked = onLocked
    _model = State(
      initialValue: WritingModel(
        activity: activity, start: start, onboardingFinish: onboardingFinish))
  }

  var body: some View {
    GeometryReader { outer in
      let landscape = outer.size.width > outer.size.height
      Group {
        if landscape {
          // 横向き: 書く手と反対の側にパネル（右利きなら左）。D154。
          HStack(alignment: .top, spacing: 24) {
            if panelOnLeft, !model.isOnboarding { sidePanel(vertical: true) }
            mainColumn(landscape: true)
            // 横向きは、ボタンを書く場所の横に縦に並べて、書く場所を広く残す。
            toolBar(vertical: true)
            if !panelOnLeft, !model.isOnboarding { sidePanel(vertical: true) }
          }
        } else {
          // 縦向き: 横に置くと書く場所が狭くなるので、上に置く。
          VStack(spacing: 12) {
            if !model.isOnboarding { sidePanel(vertical: false) }
            mainColumn(landscape: false)
          }
        }
      }
      .padding(.horizontal, 32)
      .padding(.bottom, 24)
      .padding(.top, 8)
    }
    .defersSystemGestures(on: .all)
    .overlay(alignment: penStandAlignment()) { PenStandButton().padding(24) }
    .overlay(alignment: .top) { CaptionBubble().padding(.top, 12) }
    .overlay {
      if model.showsCelebration, let rating = model.finishedRating, let char = model.currentChar {
        CelebrationView(
          rating: rating, char: char, onTap: { model.dismissCelebration() },
          frozenAt: Self.frozenCelebration
        )
        .accessibilityIdentifier("celebration")
      }
    }
    .animation(.easeOut(duration: 0.25), value: model.showsCelebration)
  }

  /// 確かめ用: ごほうびを止めて見せる秒数。
  private static var frozenCelebration: Double? {
    #if DEBUG
      UserDefaults.standard.bool(forKey: "freezeCelebration") ? 0.9 : nil
    #else
      nil
    #endif
  }

  /// パネルは書く手と反対の側に置く（D154）。右利きなら左。
  private var panelOnLeft: Bool {
    ProgressStore.shared.currentProfile?.handedness != .left
  }

  private func sidePanel(vertical: Bool) -> some View {
    WritingPanel(model: model, vertical: vertical) {
      onLocked(model.script.entitlementScript)
    }
  }

  /// 状態の一言・書く場所・画の点・ボタン。
  private func mainColumn(landscape: Bool) -> some View {
    VStack(spacing: 12) {
      statusLine(landscape: landscape)
      GeometryReader { proxy in
        let side =
          min(proxy.size.width, proxy.size.height) * (ProgressStore.shared.largeGrid ? 1 : 0.92)
        canvas
          .frame(width: side, height: side)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .onAppear {
            model.side = side
            #if DEBUG
              if let until = UserDefaults.standard.string(forKey: "simulateUntil") {
                model.simulateModelWriting(until: PracticeStep(rawValue: until))
              } else if UserDefaults.standard.bool(forKey: "simulateWriting") {
                model.simulateModelWriting()
              }
            #endif
          }
          .onChange(of: side) { _, newValue in model.side = newValue }
      }
      StrokeDots(total: model.strokeTotal, done: model.strokesDone)
        .frame(height: 48)
      if !landscape { toolBar(vertical: false) }
      #if DEBUG
        if UserDefaults.standard.bool(forKey: "debugControls") { debugControls }
      #endif
    }
  }

  /// ボタン（どの段階でも「やりなおす」。D154）。
  private func toolBar(vertical: Bool) -> some View {
    let layout =
      vertical ? AnyLayout(VStackLayout(spacing: 16)) : AnyLayout(HStackLayout(spacing: 20))
    return layout {
      if model.isOnboarding {
        // はじめての流れは「やりなおす」だけ（終わったらごほうびのあと自動で次へ）。
        if model.finishedRating == nil {
          ChildToolButton(title: "やりなおす", systemImage: "arrow.counterclockwise") {
            model.retryStep()
          }
        }
      } else if model.finishedRating != nil {
        ChildToolButton(
          title: "もういっこ", systemImage: "arrow.counterclockwise", color: Theme.accent
        ) {
          model.restartCharacter()
        }
        ChildToolButton(
          title: "つぎの もじ", systemImage: "arrow.right.circle.fill", color: Theme.green
        ) {
          model.nextCharacter()
        }
      } else {
        ChildToolButton(title: "やりなおす", systemImage: "arrow.counterclockwise") {
          model.retryStep()
        }
        if model.step == .jibunde {
          // ④ だけに置く（②③は違う画が消えるので置かない。D56）。
          ChildToolButton(title: "ひとつ もどす", systemImage: "arrow.uturn.backward") {
            model.undo()
          }
          ChildToolButton(title: "ぜんぶ けす", systemImage: "trash") { model.clear() }
          ChildToolButton(
            title: "できた！", systemImage: "checkmark.circle.fill", color: Theme.green,
            highlighted: model.highlightsDone
          ) { model.judgeNow() }
        }
      }
    }
    .frame(minHeight: vertical ? nil : 112)
    .frame(maxHeight: vertical ? .infinity : nil)
    // 押したら、次の字へ自動で進むのをやめる（D154）。
    .simultaneousGesture(TapGesture().onEnded { model.cancelAutoAdvance() })
  }

  #if DEBUG
    private var debugControls: some View {
      HStack(spacing: 24) {
        Picker("判定", selection: $model.preset) {
          Text("はじめて").tag(JudgePreset.hajimete)
          Text("なれてきた").tag(JudgePreset.naretekita)
          Text("しっかり").tag(JudgePreset.shikkari)
          Text("きっちり").tag(JudgePreset.kicchiri)
        }
        .pickerStyle(.segmented)
        .fixedSize()
        Text(model.step.map(stepName) ?? "").foregroundStyle(.secondary)
        Toggle("遅れの目安", isOn: $showsLatency).fixedSize()
      }
      // 角のペンたてと重ならないように、両側をあける。
      .padding(.horizontal, 140)
    }
  #endif

  /// 判定の結果や、とめ・はね・はらいのヒント。
  private func statusLine(landscape: Bool) -> some View {
    HStack(spacing: 16) {
      // 縦向きは、キャラクターのひとことをここに出す（パネルを1段にするため）。
      if !landscape, !model.isOnboarding { WritingHelper(model: model, vertical: false) }
      if model.isOnboarding {
        // 案内役のひとこと（はじめての流れ。パネルを出さないかわり）。
        Text(model.guidance)
          .font(.ui(32, bold: true))
          .foregroundStyle(Theme.ink)
          .accessibilityIdentifier("onboardingGuidance")
      }
      Spacer()
      if let hint = model.endingHint {
        Label(hint.message, systemImage: "lightbulb.fill")
          .font(.ui(24, bold: true))
          .foregroundStyle(Theme.accent)
      }
      if model.finishedRating == nil, let result = model.result {
        ResultBadge(result: result)
      }
      Spacer()
    }
    .frame(height: model.isOnboarding ? 64 : landscape ? 44 : 64)
  }

  private var canvas: some View {
    TimelineView(.animation(paused: model.step != .miru && model.hintStroke == nil)) { timeline in
      Canvas { context, size in
        CanvasDrawing.guide(in: &context, size: size)
        if let character = model.character {
          drawStep(character, in: &context, size: size, now: timeline.date)
        }
        drawWriting(in: &context, size: size)
        // 書き始めの印（番号）は、書いた線より上に描く。前の画の線で番号が隠れないように。
        if let character = model.character {
          drawMarker(character, in: &context, size: size, now: timeline.date)
        }
      }
    }
    .background(Theme.paper)
    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.paper))
    .overlay(
      RoundedRectangle(cornerRadius: Theme.Radius.paper).stroke(
        Theme.accent.opacity(0.7), lineWidth: 4)
    )
    .softShadow()
    .gesture(StrokeInputGesture { event, convert in model.handle(event, convert: convert) })
    .accessibilityLabel("もじを かく ばしょ")
  }

  /// 子どもが書いた線。
  private func drawWriting(in context: inout GraphicsContext, size: CGSize) {
    for stroke in model.strokes { CanvasDrawing.ink(stroke, in: &context) }
    CanvasDrawing.ink(model.recorder.current, in: &context)
    if let last = model.recorder.current.last {
      CanvasDrawing.ink([last] + model.recorder.predicted, in: &context, opacity: 0.5)
    }
    if showsLatency, model.recorder.lastInputTime > 0 {
      let delay = (CACurrentMediaTime() - model.recorder.lastInputTime) * 1000
      context.draw(
        Text(String(format: "入力から描画まで %.1f ms", delay)).font(.caption).foregroundStyle(.gray),
        at: CGPoint(x: size.width - 110, y: 16))
    }
  }

  /// ステップごとのお手本（§3.2）。
  private func drawStep(
    _ character: CharacterData, in context: inout GraphicsContext, size: CGSize, now: Date
  ) {
    let scale = size.width / 1000
    switch model.step {
    case .miru:
      // ① みる: お手本を薄く出し、書き順のとおりに1画ずつ線を引いていく。
      context.fill(
        CanvasDrawing.outline(character.strokes, scale: scale), with: .color(.gray.opacity(0.18)))
      let elapsed = model.animationStart.map { now.timeIntervalSince($0) } ?? 0
      let per = WritingModel.strokeAnimationDuration + WritingModel.strokeAnimationGap
      for (i, stroke) in character.strokes.enumerated() {
        let progress = min(
          max((elapsed - Double(i) * per) / WritingModel.strokeAnimationDuration, 0), 1)
        guard progress > 0 else { break }
        let points = stroke.centerlinePoints()
        let shown = points.prefix(max(2, Int(Double(points.count) * progress)))
        var path = Path()
        path.addLines(shown.map { CGPoint(x: $0.x * scale, y: $0.y * scale) })
        context.stroke(
          path, with: .color(Color(red: 0.9, green: 0.35, blue: 0.2)),
          style: StrokeStyle(lineWidth: 18, lineCap: .round, lineJoin: .round))
        if progress < 1, let tip = shown.last {
          context.fill(CanvasDrawing.dot(at: tip, scale: scale, radius: 16), with: .color(.orange))
        }
      }
    case .nazoru:
      // ② なぞる: 太いお手本と、書き始めの印（●）。
      context.fill(
        CanvasDrawing.outline(character.strokes, scale: scale), with: .color(.gray.opacity(0.4)))
    case .usuku:
      // ③ うすく: お手本を点線だけで。
      context.stroke(
        CanvasDrawing.outline(character.strokes, scale: scale), with: .color(.gray.opacity(0.5)),
        style: StrokeStyle(lineWidth: 2, dash: [6, 6]))
    case .jibunde:
      // ④ じぶんで: 何も出さない。判定のあとはお手本を重ねる（§3.2）。
      if model.result != nil {
        context.fill(
          CanvasDrawing.outline(character.strokes, scale: scale), with: .color(.gray.opacity(0.22)))
      }
      // 終わり方のヒント: その画の終わりに印をつける（D145）。
      if let hint = model.endingHint, character.strokes.indices.contains(hint.stroke),
        let end = character.strokes[hint.stroke].centerlinePoints().last
      {
        context.stroke(
          CanvasDrawing.dot(at: end, scale: scale, radius: 28), with: .color(.orange),
          style: StrokeStyle(lineWidth: 5, dash: [6, 5]))
      }
    case nil:
      break
    }
  }

  /// 書き始めの印を出すステップだけ描く（② なぞる はいつも、③ うすく はヒントのときだけ）。
  private func drawMarker(
    _ character: CharacterData, in context: inout GraphicsContext, size: CGSize, now: Date
  ) {
    let scale = size.width / 1000
    switch model.step {
    case .nazoru:
      drawStartMarker(character, in: &context, scale: scale, now: now)
    case .usuku where model.hintStroke != nil:
      drawStartMarker(character, in: &context, scale: scale, now: now)
    default:
      break
    }
  }

  /// 次に書く画の書き始めの印。違う画を書いたあとは、光らせる（D47）。
  private func drawStartMarker(
    _ character: CharacterData, in context: inout GraphicsContext, scale: Double, now: Date
  ) {
    guard let flow = model.flow, flow.expectedStroke < character.strokes.count else { return }
    let pulse = model.hintStroke == nil ? 0 : (sin(now.timeIntervalSinceReferenceDate * 6) + 1) * 6
    CanvasDrawing.startMarker(
      for: character.strokes[flow.expectedStroke], number: flow.expectedStroke + 1, in: &context,
      scale: scale, pulse: pulse)
  }

  private func stepName(_ step: PracticeStep) -> String {
    switch step {
    case .miru: "① みる"
    case .nazoru: "② なぞる"
    case .usuku: "③ うすく"
    case .jibunde: "④ じぶんで"
    }
  }

}

/// 判定の結果（試作。ほめる演出は M0 で作り込む）。バツ印は使わない（§3.2）。
private struct ResultBadge: View {
  var result: JudgeResult

  var body: some View {
    VStack(alignment: .trailing, spacing: 4) {
      Text(title).font(.ui(32, bold: true)).foregroundStyle(color)
      #if DEBUG
        if !result.issues.isEmpty {
          Text(result.issues.map(describe).joined(separator: " / "))
            .font(.caption).foregroundStyle(.secondary)
        }
      #endif
    }
  }

  private var title: String {
    switch result.rating {
    case .hanamaru: "はなまる！"
    case .nijumaru: "にじゅうまる！"
    case .maru: "まる！"
    case nil: "もういちど かいてみよう"
    }
  }

  private var color: Color {
    switch result.rating {
    case .hanamaru: .pink
    case .nijumaru: .orange
    case .maru: .green
    case nil: .blue
    }
  }

  private func describe(_ issue: JudgeIssue) -> String {
    switch issue {
    case .strokeCount(let expected, let actual): "画数 \(actual)/\(expected)"
    case .order(let written, let model): "書き順 \(written + 1)→\(model + 1)"
    case .direction(let model): "\(model + 1)画目の向き"
    case .mirrored: "鏡の字"
    case .shape(let model, let distance): "\(model + 1)画目の形 \(Int(distance))"
    case .deviation(let model, let distance): "\(model + 1)画目のずれ \(Int(distance))"
    }
  }
}

#Preview {
  WritingCanvasView()
}
