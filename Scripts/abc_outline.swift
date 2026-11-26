// 中心線を太らせて、お手本に見せる輪郭にする（D180）。Scripts/make_abc.py から呼ぶ。Mac だけ。
// 入力（標準入力の JSON）: [{ "width": 太さ, "strokes": [{ "start": [x, y], "segments": [[c1x, c1y, c2x, c2y, x, y]] }] }]
// 出力（標準出力の JSON）: 字ごと・画ごとの、閉じた輪郭の並び [[[{ "start": [x, y], "segments": [[...]] }]]]
import CoreGraphics
import Foundation

struct Item: Decodable {
  var width: Double
  var strokes: [Stroke]
}

struct Stroke: Decodable {
  var start: [Double]
  var segments: [[Double]]
}

struct Subpath: Encodable {
  var start: [Int]
  var segments: [[Int]]
}

func outline(of stroke: Stroke, width: Double) -> [Subpath] {
  let start = CGPoint(x: stroke.start[0], y: stroke.start[1])
  var length = 0.0
  var previous = start
  for s in stroke.segments {
    let end = CGPoint(x: s[4], y: s[5])
    length += hypot(end.x - previous.x, end.y - previous.y)
    previous = end
  }
  let shape: CGPath
  if length < 1 {
    // 点（i・j）は丸にする。
    shape = CGPath(
      ellipseIn: CGRect(
        x: start.x - width * 0.6, y: start.y - width * 0.6, width: width * 1.2, height: width * 1.2),
      transform: nil)
  } else {
    let path = CGMutablePath()
    path.move(to: start)
    for s in stroke.segments {
      path.addCurve(
        to: CGPoint(x: s[4], y: s[5]), control1: CGPoint(x: s[0], y: s[1]),
        control2: CGPoint(x: s[2], y: s[3]))
    }
    // 太らせてから、重なりをまとめて1つの外側の線にする（もどり書きや角で線が重なるため）。
    shape = path.copy(strokingWithWidth: width, lineCap: .round, lineJoin: .round, miterLimit: 4)
      .normalized(using: .winding)
  }
  var result: [Subpath] = []
  var current: Subpath?
  var first = CGPoint.zero
  var last = CGPoint.zero
  func r(_ v: CGFloat) -> Int { Int(v.rounded()) }
  func finish() {
    guard var sub = current else { return }
    if r(last.x) != sub.start[0] || r(last.y) != sub.start[1] {
      sub.segments.append(line(from: last, to: first))
    }
    // とても小さいかけらは捨てる。
    let xs = sub.segments.map { $0[4] } + [sub.start[0]]
    let ys = sub.segments.map { $0[5] } + [sub.start[1]]
    if (xs.max()! - xs.min()!) > 3 || (ys.max()! - ys.min()!) > 3 { result.append(sub) }
    current = nil
  }
  func line(from a: CGPoint, to b: CGPoint) -> [Int] {
    [
      r(a.x + (b.x - a.x) / 3), r(a.y + (b.y - a.y) / 3), r(a.x + (b.x - a.x) * 2 / 3),
      r(a.y + (b.y - a.y) * 2 / 3), r(b.x), r(b.y),
    ]
  }
  shape.applyWithBlock { pointer in
    let element = pointer.pointee
    let p = element.points
    switch element.type {
    case .moveToPoint:
      finish()
      first = p[0]
      last = p[0]
      current = Subpath(start: [r(p[0].x), r(p[0].y)], segments: [])
    case .addLineToPoint:
      current?.segments.append(line(from: last, to: p[0]))
      last = p[0]
    case .addQuadCurveToPoint:
      let c1 = CGPoint(x: last.x + (p[0].x - last.x) * 2 / 3, y: last.y + (p[0].y - last.y) * 2 / 3)
      let c2 = CGPoint(x: p[1].x + (p[0].x - p[1].x) * 2 / 3, y: p[1].y + (p[0].y - p[1].y) * 2 / 3)
      current?.segments.append([r(c1.x), r(c1.y), r(c2.x), r(c2.y), r(p[1].x), r(p[1].y)])
      last = p[1]
    case .addCurveToPoint:
      current?.segments.append([r(p[0].x), r(p[0].y), r(p[1].x), r(p[1].y), r(p[2].x), r(p[2].y)])
      last = p[2]
    case .closeSubpath:
      finish()
    @unknown default:
      break
    }
  }
  finish()
  return result
}

let input = FileHandle.standardInput.readDataToEndOfFile()
let items = try JSONDecoder().decode([Item].self, from: input)
let output = items.map { item in item.strokes.map { outline(of: $0, width: item.width) } }
FileHandle.standardOutput.write(try JSONEncoder().encode(output))
