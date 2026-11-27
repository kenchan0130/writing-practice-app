import ContentModel
import Testing

@testable import PracticeKit

@Suite("いえの なかの置き場所（D185）")
struct HouseLayoutTests {
  static let words = WordCatalog.all.filter { $0.kind == .furniture }.map(\.text)

  @Test("置き場所は、棚4つ・床2つ・壁2つの 8つ（D82）")
  func capacity() {
    #expect(HouseLayout.totalCapacity == 8)
    for spot in HouseSpot.allCases {
      let slots = HouseLayout.slots(spot)
      #expect(slots.count == HouseLayout.capacity(spot))
      #expect(slots.map(\.index) == Array(0..<slots.count))
      #expect(slots.allSatisfy { $0.spot == spot })
    }
  }

  @Test("どの種類にも、置くことばがある。いえの物は、どれも使い方が決まっている")
  func everyWord() {
    #expect(Self.words.count == 23)
    for spot in HouseSpot.allCases {
      #expect(Self.words.contains { HouseLayout.spot(for: $0) == spot })
    }
    for word in Self.words {
      #expect(HouseLayout.use(for: word) != nil, "\(word)")
    }
    #expect(HouseLayout.spot(for: "とけい") == .wall)
    #expect(HouseLayout.spot(for: "かがみ") == .wall)
    #expect(HouseLayout.spot(for: "いす") == .floor)
    #expect(HouseLayout.spot(for: "ふとん") == .floor)
    #expect(HouseLayout.spot(for: "なべ") == .shelf)
    #expect(HouseLayout.spot(for: "せっけん") == .shelf)
    // ぶんぼうぐ（めぐり School2）は棚に置かれ、つくえに むかうときと同じ動きで使う。
    #expect(HouseLayout.spot(for: "えんぴつ") == .shelf)
    #expect(HouseLayout.use(for: "えんぴつ") == .study)
    #expect(HouseLayout.use(for: "ねんど") == .study)
    // いえの物でないことばには、使い方がない。
    for entry in WordCatalog.all where entry.kind != .furniture {
      #expect(HouseLayout.use(for: entry.text) == nil, "\(entry.text)")
    }
  }

  @Test("置き場所は部屋の中に収まり、棚は棚の上、床は床の上、壁は床より上")
  func insideRoom() {
    for spot in HouseSpot.allCases {
      for slot in HouseLayout.slots(spot) {
        #expect(slot.x > 0.05 && slot.x < 0.95)
        #expect(slot.y > 0 && slot.y < 0.95)
        #expect(slot.scale > 0)
      }
    }
    for slot in HouseLayout.slots(.shelf) {
      #expect(slot.y == HouseLayout.shelfY)
      #expect(slot.x > HouseLayout.shelfMinX && slot.x < HouseLayout.shelfMaxX)
    }
    for slot in HouseLayout.slots(.floor) { #expect(slot.y < HouseLayout.floorTop) }
    for slot in HouseLayout.slots(.wall) { #expect(slot.y > HouseLayout.shelfY) }
  }

  @Test("同じ種類の置き場所は、横に重ならない")
  func noOverlap() {
    for spot in HouseSpot.allCases {
      let xs = HouseLayout.slots(spot).map(\.x).sorted()
      for (a, b) in zip(xs, xs.dropFirst()) { #expect(b - a >= 0.15) }
    }
  }

  @Test("ことばの種類ごとの場所と、上限（D74・D82）")
  func groups() {
    #expect(ShelfGroup.group(kind: .vehicle, word: "くるま") == .roaming)
    #expect(ShelfGroup.group(kind: .flyer, word: "はと") == .roaming)
    #expect(ShelfGroup.group(kind: .scenery, word: "やま") == .scenery)
    #expect(ShelfGroup.group(kind: .swimmer, word: "たこ") == .swimmers)
    #expect(ShelfGroup.group(kind: .plaything, word: "こま") == .park)
    #expect(ShelfGroup.group(kind: .furniture, word: "なべ") == .houseShelf)
    #expect(ShelfGroup.group(kind: .furniture, word: "いす") == .houseFloor)
    #expect(ShelfGroup.group(kind: .furniture, word: "とけい") == .houseWall)
    #expect(ShelfGroup.group(kind: .clothes, word: "ふく") == nil)
    #expect(ShelfGroup.group(kind: .sky, word: "くも") == nil)
    #expect(ShelfGroup.group(kind: .bodyAction, word: "て") == nil)
    #expect(ShelfGroup.roaming.capacity == 8)
    #expect(ShelfGroup.scenery.capacity == 12)
    #expect(ShelfGroup.swimmers.capacity == 6)
    #expect(ShelfGroup.park.capacity == 8)
    #expect(ShelfGroup.house.map(\.capacity).reduce(0, +) == 8)
    // どの種類のことばも、置く場所があるか、置かない種類か。
    for entry in WordCatalog.all {
      let group = ShelfGroup.group(kind: entry.kind, word: entry.text)
      #expect((group == nil) == [.clothes, .sky, .bodyAction].contains(entry.kind))
    }
  }
}
