import ContentModel
import Foundation

/// 判定に使う点（マス 0〜1000）。
public struct Point: Sendable, Hashable {
  public var x: Double
  public var y: Double

  public init(_ x: Double, _ y: Double) {
    self.x = x
    self.y = y
  }

  static func + (a: Point, b: Point) -> Point { Point(a.x + b.x, a.y + b.y) }
  static func - (a: Point, b: Point) -> Point { Point(a.x - b.x, a.y - b.y) }
  static func * (a: Point, k: Double) -> Point { Point(a.x * k, a.y * k) }

  func distance(to other: Point) -> Double {
    let dx = x - other.x
    let dy = y - other.y
    return (dx * dx + dy * dy).squareRoot()
  }
}

/// 1画の線（点の並び）。
public typealias Polyline = [Point]

extension CharacterData.Stroke {
  /// 中心線を細かい点の並びにする（お手本どおりに書いた線の代わりなどに使う）。
  public func centerlinePoints(stepsPerSegment: Int = 16) -> Polyline {
    Geometry.polyline(of: self, stepsPerSegment: stepsPerSegment)
  }
}

enum Geometry {
  /// お手本の1画の中心線（3次ベジェの並び）を、細かい点の並びにする。
  static func polyline(of stroke: CharacterData.Stroke, stepsPerSegment: Int = 16) -> Polyline {
    guard stroke.start.count == 2 else { return [] }
    var points = [Point(stroke.start[0], stroke.start[1])]
    var current = points[0]
    for segment in stroke.segments where segment.count == 6 {
      let c1 = Point(segment[0], segment[1])
      let c2 = Point(segment[2], segment[3])
      let end = Point(segment[4], segment[5])
      for step in 1...stepsPerSegment {
        let t = Double(step) / Double(stepsPerSegment)
        let u = 1 - t
        let a = current * (u * u * u)
        let b = c1 * (3 * u * u * t)
        let c = c2 * (3 * u * t * t)
        let d = end * (t * t * t)
        points.append(a + b + c + d)
      }
      current = end
    }
    return points
  }

  static func length(of line: Polyline) -> Double {
    zip(line, line.dropFirst()).reduce(0) { $0 + $1.0.distance(to: $1.1) }
  }

  /// 線を、長さにそって同じ間かくの `count` 個の点に置き直す（D107 ①）。
  static func resample(_ line: Polyline, count: Int = 32) -> Polyline {
    guard let first = line.first else { return [] }
    let total = length(of: line)
    guard line.count > 1, total > 0 else { return Array(repeating: first, count: count) }
    let step = total / Double(count - 1)
    var result = [first]
    var previous = first
    var walked = 0.0
    var target = step
    var index = 1
    while index < line.count, result.count < count - 1 {
      let next = line[index]
      let segment = previous.distance(to: next)
      if walked + segment >= target, segment > 0 {
        let t = (target - walked) / segment
        let point = previous + (next - previous) * t
        result.append(point)
        previous = point
        walked = target
        target += step
      } else {
        walked += segment
        previous = next
        index += 1
      }
    }
    while result.count < count { result.append(line[line.count - 1]) }
    return result
  }

  /// 点の集まりの外枠。
  static func bounds(of lines: [Polyline]) -> (min: Point, max: Point)? {
    let all = lines.flatMap { $0 }
    guard let first = all.first else { return nil }
    var lo = first
    var hi = first
    for p in all {
      lo = Point(min(lo.x, p.x), min(lo.y, p.y))
      hi = Point(max(hi.x, p.x), max(hi.y, p.y))
    }
    return (lo, hi)
  }

  /// 字全体の位置と大きさを、お手本の外枠に合わせる（D107 ①。④じぶんで で使う）。
  /// 画ごとには合わせず、画どうしの位置関係を残す。縦横の比は変えない。
  static func align(_ written: [Polyline], to model: [Polyline]) -> [Polyline] {
    guard let w = bounds(of: written), let m = bounds(of: model) else { return written }
    let wSize = max(w.max.x - w.min.x, w.max.y - w.min.y)
    let mSize = max(m.max.x - m.min.x, m.max.y - m.min.y)
    guard wSize > 0 else { return written }
    let scale = mSize / wSize
    let wCenter = (w.min + w.max) * 0.5
    let mCenter = (m.min + m.max) * 0.5
    return written.map { line in line.map { (($0 - wCenter) * scale) + mCenter } }
  }

  /// 左右を反転する（鏡の字を見分けるため）。
  static func mirrored(_ lines: [Polyline]) -> [Polyline] {
    guard let b = bounds(of: lines) else { return lines }
    let center = (b.min.x + b.max.x) / 2
    return lines.map { line in line.map { Point(2 * center - $0.x, $0.y) } }
  }

  /// 2本の線（同じ点の数に置き直したもの）の、点どうしの平均の距離。
  static func meanDistance(_ a: Polyline, _ b: Polyline) -> Double {
    guard a.count == b.count, !a.isEmpty else { return .infinity }
    return zip(a, b).reduce(0) { $0 + $1.0.distance(to: $1.1) } / Double(a.count)
  }

  /// 2本の線（同じ点の数に置き直したもの）の、点どうしのいちばん大きい距離。
  static func maxDistance(_ a: Polyline, _ b: Polyline) -> Double {
    guard a.count == b.count, !a.isEmpty else { return .infinity }
    return zip(a, b).reduce(0) { max($0, $1.0.distance(to: $1.1)) }
  }

  /// 点から線（折れ線）までのいちばん近い距離。
  static func distance(from p: Point, to line: Polyline) -> Double {
    guard let first = line.first else { return .infinity }
    guard line.count > 1 else { return p.distance(to: first) }
    var best = Double.infinity
    for (a, b) in zip(line, line.dropFirst()) {
      let ab = b - a
      let lengthSquared = ab.x * ab.x + ab.y * ab.y
      let t =
        lengthSquared > 0
        ? max(0, min(1, ((p.x - a.x) * ab.x + (p.y - a.y) * ab.y) / lengthSquared)) : 0
      best = min(best, p.distance(to: a + ab * t))
    }
    return best
  }

  /// 2本の線の形の違い（D107 ②）。点の番号どうしではなく、それぞれの点から相手の線の
  /// いちばん近いところまでの距離で比べる（線の長さや書く速さの違いに強い）。両方向の平均と最大。
  static func shapeDifference(_ a: Polyline, _ b: Polyline) -> (mean: Double, max: Double) {
    guard !a.isEmpty, !b.isEmpty else { return (.infinity, .infinity) }
    let ab = a.map { distance(from: $0, to: b) }
    let ba = b.map { distance(from: $0, to: a) }
    let mean = (ab.reduce(0, +) / Double(ab.count) + ba.reduce(0, +) / Double(ba.count)) / 2
    return (mean, max(ab.max() ?? 0, ba.max() ?? 0))
  }

  /// 書き始めと書き終わりの位置の違い。向きどおり（forward）と逆向き（backward）。
  static func endpointDifference(_ a: Polyline, _ b: Polyline) -> (
    forward: Double, backward: Double
  ) {
    guard let a0 = a.first, let a1 = a.last, let b0 = b.first, let b1 = b.last else {
      return (.infinity, .infinity)
    }
    return (a0.distance(to: b0) + a1.distance(to: b1), a0.distance(to: b1) + a1.distance(to: b0))
  }

  /// 線の書き始めから書き終わりへの向き（長さ1）。
  static func direction(of line: Polyline) -> Point {
    guard let first = line.first, let last = line.last else { return Point(0, 0) }
    let d = last - first
    let n = (d.x * d.x + d.y * d.y).squareRoot()
    return n > 0 ? d * (1 / n) : Point(0, 0)
  }
}
