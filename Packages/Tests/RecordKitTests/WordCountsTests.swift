import Foundation
import Testing

@testable import RecordKit

@Suite("ずかんの書いた回数（D82）・字を書けたか（D181）")
struct WordCountsTests {
  private func word(_ text: String) -> WordRecord { WordRecord(date: Date(), word: text) }

  @Test("ことばごとに、書いた行の数を数える")
  func counts() {
    var log = LearningLog()
    log.append(word("いぬ"))
    log.append(word("いぬ"))
    log.append(word("ねこ"))
    #expect(log.wordWriteCounts == ["いぬ": 2, "ねこ": 1])
  }

  @Test("リセットより前の行は数えない（行は消さない）")
  func resetIgnoresOldRows() {
    var log = LearningLog()
    log.append(word("いぬ"))
    log.reset()
    #expect(log.wordWriteCounts.isEmpty)
    log.append(word("いぬ"))
    #expect(log.wordWriteCounts == ["いぬ": 1])
    #expect(log.words.count == 2)
  }

  @Test("なぞって かけた（つぼみ）以上で「書けた」。れんしゅうちゅうは まだ")
  func canWrite() {
    var log = LearningLog()
    let id = "hira.3042"
    #expect(!log.canWrite(characterID: id))
    log.append(
      CharacterRecord(date: Date(), characterID: id, stage: .nazoru, passed: false))
    #expect(!log.canWrite(characterID: id))
    log.append(CharacterRecord(date: Date(), characterID: id, stage: .nazoru, passed: true))
    #expect(log.canWrite(characterID: id))
    // 救済で先へ進んだだけでは、書けたことにしない。
    log.append(
      CharacterRecord(
        date: Date(), characterID: "hira.3044", stage: .nazoru, passed: true, rescued: true))
    #expect(!log.canWrite(characterID: "hira.3044"))
  }
}
