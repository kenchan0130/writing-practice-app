import ContentModel
import Foundation

/// アプリに入れた文字のデータを読む（D106）。
enum PackLibrary {
  /// M0 の約20語に要る字（D78）。試作ではこの順に練習する。
  static let m0Characters = Array("そりくるまふねてんしやかせういぬこすほゆたつきものでじぼゃ")

  static func hiragana(_ char: Character) -> CharacterData? {
    character(char, script: .hiragana)
  }

  /// ことばの字1つ分の字のデータ。ひらがな・カタカナ・英字（小文字）を、字から決める（D199）。
  static func character(forWordLetter char: Character) -> CharacterData? {
    guard let script = KanaTable.script(of: char) else { return nil }
    return character(char, script: script)
  }

  static func character(_ char: Character, script: KanaScript) -> CharacterData? {
    guard let name = KanaTable.characterID(char, script: script) else { return nil }
    guard
      let url = Bundle.main.url(
        forResource: name, withExtension: "json", subdirectory: "Packs/\(script.packPrefix)"),
      let data = try? Data(contentsOf: url)
    else { return nil }
    return try? JSONDecoder().decode(CharacterData.self, from: data)
  }
}
