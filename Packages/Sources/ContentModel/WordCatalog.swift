/// ことばの種類。動きの型と置き方の型を決める（D53・D110）。
public enum WordKind: String, Sendable, CaseIterable, Codable {
  /// 乗り物: はずみながら走る。
  case vehicle
  /// 四つ足の動物: 歩く・はねる・たちどまって向きを変える。
  case animal
  /// 着る物: 服・おしゃれ こもの・へんしん・おしごと の ひとそろい（D178）。クローゼットのハンガーにかかって揺れる。
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
  /// 体の一部: まちには置かず、主人公が その体の動きを見せる（D175）。
  case bodyAction
  /// いえの物: キャラクターのいえの 棚・床・壁に置かれ、主人公が使う（D185）。
  case furniture
  /// 季節の飾り: まちの「おまつりの はた」の下に、つるす・立てる・空にあがる（§3.4・D53・D186）。
  case seasonal
}

/// ことば 1つ（絵は持たない。絵はアプリ側）。
public struct WordEntry: Sendable, Hashable {
  public let text: String
  public let kind: WordKind

  public init(_ text: String, _ kind: WordKind) {
    self.text = text
    self.kind = kind
  }

  /// ことばの文字の種類。字から決まる（ひらがな・カタカナ。D199）。ことばのデータに別の印はいらない。
  public var script: KanaScript? { WordText.script(of: text) }

  /// カタカナで書くことば（バス・パトカーなど。D7・D199）。
  public var isKatakana: Bool { script == .katakana }
}

/// ことばの字から、文字の種類を決める（D199）。画面に頼らない。
public enum WordText {
  private static let hiragana = Set(KanaTable.all(.hiragana))
  private static let katakana = Set(KanaTable.all(.katakana))

  /// すべてひらがななら `.hiragana`、すべてカタカナ（長音「ー」と小さい字をふくむ）なら `.katakana`、
  /// すべて英字（小文字・大文字）なら `.abc`。まざっているときと空のときは nil。
  public static func script(of text: String) -> KanaScript? {
    guard !text.isEmpty else { return nil }
    let chars = Array(text)
    if chars.allSatisfy({ $0.isASCII && $0.isLetter }) { return .abc }
    if chars.allSatisfy({ hiragana.contains($0) }) { return .hiragana }
    if chars.allSatisfy({ katakana.contains($0) }) { return .katakana }
    return nil
  }
}

/// M0 後半の約20語（D78）に、D167 で14語、D168 で14語、D169 で18語、D170 で13語、D172 で10語、D173 で15語、D174 で18語、D175 で8語、D178 で10語、D185 で14語を足した。
public enum WordCatalog {
  /// 土台のことば（`WordBatch.base`）。新しいことばは、ここではなく `WordBatches/` の中に足す。
  static let baseEntries: [WordEntry] =
    ["そり", "くるま", "ふね", "でんしゃ", "じてんしゃ", "しんかんせん", "いかだ", "しょうぼうしゃ", "きゅうきゅうしゃ"].map {
      WordEntry($0, .vehicle)
    }
    + [
      "うし", "いぬ", "ねこ", "うま", "くま", "しか", "りす", "さる", "ぞう", "とら", "かば", "きりん", "らくだ", "ぶた", "ひつじ",
      "たぬき", "きつね", "うさぎ", "かぶとむし", "てんとうむし", "かたつむり",
    ].map { WordEntry($0, .animal) }
    + [
      "ふく", "くつ", "ぼうし", "ゆかた", "くつした", "きもの",
      "にんじゃ", "おひめさま", "おうさま", "まほうつかい", "かいぞく",
      "だいく", "せんせい", "おいしゃさん", "おまわりさん", "しょうぼうし",
    ].map { WordEntry($0, .clothes) }
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
    + [
      "て", "あし", "め", "みみ", "くち", "あたま", "おなか", "ほっぺ",
    ].map { WordEntry($0, .bodyAction) }
    + [
      "なべ", "おわん", "はし", "おさら", "やかん",
      "いす", "つくえ", "とけい", "ふとん", "たんす",
      "せっけん", "はぶらし", "くし", "かがみ",
    ].map { WordEntry($0, .furniture) }

  /// 土台と、足しためぐり（`WordBatch.all`）のことばを、その順につないだもの。
  public static let all: [WordEntry] = WordBatch.all.flatMap(\.entries)

  /// めぐりで足したことばの絵の名前（土台の分は、アプリの `WordArt` にある）。
  public static let batchArtNames: [String: String] = WordBatch.all.reduce(into: [:]) {
    $0.merge($1.artNames) { $1 }
  }

  static let baseCrawlers: Set<String> = ["かぶとむし", "てんとうむし", "かたつむり"]

  /// はねずに、ゆっくり はう物（D169）。まちでは はずまず ゆっくり歩き、変身のあとも ゆっくり進む。
  public static let crawlers: Set<String> = WordBatch.all.reduce(into: []) {
    $0.formUnion($1.crawlers)
  }

  public static func crawls(_ text: String) -> Bool { crawlers.contains(text) }

  public static func entry(for text: String) -> WordEntry? {
    all.first { $0.text == text }
  }

  /// その字を含むことば（字のカードに出す。D101）。
  public static func words(containing char: Character) -> [WordEntry] {
    all.filter { $0.text.contains(char) }
  }
}
