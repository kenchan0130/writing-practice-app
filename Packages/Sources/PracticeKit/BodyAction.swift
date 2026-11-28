import ContentModel
import Foundation

/// 体のことばを書いたときに、主人公が見せる動き（D175）。
public enum BodyMotion: String, Sendable, CaseIterable, Hashable {
  /// て: 手を振る。
  case wave
  /// あし: 2回ジャンプする。
  case jump
  /// め: まばたき（ウインク）をして、きょろきょろ見る。
  case look
  /// みみ: 首をかしげて、音を聞く。小さな ♪。
  case listen
  /// くち: 口を大きく あけて「あー」。♪ を歌う。
  case sing
  /// あたま: うなずく（頭を上下に ふる）。
  case nod
  /// おなか: おなかを ゆらす。「ぐう」のあわ。
  case belly
  /// ほっぺ: ほっぺをふくらませて、ぷにっと ゆれる。
  case puff
}

/// 体のことばを書いた記録（ことば と 書いた時刻）。
public struct BodyRecord: Sendable, Hashable {
  public let word: String
  public let date: Date

  public init(word: String, date: Date) {
    self.word = word
    self.date = date
  }
}

/// 「書いたすぐあと、まちで主人公が その動きを見せる」の決まり（D175）。画面に頼らない計算。
/// 体のことばを書いてから 10 分の間にまちを開くと、主人公がそのことばの動きを、まちが開いたとき 1 回だけ見せる。
/// まちには置かない（D74: 増えない）。書き直せば、また見せる。
public enum BodyAction {
  /// 書いてから、この秒数のあいだにまちを開くと見える（空のことば D172 と同じ）。
  public static let window: TimeInterval = SkyWeather.window

  /// ことばごとの動き。体のことばでなければ nil。
  public static func motion(for word: String) -> BodyMotion? {
    // えいごの ことば（sun・moon・star）は、借りた日本語のことばと同じ（D199）。
    switch EnglishWords.base(of: word) {
    case "て": .wave
    case "あし": .jump
    case "め": .look
    case "みみ": .listen
    case "くち": .sing
    case "あたま": .nod
    case "おなか": .belly
    case "ほっぺ": .puff
    default: nil
    }
  }

  /// 記録のうち、いちばん新しい体のことば。
  public static func latest(in records: [BodyRecord]) -> BodyRecord? {
    records.filter { motion(for: $0.word) != nil }.max { $0.date < $1.date }
  }

  /// いま見せる動き（なければ nil）。
  /// - Parameters:
  ///   - playedAt: その動きを見せた時刻（まだなら nil）。同じ記録の動きは 1 回しか見せない。
  ///     書いたことばが新しくなったら（見せた時刻より後なら）、また見せる。
  public static func pending(
    records: [BodyRecord], now: Date, playedAt: Date? = nil
  ) -> BodyMotion? {
    guard let record = latest(in: records), let motion = motion(for: record.word) else {
      return nil
    }
    // 時計がずれて、書いた時刻が先になっていても、書いたばかりとして見る。
    guard now.timeIntervalSince(record.date) <= window else { return nil }
    if let playedAt, playedAt >= record.date { return nil }
    return motion
  }
}
