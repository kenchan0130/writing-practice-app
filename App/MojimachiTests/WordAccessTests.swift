import ContentModel
import EntitlementKit
import Foundation
import PracticeKit
import Testing

@testable import Mojimachi

/// ことばの鍵（D90・D93・D199）。持っていない家庭と、パックを持っている家庭で、書けることばを確かめる。
@Suite("ことばの鍵")
struct WordAccessTests {
  private static let early = Date(timeIntervalSince1970: 1_800_000_000)
  private let none = Entitlements(purchases: [])
  private let kata = Entitlements(purchases: [
    Purchase(product: .katakanaPack, originalPurchaseDate: Self.early)
  ])
  private let abc = Entitlements(purchases: [
    Purchase(product: .abcPack, originalPurchaseDate: Self.early)
  ])

  @Test("文字の種類は、字から決まる")
  func script() {
    #expect(WordAccess.script(of: "ねこ") == .hiragana)
    #expect(WordAccess.script(of: "バス") == .katakana)
    #expect(WordAccess.script(of: "cat") == .abc)
  }

  @Test("持っていないとき: ひらがなとバスと cat だけ書ける。ほかは鍵（鍵の画面の文字の種類が分かる）")
  func nothing() {
    #expect(WordAccess.canWrite("ねこ", entitlements: none))
    #expect(WordAccess.canWrite("バス", entitlements: none))
    #expect(WordAccess.canWrite("cat", entitlements: none))
    #expect(!WordAccess.canWrite("dog", entitlements: none))
    #expect(!WordAccess.canWrite("パトカー", entitlements: none))
    #expect(WordAccess.lockedScript(of: "dog", entitlements: none) == .abc)
    #expect(WordAccess.lockedScript(of: "パトカー", entitlements: none) == .katakana)
    #expect(WordAccess.lockedScript(of: "バス", entitlements: none) == nil)
  }

  @Test("カタカナのパックで、カタカナが書ける。英語は書けない")
  func katakanaPack() {
    #expect(WordAccess.canWrite("パトカー", entitlements: kata))
    #expect(!WordAccess.canWrite("dog", entitlements: kata))
    #expect(WordAccess.canWrite("dog", entitlements: abc))
  }

  @Test("スタンプ: おためしの字には付ける。おためしのことばの中だけで書いた字には付けない")
  func stamps() {
    #expect(WordAccess.stamps("あ", entitlements: none))
    #expect(WordAccess.stamps("ハ", entitlements: none))
    #expect(!WordAccess.stamps("バ", entitlements: none))
    #expect(!WordAccess.stamps("ス", entitlements: none))
    #expect(!WordAccess.stamps("c", entitlements: none))
    #expect(WordAccess.stamps("バ", entitlements: kata))
    #expect(WordAccess.stamps("c", entitlements: abc))
  }

  @Test("おためしのことばを書いても、おためしでない字のスタンプは付かない（ことばの画面）")
  func noStampsInsideTrialWords() {
    for word in Trial.words {
      guard let script = WordAccess.script(of: word) else { continue }
      for char in word {
        let isTrialChar = Trial.characters(for: script).contains(char)
        #expect(WordAccess.stamps(char, entitlements: none) == isTrialChar, "\(word) の \(char)")
      }
    }
    // バス・cat の字は、どれもおためしの字ではない
    #expect(!"バス".contains { WordAccess.stamps($0, entitlements: none) })
    #expect(!"cat".contains { WordAccess.stamps($0, entitlements: none) })
  }

  @Test("字がおためしの字だけのことばも、鍵（おためしのことばでなければ）")
  func trialCharactersOnly() {
    #expect(!WordAccess.canWrite("ニコ", entitlements: none))
    #expect(WordAccess.lockedScript(of: "ニコ", entitlements: none) == .katakana)
  }

  @Test("しりとり: バスは書けることば。鍵のカタカナのことばだけ鍵つき。英語は入らない")
  @MainActor
  func shiritoriPool() {
    let pool = ShiritoriWords.pool(entitlements: none)
    #expect(pool.words.contains { $0.text == "バス" && !$0.isLocked })
    #expect(!pool.words.contains { EnglishWords.isEnglish($0.text) })
    #expect(ShiritoriWords.script(of: "cat") == nil)
    #expect(ShiritoriWords.script(of: "バス") == .katakana)
  }
}
