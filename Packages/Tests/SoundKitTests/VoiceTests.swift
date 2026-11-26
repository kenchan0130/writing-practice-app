import ContentModel
import Foundation
import Testing

@testable import SoundKit

@Suite struct VoiceTests {
  /// リポジトリの根（このファイルから4つ上）。
  static let root = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    .deletingLastPathComponent()
  static let voicesDirectory = root.appendingPathComponent("App/Mojimachi/Resources/Voices")

  static func manifest() throws -> VoiceManifest {
    try VoiceManifest(json: Data(contentsOf: voicesDirectory.appendingPathComponent("voices.json")))
  }

  @Test func normalizeTrimsAndCollapsesSpaces() {
    #expect(VoiceManifest.normalize("  なにが   すき？ ") == "なにが すき？")
    // 「が」を「か」+ 濁点に分けた形も、ひとつの形にそろう
    #expect(VoiceManifest.normalize("か\u{3099}") == "が")
  }

  @Test func lookupUsesNormalizedText() {
    let manifest = VoiceManifest(engine: "x", files: ["なにが すき？": "voice_a"])
    #expect(manifest.fileName(for: "なにが  すき？ ") == "voice_a")
    #expect(manifest.fileName(for: "ない") == nil)
  }

  @Test func everyLiteralLineHasAVoice() throws {
    let manifest = try Self.manifest()
    for line in VoiceLine.allCases {
      #expect(manifest.fileName(for: line.text) != nil, "声がない文: \(line.text)")
    }
  }

  @Test func everyWordHasAVoice() throws {
    let manifest = try Self.manifest()
    for word in WordCatalog.all {
      #expect(manifest.fileName(for: word.text) != nil, "声がないことば: \(word.text)")
    }
  }

  /// 1字のことば（て・め）は、同じ字の声と同じ文字で引くので、ことば用のファイルは作らない（D175）。
  /// 字の声は、ことばの声と同じ「おちつき」で、読みを変えていないので、同じ音になる。
  @Test func oneKanaWordUsesTheKanaVoice() throws {
    let manifest = try Self.manifest()
    let lines = try String(
      contentsOf: Self.root.appendingPathComponent("Content/Voices/lines.csv"), encoding: .utf8)
    let rows = lines.split(separator: "\n").map {
      $0.split(separator: ",", omittingEmptySubsequences: false)
    }
    let oneKana = WordCatalog.all.filter { $0.text.count == 1 }
    #expect(!oneKana.isEmpty)
    for word in oneKana {
      let file = try #require(manifest.fileName(for: word.text))
      #expect(file.hasPrefix("voice_kana_"), "\(word.text)")
      let row = try #require(rows.first { $0.count >= 5 && "voice_" + $0[0] == file })
      #expect(row[1] == Substring(word.text))
      #expect(row[2] == "ochitsuki")
      #expect(row[3].isEmpty, "読みを変えた字の声は、ことばの声にならない: \(word.text)")
      #expect(
        !rows.contains {
          $0.first.map { $0.hasPrefix("word_") } == true && $0[1] == Substring(word.text)
        })
    }
  }

  @Test func everyPracticableKanaHasAVoice() throws {
    let manifest = try Self.manifest()
    for script in KanaScript.allCases {
      let chars =
        KanaTable.main(script).characters + KanaTable.dakuon(script).characters
        + KanaTable.small(script).characters
      #expect(!chars.isEmpty)
      for char in chars {
        #expect(manifest.fileName(for: String(char)) != nil, "声がない字: \(char)")
      }
    }
  }

  @Test func everyPackCharacterHasAVoice() throws {
    let manifest = try Self.manifest()
    var count = 0
    for pack in ["hira", "kata"] {
      let dir = Self.root.appendingPathComponent("Content/Packs/\(pack)")
      let files = try FileManager.default.contentsOfDirectory(atPath: dir.path)
        .filter { $0.hasSuffix(".json") }
      for file in files {
        let data = try Data(contentsOf: dir.appendingPathComponent(file))
        let object = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        let char = try #require(object["char"] as? String)
        #expect(manifest.fileName(for: char) != nil, "声がない字: \(char)")
        count += 1
      }
    }
    #expect(count > 100)
  }

  @Test func everyManifestFileIsOnDisk() throws {
    let manifest = try Self.manifest()
    #expect(!manifest.files.isEmpty)
    for name in Set(manifest.files.values) {
      let url = Self.voicesDirectory.appendingPathComponent(name + ".caf")
      #expect(FileManager.default.fileExists(atPath: url.path), "ファイルがない: \(name)")
    }
  }

  @Test func everyFileOnDiskIsInTheManifest() throws {
    let manifest = try Self.manifest()
    let names = Set(manifest.files.values)
    let onDisk = try FileManager.default.contentsOfDirectory(atPath: Self.voicesDirectory.path)
      .filter { $0.hasSuffix(".caf") }
    #expect(onDisk.count == names.count)
    for file in onDisk {
      #expect(names.contains(String(file.dropLast(4))), "表にないファイル: \(file)")
    }
  }
}
