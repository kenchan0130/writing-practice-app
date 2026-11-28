/// ことばのひとまとまり（めぐり）。1つのめぐりを1つのファイル（`WordBatches/Batch<名前>.swift`）に書けるので、
/// 何人かが同じ行を触らずに、ことばを足せる。共有する行は、下の `all` の1行だけ。
public struct WordBatch: Sendable {
  public let name: String
  /// このめぐりのことば（種類つき）。
  public let entries: [WordEntry]
  /// テーマの ID → このめぐりで足すことば（そのテーマの、土台のことばの後ろに順に並ぶ）。
  public let themeWords: [String: [String]]
  /// ことば → ずかんの ひとこと説明。
  public let notes: [String: String]
  /// ことば → 絵の名前（ローマ字。`Content/Art/words/<名前>.svg` と `word-<名前>` のアセット）。土台の分はアプリの `WordArt` にある。
  public let artNames: [String: String]
  /// ことば → 季節の印（なければ書かない）。
  public let seasons: [String: Season]
  /// ゆっくり はうことば。
  public let crawlers: Set<String>
  /// このめぐりで足す、えいごの ことば（D199）。絵は日本語のことばの絵を使い回す。ことばの数にはふくめない。
  public let english: [EnglishWord]

  public init(
    name: String,
    entries: [WordEntry],
    themeWords: [String: [String]],
    notes: [String: String],
    artNames: [String: String] = [:],
    seasons: [String: Season] = [:],
    crawlers: Set<String> = [],
    english: [EnglishWord] = []
  ) {
    self.name = name
    self.entries = entries
    self.themeWords = themeWords
    self.notes = notes
    self.artNames = artNames
    self.seasons = seasons
    self.crawlers = crawlers
    self.english = english
  }

  /// めぐりの一覧。**ここが共有する唯一の行**。新しいめぐりは、1行足すだけ（足す順がことばの順）。
  public static let all: [WordBatch] = [
    .base,
    .animals2,
    .school2,
    .food2,
    .kataSeed,
    .englishSeed,
    .english2,
  ]

  /// 今までのことば（`WordCatalog`・`WordMap`・`WordNotes`・`WordSeason` に書いてある分）。
  static let base = WordBatch(
    name: "base",
    entries: WordCatalog.baseEntries,
    themeWords: [:],
    notes: WordNotes.baseNotes,
    seasons: WordSeason.baseTable,
    crawlers: WordCatalog.baseCrawlers
  )
}
