/// 書いた線の1点（D106）。座標はマス 0〜1000（y は下向き）。
public struct StrokePoint: Sendable, Hashable, Codable {
  public var x: Double
  public var y: Double
  /// 書き始めからの秒数。
  public var time: Double
  /// 筆圧（0〜1）。筆圧を取れない入力では nil（D66）。
  public var force: Double?

  public init(x: Double, y: Double, time: Double, force: Double? = nil) {
    self.x = x
    self.y = y
    self.time = time
    self.force = force
  }
}

/// 入力の種類（D47・D100）。Pencil 以外はすべて指として判定する。
public enum StrokeInput: String, Sendable, Hashable, Codable {
  case pencil
  case finger
}

/// 1画分の線の記録（D106）。
public struct StrokeSample: Sendable, Hashable, Codable {
  public var input: StrokeInput
  public var points: [StrokePoint]

  public init(input: StrokeInput, points: [StrokePoint]) {
    self.input = input
    self.points = points
  }

  /// 線の長さ（座標の単位）。
  public var length: Double {
    zip(points, points.dropFirst()).reduce(0) { total, pair in
      let dx = pair.1.x - pair.0.x
      let dy = pair.1.y - pair.0.y
      return total + (dx * dx + dy * dy).squareRoot()
    }
  }
}
