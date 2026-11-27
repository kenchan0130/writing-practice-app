import ContentModel
import Foundation
import PracticeKit
import RecordKit

/// まちと いえに出ている物と、おもちゃばこの中身（D74・D82・D185）。
/// 手に入れた物の行と「出した」「しまった」の行から、場所ごとに計算する（計算は `ToyBox`）。
struct ToyBoxBoard {
  private let objects: [UUID: PlacedObject]
  private let items: [ShelfGroup: [ToyBoxItem]]
  private let shelves: [ShelfGroup: ToyBoxShelf]

  init(placed: [PlacedObject], moves: [ToyBoxMove]) {
    var objects: [UUID: PlacedObject] = [:]
    var grouped: [ShelfGroup: [ToyBoxItem]] = [:]
    for object in placed {
      guard let group = ShelfGroup.group(kind: object.kind, word: object.word) else { continue }
      objects[object.id] = object
      grouped[group, default: []].append(
        ToyBoxItem(id: object.id, word: object.word, date: object.date))
    }
    // 同じことばの物は、新しい3つまで（D74）。
    // 季節の飾りは増やさず、いちばん新しい 1つ（`ShelfGroup.perWord`）。
    let items = Dictionary(
      uniqueKeysWithValues: grouped.map { ($0.key, ToyBox.newestPerWord($0.value, limit: $0.key.perWord)) })
    self.objects = objects
    self.items = items
    shelves = Dictionary(
      uniqueKeysWithValues: ShelfGroup.allCases.map { group in
        (group, ToyBox.arrange(items: items[group] ?? [], moves: moves, capacity: group.capacity))
      })
  }

  /// その場所に出ている物と、置き場所の番号（番号の順）。
  func shown(_ group: ShelfGroup) -> [(object: PlacedObject, slot: Int)] {
    guard let shelf = shelves[group] else { return [] }
    return shelf.slots.enumerated().compactMap { slot, id in
      id.flatMap { objects[$0] }.map { (object: $0, slot: slot) }
    }
  }

  /// おもちゃばこの中（出していた時間が新しい順に、場所ごと）。
  func boxed(_ groups: [ShelfGroup]) -> [PlacedObject] {
    groups.flatMap { group in (shelves[group]?.boxed ?? []).compactMap { objects[$0] } }
  }

  /// おもちゃばこの物を出すときに足す行。
  func takeOut(_ id: UUID, moves: [ToyBoxMove], date: Date) -> [ToyBoxMove] {
    guard let object = objects[id],
      let group = ShelfGroup.group(kind: object.kind, word: object.word)
    else { return [] }
    return ToyBox.takeOut(
      id, items: items[group] ?? [], moves: moves, capacity: group.capacity, date: date)
  }
}
