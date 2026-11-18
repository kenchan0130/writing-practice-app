import Foundation

/// まちで動きまわる物の種類（D53）。乗り物は道、動物は草の上。
public enum TownRole: Equatable, Hashable, Sendable {
  case vehicle
  case animal
}

/// 動きまわる物ひとつ分の、まちの中の持ち場（D165）。画面の絵に頼らない普通の値。
public struct TownSlot: Equatable, Sendable {
  public let index: Int
  public let role: TownRole
  /// 同じ種類の中での奥行きの段（0 がいちばん手前）。
  public let lane: Int
  /// 動きまわれる左端・右端（物の中心の x）。
  public let minX: Double
  public let maxX: Double
  /// 出発の x（持ち場の真ん中）。
  public let startX: Double
  /// 足もとの高さ（画面の高さに対する割合。0 が下）。
  public let yFraction: Double
  /// 絵の大きさの倍率。手前（下）ほど大きい。
  public let scale: Double
}

/// まちの広さと、物の持ち場を決める計算（D8・D74・D165）。
public struct TownLayout: Equatable, Sendable {
  /// 1か所に出して動きまわる物の上限（D74）。
  public static let maxRoaming = 8
  /// 奥行きの段の数。
  public static let laneCount = 3
  /// 足もとの高さ（割合）。道が下、草が上。
  public static let vehicleLaneY: [Double] = [0.04, 0.09, 0.14]
  public static let animalLaneY: [Double] = [0.20, 0.26, 0.32]
  /// 持ち場が隣へはみ出してよい割合（持ち場の幅に対して。段がちがう物どうしだけがすれちがう）。
  public static let overlap = 0.25

  public let worldWidth: Double
  public let slots: [TownSlot]

  /// 古い順の一覧から、出す物（新しい8つ。並びは古い順のまま）を選ぶ。
  public static func shown<T>(_ items: [T]) -> [T] {
    Array(items.suffix(maxRoaming))
  }

  /// まちの幅は画面の何枚分か。物が少なくてもすこし広く、多いときは3枚分。
  public static func screens(count: Int) -> Double {
    switch count {
    case ..<4: return 1.5
    case 4...5: return 2
    case 6...7: return 2.5
    default: return 3
    }
  }

  /// 奥行きに合わせた倍率（下ほど大きい）。
  public static func scale(yFraction: Double) -> Double {
    1.15 - yFraction * 0.9
  }

  public static func make(roles: [TownRole], screenWidth: Double, objectWidth: Double)
    -> TownLayout
  {
    let roles = Array(roles.prefix(maxRoaming))
    let worldWidth = screenWidth * screens(count: roles.count)
    guard !roles.isEmpty else { return TownLayout(worldWidth: worldWidth, slots: []) }
    let slotWidth = worldWidth / Double(roles.count)
    var counters: [TownRole: Int] = [:]
    var slots: [TownSlot] = []
    for (index, role) in roles.enumerated() {
      let count = counters[role, default: 0]
      counters[role] = count + 1
      let lane = count % laneCount
      let y = (role == .vehicle ? vehicleLaneY : animalLaneY)[lane]
      let start = Double(index) * slotWidth
      let margin = max(objectWidth / 2, 0)
      let lower = max(start - slotWidth * overlap, 0) + margin
      let upper = min(start + slotWidth * (1 + overlap), worldWidth) - margin
      let center = start + slotWidth / 2
      slots.append(
        TownSlot(
          index: index, role: role, lane: lane,
          minX: min(lower, center), maxX: max(upper, center), startX: center,
          yFraction: y, scale: scale(yFraction: y)))
    }
    return TownLayout(worldWidth: worldWidth, slots: slots)
  }
}
