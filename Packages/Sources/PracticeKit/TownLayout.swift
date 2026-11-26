import Foundation

/// まちで動きまわる物の種類（D53）。乗り物は道、動物は草の上、飛ぶ物は空（D168）。
public enum TownRole: Equatable, Hashable, Sendable {
  case vehicle
  case animal
  case flyer
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
  /// 足もとの高さ（画面の高さに対する割合。0 が下）。飛ぶ物は絵の真ん中の高さ（D168）。
  public let yFraction: Double
  /// 絵の大きさの倍率。手前（下）ほど大きい。
  public let scale: Double
}

/// 景色になる物ひとつ分の置き場所（D168）。動かず、草の上に立つ。
public struct SceneryPlace: Equatable, Sendable {
  public let index: Int
  /// 物の中心の x。
  public let x: Double
  /// 足もとの高さ（画面の高さに対する割合）。
  public let yFraction: Double
  /// 手前の列は 0、丘に近い列は 1。
  public let row: Int
  public let scale: Double
}

/// 水の中の生きもの ひとつ分の持ち場（D170）。水の中だけを動く。
public struct SwimSlot: Equatable, Sendable {
  public let index: Int
  /// 水の中の段（0 がいちばん手前）。
  public let lane: Int
  /// 動きまわれる左端・右端（物の中心の x）。
  public let minX: Double
  public let maxX: Double
  public let startX: Double
  /// 絵の真ん中の高さ（画面の高さに対する割合）。
  public let yFraction: Double
  public let scale: Double
}

/// まちの右はしにある水べ（海・いけ）の広がり（D170）。
public struct WaterArea: Equatable, Sendable {
  /// 水べの左はし（砂浜のはじまり）と、右はし（まちのはし）。
  public let minX: Double
  public let maxX: Double
  /// 水の中の生きものが動ける左はし（砂浜より右）。
  public let swimMinX: Double
}

/// こうえんの物ひとつ分の置き場所（D173）。置き場所は8つで、場所ごとに決まっている（D82）。
public struct ParkSlot: Equatable, Sendable {
  public let index: Int
  /// 物の中心の x。
  public let x: Double
  /// 足もとの高さ（画面の高さに対する割合）。
  public let yFraction: Double
  /// 手前の列は 0、奥の列は 1。
  public let row: Int
  public let scale: Double
}

/// まちの左はしにあるこうえんの広がり（D173）。
public struct ParkArea: Equatable, Sendable {
  /// こうえんの左はし（まちのはし）と、右はし（陸のまちのはじまり）。
  public let minX: Double
  public let maxX: Double
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
  /// 飛ぶ物の空の段（絵の真ん中の高さ）。丘の上に収まる。D168。
  public static let skyLaneY: [Double] = [0.62, 0.74, 0.86]
  /// 飛ぶ物の倍率。高い段ほど遠いので小さい。
  public static let skyLaneScale: [Double] = [0.9, 0.8, 0.7]
  /// 1か所に出す景色の上限（D74）。
  public static let maxScenery = 12
  /// 景色の足もとの高さ。丘に近い列（奥）と、その手前の列。動物の通る草より奥に描く。
  public static let sceneryRowY: [Double] = [0.30, 0.345]
  /// 景色の倍率（動物より小さい）。
  public static let sceneryScale = 0.7
  /// 大きな景色（やま・たき・たてもの。D174）の足もとの高さ。丘と草の境目（まちの高さの0.36）に立つ。
  public static let landmarkBaseY = 0.355
  /// 大きな景色の絵の、横はば（絵の四角に対する割合の半分）。背景と重ならないよう はかる。
  public static let landmarkHalfWidth = 0.45
  /// 水の中に出す生きものの上限（D170）。動きまわる物の8つとは別に数える。
  public static let maxSwimmers = 6
  /// 水の中の段の数。絵の真ん中の高さ。奥ほど小さい。
  public static let swimLaneY: [Double] = [0.12, 0.20, 0.28]
  public static let swimLaneScale: [Double] = [1.0, 0.9, 0.8]
  /// 水べの幅（画面の何枚分か）と、そのうち砂浜の幅（画面に対する割合）。
  public static let waterScreens = 0.9
  public static let shoreScreens = 0.1
  /// こうえんに出す物の上限と、置き場所の数（D74・D82・D173）。動きまわる物の8つとは別に数える。
  public static let maxPlaythings = 8
  /// こうえんの置き場所の足もとの高さと倍率。手前の列・奥の列。
  public static let parkRowY: [Double] = [0.10, 0.21]
  public static let parkRowScale: [Double] = [1.05, 0.92]
  /// こうえんの幅（画面の何枚分か）。
  public static let parkScreens = 0.9
  /// 持ち場が隣へはみ出してよい割合（持ち場の幅に対して。段がちがう物どうしだけがすれちがう）。
  public static let overlap = 0.25

  public let worldWidth: Double
  public let slots: [TownSlot]
  public let scenery: [SceneryPlace]
  /// 水の中の生きものの持ち場（D170）。
  public let swimSlots: [SwimSlot]
  /// 水べ。生きものがいないときは nil（まちは今までどおり）。
  public let water: WaterArea?
  /// 水べとこうえんをのぞいた、陸のまちの幅。
  public let landWidth: Double
  /// こうえんの置き場所（8つ。こうえんがあるときだけ。D173）。
  public let parkSlots: [ParkSlot]
  /// こうえん。物がないときは nil（まちは今までどおり）。
  public let park: ParkArea?
  /// 陸のまちのはじまりの x（こうえんがあれば、その右はし。なければ 0）。
  public let landMinX: Double

  /// 古い順の一覧から、出す物（新しい8つ。並びは古い順のまま）を選ぶ。
  public static func shown<T>(_ items: [T]) -> [T] {
    Array(items.suffix(maxRoaming))
  }

  /// 景色になる物は、新しい12個まで（D74・D168）。
  public static func shownScenery<T>(_ items: [T]) -> [T] {
    Array(items.suffix(maxScenery))
  }

  /// 水の中の生きものは、新しい6つまで（D170）。
  public static func shownSwimmers<T>(_ items: [T]) -> [T] {
    Array(items.suffix(maxSwimmers))
  }

  /// こうえんの物は、新しい8つまで（D173）。
  public static func shownPlaythings<T>(_ items: [T]) -> [T] {
    Array(items.suffix(maxPlaythings))
  }

  /// 何番目に置いたこうえんの物か（0 から）から、置き場所の番号を決める。
  /// 8つを超えたら、いちばん古い物の場所に、新しい物が入る（D82）。
  public static func parkSlotIndex(ordinal: Int) -> Int {
    ((ordinal % maxPlaythings) + maxPlaythings) % maxPlaythings
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

  /// 飛ぶ物も「動きまわる物」として、上限の8つに数える（D74・D168）。
  /// 景色は別に12個まで。景色が多いときは、まちを少し広げる。
  public static func make(
    roles: [TownRole], scenery sceneryCount: Int = 0, swimmers swimmerCount: Int = 0,
    playthings playCount: Int = 0, screenWidth: Double, objectWidth: Double
  ) -> TownLayout {
    let roles = Array(roles.prefix(maxRoaming))
    let sceneryCount = min(max(sceneryCount, 0), maxScenery)
    let swimmerCount = min(max(swimmerCount, 0), maxSwimmers)
    let landWidth = screenWidth * screens(count: roles.count + sceneryCount / 2)
    let parkWidth = playCount > 0 ? screenWidth * parkScreens : 0
    let landMinX = parkWidth
    let waterWidth = swimmerCount > 0 ? screenWidth * waterScreens : 0
    let worldWidth = parkWidth + landWidth + waterWidth
    let park: ParkArea? = playCount > 0 ? ParkArea(minX: 0, maxX: parkWidth) : nil
    let parkSlots = parkSlots(area: park, objectWidth: objectWidth)
    let places = sceneryPlaces(count: sceneryCount, worldWidth: landWidth, originX: landMinX)
    let landMaxX = landMinX + landWidth
    let water: WaterArea? =
      swimmerCount > 0
      ? WaterArea(
        minX: landMaxX, maxX: worldWidth, swimMinX: landMaxX + screenWidth * shoreScreens) : nil
    let swim = swimSlots(count: swimmerCount, water: water, objectWidth: objectWidth)
    guard !roles.isEmpty else {
      return TownLayout(
        worldWidth: worldWidth, slots: [], scenery: places, swimSlots: swim, water: water,
        landWidth: landWidth, parkSlots: parkSlots, park: park, landMinX: landMinX)
    }
    let slotWidth = landWidth / Double(roles.count)
    var counters: [TownRole: Int] = [:]
    var slots: [TownSlot] = []
    for (index, role) in roles.enumerated() {
      let count = counters[role, default: 0]
      counters[role] = count + 1
      let lane = count % laneCount
      let y: Double
      let scale: Double
      switch role {
      case .vehicle:
        y = vehicleLaneY[lane]
        scale = Self.scale(yFraction: y)
      case .animal:
        y = animalLaneY[lane]
        scale = Self.scale(yFraction: y)
      case .flyer:
        y = skyLaneY[lane]
        scale = skyLaneScale[lane]
      }
      let start = landMinX + Double(index) * slotWidth
      let margin = max(objectWidth / 2, 0)
      let lower = max(start - slotWidth * overlap, landMinX) + margin
      let upper = min(start + slotWidth * (1 + overlap), landMaxX) - margin
      let center = start + slotWidth / 2
      slots.append(
        TownSlot(
          index: index, role: role, lane: lane,
          minX: min(lower, center), maxX: max(upper, center), startX: center,
          yFraction: y, scale: scale))
    }
    return TownLayout(
      worldWidth: worldWidth, slots: slots, scenery: places, swimSlots: swim, water: water,
      landWidth: landWidth, parkSlots: parkSlots, park: park, landMinX: landMinX)
  }

  /// こうえんの置き場所は、右（まちに近い方）から左へ8つ。手前の列と奥の列を交互にする。
  /// 同じ列の物は、まちに近い方から1つおきに並ぶので、重ならない。
  /// 両はしの物も、絵（`objectWidth`）がこうえんの中に収まる。
  static func parkSlots(area: ParkArea?, objectWidth: Double) -> [ParkSlot] {
    guard let area else { return [] }
    let margin = max(objectWidth / 2, 0)
    let part = max(area.maxX - area.minX - margin * 2, 0) / Double(maxPlaythings - 1)
    return (0..<maxPlaythings).map { index in
      let row = index % 2
      return ParkSlot(
        index: index, x: area.maxX - margin - part * Double(index), yFraction: parkRowY[row],
        row: row, scale: parkRowScale[row])
    }
  }

  /// 水の中の生きものは、3つの段を順に回し、同じ段の物は水を等しく分けて持ち場にする。
  /// 同じ段の持ち場は重ならず、水の外へは出ない。
  static func swimSlots(count: Int, water: WaterArea?, objectWidth: Double) -> [SwimSlot] {
    guard count > 0, let water else { return [] }
    let margin = max(objectWidth / 2, 0)
    let perLane = (0..<laneCount).map { lane in
      (0..<count).filter { $0 % laneCount == lane }.count
    }
    var taken = [Int](repeating: 0, count: laneCount)
    var slots: [SwimSlot] = []
    for index in 0..<count {
      let lane = index % laneCount
      let column = taken[lane]
      taken[lane] += 1
      let part = (water.maxX - water.swimMinX) / Double(perLane[lane])
      let from = water.swimMinX + part * Double(column)
      let lower = from + margin
      let upper = from + part - margin
      // 出発は、水の幅を物の数で分けた位置にばらして、段がちがう物が重ならないようにする。
      let spread =
        water.swimMinX + (water.maxX - water.swimMinX) * (Double(index) + 0.5) / Double(count)
      let center = min(max(spread, min(lower, from + part / 2)), max(upper, from + part / 2))
      slots.append(
        SwimSlot(
          index: index, lane: lane, minX: min(lower, center), maxX: max(upper, center),
          startX: center, yFraction: swimLaneY[lane], scale: swimLaneScale[lane]))
    }
    return slots
  }

  /// 大きな景色の置き場所（D174）。同じ x のまま、丘と草の境目に立ち、`factor` 倍になる。
  /// やまは、とても大きく（背景の家の2.5倍ほど）。たてものは すこし大きく。
  /// 描くのは背景の木・家と同じ奥（ほかの景色・動物より奥）。
  public static func landmarkPlace(_ place: SceneryPlace, factor: Double) -> SceneryPlace {
    SceneryPlace(
      index: place.index, x: place.x, yFraction: landmarkBaseY, row: 1,
      scale: place.scale * factor)
  }

  /// 大きな景色が まちの横で ふさぐはば。
  public static func landmarkSpan(_ place: SceneryPlace, objectWidth: Double) -> ClosedRange<Double>
  {
    let half = objectWidth * place.scale * landmarkHalfWidth
    return (place.x - half)...(place.x + half)
  }

  /// 背景の木と家ひとつ分（丘の向こう側。D165）。
  public struct BackdropSpot: Equatable, Sendable {
    public let index: Int
    public let x: Double
    /// 絵のはばの半分。
    public let halfWidth: Double
    public let isHouse: Bool
  }

  /// 背景の木と家の並べ方。家は3つに1つで、そのあいだに木。`unit` はまちの高さの基準（`TownScene.unit`）。
  public static func backdropSpots(minX: Double, width: Double, unit: Double) -> [BackdropSpot] {
    var spots: [BackdropSpot] = []
    var x = minX + 140
    var index = 0
    while x < minX + width {
      if index % 3 == 1 {
        spots.append(BackdropSpot(index: index, x: x, halfWidth: unit * 0.14, isHouse: true))
        x += 380
      } else {
        let s = 0.9 + Double(index % 3) * 0.15
        spots.append(BackdropSpot(index: index, x: x, halfWidth: unit * 0.075 * s, isHouse: false))
        x += 300 + Double(index % 2) * 70
      }
      index += 1
    }
    return spots
  }

  /// 大きな景色が立つはばに かかる背景の木・家は、出さない（大きな景色が背景と重ならない。D174）。
  public static func backdrop(_ spots: [BackdropSpot], avoiding spans: [ClosedRange<Double>])
    -> [BackdropSpot]
  {
    spots.filter { spot in
      !spans.contains {
        ($0.lowerBound - spot.halfWidth)...($0.upperBound + spot.halfWidth) ~= spot.x
      }
    }
  }

  /// 景色は、まちの幅いっぱいに同じ間をあけて並べ、2つの列に交互に置く。
  static func sceneryPlaces(count: Int, worldWidth: Double, originX: Double = 0)
    -> [SceneryPlace]
  {
    guard count > 0 else { return [] }
    let gap = worldWidth / Double(count)
    return (0..<count).map { index in
      let row = index % 2
      return SceneryPlace(
        index: index, x: originX + gap * (Double(index) + 0.5), yFraction: sceneryRowY[row],
        row: row,
        scale: sceneryScale)
    }
  }
}
