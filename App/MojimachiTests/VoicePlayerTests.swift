import ContentModel
import SoundKit
import Testing

@testable import Mojimachi

/// 声のファイルが、アプリに入っていて、読めることを確かめる（D162）。
@Suite("声")
@MainActor
struct VoicePlayerTests {
  @Test("決まった文すべてに、声のファイルがある")
  func everyLiteralLineHasFile() {
    for line in VoiceLine.allCases {
      #expect(VoicePlayer.shared.url(for: line.text) != nil, "\(line.text)")
    }
  }

  @Test("すべてのことばに、声のファイルがある")
  func everyWordHasFile() {
    for word in WordCatalog.all {
      #expect(VoicePlayer.shared.url(for: word.text) != nil, "\(word.text)")
    }
  }

  @Test("すべての英語のことばに、声のファイルがある（D199）")
  func everyEnglishWordHasFile() {
    for word in EnglishWords.all {
      #expect(VoicePlayer.shared.url(for: word.text) != nil, "\(word.text)")
    }
  }

  @Test("ずかんの説明の声が、すべてのことばにある（バスをふくむ）")
  func everyNoteHasFile() {
    for (word, note) in WordNotes.all {
      #expect(VoicePlayer.shared.url(for: note) != nil, "\(word): \(note)")
    }
  }

  @Test("練習できるすべての字に、声のファイルがある")
  func everyKanaHasFile() {
    for script in KanaScript.allCases {
      for char in KanaTable.all(script) {
        #expect(VoicePlayer.shared.url(for: String(char)) != nil, "\(char)")
      }
    }
  }

  @Test("表のすべてのファイルが、アプリに入っている")
  func everyManifestEntryIsBundled() {
    #expect(!VoicePlayer.shared.manifest.files.isEmpty)
    for text in VoicePlayer.shared.manifest.files.keys {
      #expect(VoicePlayer.shared.url(for: text) != nil, "\(text)")
    }
  }
}
