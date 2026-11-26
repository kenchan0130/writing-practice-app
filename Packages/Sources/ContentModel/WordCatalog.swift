/// ことばの種類。動きの型と置き方の型を決める（D53・D110）。
public enum WordKind: String, Sendable, CaseIterable, Codable {
  /// 乗り物: はずみながら走る。
  case vehicle
  /// 四つ足の動物: 歩く・はねる・たちどまって向きを変える。
  case animal
  /// 服: 着る。ハンガーにかかって揺れる。
  case clothes
  /// 空を飛ぶ物: まちの空をゆったり飛ぶ（D168）。
  case flyer
  /// 景色になる物: 草の上に立って、ゆれる（D168）。
  case scenery
}

/// ことば 1つ（絵は持たない。絵はアプリ側）。
public struct WordEntry: Sendable, Hashable {
  public let text: String
  public let kind: WordKind

  public init(_ text: String, _ kind: WordKind) {
    self.text = text
    self.kind = kind
  }
}

/// M0 後半の約20語（D78）に、D167 で14語、D168 で14語を足した。
public enum WordCatalog {
  public static let all: [WordEntry] =
    ["そり", "くるま", "ふね", "でんしゃ", "じてんしゃ", "しんかんせん", "いかだ", "しょうぼうしゃ", "きゅうきゅうしゃ"].map {
      WordEntry($0, .vehicle)
    }
    + [
      "うし", "いぬ", "ねこ", "うま", "くま", "しか", "りす", "さる", "ぞう", "とら", "かば", "きりん", "らくだ", "ぶた", "ひつじ",
      "たぬき", "きつね", "うさぎ",
    ].map { WordEntry($0, .animal) }
    + ["ふく", "くつ", "ぼうし", "ゆかた", "くつした", "きもの"].map { WordEntry($0, .clothes) }
    + ["ひこうき", "ききゅう", "はと", "すずめ", "からす"].map { WordEntry($0, .flyer) }
    + [
      "さくら", "ひまわり", "たんぽぽ", "りんご", "みかん", "いちご", "にんじん", "だいこん", "かぼちゃ",
    ].map { WordEntry($0, .scenery) }

  public static func entry(for text: String) -> WordEntry? {
    all.first { $0.text == text }
  }

  /// その字を含むことば（字のカードに出す。D101）。
  public static func words(containing char: Character) -> [WordEntry] {
    all.filter { $0.text.contains(char) }
  }
}
