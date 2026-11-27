/// 傾けると転がる（§3.3・D133）。画面に頼らない計算。
///
/// まちの丸い物が、iPad を傾けた向きへ少し転がる。押しても転がる（傾きのセンサーのない Mac でも同じ）。
/// 動きは おだやかで、もとの場所から `limit` より遠くへは行かない。
public struct RollState: Sendable, Equatable {
  /// もとの場所からの ずれ（ポイント。右が正）。
  public var offset: Double
  /// 速さ（ポイント/秒）。
  public var velocity: Double

  public init(offset: Double = 0, velocity: Double = 0) {
    self.offset = offset
    self.velocity = velocity
  }

  /// 止まっているか。
  public var isResting: Bool { velocity == 0 }
}

public enum Rolling {
  /// 転がる物（丸い くだもの・やさい・木の実）。
  public static let words: Set<String> = [
    "りんご", "みかん", "もも", "すいか", "かぼちゃ", "なし", "かき", "くり", "どんぐり", "たまねぎ",
    "じゃがいも",
  ]

  public static func isRollable(_ word: String) -> Bool { words.contains(word) }

  /// これより小さい傾きでは動かない（机に置いた iPad が少し傾いていても、転がらない）。
  public static let deadZone = 0.1
  /// これより大きい傾きは、同じ強さとして見る。
  public static let fullTilt = 0.5
  /// はしで はね返る強さ（0 = 止まる、1 = 同じ速さで返る）。
  static let bounce = 0.25
  /// 速さが落ちる割合（1秒あたり）。
  static let drag = 2.2
  /// これより遅くなったら止める（ポイント/秒）。
  static let restSpeed = 3.0

  /// 傾き（重力の横向きの成分。-1〜1）を、押す強さ（-1〜1）にする。
  public static func push(tilt: Double) -> Double {
    guard tilt.isFinite else { return 0 }
    let size = abs(tilt)
    guard size > deadZone else { return 0 }
    let strength = min((size - deadZone) / (fullTilt - deadZone), 1)
    return tilt < 0 ? -strength : strength
  }

  /// `dt` 秒だけ進める。
  /// - Parameters:
  ///   - tilt: 傾き（-1〜1。右に傾けると正）。
  ///   - limit: もとの場所から動ける はば（ポイント）。左右で変えるときは `range` を使う。
  public static func step(_ state: RollState, tilt: Double, dt: Double, limit: Double) -> RollState
  {
    step(state, tilt: tilt, dt: dt, range: -abs(limit)...abs(limit))
  }

  /// `dt` 秒だけ進める。`range` は、ずれの動ける はんい（0 を含む）。
  public static func step(
    _ state: RollState, tilt: Double, dt: Double, range: ClosedRange<Double>
  ) -> RollState {
    // 画面が止まっていたあとの大きな `dt` で、飛ばないようにする。
    let dt = min(max(dt.isFinite ? dt : 0, 0), 0.05)
    let reach = max(range.upperBound - range.lowerBound, 1)
    let force = push(tilt: tilt)
    var velocity = state.velocity + force * reach * 2.4 * dt
    velocity *= max(1 - drag * dt, 0)
    var offset = state.offset + velocity * dt
    if offset > range.upperBound {
      offset = range.upperBound
      velocity = velocity > 0 ? -velocity * bounce : velocity
    } else if offset < range.lowerBound {
      offset = range.lowerBound
      velocity = velocity < 0 ? -velocity * bounce : velocity
    }
    // 押す力がなくて、ゆっくりなら止める。はしに押しつけられているときも止める。
    let pinned =
      (offset == range.upperBound && force > 0) || (offset == range.lowerBound && force < 0)
    if abs(velocity) < restSpeed, force == 0 || pinned { velocity = 0 }
    return RollState(offset: offset, velocity: velocity)
  }

  /// 押したときの はじめの速さ（ポイント/秒）。押したところの反対へ転がる。
  /// - Parameters:
  ///   - tappedRightSide: 物の右がわを押したか。
  public static func tapped(
    _ state: RollState, tappedRightSide: Bool, range: ClosedRange<Double>
  ) -> RollState {
    let reach = max(range.upperBound - range.lowerBound, 1)
    var direction: Double = tappedRightSide ? -1 : 1
    // はしにいるときは、中へ もどる向きへ。
    if state.offset >= range.upperBound - 1 { direction = -1 }
    if state.offset <= range.lowerBound + 1 { direction = 1 }
    return RollState(offset: state.offset, velocity: direction * reach * 0.9)
  }

  /// 転がった きょりから、回る角度（ラジアン。右へ転がると時計回り＝負）。
  public static func angle(offset: Double, radius: Double) -> Double {
    -offset / max(radius, 1)
  }
}
