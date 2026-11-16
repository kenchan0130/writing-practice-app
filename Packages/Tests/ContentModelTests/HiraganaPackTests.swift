import Foundation
import Testing

@testable import ContentModel

/// `Content/Packs/hira` のデータを確かめる（`content-check` の一部）。
@Suite("ひらがなのパック")
struct HiraganaPackTests {
  static let packDirectory = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()  // ContentModelTests
    .deletingLastPathComponent()  // Tests
    .deletingLastPathComponent()  // Packages
    .deletingLastPathComponent()  // リポジトリ
    .appendingPathComponent("Content/Packs/hira")

  static func loadAll() throws -> [CharacterData] {
    let files = try FileManager.default.contentsOfDirectory(
      at: packDirectory, includingPropertiesForKeys: nil
    )
    .filter { $0.pathExtension == "json" }
    .sorted { $0.lastPathComponent < $1.lastPathComponent }
    return try files.map {
      try JSONDecoder().decode(CharacterData.self, from: Data(contentsOf: $0))
    }
  }

  /// M0 の約20語に要る字（D78）。
  static let m0Characters = Array("そりくるまふねてんしやかせういぬこすほゆたつきものでじぼゃ")

  @Test("すべてのファイルを読めて、データの決まりに合う")
  func decodesAndValidates() throws {
    let all = try Self.loadAll()
    #expect(!all.isEmpty)
    let problems = all.flatMap { $0.problems() }
    #expect(problems.isEmpty, "\(problems.joined(separator: "\n"))")
  }

  @Test("ファイル名と ID と字が対応している")
  func idMatchesCharacter() throws {
    for data in try Self.loadAll() {
      let code = String(data.char.unicodeScalars.first!.value, radix: 16)
      #expect(data.id == "hira.\(code)", "\(data.char)")
    }
  }

  @Test("画数が教科書の画数と合う（D66）")
  func strokeCountsMatchTextbook() throws {
    var mismatches: [String] = []
    for data in try Self.loadAll() {
      guard let expected = StrokeCounts.hiragana(Character(data.char)) else { continue }
      if data.strokes.count != expected {
        mismatches.append("\(data.char): データ \(data.strokes.count) 画、教科書 \(expected) 画")
      }
    }
    #expect(mismatches.isEmpty, "\(mismatches.joined(separator: "\n"))")
  }

  @Test("M0 に要る字がそろっている（D78）")
  func coversM0Characters() throws {
    let chars = Set(try Self.loadAll().map { Character($0.char) })
    let missing = Self.m0Characters.filter { !chars.contains($0) }
    #expect(missing.isEmpty, "足りない字: \(String(missing))")
  }
}
