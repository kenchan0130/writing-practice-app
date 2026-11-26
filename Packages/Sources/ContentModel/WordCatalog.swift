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
  /// 水の中の生きもの: まちの水べで泳ぐ・ういている（D170）。
  case swimmer
  /// 空を変える物: まちに置かず、しばらくのあいだ まちの空が変わる（D172）。
  case sky
  /// キャラクターが使う物: まちのこうえんで、キャラクターが使って遊ぶ（D173）。
  case plaything
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

/// M0 後半の約20語（D78）に、D167 で14語、D168 で14語、D169 で18語、D170 で13語、D172 で10語、D173 で15語、D174 で18語を足した。
public enum WordCatalog {
  public static let all: [WordEntry] =
    ["そり", "くるま", "ふね", "でんしゃ", "じてんしゃ", "しんかんせん", "いかだ", "しょうぼうしゃ", "きゅうきゅうしゃ"].map {
      WordEntry($0, .vehicle)
    }
    + [
      "うし", "いぬ", "ねこ", "うま", "くま", "しか", "りす", "さる", "ぞう", "とら", "かば", "きりん", "らくだ", "ぶた", "ひつじ",
      "たぬき", "きつね", "うさぎ", "かぶとむし", "てんとうむし", "かたつむり",
    ].map { WordEntry($0, .animal) }
    + ["ふく", "くつ", "ぼうし", "ゆかた", "くつした", "きもの"].map { WordEntry($0, .clothes) }
    + [
      "ひこうき", "ききゅう", "はと", "すずめ", "からす", "ちょう", "とんぼ", "はち", "ほたる", "せみ",
    ].map { WordEntry($0, .flyer) }
    + [
      "さくら", "ひまわり", "たんぽぽ", "りんご", "みかん", "いちご", "にんじん", "だいこん", "かぼちゃ",
      "もも", "ぶどう", "すいか", "くり", "だんご", "せんべい", "わたあめ", "おにぎり", "すし", "うどん",
      "あさがお", "ばら",
      "やま", "たき", "いし", "いけ",
      "くさ", "まつ", "どんぐり", "はっぱ", "きのこ",
      "いえ", "がっこう", "びょういん", "おしろ",
      "しんごう", "ふみきり", "がいとう",
    ].map { WordEntry($0, .scenery) }
    + [
      "たこ", "いか", "かに", "かめ", "くじら", "くらげ", "いるか", "さかな", "ひとで",
      "かえる", "めだか", "ざりがに", "おたまじゃくし",
    ].map { WordEntry($0, .swimmer) }
    + [
      "くも", "にじ", "あめ", "ゆき", "かみなり", "かぜ", "たいよう", "ほし", "つき", "うちゅうじん",
    ].map { WordEntry($0, .sky) }
    + [
      "つみき", "こま", "けんだま", "ふうせん", "にんぎょう",
      "たいこ", "ふえ", "すず", "もっきん",
      "なわとび", "てつぼう", "とびばこ",
      "ぶらんこ", "すべりだい", "すなば",
    ].map { WordEntry($0, .plaything) }

  /// はねずに、ゆっくり はう物（D169）。まちでは はずまず ゆっくり歩き、変身のあとも ゆっくり進む。
  public static let crawlers: Set<String> = ["かぶとむし", "てんとうむし", "かたつむり"]

  public static func crawls(_ text: String) -> Bool { crawlers.contains(text) }

  public static func entry(for text: String) -> WordEntry? {
    all.first { $0.text == text }
  }

  /// その字を含むことば（字のカードに出す。D101）。
  public static func words(containing char: Character) -> [WordEntry] {
    all.filter { $0.text.contains(char) }
  }
}
