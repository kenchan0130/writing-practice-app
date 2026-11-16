import ContentModel
import JudgeKit
import SwiftUI

/// 書く場所に描くものの共通の部品（マス、お手本、書いた線）。
enum CanvasDrawing {
  /// いまの子のペンの色（D88）。
  static var inkColor: Color { ProgressStore.shared.penColor.color }

  /// マスと十字の補助線。
  static func guide(in context: inout GraphicsContext, size: CGSize) {
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

  /// お手本の字（Klee One の形の輪郭。D55・D106）。
  static func outline(_ strokes: [CharacterData.Stroke], scale: Double) -> Path {
    var path = Path()
    for stroke in strokes {
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
    return path
  }

  static func dot(at p: JudgeKit.Point, scale: Double, radius: Double) -> Path {
    Path(
      ellipseIn: CGRect(
        x: p.x * scale - radius, y: p.y * scale - radius, width: radius * 2, height: radius * 2))
  }

  /// 次に書く画の書き始めの印と、向きを示す矢印（②。D47）。`pulse` で光らせる。
  static func startMarker(
    for stroke: CharacterData.Stroke, in context: inout GraphicsContext, scale: Double,
    pulse: Double
  ) {
    let points = stroke.centerlinePoints()
    guard let start = points.first else { return }
    context.fill(dot(at: start, scale: scale, radius: 14 + pulse), with: .color(.green))
    if points.count > 6 {
      var arrow = Path()
      arrow.addLines(points.prefix(7).map { CGPoint(x: $0.x * scale, y: $0.y * scale) })
      context.stroke(
        arrow, with: .color(.green.opacity(0.8)),
        style: StrokeStyle(lineWidth: 6, lineCap: .round, dash: [2, 8]))
    }
  }

  /// 太さが変わる線を、点どうしをつなぐ短い線で描く。
  static func ink(
    _ points: [DrawnPoint], in context: inout GraphicsContext, color: Color? = nil,
    opacity: Double = 1
  ) {
    // 色は、書いたときに線へ付けた色（D88）。
    let color = (color ?? points.first?.color.color ?? inkColor).opacity(opacity)
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
