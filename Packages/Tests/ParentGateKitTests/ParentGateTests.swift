import Testing

@testable import ParentGateKit

@Suite("保護者用の確認")
struct ParentGateTests {
  @Test(
    "漢数字は 1〜99 を正しく書く",
    arguments: [
      (6, "六"), (10, "十"), (12, "十二"), (14, "十四"), (19, "十九"), (20, "二十"), (37, "三十七"),
      (99, "九十九"),
    ])
  func kanji(n: Int, expected: String) {
    #expect(KanjiNumeral.string(n) == expected)
  }

  @Test("英語の数の言葉", arguments: [(6, "six"), (14, "fourteen"), (23, "twenty-three"), (40, "forty")])
  func english(n: Int, expected: String) {
    #expect(EnglishNumeral.string(n) == expected)
  }

  @Test("問題はいつも 12〜19 × 3〜9（D64）")
  func questionRange() {
    for value in stride(from: 0.0, to: 1.0, by: 0.01) {
      let q = GateQuestion.make(random: { value })
      #expect((12...19).contains(q.left))
      #expect((3...9).contains(q.right))
    }
    #expect(GateQuestion.make(random: { 0.999_999 }).left == 19)
  }

  @Test("問題文の例")
  func questionText() {
    let q = GateQuestion(left: 14, right: 6)
    #expect(q.japanese == "十四かける六の答えを入力してください")
    #expect(q.english == "Enter fourteen times six")
    #expect(q.answer == 84)
  }

  @Test("正しく答えると通り、5分間有効（D49）")
  func passAndExpire() {
    var gate = ParentGate(random: { 0.25 })
    let answer = gate.question.answer
    #expect(gate.answer(answer, at: 100) == .passed)
    #expect(gate.isOpen(at: 100 + 299))
    #expect(!gate.isOpen(at: 100 + 300))
  }

  @Test("操作すると有効な時間が延び、閉じると切れる")
  func touchAndClose() {
    var gate = ParentGate(random: { 0.5 })
    _ = gate.answer(gate.question.answer, at: 0)
    gate.touch(at: 200)
    #expect(gate.isOpen(at: 450))
    gate.close()
    #expect(!gate.isOpen(at: 451))
  }

  @Test("3回まちがえると30秒待つ（D49）")
  func lockout() {
    var gate = ParentGate(random: { 0.1 })
    #expect(gate.answer(-1, at: 0) == .wrong(remaining: 2))
    #expect(gate.answer(-1, at: 1) == .wrong(remaining: 1))
    #expect(gate.answer(-1, at: 2) == .locked(until: 32))
    let correct = gate.question.answer
    #expect(gate.answer(correct, at: 10) == .locked(until: 32))
    #expect(gate.answer(correct, at: 33) == .passed)
  }
}
