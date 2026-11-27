import Foundation

/// おもちゃばこの計算（D74・D82・D185）。画面や保存の仕組みに頼らない部品。
///
/// まちや いえに出せる数には上限がある。超えた物は、その場所の おもちゃばこに入る。
/// どれを出すかは、行（手に入れた行と「出した」「しまった」の行）から、いつも同じ計算で決める。
/// 行は足すだけで、消さない（D44）。2台の iPad の行を合わせても、同じ結果になる（D82）。

/// 「出した」「しまった」の記録（D82）。
public struct ToyBoxMove: Sendable, Hashable, Codable, Identifiable {
  public enum Action: String, Sendable, Hashable, Codable {
    /// おもちゃばこから出した。
    case takeOut
    /// おもちゃばこにしまった。
    case putAway
  }

  public var id: UUID
  public var date: Date
  /// 動かした物（手に入れた行の ID）。
  public var objectID: UUID
  public var action: Action

  public init(id: UUID = UUID(), date: Date, objectID: UUID, action: Action) {
    self.id = id
    self.date = date
    self.objectID = objectID
    self.action = action
  }
}

/// 手に入れた物 1つ（手に入れた行）。
public struct ToyBoxItem: Sendable, Hashable, Identifiable {
  public var id: UUID
  public var word: String
  /// 手に入れた（ことばを書いた）時間。
  public var date: Date

  public init(id: UUID, word: String, date: Date) {
    self.id = id
    self.word = word
    self.date = date
  }
}

/// 1か所の並び: 置き場所ごとの物と、おもちゃばこの中身。
public struct ToyBoxShelf: Sendable, Equatable {
  /// 置き場所ごとの物（空いていれば nil）。数は、その場所の上限。
  public var slots: [UUID?]
  /// おもちゃばこの中（出していた時間が新しい順）。
  public var boxed: [UUID]

  public init(slots: [UUID?], boxed: [UUID]) {
    self.slots = slots
    self.boxed = boxed
  }

  /// 出している物（置き場所の番号の順）。
  public var shown: [UUID] { slots.compactMap { $0 } }

  /// その物の置き場所の番号。出していなければ nil。
  public func slot(of id: UUID) -> Int? { slots.firstIndex(of: id) }
}

public enum ToyBox {
  /// 同じことばの物は3つまで（D74）。
  public static let maxPerWord = 3

  /// 同じことばの物は、新しい `limit` 個だけ残す（D74・D82）。並びは変えない。
  /// 古い物の行は消さない（ここでは数えないだけ）。
  public static func newestPerWord(_ items: [ToyBoxItem], limit: Int = maxPerWord) -> [ToyBoxItem] {
    var keep = Set<UUID>()
    for (_, group) in Dictionary(grouping: items, by: \.word) {
      for item in group.sorted(by: isOlder).suffix(max(limit, 0)) { keep.insert(item.id) }
    }
    return items.filter { keep.contains($0.id) }
  }

  /// 行から、1か所の並びを計算する（D82）。
  ///
  /// - 手に入れた物と、出した物は、空いている置き場所（番号の小さい順）に入る。
  /// - いっぱいなら、出してからいちばん長い物が おもちゃばこに入り、その置き場所に入る。
  /// - しまった物の置き場所には、おもちゃばこの中の、いちばん新しく出していた物が入る。
  /// - 時間が同じ行は、物の ID の順（どの iPad でも同じ順）。
  public static func arrange(items: [ToyBoxItem], moves: [ToyBoxMove], capacity: Int) -> ToyBoxShelf
  {
    let capacity = max(capacity, 0)
    var seen = Set<UUID>()
    let items = items.filter { seen.insert($0.id).inserted }
    let known = Set(items.map(\.id))
    var seenMoves = Set<UUID>()
    var events: [Event] = items.map { Event(date: $0.date, object: $0.id, order: 0) }
    for move in moves where known.contains(move.objectID) && seenMoves.insert(move.id).inserted {
      events.append(
        Event(date: move.date, object: move.objectID, order: move.action == .takeOut ? 1 : 2))
    }
    events.sort {
      if $0.date != $1.date { return $0.date < $1.date }
      if $0.order != $1.order { return $0.order < $1.order }
      return $0.object.uuidString < $1.object.uuidString
    }

    var slots = [UUID?](repeating: nil, count: capacity)
    /// 最後に出した順の番号（大きいほど新しい）。
    var lastOut: [UUID: Int] = [:]
    /// 自分でしまった物。
    var stored = Set<UUID>()
    var arrived = Set<UUID>()

    func oldestSlot() -> Int? {
      slots.indices.min { a, b in
        (slots[a].flatMap { lastOut[$0] } ?? -1) < (slots[b].flatMap { lastOut[$0] } ?? -1)
      }
    }

    for (step, event) in events.enumerated() {
      let id = event.object
      switch event.order {
      case 0, 1:
        arrived.insert(id)
        stored.remove(id)
        lastOut[id] = step
        guard capacity > 0, !slots.contains(id) else { continue }
        if let free = slots.firstIndex(of: nil) {
          slots[free] = id
        } else if let oldest = oldestSlot() {
          slots[oldest] = id
        }
      default:
        guard arrived.contains(id) else { continue }
        stored.insert(id)
        guard let index = slots.firstIndex(of: id) else { continue }
        let waiting = arrived.filter { !slots.contains($0) && $0 != id }
        let next =
          waiting.filter { !stored.contains($0) }.max { lastOut[$0] ?? -1 < lastOut[$1] ?? -1 }
          ?? waiting.max { lastOut[$0] ?? -1 < lastOut[$1] ?? -1 }
        slots[index] = next
      }
    }
    let boxed = items.map(\.id).filter { !slots.contains($0) }
      .sorted { lastOut[$0] ?? -1 > lastOut[$1] ?? -1 }
    return ToyBoxShelf(slots: slots, boxed: boxed)
  }

  /// おもちゃばこの物を出すときに足す行（D74・D82）。
  /// 出す物の「出した」と、入れ替わりでしまわれる物（出してからいちばん長い物）の「しまった」。
  /// もう出ている物・知らない物なら、何も足さない。
  public static func takeOut(
    _ id: UUID, items: [ToyBoxItem], moves: [ToyBoxMove], capacity: Int, date: Date
  ) -> [ToyBoxMove] {
    let before = arrange(items: items, moves: moves, capacity: capacity)
    guard before.boxed.contains(id), capacity > 0 else { return [] }
    // iPad の時計がずれていても、いちばん新しい行になるようにする。
    let latest = (items.map(\.date) + moves.map(\.date)).max() ?? date
    let date = max(date, latest.addingTimeInterval(0.001))
    let out = ToyBoxMove(date: date, objectID: id, action: .takeOut)
    let after = arrange(items: items, moves: moves + [out], capacity: capacity)
    let displaced = before.shown.filter { !after.shown.contains($0) }
    return [out] + displaced.map { ToyBoxMove(date: date, objectID: $0, action: .putAway) }
  }

  private struct Event {
    let date: Date
    let object: UUID
    /// 0 = 手に入れた、1 = 出した、2 = しまった。
    let order: Int
  }

  private static func isOlder(_ a: ToyBoxItem, _ b: ToyBoxItem) -> Bool {
    a.date != b.date ? a.date < b.date : a.id.uuidString < b.id.uuidString
  }
}
