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
  /// 手のひらは、触れてから面が広がり切るまで 0.1〜0.3 秒ほどかかる（D191）。
  public var growthWindow: Double
  /// 触れてからの時間内に、面がこの大きさ以上に広がったら手のひらとみなす（ポイント。D191）。
  public var growthRadius: Double
  /// 手のひらは、書き始めからあまり動かない。これより動いた線は、取り消さない（ポイント。D191）。
  public var maxPalmTravel: Double

  public init(
    maxFingerRadius: Double = 40,
    bottomBandRatio: Double = 0.06,
    pencilGracePeriod: Double = 1.0,
    growthWindow: Double = 0.3,
    growthRadius: Double = 50,
    maxPalmTravel: Double = 30
  ) {
    self.growthRadius = growthRadius
    self.maxPalmTravel = maxPalmTravel
    self.maxFingerRadius = maxFingerRadius
    self.bottomBandRatio = bottomBandRatio
    self.pencilGracePeriod = pencilGracePeriod
    self.growthWindow = growthWindow
  }

  /// 新しい接触への答え（D191）。
  public enum Decision: Sendable, Equatable {
    /// 書き始めとして受け付ける。
    case accept
    /// 捨てる。
    case reject
    /// 書いている指の線を取り消して、この Pencil の線を書き始める。
    /// 先に手のひらが指の線として始まっていても、Pencil を優先する。
    case replaceActive
  }

  /// 新しい接触を、どうするか決める。
  /// - Parameters:
  ///   - lastPencilTime: 最後に Pencil で書いた時刻。まだ使っていなければ nil。
  ///   - activeInput: すでに書いている線の入力。書いていなければ nil（途中で増えた接触は捨てる）。
  public func decide(_ touch: TouchCandidate, lastPencilTime: Double?, activeInput: StrokeInput?)
    -> Decision
  {
    if let activeInput {
      return touch.input == .pencil && activeInput == .finger ? .replaceActive : .reject
    }
    return accepts(touch, lastPencilTime: lastPencilTime, strokeInProgress: false)
      ? .accept : .reject
  }

  /// 新しい接触を書き始めとして受け付けるか。
  /// - Parameters:
  ///   - lastPencilTime: 最後に Pencil で書いた時刻。まだ使っていなければ nil。
  ///   - strokeInProgress: すでに1画を書いている最中か（途中で増えた接触は捨てる）。
  ///     Pencil が指の線に重なる場合は `decide` を使う。
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
  /// 面が `growthRadius` 以上に広がり、しかも、ほとんど動いていないときだけ取り消す（D191）。
  /// 太い指でしっかり書いている線（面は大きいが、動いている）は取り消さない。
  /// - Parameter travel: 書き始めから動いた距離（ポイント）。
  public func shouldCancel(
    input: StrokeInput, majorRadius: Double, elapsed: Double, travel: Double = 0
  ) -> Bool {
    input == .finger && elapsed <= growthWindow && majorRadius >= growthRadius
      && travel <= maxPalmTravel
  }
}
