import ContentModel

/// 出せる数に上限のある場所（D74・D82・D185）。場所ごとに おもちゃばこの計算をする。
public enum ShelfGroup: String, Sendable, Hashable, CaseIterable {
  /// まちを動きまわる物（のりもの・どうぶつ・そらを とぶ もの）。
  case roaming
  /// まちの景色。
  case scenery
  /// 水べの生きもの。
  case swimmers
  /// こうえんの物。
  case park
  /// まちの 季節の飾り（おまつりの はた の下）。
  case festive
  /// キャラクターのいえの 棚・床・壁。
  case houseShelf
  case houseFloor
  case houseWall

  /// その場所に出せる数（D74・D82・D170・D173・D185）。
  public var capacity: Int {
    switch self {
    case .roaming: TownLayout.maxRoaming
    case .scenery: TownLayout.maxScenery
    case .swimmers: TownLayout.maxSwimmers
    case .park: TownLayout.maxPlaythings
    case .festive: FestiveLayout.capacity
    case .houseShelf: HouseLayout.capacity(.shelf)
    case .houseFloor: HouseLayout.capacity(.floor)
    case .houseWall: HouseLayout.capacity(.wall)
    }
  }

  /// まちの おもちゃばこに入る場所。
  public static let town: [ShelfGroup] = [.roaming, .scenery, .swimmers, .park, .festive]

  /// 同じことばの物を いくつまで出すか（D74）。季節の飾りは増やさず、いちばん新しい 1つ。
  public var perWord: Int { self == .festive ? 1 : 3 }
  /// いえの おもちゃばこに入る場所。
  public static let house: [ShelfGroup] = [.houseShelf, .houseFloor, .houseWall]

  /// そのことばの物が置かれる場所。置かない物（着る物・空・体）は nil。
  public static func group(kind: WordKind, word: String) -> ShelfGroup? {
    switch kind {
    case .vehicle, .animal, .flyer: .roaming
    case .scenery: .scenery
    case .swimmer: .swimmers
    case .plaything: .park
    case .seasonal: .festive
    case .furniture:
      switch HouseLayout.spot(for: word) {
      case .shelf: .houseShelf
      case .floor: .houseFloor
      case .wall: .houseWall
      }
    case .clothes, .sky, .bodyAction: nil
    }
  }
}

/// いえの なかの置き場所の種類（§3.4・D185）。
public enum HouseSpot: String, Sendable, Hashable, CaseIterable {
  case shelf
  case floor
  case wall
}

/// いえの なかの置き場所 1つ（D185）。部屋の大きさに対する割合で持つ。
public struct HouseSlot: Sendable, Equatable {
  public let spot: HouseSpot
  /// その種類の中での番号（0 から）。
  public let index: Int
  /// 物の中心の x（部屋の幅に対する割合。0 が左）。
  public let x: Double
  /// 棚・床は物の下、壁は物の真ん中の高さ（部屋の高さに対する割合。0 が下）。
  public let y: Double
  /// 絵の大きさの倍率。
  public let scale: Double
}

/// 主人公が いえの物を使うときの動き（D185）。
public enum HouseUse: String, Sendable, Hashable, CaseIterable {
  /// たべる（はし・おわん・おさら）。
  case eat
  /// ゆげが のぼる（なべ・やかん）。
  case cook
  /// すわる（いす）。
  case sit
  /// つくえに むかう（つくえ）。ぶんぼうぐを つかう（えんぴつ・はさみ など）。
  case study
  /// じかんを みる（とけい）。
  case look
  /// ねむる（ふとん）。
  case sleep
  /// ひきだしを あける（たんす）。
  case tidy
  /// あわで あらう（せっけん）。
  case wash
  /// はを みがく・かみを とかす（はぶらし・くし）。
  case groom
  /// かがみに てを ふる（かがみ）。
  case mirror
}

/// キャラクターのいえ（いえの なか）の置き場所の決まり（§3.4・D74・D82・D185）。
public enum HouseLayout {
  /// 置き場所は、棚4つ・床2つ・壁2つの 8つ（D82）。
  public static func capacity(_ spot: HouseSpot) -> Int {
    switch spot {
    case .shelf: 4
    case .floor: 2
    case .wall: 2
    }
  }

  public static var totalCapacity: Int { HouseSpot.allCases.map(capacity).reduce(0, +) }

  /// 床の上のはし（部屋の高さに対する割合）。これより下が床。
  public static let floorTop = 0.34
  /// 棚の板の上の面の高さと、左右のはし。
  public static let shelfY = 0.58
  public static let shelfMinX = 0.05
  public static let shelfMaxX = 0.67
  /// 主人公が ふだん立つ場所。
  public static let homeX = 0.5
  public static let homeY = 0.13

  private static let floorWords: Set<String> = ["いす", "つくえ", "ふとん", "たんす"]
  private static let wallWords: Set<String> = ["とけい", "かがみ"]

  /// そのことばの物の置き場所の種類。壁にかける物・床に置く家具のほかは、棚。
  public static func spot(for word: String) -> HouseSpot {
    if floorWords.contains(word) { return .floor }
    if wallWords.contains(word) { return .wall }
    return .shelf
  }

  /// 置き場所（種類ごと。番号の順）。同じ種類の置き場所は重ならない。
  public static func slots(_ spot: HouseSpot) -> [HouseSlot] {
    switch spot {
    case .shelf:
      let count = capacity(.shelf)
      let part = (shelfMaxX - shelfMinX) / Double(count)
      return (0..<count).map {
        HouseSlot(
          spot: .shelf, index: $0, x: shelfMinX + part * (Double($0) + 0.5), y: shelfY, scale: 0.62)
      }
    case .floor:
      return [
        HouseSlot(spot: .floor, index: 0, x: 0.2, y: 0.2, scale: 1.25),
        HouseSlot(spot: .floor, index: 1, x: 0.8, y: 0.2, scale: 1.25),
      ]
    case .wall:
      return [
        HouseSlot(spot: .wall, index: 0, x: 0.84, y: 0.7, scale: 0.8),
        HouseSlot(spot: .wall, index: 1, x: 0.5, y: 0.87, scale: 0.8),
      ]
    }
  }

  /// 主人公の使い方。いえの物でなければ nil。
  public static func use(for word: String) -> HouseUse? {
    switch word {
    case "はし", "おわん", "おさら", "ゆのみ", "おぼん": .eat
    case "なべ", "やかん", "まないた", "しゃもじ", "おたま", "ざる": .cook
    case "いす": .sit
    case "つくえ", "えんぴつ", "はさみ", "のり", "ふでばこ", "じょうぎ", "えのぐ", "ふで", "ほん", "ねんど",
      "はんこ", "ふうとう", "クレヨン":
      .study
    case "とけい", "めがね": .look
    case "ふとん", "まくら": .sleep
    case "たんす", "れいぞうこ": .tidy
    case "せっけん", "おふろ", "おけ", "てぬぐい", "ぞうきん", "タオル": .wash
    case "はぶらし", "くし", "つめきり": .groom
    case "かがみ": .mirror
    // 合う動きが まだない物（ほうき・かなづち・でんわ・かさ・かぎ・せんぷうき・ばんそうこう）は、使わない。
    default: nil
    }
  }
}
