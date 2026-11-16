import ContentModel
import Foundation

/// アプリに入れた文字のデータを読む（D106）。
enum PackLibrary {
  /// M0 の約20語に要る字（D78）。試作ではこの順に練習する。
  static let m0Characters = Array("そりくるまふねてんしやかせういぬこすほゆたつきものでじぼゃ")

  static func hiragana(_ char: Character) -> CharacterData? {
    guard let scalar = char.unicodeScalars.first else { return nil }
    let name = "hira.\(String(scalar.value, radix: 16))"
    guard
      let url = Bundle.main.url(
        forResource: name, withExtension: "json", subdirectory: "Packs/hira"),
      let data = try? Data(contentsOf: url)
    else { return nil }
    return try? JSONDecoder().decode(CharacterData.self, from: data)
  }
}
