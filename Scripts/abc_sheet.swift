// アルファベットと数字のお手本を、1枚の絵に並べる（人が形と書き順を確かめるため。D180）。Mac だけ。
// 使い方: swift Scripts/abc_sheet.swift Content/Packs/abc <出力.png>
// 灰色がお手本の輪郭、赤い線が中心線、丸の数字が書き始めと書き順。青い線は4本の線（数字は上下の線）。
import AppKit
import Foundation

let args = CommandLine.arguments
guard args.count == 3 else {
  print("使い方: swift Scripts/abc_sheet.swift Content/Packs/abc <出力.png>")
  exit(2)
}
let chars =
  (0x41...0x5A).map { $0 } + (0x61...0x7A).map { $0 } + (0x30...0x39).map { $0 }
let columns = 9
let cell = 220.0
let rows = Int((Double(chars.count) / Double(columns)).rounded(.up))
let size = NSSize(width: cell * Double(columns), height: cell * Double(rows))
let image = NSImage(size: size)
image.lockFocusFlipped(true)
NSColor.white.setFill()
NSRect(origin: .zero, size: size).fill()

func path(start: [Double], segments: [[Double]], scale: Double, origin: NSPoint) -> NSBezierPath {
  let p = NSBezierPath()
  func pt(_ x: Double, _ y: Double) -> NSPoint { NSPoint(x: origin.x + x * scale, y: origin.y + y * scale) }
  p.move(to: pt(start[0], start[1]))
  for s in segments {
    p.curve(to: pt(s[4], s[5]), controlPoint1: pt(s[0], s[1]), controlPoint2: pt(s[2], s[3]))
  }
  return p
}

for (index, code) in chars.enumerated() {
  let url = URL(fileURLWithPath: args[1]).appendingPathComponent("abc.\(String(code, radix: 16)).json")
  guard let data = try? Data(contentsOf: url),
    let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
    let strokes = object["strokes"] as? [[String: Any]]
  else { continue }
  let origin = NSPoint(x: Double(index % columns) * cell + 10, y: Double(index / columns) * cell + 10)
  let scale = (cell - 20) / 1000
  NSColor(white: 0.85, alpha: 1).setStroke()
  NSBezierPath(rect: NSRect(x: origin.x, y: origin.y, width: cell - 20, height: cell - 20)).stroke()
  let isDigit = (0x30...0x39).contains(code)
  NSColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 0.6).setStroke()
  for y in isDigit ? [140.0, 860] : [70.0, 340, 660, 930] {
    let guide = NSBezierPath()
    guide.move(to: NSPoint(x: origin.x, y: origin.y + y * scale))
    guide.line(to: NSPoint(x: origin.x + cell - 20, y: origin.y + y * scale))
    guide.stroke()
  }
  // アプリと同じように、すべての輪郭を1つの形にまとめて塗る（丸の中は抜ける）。
  NSColor(white: 0.45, alpha: 1).setFill()
  let whole = NSBezierPath()
  for stroke in strokes {
    for sub in stroke["outline"] as? [[String: Any]] ?? [] {
      let p = path(
        start: sub["start"] as! [Double], segments: sub["segments"] as! [[Double]], scale: scale,
        origin: origin)
      p.close()
      whole.append(p)
    }
  }
  whole.fill()
  for (number, stroke) in strokes.enumerated() {
    let start = stroke["start"] as! [Double]
    let p = path(start: start, segments: stroke["segments"] as! [[Double]], scale: scale, origin: origin)
    NSColor.systemRed.setStroke()
    p.lineWidth = 1.5
    p.stroke()
    let center = NSPoint(x: origin.x + start[0] * scale, y: origin.y + start[1] * scale)
    NSColor.systemPink.setFill()
    NSBezierPath(ovalIn: NSRect(x: center.x - 8, y: center.y - 8, width: 16, height: 16)).fill()
    let text = NSAttributedString(
      string: "\(number + 1)",
      attributes: [.font: NSFont.boldSystemFont(ofSize: 11), .foregroundColor: NSColor.white])
    text.draw(at: NSPoint(x: center.x - 3.5, y: center.y - 7))
  }
}
image.unlockFocus()
guard let tiff = image.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff),
  let png = rep.representation(using: .png, properties: [:])
else { exit(1) }
try png.write(to: URL(fileURLWithPath: args[2]))
