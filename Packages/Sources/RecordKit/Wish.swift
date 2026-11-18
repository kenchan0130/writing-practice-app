import Foundation

/// 子どもの「おねがい」（D54・D160）。鍵のかかった字で「おとなのひとに おねがいする」を押した記録。
/// 押した事実だけを残す。購入画面は開かない。
public struct Wish: Sendable, Hashable, Identifiable {
  public var id: UUID
  public var profileID: UUID
  /// 何をやりたがったか。購入できる単位（パック）の名前（例: `katakana`・`abc`）。
  public var item: String
  public var date: Date

  public init(id: UUID = UUID(), profileID: UUID, item: String, date: Date) {
    self.id = id
    self.profileID = profileID
    self.item = item
    self.date = date
  }
}

/// 保護者用の画面に出す「やりたがっています」のお知らせ1つ。
public struct WishNotice: Sendable, Hashable, Identifiable {
  public var profileID: UUID
  public var item: String
  /// 最後に押した日だけ。回数は持たない（保護者を急かさないため。D54）。
  public var date: Date

  public var id: String { "\(profileID.uuidString)/\(item)" }

  public init(profileID: UUID, item: String, date: Date) {
    self.profileID = profileID
    self.item = item
    self.date = date
  }
}

extension WishNotice {
  /// おねがいの一覧から、お知らせを作る（D160）。
  /// - 同じ子・同じものを何度押しても、いちばん新しい日の1つにまとめる。
  /// - すでに買ったもの（`isOwned`）のお知らせは出さない。
  /// - 新しい日のものを上に並べる。
  public static func notices(from wishes: [Wish], isOwned: (String) -> Bool = { _ in false })
    -> [WishNotice]
  {
    var latest: [String: WishNotice] = [:]
    for wish in wishes where !isOwned(wish.item) {
      let notice = WishNotice(profileID: wish.profileID, item: wish.item, date: wish.date)
      if let existing = latest[notice.id], existing.date >= notice.date { continue }
      latest[notice.id] = notice
    }
    return latest.values.sorted {
      $0.date != $1.date ? $0.date > $1.date : $0.id < $1.id
    }
  }

  /// 「11月15日」の形の日付（回数や時刻は出さない）。
  public static func dateText(_ date: Date, calendar: Calendar = .current) -> String {
    let parts = calendar.dateComponents([.month, .day], from: date)
    return "\(parts.month ?? 1)月\(parts.day ?? 1)日"
  }

  /// 保護者用の画面の文（ふつうの日本語。D157）。
  /// 例:「はなちゃんが、カタカナをやりたがっています（11月15日）」。
  /// `name` が空なら「お子さま」にする。
  public func text(name: String, itemTitle: String, calendar: Calendar = .current) -> String {
    let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
    let who = trimmed.isEmpty ? "お子さま" : trimmed
    return "\(who)が、\(itemTitle)をやりたがっています（\(Self.dateText(date, calendar: calendar))）"
  }
}
