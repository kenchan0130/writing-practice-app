/// 書き始めの接触の情報（D47・D109）。
public struct TouchCandidate: Sendable, Hashable {
  public var input: StrokeInput
  /// 触れた面の大きさ（ポイント）。マウスなどでは 0 のことがある。
  public var majorRadius: Double
  /// 書く場所の中での縦の位置（ポイント。上が 0）。
  public var y: Double
  /// 書く場所の高さ（ポイント）。
  public var areaHeight: Double
  /// 触れた時刻（秒）。
  public var time: Double

  public init(input: StrokeInput, majorRadius: Double, y: Double, areaHeight: Double, time: Double)
  {
    self.input = input
    self.majorRadius = majorRadius
    self.y = y
    self.areaHeight = areaHeight
    self.time = time
  }
}

/// 手のひらを見分ける決まり（D47・D109）。値は M0 で実機に合わせて直す。
public struct PalmRejection: Sendable, Hashable {
  /// これより大きい面の指の接触は、手のひらとして捨てる（ポイント）。
  public var maxFingerRadius: Double
  /// 書く場所の下の端の帯（高さに対する割合）。ここから始まった指の接触は捨てる。
  public var bottomBandRatio: Double
  /// Pencil を最後に使ってからこの秒数のあいだは、指の入力を無視する。
  public var pencilGracePeriod: Double
  /// 触れてからこの秒数のうちに面が広がったら、その線を取り消す。
  public var growthWindow: Double

  public init(
    maxFingerRadius: Double = 40,
    bottomBandRatio: Double = 0.06,
    pencilGracePeriod: Double = 1.0,
    growthWindow: Double = 0.05
  ) {
    self.maxFingerRadius = maxFingerRadius
    self.bottomBandRatio = bottomBandRatio
    self.pencilGracePeriod = pencilGracePeriod
    self.growthWindow = growthWindow
  }

  /// 新しい接触を書き始めとして受け付けるか。
  /// - Parameters:
  ///   - lastPencilTime: 最後に Pencil で書いた時刻。まだ使っていなければ nil。
  ///   - strokeInProgress: すでに1画を書いている最中か（途中で増えた接触は捨てる）。
  public func accepts(_ touch: TouchCandidate, lastPencilTime: Double?, strokeInProgress: Bool)
    -> Bool
  {
    if strokeInProgress { return false }
    if touch.input == .pencil { return true }
    if let lastPencilTime, touch.time - lastPencilTime < pencilGracePeriod { return false }
    if touch.majorRadius > maxFingerRadius { return false }
    if touch.y > touch.areaHeight * (1 - bottomBandRatio) { return false }
    return true
  }

  /// 書いている途中の指の接触を、手のひらだったとして取り消すか。
  public func shouldCancel(input: StrokeInput, majorRadius: Double, elapsed: Double) -> Bool {
    input == .finger && elapsed <= growthWindow && majorRadius > maxFingerRadius
  }
}
