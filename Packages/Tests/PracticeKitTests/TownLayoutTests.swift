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

  // MARK: 水べ（D170）

  @Test("水の生きものがいなければ、水べはなく、まちの幅は今までどおり")
  func noWaterWithoutSwimmers() {
    let layout = TownLayout.make(roles: [], screenWidth: 1000, objectWidth: 160)
    #expect(layout.water == nil)
    #expect(layout.swimSlots.isEmpty)
    #expect(layout.worldWidth == layout.landWidth)
  }

  @Test("水の生きものがいれば、右はしに水べが広がり、陸の幅は変わらない")
  func waterAtTheEnd() throws {
    let plain = TownLayout.make(roles: Self.mixed, screenWidth: 1000, objectWidth: 160)
    let layout = TownLayout.make(
      roles: Self.mixed, swimmers: 3, screenWidth: 1000, objectWidth: 160)
    let water = try #require(layout.water)
    #expect(layout.landWidth == plain.worldWidth)
    #expect(water.minX == layout.landWidth)
    #expect(water.maxX == layout.worldWidth)
    #expect(water.swimMinX > water.minX)
    #expect(layout.slots == plain.slots)
    // 陸の物は水べに入らない。
    for slot in layout.slots { #expect(slot.maxX + 80 <= layout.landWidth) }
  }

  @Test("水の生きものは新しい6つまで（別の上限）")
  func swimmerCap() {
    #expect(TownLayout.maxSwimmers == 6)
    #expect(TownLayout.shownSwimmers(Array(0..<10)) == Array(4..<10))
    let layout = TownLayout.make(
      roles: Array(repeating: .animal, count: 8), swimmers: 20, screenWidth: 1000,
      objectWidth: 160)
    #expect(layout.slots.count == 8)
    #expect(layout.swimSlots.count == 6)
  }

  @Test("水の生きものは3つの段を順に回り、同じ段の持ち場は重ならない")
  func swimLanes() {
    for count in 1...6 {
      let layout = TownLayout.make(roles: [], swimmers: count, screenWidth: 1100, objectWidth: 160)
      #expect(layout.swimSlots.map(\.lane) == (0..<count).map { $0 % 3 })
      for a in layout.swimSlots {
        #expect(a.yFraction == TownLayout.swimLaneY[a.lane])
        for b in layout.swimSlots where a.index < b.index && a.lane == b.lane {
          // 中心の動く範囲が重ならず、絵（160）も重ならない。
          #expect(b.minX - a.maxX >= 160)
        }
      }
    }
  }

  @Test("水の生きものは、水の中だけを動く")
  func swimmersStayInWater() throws {
    for count in 1...6 {
      let layout = TownLayout.make(
        roles: Self.mixed, swimmers: count, screenWidth: 1100, objectWidth: 160)
      let water = try #require(layout.water)
      for slot in layout.swimSlots {
        #expect(slot.minX - 80 >= water.swimMinX)
        #expect(slot.maxX + 80 <= water.maxX)
        #expect(slot.minX <= slot.startX && slot.startX <= slot.maxX)
        // 水面（地平線の0.36）より下に、絵がほぼ収まる。
        #expect(slot.yFraction + 0.09 <= 0.38)
        #expect(slot.yFraction - 0.09 >= 0)
      }
    }
  }

  // MARK: こうえん（D173）

  @Test("こうえんの物がなければ、こうえんはなく、まちの幅は今までどおり")
  func noParkWithoutPlaythings() {
    let layout = TownLayout.make(roles: Self.mixed, screenWidth: 1000, objectWidth: 160)
    #expect(layout.park == nil)
    #expect(layout.parkSlots.isEmpty)
    #expect(layout.landMinX == 0)
    #expect(layout.worldWidth == layout.landWidth)
  }

  @Test("こうえんの物があれば、左はしにこうえんが広がり、陸のまちはその分だけ右へ動く")
  func parkAtTheStart() throws {
    let plain = TownLayout.make(roles: Self.mixed, screenWidth: 1000, objectWidth: 160)
    let layout = TownLayout.make(
      roles: Self.mixed, playthings: 3, screenWidth: 1000, objectWidth: 160)
    let park = try #require(layout.park)
    #expect(park.minX == 0)
    #expect(park.maxX == 900)
    #expect(layout.landMinX == park.maxX)
    #expect(layout.landWidth == plain.landWidth)
    #expect(layout.worldWidth == plain.worldWidth + park.maxX)
    // 陸の物は、こうえんに入らず、陸の中にいる。
    for (a, b) in zip(layout.slots, plain.slots) {
      #expect(a.minX == b.minX + park.maxX)
      #expect(a.maxX == b.maxX + park.maxX)
      #expect(a.startX == b.startX + park.maxX)
      #expect(a.minX - 80 >= park.maxX)
      #expect(a.maxX + 80 <= layout.worldWidth)
    }
    for (a, b) in zip(layout.scenery, plain.scenery) { #expect(a.x == b.x + park.maxX) }
  }

  @Test("こうえんと水べが両方あると、まちは両はしに広がる")
  func parkAndWater() throws {
    let layout = TownLayout.make(
      roles: Self.mixed, swimmers: 2, playthings: 2, screenWidth: 1000, objectWidth: 160)
    let park = try #require(layout.park)
    let water = try #require(layout.water)
    #expect(water.minX == park.maxX + layout.landWidth)
    #expect(layout.worldWidth == water.maxX)
    for slot in layout.slots { #expect(slot.maxX + 80 <= water.minX) }
  }

  @Test("こうえんの置き場所は8つで、同じ列の物は重ならず、こうえんの中に収まる")
  func parkSlotsFit() throws {
    #expect(TownLayout.maxPlaythings == 8)
    for count in 1...8 {
      let layout = TownLayout.make(
        roles: [], playthings: count, screenWidth: 1100, objectWidth: 160)
      let park = try #require(layout.park)
      // 物の数によらず、置き場所はいつも8つ（場所ごとに決まっている）。
      #expect(layout.parkSlots.count == 8)
      #expect(layout.parkSlots.map(\.index) == Array(0..<8))
      for a in layout.parkSlots {
        #expect(a.x - 80 >= park.minX)
        #expect(a.x + 80 <= park.maxX)
        #expect(a.yFraction == TownLayout.parkRowY[a.row])
        // 草の上（地平線 0.36）に、物の足もとがある。
        #expect(a.yFraction > 0 && a.yFraction < 0.36)
        for b in layout.parkSlots where a.index < b.index {
          if a.row == b.row {
            #expect(abs(a.x - b.x) >= 160 * a.scale)
          } else {
            // 列がちがう物は、足もとの高さがちがう。
            #expect(a.yFraction != b.yFraction)
            #expect(a.x != b.x)
          }
        }
      }
    }
  }

  @Test("こうえんの物は新しい8つまで（別の上限）。置き場所は置いた順で決まる")
  func playthingCap() {
    #expect(TownLayout.shownPlaythings(Array(0..<12)) == Array(4..<12))
    #expect(TownLayout.shownPlaythings([1, 2]) == [1, 2])
    #expect(
      (0..<10).map { TownLayout.parkSlotIndex(ordinal: $0) } == [0, 1, 2, 3, 4, 5, 6, 7, 0, 1])
    // 見えている8つは、いつも8つの別々の置き場所に入る。
    let slots = Set((5..<13).map { TownLayout.parkSlotIndex(ordinal: $0) })
    #expect(slots.count == 8)
    let layout = TownLayout.make(
      roles: Array(repeating: .animal, count: 8), scenery: 12, swimmers: 6, playthings: 20,
      screenWidth: 1000, objectWidth: 160)
    #expect(layout.slots.count == 8)
    #expect(layout.scenery.count == 12)
    #expect(layout.swimSlots.count == 6)
    #expect(layout.parkSlots.count == 8)
  }
}
