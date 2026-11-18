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
      let table = slot.role == .vehicle ? TownLayout.vehicleLaneY : TownLayout.animalLaneY
      #expect(slot.yFraction == table[slot.lane])
    }
    let vehicles = layout.slots.filter { $0.role == .vehicle }.map(\.lane)
    #expect(vehicles == [0, 1, 2, 0])
  }
}
