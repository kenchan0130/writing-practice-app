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
    // あ行が右（D146）。見た目の一番左の列はわ行。
    let hira = KanaTable.main(.hiragana)
    #expect(hira.cells[0][9] == "あ")
    #expect(hira.cells[4][9] == "お")
    #expect(hira.cells[0][0] == "わ")
    #expect(hira.cells[2][0] == "ん")
    #expect(hira.cells[4][7] == "そ")
    #expect(hira.cells[1][2] == nil)
    #expect(hira.cells.map { $0[0] } == ["わ", nil, "ん", nil, "を"])
    #expect(hira.cells.map { $0[9] } == ["あ", "い", "う", "え", "お"])
    #expect(KanaTable.main(.katakana).cells[0][9] == "ア")
    #expect(KanaTable.main(.katakana).cells[0][0] == "ワ")
  }

  @Test("濁音と小さい字も、右から左（D146）")
  func extraDirection() {
    let dakuon = KanaTable.dakuon(.hiragana)
    #expect(dakuon.cells[0] == ["ぱ", "ば", "だ", "ざ", "が"])
    #expect(dakuon.cells.map { $0[4] } == ["が", "ぎ", "ぐ", "げ", "ご"])
    #expect(KanaTable.dakuon(.katakana).cells[0][4] == "ガ")
    let small = KanaTable.small(.hiragana)
    #expect(small.cells[0].first == "ょ")
    #expect(small.cells[0].last == "ぁ")
    #expect(KanaTable.small(.katakana).cells[0].last == "ァ")
    // 折り返しても、先頭の字が右上。
    let wrapped = small.wrappedRightToLeft(perRow: 6)
    #expect(wrapped.cells[0] == ["っ", "ぉ", "ぇ", "ぅ", "ぃ", "ぁ"])
    #expect(wrapped.cells[1] == [nil, nil, nil, "ょ", "ゅ", "ゃ"])
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
      #expect(Set(halves.flatMap(\.characters)) == Set(KanaTable.main(script).characters))
      #expect(halves.flatMap(\.characters).count == 46)
    }
    // 前の半分は あ〜な で、あ行が右（D146）。
    #expect(KanaTable.halves(.hiragana)[0].cells[0] == ["な", "た", "さ", "か", "あ"])
    #expect(KanaTable.halves(.hiragana)[1].cells[0] == ["わ", "ら", "や", "ま", "は"])
    #expect(KanaTable.halves(.katakana)[0].cells[0].last == "ア")
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
      Set(WordCatalog.words(containing: "く").map(\.text)) == [
        "くるま", "くま", "くつ", "くつした", "ふく", "らくだ", "さくら", "くり", "くじら", "くらげ", "おたまじゃくし",
      ])
    #expect(WordCatalog.words(containing: "を").isEmpty)
  }
}

@Suite("地図の行（D151）")
struct KanaRowTests {
  @Test("ひらがなの行は、あ行からわ行・濁音・小さい字の順に16行")
  func hiraganaRows() {
    let rows = KanaTable.rows(.hiragana)
    #expect(rows.count == 16)
    #expect(rows[0].characters == Array("あいうえお"))
    #expect(rows[7].characters == Array("やゆよ"))
    #expect(rows[9].characters == Array("わんを"))  // 表の段の順（ん は う の段）
    #expect(rows[10].characters == Array("がぎぐげご"))
    #expect(rows[14].characters == Array("ぱぴぷぺぽ"))
    #expect(rows[15].characters == Array("ぁぃぅぇぉっゃゅょ"))
  }

  @Test("行をすべて集めると、地図の字ぜんぶと同じになる（どちらの文字でも）")
  func coversAll() {
    for script in KanaScript.allCases {
      let fromRows = KanaTable.rows(script).flatMap(\.characters)
      #expect(Set(fromRows) == Set(KanaTable.all(script)))
      #expect(fromRows.count == KanaTable.all(script).count)
    }
  }

  @Test("字からその行が引ける")
  func lookup() {
    #expect(KanaTable.row(of: "そ", script: .hiragana)?.head == "さ")
    #expect(KanaTable.row(of: "ョ", script: .katakana)?.characters.contains("ー") == true)
  }
}
