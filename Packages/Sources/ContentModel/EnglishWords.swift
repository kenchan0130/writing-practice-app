/// えいごの ことば 1つ（D45・D67・D199）。絵は、日本語のことばの絵を使い回す（cat は「ねこ」の絵）。
/// 日本語のことばは、ひらがなでもカタカナでもよい（bus は「バス」の絵）。
public struct EnglishWord: Sendable, Hashable {
  /// 英語の字（小文字。3〜4文字のやさしいことば）。書くのは `abc` パックの小文字。
  public let text: String
  /// 絵を借りる日本語のことば（`WordCatalog` にあって、絵があること）。
  public let japanese: String

  public init(_ text: String, japanese: String) {
    self.text = text
    self.japanese = japanese
  }
}

/// えいごの ことばの一覧と引き方（D199）。日本語のことばの一覧（`WordCatalog`）とは別に持つ。
/// しりとりには出さない（日本語だけ。D45）。
public enum EnglishWords {
  /// めぐり（`WordBatch.all`）に書いた順。
  public static let all: [EnglishWord] = WordBatch.all.flatMap(\.english)

  private static let byText: [String: EnglishWord] = Dictionary(
    all.map { ($0.text, $0) }, uniquingKeysWith: { first, _ in first })

  public static func word(for text: String) -> EnglishWord? { byText[text] }

  public static func isEnglish(_ text: String) -> Bool { byText[text] != nil }

  /// 英語のことばから、絵を借りる日本語のことば。英語でなければ nil。
  public static func japanese(of text: String) -> String? { byText[text]?.japanese }

  /// 日本語のことばに合う英語のことば（ふつうは1つ）。
  public static func words(for japanese: String) -> [EnglishWord] {
    all.filter { $0.japanese == japanese }
  }

  /// 絵や動きの決め方で使う、もとになる日本語のことば。英語ならその日本語、そうでなければそのまま。
  public static func base(of text: String) -> String { japanese(of: text) ?? text }

  /// 英語のことばを `WordEntry` にしたもの。種類は、借りる日本語のことばと同じ（動きも同じ）。
  /// 日本語のことばが見つからなければ nil。
  public static func entry(for text: String) -> WordEntry? {
    guard let word = byText[text], let base = WordCatalog.entry(for: word.japanese) else {
      return nil
    }
    return WordEntry(text, base.kind)
  }

  /// 英語のことばぜんぶの `WordEntry`（`all` の順。日本語のことばが見つからないものは除く）。
  public static var entries: [WordEntry] { all.compactMap { entry(for: $0.text) } }

  /// 英語のことばの字がすべて、英字の小文字か。
  public static func isLowercaseLetters(_ text: String) -> Bool {
    !text.isEmpty && text.allSatisfy { $0.isASCII && $0.isLowercase }
  }
}
