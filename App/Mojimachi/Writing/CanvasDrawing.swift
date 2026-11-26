import ContentModel
import JudgeKit
import SwiftUI

/// 書く場所に描くものの共通の部品（マス、お手本、書いた線）。
enum CanvasDrawing {
  /// いまの子のペンの色（D88）。
  static var inkColor: Color { ProgressStore.shared.penColor.color }

  /// マスと十字の補助線（十字だけ。罫線は引かない。D152）。
  /// `letterLines`（マス 0〜1000 の高さ4つ）を渡すと、十字の代わりに英語の4本の線を引く（D180）。
  /// 基本の線（下から2本目）だけ、濃い実線にする。
  static func guide(
    in context: inout GraphicsContext, size: CGSize, letterLines: [Double]? = nil
  ) {
    if let letterLines {
      let scale = size.height / 1000
      for (index, y) in letterLines.enumerated() {
        var line = Path()
        line.move(to: CGPoint(x: 0, y: y * scale))
        line.addLine(to: CGPoint(x: size.width, y: y * scale))
        let isBase = index == 2
        context.stroke(
          line, with: .color(isBase ? Theme.pink.opacity(0.6) : Theme.accent.opacity(0.4)),
          style: isBase
            ? StrokeStyle(lineWidth: 3) : StrokeStyle(lineWidth: 2, dash: [10, 8]))
      }
    } else {
      var cross = Path()
      cross.move(to: CGPoint(x: size.width / 2, y: 0))
      cross.addLine(to: CGPoint(x: size.width / 2, y: size.height))
      cross.move(to: CGPoint(x: 0, y: size.height / 2))
      cross.addLine(to: CGPoint(x: size.width, y: size.height / 2))
      context.stroke(
        cross, with: .color(Theme.accent.opacity(0.4)),
        style: StrokeStyle(lineWidth: 2, dash: [10, 8]))
    }
    context.stroke(
      Path(CGRect(origin: .zero, size: size)), with: .color(Theme.accent.opacity(0.7)),
      lineWidth: 4)
  }

  /// お手本の字（かなは Klee One の形の輪郭、アルファベットと数字は中心線を太らせた輪郭。D55・D106・D180）。
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

  /// 次に書く画の書き始めの印（ピンクの丸に何画目かの番号。D152）と、向きを示す矢印（②。D47）。
  /// `pulse` で光らせる。`number` は 1 から。
  static func startMarker(
    for stroke: CharacterData.Stroke, number: Int, in context: inout GraphicsContext,
    scale: Double, pulse: Double
  ) {
    let points = stroke.centerlinePoints()
    guard let start = points.first else { return }
    let pink = Theme.pink
    if points.count > 6 {
      var arrow = Path()
      arrow.addLines(points.prefix(7).map { CGPoint(x: $0.x * scale, y: $0.y * scale) })
      context.stroke(
        arrow, with: .color(pink.opacity(0.75)),
        style: StrokeStyle(lineWidth: 6, lineCap: .round, dash: [2, 8]))
    }
    // 丸の大きさは画面の大きさ（ポイント）で決める。
    let center = CGPoint(x: start.x * scale, y: start.y * scale)
    let radius = 24 + pulse
    context.fill(
      Path(
        ellipseIn: CGRect(
          x: center.x - radius - 4, y: center.y - radius - 4, width: (radius + 4) * 2,
          height: (radius + 4) * 2)), with: .color(.white.opacity(0.9)))
    context.fill(
      Path(
        ellipseIn: CGRect(
          x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)),
      with: .color(pink))
    context.draw(
      Text("\(number)").font(.ui(26, bold: true)).foregroundStyle(.white), at: center)
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
