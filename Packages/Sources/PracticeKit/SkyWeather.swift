import ContentModel
import Foundation

/// まちの空が変わるときの、見せ方の種類（D172）。
public enum SkyEffect: String, Sendable, CaseIterable, Hashable {
  /// くも: 大きい雲がたくさん流れる。
  case cloudy
  /// あめ: やわらかい雨と、少しグレーの空。
  case rain
  /// ゆき: 雪が降る。
  case snow
  /// かみなり: グレーの空に、ときどき やさしい光と、小さないなずま。
  case thunder
  /// にじ: 丘の上に虹。
  case rainbow
  /// かぜ: 雲と葉が横へ流れる。
  case wind
  /// たいよう: 笑った大きな太陽。光が回る。
  case sun
  /// ほし: 夜の空に、またたく星。
  case stars
  /// つき: 夜の空に、大きな月。
  case moon
  /// うちゅうじん: 夜の空を、UFO が横切る。
  case ufo
}

/// 空のことばを書いた記録（ことば と 書いた時刻）。
public struct SkyRecord: Sendable, Hashable {
  public let word: String
  public let date: Date

  public init(word: String, date: Date) {
    self.word = word
    self.date = date
  }
}

/// いま見せる空。
public struct SkyForecast: Sendable, Equatable {
  public let effect: SkyEffect
  /// 見せはじめた時刻（まちが開いたとき）。
  public let since: Date
  /// あと何秒見せるか（0 より大きい）。
  public let remaining: TimeInterval
}

/// 「しばらくのあいだ、空が変わる」の決まり（D172）。画面に頼らない計算。
/// 空のことばを書いてから 10 分の間にまちを開くと、そのことばの空が 40 秒だけ見える。
/// 40 秒たつと、ふつうの空にもどる。書き直せば、また見える（D74: 物は増えない）。
public enum SkyWeather {
  /// 書いてから、この秒数のあいだにまちを開くと見える。
  public static let window: TimeInterval = 600
  /// 見せる長さ（秒）。そのうち、最後の `fade` 秒でゆっくり消える。
  public static let duration: TimeInterval = 40
  public static let fade: TimeInterval = 3

  /// ことばごとの空。空のことばでなければ nil。
  public static func effect(for word: String) -> SkyEffect? {
    switch word {
    case "くも": .cloudy
    case "あめ": .rain
    case "ゆき": .snow
    case "かみなり": .thunder
    case "にじ": .rainbow
    case "かぜ": .wind
    case "たいよう": .sun
    case "ほし": .stars
    case "つき": .moon
    case "うちゅうじん": .ufo
    default: nil
    }
  }

  /// 記録のうち、いちばん新しい空のことば。
  public static func latest(in records: [SkyRecord]) -> SkyRecord? {
    records.filter { effect(for: $0.word) != nil }.max { $0.date < $1.date }
  }

  /// いま見せる空（なければ nil）。
  /// - Parameters:
  ///   - shownSince: そのことばの空を見せはじめた時刻（まだなら nil）。書いたことばが新しくなったら、はじめから見せる。
  public static func forecast(
    records: [SkyRecord], now: Date, shownSince: Date? = nil
  ) -> SkyForecast? {
    guard let record = latest(in: records), let effect = effect(for: record.word) else {
      return nil
    }
    // 時計がずれて、書いた時刻が先になっていても、書いたばかりとして見る。
    guard now.timeIntervalSince(record.date) <= window else { return nil }
    let since: Date
    if let shownSince, shownSince >= record.date {
      since = shownSince
    } else {
      since = now
    }
    let remaining = duration - now.timeIntervalSince(since)
    guard remaining > 0 else { return nil }
    return SkyForecast(effect: effect, since: since, remaining: remaining)
  }
}
