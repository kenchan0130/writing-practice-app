import ContentModel
import JudgeKit
import PracticeKit
import QuartzCore
import SwiftUI

/// 書く画面（M0 前半の試作。D109）。4ステップ（みる・なぞる・うすく・じぶんで）で練習する（§3.2）。
struct WritingCanvasView: View {
  @State private var model: WritingModel
  @State private var showsLatency = false

  init(activity: WritingActivity = WritingActivity()) {
    _model = State(initialValue: WritingModel(activity: activity))
  }

  var body: some View {
    VStack(spacing: 24) {
      header
      GeometryReader { proxy in
        let side =
          min(proxy.size.width, proxy.size.height) * (ProgressStore.shared.largeGrid ? 1 : 0.85)
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
      HStack(spacing: 32) {
        if model.finishedRating != nil {
          ToolButton(title: "もういちど", systemImage: "arrow.counterclockwise") {
            model.restartCharacter()
          }
          ToolButton(title: "つぎの もじ", systemImage: "arrow.right.circle.fill") {
            model.nextCharacter()
          }
        } else if model.step == .jibunde {
          // ④ だけに置く（②③は違う画が消えるので置かない。D56）。
          ToolButton(title: "ひとつ もどす", systemImage: "arrow.uturn.backward") { model.undo() }
          ToolButton(title: "ぜんぶ けす", systemImage: "trash") { model.clear() }
          ToolButton(
            title: "できた！", systemImage: "checkmark.circle.fill",
            highlighted: model.highlightsDone
          ) { model.judgeNow() }
        }
      }
      .frame(minHeight: 120)
      #if DEBUG
        HStack(spacing: 24) {
          Picker("判定", selection: $model.preset) {
            Text("はじめて").tag(JudgePreset.hajimete)
            Text("なれてきた").tag(JudgePreset.naretekita)
            Text("しっかり").tag(JudgePreset.shikkari)
            Text("きっちり").tag(JudgePreset.kicchiri)
          }
          .pickerStyle(.segmented)
          .fixedSize()
          Button("つぎの もじ") { model.nextCharacter() }
          Text(model.step.map(stepName) ?? "").foregroundStyle(.secondary)
          Toggle("遅れの目安", isOn: $showsLatency).fixedSize()
        }
      #endif
    }
    .padding(32)
    .defersSystemGestures(on: .all)
    .overlay(alignment: penStandAlignment()) { PenStandButton().padding(24) }
    .overlay(alignment: .top) { CaptionBubble().padding(.top, 12) }
  }

  /// 練習している字と、判定の結果。
  private var header: some View {
    HStack(spacing: 24) {
      Text(model.character?.char ?? "")
        .font(.system(size: 56, weight: .bold))
      Spacer()
      if let hint = model.endingHint {
        Label(hint.message, systemImage: "lightbulb.fill")
          .font(.title3.bold())
          .foregroundStyle(.orange)
      }
      if let rating = model.finishedRating {
        RatingBadge(rating: rating)
      } else if let result = model.result {
        ResultBadge(result: result)
      }
    }
    .frame(height: 80)
  }

  private var canvas: some View {
    TimelineView(.animation(paused: model.step != .miru && model.hintStroke == nil)) { timeline in
      Canvas { context, size in
        CanvasDrawing.guide(in: &context, size: size)
        if let character = model.character {
          drawStep(character, in: &context, size: size, now: timeline.date)
        }
        drawWriting(in: &context, size: size)
      }
    }
    .background(Color(red: 0.98, green: 0.96, blue: 0.92))
    .clipShape(RoundedRectangle(cornerRadius: 12))
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
      drawStartMarker(character, in: &context, scale: scale, now: now)
    case .usuku:
      // ③ うすく: お手本を点線だけで。
      context.stroke(
        CanvasDrawing.outline(character.strokes, scale: scale), with: .color(.gray.opacity(0.5)),
        style: StrokeStyle(lineWidth: 2, dash: [6, 6]))
      if model.hintStroke != nil {
        drawStartMarker(character, in: &context, scale: scale, now: now)
      }
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

  /// 次に書く画の書き始めの印。違う画を書いたあとは、光らせる（D47）。
  private func drawStartMarker(
    _ character: CharacterData, in context: inout GraphicsContext, scale: Double, now: Date
  ) {
    guard let flow = model.flow, flow.expectedStroke < character.strokes.count else { return }
    let pulse = model.hintStroke == nil ? 0 : (sin(now.timeIntervalSinceReferenceDate * 6) + 1) * 6
    CanvasDrawing.startMarker(
      for: character.strokes[flow.expectedStroke], in: &context, scale: scale, pulse: pulse)
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

/// 子どもが押すボタン。押せる部分は 2cm 角（約104ポイント）以上（D101）。
private struct ToolButton: View {
  var title: String
  var systemImage: String
  var highlighted = false
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 8) {
        Image(systemName: systemImage).font(.system(size: 36, weight: .bold))
        Text(title).font(.headline)
      }
      .frame(minWidth: 120, minHeight: 120)
    }
    .buttonStyle(.bordered)
    .buttonBorderShape(.roundedRectangle(radius: 24))
    .tint(highlighted ? .orange : .accentColor)
    .scaleEffect(highlighted ? 1.08 : 1)
    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: highlighted)
  }
}

/// 練習が終わったときのほめ方（試作。演出は M0 で作り込む。§3.3）。
private struct RatingBadge: View {
  var rating: Rating

  var body: some View {
    Text(title)
      .font(.system(size: 40, weight: .heavy))
      .foregroundStyle(rating == .hanamaru ? .pink : rating == .nijumaru ? .orange : .green)
  }

  private var title: String {
    switch rating {
    case .hanamaru: "はなまる！"
    case .nijumaru: "にじゅうまる！"
    case .maru: "まる！"
    }
  }
}

/// 判定の結果（試作。ほめる演出は M0 で作り込む）。バツ印は使わない（§3.2）。
private struct ResultBadge: View {
  var result: JudgeResult

  var body: some View {
    VStack(alignment: .trailing, spacing: 4) {
      Text(title).font(.system(size: 40, weight: .heavy)).foregroundStyle(color)
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
