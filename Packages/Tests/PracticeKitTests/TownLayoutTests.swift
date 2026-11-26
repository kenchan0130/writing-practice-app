import Testing

@testable import PracticeKit

@Suite("まちの広さと持ち場（D165）")
struct TownLayoutTests {
  static let mixed: [TownRole] = [
    .vehicle, .animal, .vehicle, .animal, .animal, .vehicle, .vehicle, .animal,
  ]

  @Test("出す物は新しい8つまで（D74）")
  func cap() {
    #expect(TownLayout.shown(Array(0..<12)) == Array(4..<12))
    #expect(TownLayout.shown([1, 2]) == [1, 2])
    let layout = TownLayout.make(
      roles: Array(repeating: .animal, count: 12), screenWidth: 1000, objectWidth: 160)
    #expect(layout.slots.count == 8)
  }

  @Test("物が多いほどまちは広い（1.5〜3枚分）")
  func width() {
    #expect(TownLayout.screens(count: 0) == 1.5)
    #expect(TownLayout.screens(count: 3) == 1.5)
    #expect(TownLayout.screens(count: 5) == 2)
    #expect(TownLayout.screens(count: 7) == 2.5)
    #expect(TownLayout.screens(count: 8) == 3)
    let empty = TownLayout.make(roles: [], screenWidth: 1000, objectWidth: 160)
    #expect(empty.worldWidth == 1500)
    #expect(empty.slots.isEmpty)
  }

  @Test("出発の位置は物ごとにはなれている")
  func startsApart() {
    let layout = TownLayout.make(roles: Self.mixed, screenWidth: 1100, objectWidth: 160)
    let starts = layout.slots.map(\.startX)
    for (a, b) in zip(starts, starts.dropFirst()) { #expect(b - a >= 160) }
  }

  @Test("同じ種類で同じ段の物は、動く範囲が重ならない")
  func sameLaneNeverOverlaps() {
    let layout = TownLayout.make(roles: Self.mixed, screenWidth: 1100, objectWidth: 160)
    for a in layout.slots {
      for b in layout.slots where a.index < b.index && a.role == b.role && a.lane == b.lane {
        #expect(a.maxX < b.minX)
      }
    }
  }

  @Test("動く範囲はまちの中に収まり、手前ほど大きい")
  func bounds() {
    let layout = TownLayout.make(roles: Self.mixed, screenWidth: 1100, objectWidth: 160)
    for slot in layout.slots {
      #expect(slot.minX - 80 >= 0)
      #expect(slot.maxX + 80 <= layout.worldWidth)
      #expect(slot.minX <= slot.startX && slot.startX <= slot.maxX)
      #expect(slot.yFraction >= 0.04 && slot.yFraction <= 0.32)
      #expect(slot.scale > 0.8 && slot.scale < 1.2)
    }
    #expect(TownLayout.scale(yFraction: 0.04) > TownLayout.scale(yFraction: 0.32))
  }

  @Test("乗り物は道、動物は草。同じ種類は段を回す")
  func lanes() {
    let layout = TownLayout.make(roles: Self.mixed, screenWidth: 1100, objectWidth: 160)
    for slot in layout.slots {
      let table: [Double]
      switch slot.role {
      case .vehicle: table = TownLayout.vehicleLaneY
      case .animal: table = TownLayout.animalLaneY
      case .flyer: table = TownLayout.skyLaneY
      }
      #expect(slot.yFraction == table[slot.lane])
    }
    let vehicles = layout.slots.filter { $0.role == .vehicle }.map(\.lane)
    #expect(vehicles == [0, 1, 2, 0])
  }

  // MARK: - 飛ぶ物と景色（D168）

  static let withFlyers: [TownRole] = [
    .flyer, .animal, .flyer, .vehicle, .flyer, .flyer, .animal, .flyer,
  ]

  @Test("飛ぶ物は空の段に1つずつ。段を順に回り、丘より上にいる")
  func flyerLanes() {
    let layout = TownLayout.make(roles: Self.withFlyers, screenWidth: 1100, objectWidth: 160)
    let flyers = layout.slots.filter { $0.role == .flyer }
    #expect(flyers.map(\.lane) == [0, 1, 2, 0, 1])
    for slot in flyers {
      #expect(slot.yFraction == TownLayout.skyLaneY[slot.lane])
      #expect(slot.yFraction - 0.1 > 0.5)  // 丘（高さの約5割）より上
      #expect(slot.yFraction + 0.06 <= 1)
      #expect(slot.scale == TownLayout.skyLaneScale[slot.lane])
    }
    // 空は動物の草より高い。
    #expect(TownLayout.skyLaneY.min()! > TownLayout.animalLaneY.max()!)
    #expect(TownLayout.skyLaneScale == TownLayout.skyLaneScale.sorted(by: >))
  }

  @Test("飛ぶ物どうしは、同じ段で動く範囲が重ならず、出発の位置もはなれている")
  func flyersNeverStack() {
    for count in 1...8 {
      let roles = Array(repeating: TownRole.flyer, count: count)
      let layout = TownLayout.make(roles: roles, screenWidth: 1100, objectWidth: 160)
      for a in layout.slots {
        for b in layout.slots where a.index < b.index && a.lane == b.lane {
          #expect(a.maxX < b.minX, "\(count) 個のとき")
        }
        for b in layout.slots where a.index < b.index {
          #expect(abs(a.startX - b.startX) >= 160)
        }
      }
    }
  }

  @Test("飛ぶ物も動きまわる物の8つに数える。景色は別に12個まで")
  func caps() {
    let flyers = TownLayout.make(
      roles: Array(repeating: .flyer, count: 12), screenWidth: 1000, objectWidth: 160)
    #expect(flyers.slots.count == 8)
    #expect(TownLayout.shownScenery(Array(0..<20)) == Array(8..<20))
    #expect(TownLayout.shownScenery([1, 2, 3]) == [1, 2, 3])
    let scenery = TownLayout.make(roles: [], scenery: 30, screenWidth: 1000, objectWidth: 160)
    #expect(scenery.scenery.count == 12)
    let both = TownLayout.make(
      roles: Array(repeating: .animal, count: 8), scenery: 12, screenWidth: 1000, objectWidth: 160)
    #expect(both.slots.count == 8 && both.scenery.count == 12)
  }

  @Test("景色は、まちの幅いっぱいに間をあけて、2つの列に交互に立つ")
  func sceneryPlacement() {
    for count in [1, 2, 5, 8, 12] {
      let layout = TownLayout.make(
        roles: [.animal], scenery: count, screenWidth: 1100, objectWidth: 160)
      let places = layout.scenery
      #expect(places.count == count)
      for place in places {
        #expect(place.x - 80 * place.scale >= 0)
        #expect(place.x + 80 * place.scale <= layout.worldWidth)
        #expect(place.yFraction == TownLayout.sceneryRowY[place.row])
        #expect(place.row == place.index % 2)
      }
      for (a, b) in zip(places, places.dropFirst()) {
        // となりの景色の絵（160 の 70%）が重ならない。
        #expect(b.x - a.x >= 160 * TownLayout.sceneryScale)
      }
    }
  }

  @Test("景色は、動物の草より奥、丘（地平線の0.36）の手前に立ち、動物より小さい")
  func sceneryBehindAnimals() {
    #expect(TownLayout.sceneryRowY.allSatisfy { $0 < 0.36 })
    #expect(TownLayout.sceneryRowY.min()! < TownLayout.animalLaneY.max()!)
    #expect(TownLayout.sceneryScale < TownLayout.scale(yFraction: TownLayout.animalLaneY.max()!))
  }

  @Test("景色が多いときは、まちを少し広げる")
  func sceneryWidensTown() {
    let few = TownLayout.make(roles: [], scenery: 2, screenWidth: 1000, objectWidth: 160)
    let many = TownLayout.make(roles: [], scenery: 12, screenWidth: 1000, objectWidth: 160)
    #expect(few.worldWidth == 1500)
    #expect(many.worldWidth == 2500)
    let full = TownLayout.make(
      roles: Array(repeating: .animal, count: 8), scenery: 12, screenWidth: 1000, objectWidth: 160)
    #expect(full.worldWidth == 3000)
  }
}
