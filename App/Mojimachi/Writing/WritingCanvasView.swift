import QuartzCore
import SwiftUI

/// 書く画面（M0 前半の試作。D109）。マスに書くと線が出る。
struct WritingCanvasView: View {
  @State private var model = WritingModel()
  @State private var showsLatency = false

  var body: some View {
    VStack(spacing: 24) {
      GeometryReader { proxy in
        let side = min(proxy.size.width, proxy.size.height)
        canvas
          .frame(width: side, height: side)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .onAppear { model.side = side }
          .onChange(of: side) { _, newValue in model.side = newValue }
      }
      HStack(spacing: 32) {
        ToolButton(title: "ひとつ もどす", systemImage: "arrow.uturn.backward") { model.undo() }
        ToolButton(title: "ぜんぶ けす", systemImage: "trash") { model.clear() }
      }
      #if DEBUG
        Toggle("遅れの目安を表示", isOn: $showsLatency)
          .fixedSize()
      #endif
    }
    .padding(32)
    .defersSystemGestures(on: .all)
  }

  private var canvas: some View {
    Canvas { context, size in
      drawGuide(in: &context, size: size)
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
  }
}

#Preview {
  WritingCanvasView()
}
