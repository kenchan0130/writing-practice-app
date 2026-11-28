/// まちの地図の場所（D53・D67。付録 A.2）。ID は変えない・使い回さない（D114）。
public struct Place: Sendable, Hashable, Identifiable {
  public let id: String
  /// 子どもに見せる短いひらがなの名前。
  public let name: String

  init(_ id: String, _ name: String) {
    self.id = id
    self.name = name
  }
}

/// キャラクターのいえの2列（D67）。
public enum HouseRow: String, Sendable, Hashable, CaseIterable {
  case inside
  case closet

  public var name: String {
    switch self {
    case .inside: "いえの なか"
    case .closet: "クローゼット"
    }
  }
}

/// テーマ（約38。付録 A.2）。ID は変えない・使い回さない（D114）。
public struct WordTheme: Sendable, Hashable, Identifiable {
  public let id: String
  public let name: String
  public let placeID: String
  /// キャラクターのいえのテーマだけ、どちらの列か。
  public let row: HouseRow?
  /// このテーマのことば。ならべる順（絵カードの順）。
  public let words: [String]

  init(_ id: String, _ name: String, in placeID: String, row: HouseRow? = nil, words: [String] = [])
  {
    self.id = id
    self.name = name
    self.placeID = placeID
    self.row = row
    self.words = words
  }
}

/// 場所とテーマのデータ（D166）。ことばの割りふりは、ことばをここに足すだけでよい。
/// 1つのことばは、いくつかのテーマに入ってよい（付録 A.2）。
public enum WordMap {
  /// 地図に出す場所の順。最後は地図の上の「きせつ の はた」（D67）。
  public static let places: [Place] = [
    Place("eki", "えき"),
    Place("michi", "みち"),
    Place("sora", "そら"),
    Place("dobutsuen", "どうぶつえん"),
    Place("makiba", "まきば"),
    Place("mori", "もり"),
    Place("ie", "おうち"),
    Place("umi", "うみ"),
    Place("kawa", "かわ"),
    Place("omise", "おみせ"),
    Place("koen", "こうえん"),
    Place("uchu", "うちゅう"),
    Place("kisetsu", "きせつ の はた"),
  ]

  /// 1画面に出すテーマの数の上限（キャラクターのいえは2列で8。D67）。
  public static let maxThemesPerPlace = 4
  public static let maxThemesInHouse = 8
  /// 1画面に出すことばの数の上限（D53）。
  public static let maxWordsPerTheme = 12

  /// テーマの並び（ことばは土台だけ）。ことばを足すときは、ここではなく `WordBatches/` の中に書く。
  static let baseThemes: [WordTheme] = [
    WordTheme(
      "norimono", "のりもの", in: "eki",
      words: ["でんしゃ", "しんかんせん", "ふね", "くるま", "じてんしゃ", "そり", "いかだ"]),
    WordTheme(
      "hataraku-kuruma", "はたらく くるま", in: "michi", words: ["しょうぼうしゃ", "きゅうきゅうしゃ"]),
    WordTheme(
      "sora-tobu-mono", "そらを とぶ もの", in: "sora", words: ["ひこうき", "ききゅう"]),
    WordTheme(
      "dobutsuen-dobutsu", "どうぶつえんの どうぶつ", in: "dobutsuen",
      words: ["さる", "ぞう", "とら", "かば", "きりん", "らくだ"]),
    WordTheme("makiba-dobutsu", "まきばの どうぶつ", in: "makiba", words: ["うし", "うま", "ぶた", "ひつじ"]),
    WordTheme("mori-dobutsu", "もりの どうぶつ", in: "mori", words: ["くま", "しか", "りす", "たぬき", "きつね"]),
    WordTheme("ie-ikimono", "いえで かう いきもの", in: "ie", row: .inside, words: ["いぬ", "ねこ", "うさぎ"]),
    WordTheme("tori", "とり", in: "sora", words: ["はと", "すずめ", "からす"]),
    WordTheme(
      "mushi", "むし", in: "mori",
      words: ["ちょう", "とんぼ", "はち", "ほたる", "せみ", "かぶとむし", "てんとうむし", "かたつむり"]),
    WordTheme(
      "umi-ikimono", "うみの いきもの", in: "umi",
      words: ["たこ", "いか", "かに", "かめ", "くじら", "くらげ", "いるか", "さかな", "ひとで"]),
    WordTheme(
      "kawa-ikimono", "かわ・いけの いきもの", in: "kawa", words: ["かえる", "めだか", "ざりがに", "おたまじゃくし"]),
    WordTheme("kyoryu", "きょうりゅう", in: "dobutsuen"),
    WordTheme(
      "kudamono", "くだもの", in: "omise", words: ["りんご", "みかん", "いちご", "もも", "ぶどう", "すいか", "くり"]),
    WordTheme("yasai", "やさい", in: "makiba", words: ["にんじん", "だいこん", "かぼちゃ"]),
    WordTheme("gohan-nomimono", "ごはん・のみもの", in: "omise", words: ["おにぎり", "すし", "うどん"]),
    WordTheme("okashi", "おかし", in: "omise", words: ["だんご", "せんべい", "わたあめ"]),
    WordTheme("fuku", "ふく", in: "ie", row: .closet, words: ["ふく", "ゆかた", "きもの"]),
    WordTheme("oshare-komono", "おしゃれ こもの", in: "ie", row: .closet, words: ["くつ", "ぼうし", "くつした"]),
    WordTheme(
      "oshigoto", "おしごと", in: "michi",
      words: ["だいく", "せんせい", "おいしゃさん", "おまわりさん", "しょうぼうし"]),
    WordTheme(
      "henshin", "へんしん", in: "ie", row: .closet,
      words: ["にんじゃ", "おひめさま", "おうさま", "まほうつかい", "かいぞく"]),
    WordTheme(
      "sora-tenki", "そら・てんき", in: "sora",
      words: ["くも", "にじ", "あめ", "ゆき", "かみなり", "かぜ", "ほし", "つき"]),
    WordTheme("shizen", "しぜん", in: "kawa", words: ["やま", "たき", "いし", "いけ"]),
    WordTheme("hana", "はな", in: "mori", words: ["さくら", "ひまわり", "たんぽぽ", "あさがお", "ばら"]),
    WordTheme(
      "ki-kusa-kinoko", "き・くさ・きのこ", in: "mori", words: ["くさ", "まつ", "どんぐり", "はっぱ", "きのこ"]),
    WordTheme(
      "omocha", "おもちゃ", in: "koen", words: ["つみき", "こま", "けんだま", "ふうせん", "にんぎょう"]),
    WordTheme("gakki", "がっき", in: "koen", words: ["たいこ", "ふえ", "すず", "もっきん"]),
    WordTheme("sports", "スポーツ", in: "koen", words: ["なわとび", "てつぼう", "とびばこ"]),
    WordTheme("koen-asobi", "こうえんの あそび", in: "koen", words: ["ぶらんこ", "すべりだい", "すなば"]),
    WordTheme(
      "karada", "からだ", in: "ie", row: .closet,
      words: ["て", "あし", "め", "みみ", "くち", "あたま", "おなか", "ほっぺ"]),
    WordTheme(
      "daidokoro", "だいどころ", in: "ie", row: .inside, words: ["なべ", "おわん", "はし", "おさら", "やかん"]),
    WordTheme(
      "ie-no-mono", "いえの もの", in: "ie", row: .inside,
      words: ["いす", "つくえ", "とけい", "ふとん", "たんす"]),
    WordTheme(
      "ofuro-mijitaku", "おふろ・みじたく", in: "ie", row: .inside,
      words: ["せっけん", "はぶらし", "くし", "かがみ"]),
    WordTheme("bunbogu", "ぶんぼうぐ", in: "omise"),
    WordTheme("tatemono", "たてもの", in: "eki", words: ["いえ", "がっこう", "びょういん", "おしろ"]),
    WordTheme("machi-no-mono", "まちの もの", in: "michi", words: ["しんごう", "ふみきり", "がいとう"]),
    WordTheme("uchu", "うちゅう", in: "uchu", words: ["たいよう", "ほし", "つき", "うちゅうじん"]),
    WordTheme("haru-natsu-gyoji", "はる・なつの ぎょうじ", in: "kisetsu"),
    WordTheme("aki-fuyu-gyoji", "あき・ふゆの ぎょうじ", in: "kisetsu"),
  ]

  /// 土台のことばの後ろに、めぐり（`WordBatch.all`）のことばを順に足したテーマ。
  public static let themes: [WordTheme] = baseThemes.map { theme in
    let extra = WordBatch.all.flatMap { $0.themeWords[theme.id] ?? [] }
    guard !extra.isEmpty else { return theme }
    return WordTheme(
      theme.id, theme.name, in: theme.placeID, row: theme.row, words: theme.words + extra)
  }

  public static func place(id: String) -> Place? { places.first { $0.id == id } }
  public static func theme(id: String) -> WordTheme? { themes.first { $0.id == id } }
}

/// 「いま絵のあることば」から決まる、地図の見え方（D166）。
/// テーマは、絵のあることばが1つ以上あるときだけ出す。場所は、出すテーマが1つ以上あるときだけ出す。
/// ことばが増えると、場所もテーマも自然に増える。
public struct WordMapIndex: Sendable {
  /// 場所を押したときの行き先。
  public enum Entrance: Sendable, Equatable {
    /// テーマの絵カードを出す（2つ以上）。
    case themes([WordTheme])
    /// テーマが1つだけなので、すぐことばのカードを出す（D67）。
    case words(WordTheme)
  }

  private let hasArt: @Sendable (String) -> Bool
  private let trialWords: Set<String>

  /// `hasArt` は、そのことばに絵があるか。`trialWords` は、おためしのことば（バス・cat。D90）。
  public init(trialWords: Set<String> = [], hasArt: @escaping @Sendable (String) -> Bool) {
    self.trialWords = trialWords
    self.hasArt = hasArt
  }

  /// 絵のあることばだけを、テーマの順で。ひらがなのことばが先、次におためしのことば、
  /// 最後に鍵のかかる（かもしれない）カタカナのことば（D93）。同じ並びの中では、テーマに書いた順のまま。
  public func words(in theme: WordTheme) -> [String] {
    Self.arranged(theme.words.filter(hasArt), trial: trialWords)
  }

  /// 英語のことばが出る順: おためしのことば（cat）が先、あとは、テーマの日本語のことばの順（`words(in:)`。
  /// 同じ日本語のことばの英語は `EnglishWords` に書いた順）。旗で切り替えても、絵が同じ並びになる（D92・D199）。
  /// 絵を借りる日本語のことばが、このテーマにあって、絵もあるものだけ。
  /// ひとつもなければ、テーマの画面に「ABC」の旗は出さない（D67・D92）。
  public func englishWords(in theme: WordTheme) -> [String] {
    let found = words(in: theme).flatMap { EnglishWords.words(for: $0).map(\.text) }
    return found.filter(trialWords.contains) + found.filter { !trialWords.contains($0) }
  }

  /// ひらがな → おためし → そのほかのカタカナ の順に、安定して並べる（D93）。
  public static func arranged(_ words: [String], trial: Set<String>) -> [String] {
    func rank(_ word: String) -> Int {
      guard WordText.script(of: word) == .katakana else { return 0 }
      return trial.contains(word) ? 1 : 2
    }
    return (0...2).flatMap { level in words.filter { rank($0) == level } }
  }

  /// 場所の中の、出すテーマ。
  public func themes(in place: Place) -> [WordTheme] {
    WordMap.themes.filter { $0.placeID == place.id && !words(in: $0).isEmpty }
  }

  /// 出す場所。
  public var places: [Place] {
    WordMap.places.filter { !themes(in: $0).isEmpty }
  }

  public func entrance(of place: Place) -> Entrance? {
    let shown = themes(in: place)
    switch shown.count {
    case 0: return nil
    case 1: return .words(shown[0])
    default: return .themes(shown)
    }
  }

  /// テーマの絵カードに使うことば（そのテーマの最初の、絵のあることば）。
  public func representative(of theme: WordTheme) -> String? {
    words(in: theme).first
  }

  /// 場所の絵のカードに添えるテーマ名の代わりに、その場所のどれか1つのことば。
  public func representative(of place: Place) -> String? {
    themes(in: place).first.flatMap(representative(of:))
  }
}
