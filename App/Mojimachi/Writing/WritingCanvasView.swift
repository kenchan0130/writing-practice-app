import ContentModel
import JudgeKit
import QuartzCore
import SwiftUI

/// 書く画面（M0 前半の試作。D109）。お手本を薄く出し、書き終わったら判定する（D107）。
struct WritingCanvasView: View {
  @State private var model = WritingModel()
  @State private var showsLatency = false

  var body: some View {
    VStack(spacing: 24) {
      header
      GeometryReader { proxy in
        let side = min(proxy.size.width, proxy.size.height)
        canvas
          .frame(width: side, height: side)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .onAppear {
            model.side = side
            #if DEBUG
              if UserDefaults.standard.bool(forKey: "simulateWriting") {
                model.simulateModelWriting()
              }
            #endif
          }
          .onChange(of: side) { _, newValue in model.side = newValue }
      }
      HStack(spacing: 32) {
        ToolButton(title: "ひとつ もどす", systemImage: "arrow.uturn.backward") { model.undo() }
        ToolButton(title: "ぜんぶ けす", systemImage: "trash") { model.clear() }
        ToolButton(
          title: "できた！", systemImage: "checkmark.circle.fill", highlighted: model.highlightsDone
        ) { model.judgeNow() }
      }
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
          Toggle("遅れの目安", isOn: $showsLatency).fixedSize()
        }
      #endif
    }
    .padding(32)
    .defersSystemGestures(on: .all)
  }

  /// 練習している字と、判定の結果。
  private var header: some View {
    HStack(spacing: 24) {
      Text(model.character?.char ?? "")
        .font(.system(size: 56, weight: .bold))
      Spacer()
      if let result = model.result {
        ResultBadge(result: result)
      }
    }
    .frame(height: 80)
  }

  private var canvas: some View {
    Canvas { context, size in
      drawGuide(in: &context, size: size)
      if let character = model.character {
        drawModel(character, in: &context, size: size)
      }
      for stroke in model.strokes { draw(stroke, in: &context) }
      draw(model.current, in: &context)
      if let last = model.current.last {
        draw([last] + model.predicted, in: &context, opacity: 0.5)
      }
      if showsLatency, model.lastInputTime > 0 {
        let delay = (CACurrentMediaTime() - model.lastInputTime) * 1000
        context.draw(
          Text(String(format: "入力から描画まで %.1f ms", delay)).font(.caption).foregroundStyle(.gray),
          at: CGPoint(x: size.width - 110, y: 16))
      }
    }
    .background(Color(red: 0.98, green: 0.96, blue: 0.92))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .gesture(StrokeInputGesture { event, convert in model.handle(event, convert: convert) })
    .accessibilityLabel("もじを かく ばしょ")
  }

  /// お手本の字（Klee One の形の輪郭）を薄く描く（③うすく。D55・D106）。
  private func drawModel(
    _ character: CharacterData, in context: inout GraphicsContext, size: CGSize
  ) {
    let scale = size.width / 1000
    var path = Path()
    for stroke in character.strokes {
      for sub in stroke.outline ?? [] where sub.start.count == 2 {
        path.move(to: CGPoint(x: sub.start[0] * scale, y: sub.start[1] * scale))
        for s in sub.segments where s.count == 6 {
          path.addCurve(
            to: CGPoint(x: s[4] * scale, y: s[5] * scale),
            control1: CGPoint(x: s[0] * scale, y: s[1] * scale),
            control2: CGPoint(x: s[2] * scale, y: s[3] * scale))
        }
        path.closeSubpath()
      }
    }
    context.fill(path, with: .color(.gray.opacity(0.25)))
  }

  /// マスと十字の補助線。
  private func drawGuide(in context: inout GraphicsContext, size: CGSize) {
    var cross = Path()
    cross.move(to: CGPoint(x: size.width / 2, y: 0))
    cross.addLine(to: CGPoint(x: size.width / 2, y: size.height))
    cross.move(to: CGPoint(x: 0, y: size.height / 2))
    cross.addLine(to: CGPoint(x: size.width, y: size.height / 2))
    context.stroke(
      cross, with: .color(.orange.opacity(0.35)), style: StrokeStyle(lineWidth: 2, dash: [10, 8]))
    context.stroke(
      Path(CGRect(origin: .zero, size: size)), with: .color(.orange.opacity(0.6)), lineWidth: 4)
  }

  /// 太さが変わる線を、点どうしをつなぐ短い線で描く。
  private func draw(_ points: [DrawnPoint], in context: inout GraphicsContext, opacity: Double = 1)
  {
    let color = Color(red: 0.17, green: 0.3, blue: 0.6).opacity(opacity)
    if points.count == 1, let point = points.first {
      let r = point.width / 2
      context.fill(
        Path(
          ellipseIn: CGRect(
            x: point.location.x - r, y: point.location.y - r, width: r * 2, height: r * 2)),
        with: .color(color))
      return
    }
    for (a, b) in zip(points, points.dropFirst()) {
      var segment = Path()
      segment.move(to: a.location)
      segment.addLine(to: b.location)
      context.stroke(
        segment, with: .color(color),
        style: StrokeStyle(lineWidth: (a.width + b.width) / 2, lineCap: .round, lineJoin: .round))
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
    }
  }
}

#Preview {
  WritingCanvasView()
}
