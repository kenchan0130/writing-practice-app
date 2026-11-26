/// 季節（日本の四季。D54）。
public enum Season: String, Sendable, CaseIterable, Codable {
  case spring
  case summer
  case autumn
  case winter

  /// 月（1〜12）から季節。春は3〜5月、夏は6〜8月、秋は9〜11月、冬は12〜2月。
  public static func of(month: Int) -> Season {
    switch month {
    case 3...5: .spring
    case 6...8: .summer
    case 9...11: .autumn
    default: .winter
    }
  }
}

/// ことばの季節の印（D182）。だれが見ても「この季節」と分かることばだけに付ける。
/// 印のないことばは、いつでも出してよい。使うのは「きょうの ことば」だけで、
/// iPad の地域が日本のときに限る（D54）。
public enum WordSeason {
  private static let table: [String: Season] = [
    "さくら": .spring, "たんぽぽ": .spring, "いちご": .spring,
    "ひまわり": .summer, "あさがお": .summer, "すいか": .summer, "せみ": .summer,
    "ほたる": .summer, "かぶとむし": .summer, "ゆかた": .summer,
    "とんぼ": .autumn, "くり": .autumn, "どんぐり": .autumn, "ぶどう": .autumn, "きのこ": .autumn,
    "ゆき": .winter, "みかん": .winter,
  ]

  /// そのことばの季節。印がなければ nil。
  public static func season(of word: String) -> Season? { table[word] }

  /// 印のあることば（テスト・一覧用）。
  public static var tagged: [String: Season] { table }
}
