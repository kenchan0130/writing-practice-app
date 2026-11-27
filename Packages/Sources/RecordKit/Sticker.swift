import Foundation

/// ステッカーの記録（§3.3・§3.5・D54）。画面や保存の仕組みに頼らない部品。
///
/// 「おたのしみ ボックス」から出たステッカーと、貼った・はがした を、追加するだけの行で持つ（D44）。
/// いまどこに貼ってあるかは、行から いつも同じ計算で決める。2台の iPad の行を合わせても同じ結果になる（D82）。
public struct StickerEvent: Sendable, Hashable, Codable, Identifiable {
  public enum Action: String, Sendable, Hashable, Codable {
    /// おたのしみ ボックスから出た（手に入れた）。
    case earned
    /// 貼った（場所を変えたときも、この行を足す）。
    case placed
    /// はがした。
    case removed
  }

  /// 貼るところ。
  public enum Surface: String, Sendable, Hashable, Codable, CaseIterable {
    /// わたしのまち。
    case town
    /// ずかんの表紙。
    case zukan
  }

  public var id: UUID
  public var date: Date
  public var action: Action
  /// どのステッカーの行か（手に入れた行の ID。手に入れた行では `id` と同じ）。
  public var itemID: UUID
  /// 絵の名前（手に入れた行だけ。例: `hoshi`）。
  public var sticker: String
  /// 貼ったところ（貼った行だけ）。
  public var surface: Surface?
  /// 貼った位置（貼った行だけ）。単位は貼るところが決める。
  public var x: Double
  public var y: Double

  public init(
    id: UUID = UUID(), date: Date, action: Action, itemID: UUID? = nil, sticker: String = "",
    surface: Surface? = nil, x: Double = 0, y: Double = 0
  ) {
    self.id = id
    self.date = date
    self.action = action
    self.itemID = itemID ?? id
    self.sticker = sticker
    self.surface = surface
    self.x = x
    self.y = y
  }
}

/// 貼ってある場所。
public struct StickerPlacement: Sendable, Hashable {
  public var surface: StickerEvent.Surface
  public var x: Double
  public var y: Double

  public init(surface: StickerEvent.Surface, x: Double, y: Double) {
    self.surface = surface
    self.x = x
    self.y = y
  }
}

/// 持っているステッカー 1枚。
public struct OwnedSticker: Sendable, Hashable, Identifiable {
  /// 手に入れた行の ID。
  public var id: UUID
  /// 絵の名前。
  public var sticker: String
  /// 手に入れた時間。
  public var date: Date
  /// 貼ってある場所。貼っていなければ nil（ステッカーの入れ物の中）。
  public var placement: StickerPlacement?

  public init(id: UUID, sticker: String, date: Date, placement: StickerPlacement? = nil) {
    self.id = id
    self.sticker = sticker
    self.date = date
    self.placement = placement
  }
}

/// おたのしみ ボックスの、きょうの状態。
public enum TreatBoxState: String, Sendable, Hashable {
  /// きょうの もくひょうに、まだ届いていない。
  case notYet
  /// あけられる。
  case ready
  /// きょうは もう あけた。
  case opened
}

public enum StickerBook {
  /// 行から、持っているステッカーと、貼ってある場所を計算する（手に入れた順）。
  /// - 同じ ID の行は 1つに数える。
  /// - 貼った・はがした は、いちばん新しい行が勝つ（時間が同じなら、行の ID の順）。
  /// - 手に入れた行のないステッカーの行は、数えない。
  public static func owned(_ events: [StickerEvent]) -> [OwnedSticker] {
    var seen = Set<UUID>()
    let events = events.filter { seen.insert($0.id).inserted }.sorted(by: isOlder)
    var order: [UUID] = []
    var owned: [UUID: OwnedSticker] = [:]
    for event in events where event.action == .earned && owned[event.id] == nil {
      order.append(event.id)
      owned[event.id] = OwnedSticker(id: event.id, sticker: event.sticker, date: event.date)
    }
    for event in events where owned[event.itemID] != nil {
      switch event.action {
      case .earned: break
      case .placed:
        guard let surface = event.surface else { continue }
        owned[event.itemID]?.placement = StickerPlacement(surface: surface, x: event.x, y: event.y)
      case .removed:
        owned[event.itemID]?.placement = nil
      }
    }
    return order.compactMap { owned[$0] }
  }

  /// きょう、おたのしみ ボックスを あけたか（きょう手に入れた行があるか）。
  public static func openedToday(_ events: [StickerEvent], now: Date, calendar: Calendar) -> Bool {
    let start = calendar.startOfDay(for: now)
    guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return false }
    return events.contains { $0.action == .earned && $0.date >= start && $0.date < end }
  }

  /// おたのしみ ボックスの状態（§3.5）。目標に届いた日に、1回だけ あけられる。
  /// - Parameters:
  ///   - practiced: きょう練習した字の数（同じ字は1つ）。
  ///   - goal: きょうの もくひょう（字の数）。
  public static func boxState(
    practiced: Int, goal: Int, events: [StickerEvent], now: Date, calendar: Calendar
  ) -> TreatBoxState {
    if openedToday(events, now: now, calendar: calendar) { return .opened }
    return practiced >= max(goal, 1) ? .ready : .notYet
  }

  /// 貼る位置を、貼るところの中（0〜`maxX`、0〜1）におさめる。
  public static func clamped(x: Double, y: Double, maxX: Double = 1) -> (x: Double, y: Double) {
    let x = x.isFinite ? x : 0
    let y = y.isFinite ? y : 0
    return (min(max(x, 0), max(maxX, 0)), min(max(y, 0), 1))
  }

  private static func isOlder(_ a: StickerEvent, _ b: StickerEvent) -> Bool {
    a.date != b.date ? a.date < b.date : a.id.uuidString < b.id.uuidString
  }
}
