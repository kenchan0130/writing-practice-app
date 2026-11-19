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

  public static let themes: [WordTheme] = [
    WordTheme(
      "norimono", "のりもの", in: "eki",
      words: ["でんしゃ", "しんかんせん", "ふね", "くるま", "じてんしゃ", "そり"]),
    WordTheme("hataraku-kuruma", "はたらく くるま", in: "michi"),
    WordTheme("sora-tobu-mono", "そらを とぶ もの", in: "sora"),
    WordTheme("dobutsuen-dobutsu", "どうぶつえんの どうぶつ", in: "dobutsuen"),
    WordTheme("makiba-dobutsu", "まきばの どうぶつ", in: "makiba", words: ["うし", "うま"]),
    WordTheme("mori-dobutsu", "もりの どうぶつ", in: "mori", words: ["くま", "しか", "りす"]),
    WordTheme("ie-ikimono", "いえで かう いきもの", in: "ie", row: .inside, words: ["いぬ", "ねこ"]),
    WordTheme("tori", "とり", in: "sora"),
    WordTheme("mushi", "むし", in: "mori"),
    WordTheme("umi-ikimono", "うみの いきもの", in: "umi"),
    WordTheme("kawa-ikimono", "かわ・いけの いきもの", in: "kawa"),
    WordTheme("kyoryu", "きょうりゅう", in: "dobutsuen"),
    WordTheme("kudamono", "くだもの", in: "omise"),
    WordTheme("yasai", "やさい", in: "makiba"),
    WordTheme("gohan-nomimono", "ごはん・のみもの", in: "omise"),
    WordTheme("okashi", "おかし", in: "omise"),
    WordTheme("fuku", "ふく", in: "ie", row: .closet, words: ["ふく", "ゆかた", "きもの"]),
    WordTheme("oshare-komono", "おしゃれ こもの", in: "ie", row: .closet, words: ["くつ", "ぼうし", "くつした"]),
    WordTheme("oshigoto", "おしごと", in: "michi"),
    WordTheme("henshin", "へんしん", in: "ie", row: .closet),
    WordTheme("sora-tenki", "そら・てんき", in: "sora"),
    WordTheme("shizen", "しぜん", in: "kawa"),
    WordTheme("hana", "はな", in: "mori"),
    WordTheme("ki-kusa-kinoko", "き・くさ・きのこ", in: "mori"),
    WordTheme("omocha", "おもちゃ", in: "koen"),
    WordTheme("gakki", "がっき", in: "koen"),
    WordTheme("sports", "スポーツ", in: "koen"),
    WordTheme("koen-asobi", "こうえんの あそび", in: "koen"),
    WordTheme("karada", "からだ", in: "ie", row: .closet),
    WordTheme("daidokoro", "だいどころ", in: "ie", row: .inside),
    WordTheme("ie-no-mono", "いえの もの", in: "ie", row: .inside),
    WordTheme("ofuro-mijitaku", "おふろ・みじたく", in: "ie", row: .inside),
    WordTheme("bunbogu", "ぶんぼうぐ", in: "omise"),
    WordTheme("tatemono", "たてもの", in: "eki"),
    WordTheme("machi-no-mono", "まちの もの", in: "michi"),
    WordTheme("uchu", "うちゅう", in: "uchu"),
    WordTheme("haru-natsu-gyoji", "はる・なつの ぎょうじ", in: "kisetsu"),
    WordTheme("aki-fuyu-gyoji", "あき・ふゆの ぎょうじ", in: "kisetsu"),
  ]

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

  /// `hasArt` は、そのことばに絵があるか。
  public init(hasArt: @escaping @Sendable (String) -> Bool) {
    self.hasArt = hasArt
  }

  /// 絵のあることばだけを、テーマの順で。
  public func words(in theme: WordTheme) -> [String] {
    theme.words.filter(hasArt)
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
