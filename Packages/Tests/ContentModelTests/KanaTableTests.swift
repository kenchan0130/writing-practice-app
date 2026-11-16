import Foundation
import Testing

@testable import ContentModel

@Suite("文字の地図の並び（D101・D125）")
struct KanaTableTests {
  /// リポジトリの Content/Packs/<pack> にある字のファイル。
  private func packChars(_ prefix: String) throws -> Set<Character> {
    let root = URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent().deletingLastPathComponent()
      .deletingLastPathComponent().deletingLastPathComponent()
      .appendingPathComponent("Content/Packs/\(prefix)")
    let names = try FileManager.default.contentsOfDirectory(atPath: root.path)
    return Set(
      names.compactMap { name -> Character? in
        guard name.hasPrefix("\(prefix)."), name.hasSuffix(".json"),
          let code = UInt32(name.dropFirst(prefix.count + 1).dropLast(5), radix: 16),
          let scalar = Unicode.Scalar(code)
        else { return nil }
        return Character(scalar)
      })
  }

  @Test("50音表は10列5段で、字は46（ひらがな）と同じ形のカタカナ")
  func mainShape() {
    for script in KanaScript.allCases {
      let table = KanaTable.main(script)
      #expect(table.columnCount == 10)
      #expect(table.rowCount == 5)
      #expect(table.characters.count == 46)
      #expect(Set(table.characters).count == 46)
    }
    #expect(KanaTable.main(.hiragana).cells[0][0] == "あ")
    #expect(KanaTable.main(.hiragana).cells[4][2] == "そ")
    #expect(KanaTable.main(.hiragana).cells[1][7] == nil)
  }

  @Test("地図の字は、ぜんぶ字のデータにある")
  func cellsExistInPacks() throws {
    for script in KanaScript.allCases {
      let pack = try packChars(script.packPrefix)
      for char in KanaTable.all(script) {
        #expect(pack.contains(char), "\(char) のデータがない")
      }
    }
  }

  @Test("字のデータは、ぜんぶ地図のどこかにある")
  func packCharsOnMap() throws {
    for script in KanaScript.allCases {
      let onMap = Set(KanaTable.all(script))
      let extra = try packChars(script.packPrefix).subtracting(onMap)
      #expect(extra.isEmpty, "地図にない字: \(extra)")
    }
  }

  @Test("2つに分けた表は、50音表をそのまま覆う")
  func halvesCoverTable() {
    for script in KanaScript.allCases {
      let halves = KanaTable.halves(script)
      #expect(halves.count == 2)
      #expect(halves[0].columnCount == 5 && halves[1].columnCount == 5)
      #expect(halves[0].characters.first == KanaTable.main(script).characters.first)
      #expect(Set(halves.flatMap(\.characters)) == Set(KanaTable.main(script).characters))
      #expect(halves.flatMap(\.characters).count == 46)
    }
    #expect(KanaTable.halves(.hiragana)[0].cells[0].last == "な")
    #expect(KanaTable.halves(.hiragana)[1].cells[0].first == "は")
  }

  @Test("地図の字に重なりがない")
  func noDuplicates() {
    for script in KanaScript.allCases {
      let all = KanaTable.all(script)
      #expect(Set(all).count == all.count)
    }
  }

  @Test("字のデータの ID と文字の種類")
  func ids() {
    #expect(KanaTable.characterID("そ", script: .hiragana) == "hira.305d")
    #expect(KanaTable.characterID("ニ", script: .katakana) == "kata.30cb")
    #expect(KanaTable.script(of: "ニ") == .katakana)
    #expect(KanaTable.script(of: "そ") == .hiragana)
    #expect(KanaTable.script(of: "A") == nil)
  }

  @Test("幅が足りるときは10列、足りないときは2つに分ける（D125）")
  func layoutDecision() {
    // iPad Pro 11 インチの縦（834）は入る。
    #expect(MapLayout.decide(width: 834).split == false)
    #expect(MapLayout.decide(width: 834).cell >= MapLayout.minCell)
    // iPad mini の縦（744）と小さいウィンドウは分ける。
    let mini = MapLayout.decide(width: 744)
    #expect(mini.split)
    #expect(mini.cell >= MapLayout.minCell)
    #expect(MapLayout.decide(width: 500).split)
    // ちょうど境目。
    let edge = 10 * MapLayout.minCell + 9 * MapLayout.gap + 2 * MapLayout.edge
    #expect(MapLayout.decide(width: edge).split == false)
    #expect(MapLayout.decide(width: edge - 1).split)
    // 広いときも、字は大きくなりすぎない。
    #expect(MapLayout.decide(width: 1400).cell == MapLayout.maxCell)
  }

  @Test("字のカードのことば")
  func wordsContaining() {
    #expect(WordCatalog.words(containing: "そ").map(\.text) == ["そり"])
    #expect(
      Set(WordCatalog.words(containing: "く").map(\.text)) == ["くるま", "くま", "くつ", "くつした", "ふく"])
    #expect(WordCatalog.words(containing: "あ").isEmpty)
  }
}
