/// 書く場所（正方形のマス）の座標と、データの座標（0〜1000）の変換（D106）。
public struct GridMapping: Sendable, Hashable {
  public static let gridSize: Double = 1000
  /// マスの1辺の長さ（ポイント）。
  public var side: Double

  public init(side: Double) {
    self.side = side
  }

  public func toGrid(x: Double, y: Double) -> (x: Double, y: Double) {
    guard side > 0 else { return (0, 0) }
    let scale = Self.gridSize / side
    return (x * scale, y * scale)
  }

  public func fromGrid(x: Double, y: Double) -> (x: Double, y: Double) {
    let scale = side / Self.gridSize
    return (x * scale, y * scale)
  }
}

/// 線の太さ（D66）。筆圧を取れるときは筆圧、取れないときは書く速さで変える。
public struct StrokeWidth: Sendable, Hashable {
  /// ふつうの太さ（ポイント）。
  public var base: Double
  /// 太さの下限と上限（ふつうの太さに対する割合）。
  public var minRatio: Double
  public var maxRatio: Double
  /// この速さ（ポイント/秒）で、下限の太さになる。
  public var fastSpeed: Double

  public init(
    base: Double = 18, minRatio: Double = 0.6, maxRatio: Double = 1.4, fastSpeed: Double = 2500
  ) {
    self.base = base
    self.minRatio = minRatio
    self.maxRatio = maxRatio
    self.fastSpeed = fastSpeed
  }

  /// - Parameters:
  ///   - force: 0〜1 の筆圧。取れないときは nil。
  ///   - speed: 書く速さ（ポイント/秒）。
  public func width(force: Double?, speed: Double) -> Double {
    if let force {
      let clamped = min(max(force, 0), 1)
      return base * (minRatio + (maxRatio - minRatio) * clamped)
    }
    let t = min(max(speed / fastSpeed, 0), 1)
    return base * (1 - (1 - minRatio) * t)
  }
}
