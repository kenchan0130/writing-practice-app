import Foundation
import Testing

@testable import ContentModel

/// `Content/Packs/abc` のデータを確かめる（`content-check` の一部。D180）。
@Suite("アルファベットと数字のパック")
struct AbcPackTests {
  static let packDirectory = HiraganaPackTests.packDirectory
    .deletingLastPathComponent()
    .appendingPathComponent("abc")

  static func loadAll() throws -> [CharacterData] {
    let files = try FileManager.default.contentsOfDirectory(
      at: packDirectory, includingPropertiesForKeys: nil
    )
    .filter { $0.pathExtension == "json" && $0.lastPathComponent.hasPrefix("abc.") }
    .sorted { $0.lastPathComponent < $1.lastPathComponent }
    return try files.map {
      try JSONDecoder().decode(CharacterData.self, from: Data(contentsOf: $0))
    }
  }

  static func loadInfo() throws -> PackInfo {
    try JSONDecoder().decode(
      PackInfo.self, from: Data(contentsOf: packDirectory.appendingPathComponent("pack.json")))
  }

  @Test("大文字・小文字・数字の62字がそろい、データの決まりに合う")
  func decodesAndValidates() throws {
    let all = try Self.loadAll()
    #expect(all.count == 62)
    #expect(Set(all.map(\.char)) == Set(AbcTable.all.map { String($0) }))
    let problems = all.flatMap { $0.problems() }
    #expect(problems.isEmpty, "\(problems.joined(separator: "\n"))")
  }

  @Test("ID が abc. と字の番号になっている")
  func idMatchesCharacter() throws {
    for data in try Self.loadAll() {
      let code = String(data.char.unicodeScalars.first!.value, radix: 16)
      #expect(data.id == "abc.\(code)", "\(data.char)")
      #expect(KanaTable.characterID(Character(data.char), script: .abc) == data.id)
    }
  }

  @Test("お手本の画数が、画数の表と合う（D66）")
  func strokeCountsMatchTable() throws {
    #expect(StrokeCounts.abc.count == 62)
    var mismatches: [String] = []
    for data in try Self.loadAll() {
      let expected = try #require(StrokeCounts.abc[Character(data.char)], "表にない字: \(data.char)")
      if data.strokes.count != expected {
        mismatches.append("\(data.char): データ \(data.strokes.count) 画、表 \(expected) 画")
      }
    }
    #expect(mismatches.isEmpty, "\(mismatches.joined(separator: "\n"))")
  }

  @Test("すべての画に、お手本の輪郭と終わり方がある")
  func everyStrokeHasOutline() throws {
    for data in try Self.loadAll() {
      for (index, stroke) in data.strokes.enumerated() {
        #expect(stroke.outline?.isEmpty == false, "\(data.char) \(index + 1)画: 輪郭がない")
        #expect(stroke.end != nil, "\(data.char) \(index + 1)画: 終わり方がない")
      }
    }
  }

  @Test("左右対称に近い字は、鏡の字を見ない。b・d・p・q は見る")
  func mirrorChecks() throws {
    let all = try Self.loadAll()
    for char in ["b", "d", "p", "q", "S", "Z", "3", "6", "9"] {
      #expect(all.first { $0.char == char }?.mirrorCheck ?? true, "\(char)")
    }
    for char in ["A", "O", "T", "o", "x", "0", "8"] {
      #expect(all.first { $0.char == char }?.mirrorCheck == false, "\(char)")
    }
  }

  @Test("パックの情報が決まりに合う（おすすめ順は全部の字を1回ずつ。似た字は同じ段階に置かない）")
  func packInfo() throws {
    let info = try Self.loadInfo()
    #expect(info.id == "abc")
    #expect(info.script == KanaScript.abc.rawValue)
    let problems = info.problems(characters: AbcTable.all)
    #expect(problems.isEmpty, "\(problems.joined(separator: "\n"))")
    // おためしの字は、おすすめ順とは切り離した固定の一覧（D94）。
    #expect(info.trial.characters == ["L", "T", "I", "E", "F", "1", "7", "4"])
    #expect(info.trial.word == "cat")
  }

  @Test("地図は、大文字・小文字が7字ずつの段、数字が5字ずつの段")
  func tableShape() {
    #expect(AbcTable.grid(.upper).cells.first == ["A", "B", "C", "D", "E", "F", "G"])
    #expect(AbcTable.grid(.upper).rowCount == 4)
    #expect(AbcTable.grid(.lower).cells.last == ["v", "w", "x", "y", "z", nil, nil])
    #expect(
      AbcTable.grid(.digits).cells == [["0", "1", "2", "3", "4"], ["5", "6", "7", "8", "9"]])
    #expect(KanaTable.all(.abc).count == 62)
    #expect(KanaTable.row(of: "c", script: .abc)?.characters == Array("abcdefg"))
    #expect(KanaTable.script(of: "A") == .abc)
    #expect(KanaTable.script(of: "7") == .abc)
  }
}
