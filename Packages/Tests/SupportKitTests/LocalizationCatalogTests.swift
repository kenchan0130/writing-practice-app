import Foundation
import Testing

/// 画面の言葉の翻訳が抜けていないか確かめる（D186）。アプリの文字のカタログ（String Catalog）を
/// JSON として読むだけなので、Mac でも Linux でも動く。
struct LocalizationCatalogTests {
  private struct Catalog: Decodable {
    var sourceLanguage: String
    var strings: [String: Entry]

    struct Entry: Decodable {
      var shouldTranslate: Bool?
      var localizations: [String: Localization]?
    }

    struct Localization: Decodable {
      var stringUnit: Unit?
      var variations: Variations?
    }

    struct Unit: Decodable {
      var state: String
      var value: String
    }

    struct Variations: Decodable {
      var plural: [String: Localization]?
    }
  }

  private static func load(_ name: String) throws -> Catalog {
    // Packages/Tests/SupportKitTests/ → リポジトリの根 → App/Mojimachi
    let url = URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent().deletingLastPathComponent()
      .deletingLastPathComponent().deletingLastPathComponent()
      .appendingPathComponent("App/Mojimachi/\(name)")
    return try JSONDecoder().decode(Catalog.self, from: Data(contentsOf: url))
  }

  /// 英語の文（複数形のときは、すべての形）。
  private static func englishValues(_ entry: Catalog.Entry) -> [String] {
    guard let en = entry.localizations?["en"] else { return [] }
    if let unit = en.stringUnit { return [unit.value] }
    return en.variations?.plural?.values.compactMap { $0.stringUnit?.value } ?? []
  }

  /// `%@`・`%lld`・`%1$@` などの数。
  private static func placeholderCount(_ text: String) -> Int {
    let pattern = #"%(\d+\$)?(l{0,2}d|@)"#
    return (try? NSRegularExpression(pattern: pattern))
      .map { $0.numberOfMatches(in: text, range: NSRange(text.startIndex..., in: text)) } ?? 0
  }

  @Test func developmentLanguageIsJapanese() throws {
    #expect(try Self.load("Localizable.xcstrings").sourceLanguage == "ja")
    #expect(try Self.load("InfoPlist.xcstrings").sourceLanguage == "ja")
  }

  @Test func everyKeyHasAnEnglishValue() throws {
    for name in ["Localizable.xcstrings", "InfoPlist.xcstrings"] {
      let catalog = try Self.load(name)
      #expect(!catalog.strings.isEmpty, "\(name) が空")
      for (key, entry) in catalog.strings where entry.shouldTranslate != false {
        let values = Self.englishValues(entry)
        #expect(!values.isEmpty, "\(name) の「\(key)」に英語がない")
        #expect(
          values.allSatisfy { !$0.trimmingCharacters(in: .whitespaces).isEmpty },
          "\(name) の「\(key)」の英語が空")
      }
    }
  }

  @Test func englishKeepsTheSamePlaceholders() throws {
    let catalog = try Self.load("Localizable.xcstrings")
    for (key, entry) in catalog.strings where entry.shouldTranslate != false {
      for value in Self.englishValues(entry) {
        // 複数形の「1つ」の形は数を直接書くこともあるので、多いほうには合わせない。
        #expect(
          Self.placeholderCount(value) <= Self.placeholderCount(key),
          "「\(key)」の英語「\(value)」で %@・%lld が増えている")
      }
    }
  }
}
