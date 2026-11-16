/// 1文字のデータ（D106・D128）。座標はマス 0〜1000（y は下向き）。
public struct CharacterData: Sendable, Hashable, Codable {
  public var schema: Int
  /// 意味を持たない ID（例: `hira.304d`）。使い回さない（D114）。
  public var id: String
  public var char: String
  /// データの版。直したら上げる（D114）。
  public var rev: Int
  public var source: Source?
  /// 輪郭（`Stroke.outlines`）の座標の大きさ。
  public var outlineViewBox: Double?
  public var strokes: [Stroke]
  /// 正解の書き順（複数持てる。D66）。先頭がお手本。
  public var orders: [[Int]]
  /// 鏡に映した字を見るか（左右対称に近い字は false。D107）。nil は見る。
  public var mirrorCheck: Bool?

  public struct Source: Sendable, Hashable, Codable {
    public var name: String
    public var commit: String?
    public var license: String
  }

  /// 画の終わり方。まだ決めていない画は nil。
  public enum Ending: String, Sendable, Hashable, Codable {
    case tome
    case hane
    case harai
  }

  /// 1画。中心線は、始点と3次ベジェの区間の並び。
  public struct Stroke: Sendable, Hashable, Codable {
    public var start: [Double]
    /// 各区間は `[c1x, c1y, c2x, c2y, x, y]`。
    public var segments: [[Double]]
    public var end: Ending?
    /// お手本の表示に使う輪郭（SVG の path。座標は `outlineViewBox` 四方）。
    /// 自分と交わる画は部品ごとに分かれているので、並びで持つ。
    public var outlines: [String]?
  }
}

extension CharacterData {
  /// データの決まりに合っているかを確かめ、合わないところを返す（`content-check` で使う）。
  public func problems() -> [String] {
    var result: [String] = []
    if strokes.isEmpty { result.append("\(char): 画がない") }
    for (index, stroke) in strokes.enumerated() {
      if stroke.start.count != 2 { result.append("\(char) \(index + 1)画: 始点の形が違う") }
      if stroke.segments.isEmpty { result.append("\(char) \(index + 1)画: 区間がない") }
      for segment in stroke.segments where segment.count != 6 {
        result.append("\(char) \(index + 1)画: 区間の形が違う（\(segment.count) 個）")
      }
      let values = stroke.start + stroke.segments.flatMap { $0 }
      if let bad = values.first(where: { $0 < -100 || $0 > 1100 }) {
        result.append("\(char) \(index + 1)画: 座標がマスから大きく外れている（\(bad)）")
      }
    }
    for order in orders where order.sorted() != Array(strokes.indices) {
      result.append("\(char): 書き順 \(order) が画の数と合わない")
    }
    if orders.isEmpty { result.append("\(char): 書き順がない") }
    return result
  }
}
