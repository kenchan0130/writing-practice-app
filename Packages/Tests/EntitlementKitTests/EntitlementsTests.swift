import Foundation
import Testing

@testable import EntitlementKit

@Suite("課金の権利")
struct EntitlementsTests {
  static let early = Date(timeIntervalSince1970: 1_800_000_000)
  static let rise = Date(timeIntervalSince1970: 1_900_000_000)
  static let late = Date(timeIntervalSince1970: 1_950_000_000)

  @Test("何も持っていなければ、ひらがなだけ。商品は「ぜんぶ」が上で、パック2つ（D95）")
  func nothing() {
    let e = Entitlements(purchases: [])
    #expect(e.isUnlocked(.hiragana))
    #expect(!e.isUnlocked(.katakana))
    #expect(e.offers == [.allOpen, .katakanaPack, .abcPack])
    #expect(e.unlockedScriptCount == 1)
  }

  @Test("パック1つなら、その文字が開き、商品は持っている人向けの「ぜんぶ」だけ（D95）")
  func onePack() {
    let e = Entitlements(purchases: [
      Purchase(product: .katakanaPack, originalPurchaseDate: Self.early)
    ])
    #expect(e.isUnlocked(.katakana))
    #expect(!e.isUnlocked(.abc))
    #expect(e.offers == [.allOpenForOneOwner])
  }

  @Test("どの「ぜんぶ」でも全部開き、パックを返金しても続く（D89）")
  func allOpenSurvivesRefund() {
    let e = Entitlements(purchases: [
      Purchase(product: .katakanaPack, originalPurchaseDate: Self.early, revoked: true),
      Purchase(product: .allOpenForOneOwner, originalPurchaseDate: Self.early),
    ])
    #expect(e.allOpen)
    #expect(e.isUnlocked(.abc))
    #expect(e.offers.isEmpty)
    #expect(e.unlockedScriptCount == Script.allCases.count)
  }

  @Test("値上げ前に2つのパックを両方持っていれば「ぜんぶ」と同じ（D96）")
  func bothPacksBeforeRise() {
    let both = [
      Purchase(product: .katakanaPack, originalPurchaseDate: Self.early),
      Purchase(product: .abcPack, originalPurchaseDate: Self.early),
    ]
    #expect(Entitlements(purchases: both, priceRiseDate: Self.rise).allOpen)
    #expect(Entitlements(purchases: both).allOpen, "値上げの日が決まる前")
  }

  @Test("値上げ後に2つめを買っても「ぜんぶ」にはならない（D96）")
  func secondPackAfterRise() {
    let e = Entitlements(
      purchases: [
        Purchase(product: .katakanaPack, originalPurchaseDate: Self.early),
        Purchase(product: .abcPack, originalPurchaseDate: Self.late),
      ], priceRiseDate: Self.rise)
    #expect(!e.allOpen)
    #expect(e.isUnlocked(.katakana) && e.isUnlocked(.abc))
  }

  @Test("返金したパックは開かない")
  func refundedPack() {
    let e = Entitlements(purchases: [
      Purchase(product: .abcPack, originalPurchaseDate: Self.early, revoked: true)
    ])
    #expect(!e.isUnlocked(.abc))
    #expect(e.offers == [.allOpen, .katakanaPack, .abcPack])
  }

  @Test("鍵がかかっていても、おためしの字とおためしのことばの中は書ける（D90・D94）")
  func trial() {
    let e = Entitlements(purchases: [])
    #expect(e.canWrite("ニ", in: .katakana))
    #expect(!e.canWrite("バ", in: .katakana))
    #expect(e.canWrite("バ", in: .katakana, insideTrialWord: true))
    #expect(e.canWrite("7", in: .abc))
    #expect(!e.canWrite("A", in: .abc))
    #expect(Trial.word(for: .katakana) == "バス")
  }

  @Test("ABC のパックの情報（pack.json）のおためし・商品が、権利の決まりと同じ（D94・D180）")
  func abcPackInfoMatches() throws {
    let url = URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
      .deletingLastPathComponent().appendingPathComponent("Content/Packs/abc/pack.json")
    let object = try #require(
      try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
    let trial = try #require(object["trial"] as? [String: Any])
    #expect(
      trial["characters"] as? [String] == Trial.characters(for: .abc).map { String($0) })
    #expect(trial["word"] as? String == Trial.word(for: .abc))
    #expect(object["product"] as? String == ProductID.abcPack.rawValue)
    #expect(object["script"] as? String == Script.abc.rawValue)
  }

  @Test("どの順で買っても合計は同じ（D91）")
  func samePriceAnyOrder() {
    #expect(ProductID.allOpen.yen == ProductID.katakanaPack.yen + ProductID.allOpenForOneOwner.yen)
    #expect(ProductID.katakanaPack.yen + ProductID.abcPack.yen == ProductID.allOpen.yen)
  }
}

@Suite("ことばの鍵（D90・D93・D199）")
struct WordEntitlementsTests {
  static let early = Date(timeIntervalSince1970: 1_800_000_000)

  @Test("ひらがなのことばは、いつも書ける")
  func hiragana() {
    #expect(Entitlements(purchases: []).canWrite(word: "ねこ", in: .hiragana))
  }

  @Test("おためしのことば（バス・cat）は、パックがなくても書ける。ほかは鍵")
  func trialWordsOpen() {
    let none = Entitlements(purchases: [])
    #expect(none.canWrite(word: "バス", in: .katakana))
    #expect(!none.canWrite(word: "パトカー", in: .katakana))
    #expect(none.canWrite(word: "cat", in: .abc))
    #expect(!none.canWrite(word: "dog", in: .abc))
    #expect(Trial.isTrialWord("バス", in: .katakana))
    #expect(!Trial.isTrialWord("バス", in: .abc))
    #expect(Trial.words == ["バス", "cat"])
  }

  @Test("バスは、カタカナパックを買ったら、ほかのカタカナのことばも書ける")
  func ownedPack() {
    let kata = Entitlements(purchases: [
      Purchase(product: .katakanaPack, originalPurchaseDate: Self.early)
    ])
    #expect(kata.canWrite(word: "パトカー", in: .katakana))
    // カタカナのパックでは、英語は開かない
    #expect(!kata.canWrite(word: "dog", in: .abc))
    let abc = Entitlements(purchases: [
      Purchase(product: .abcPack, originalPurchaseDate: Self.early)
    ])
    #expect(abc.canWrite(word: "dog", in: .abc))
    #expect(!abc.canWrite(word: "パトカー", in: .katakana))
    let all = Entitlements(purchases: [
      Purchase(product: .allOpen, originalPurchaseDate: Self.early)
    ])
    #expect(all.canWrite(word: "パトカー", in: .katakana))
    #expect(all.canWrite(word: "dog", in: .abc))
  }

  @Test("おためしの字だけでできたことばも、おためしのことばでなければ鍵（字のおためしは、字の練習のもの）")
  func trialCharactersDoNotOpenWords() {
    let none = Entitlements(purchases: [])
    // ニ・ト・ロ・コ・ハ はおためしの字だが、ことばは開かない
    #expect(!none.canWrite(word: "ニコ", in: .katakana))
    #expect(!none.canWrite(word: "ハト", in: .katakana))
    #expect(!none.canWrite(word: "", in: .katakana))
    // 字としては書ける
    #expect(none.canWrite("ニ", in: .katakana))
    // 買えば開く
    let kata = Entitlements(purchases: [
      Purchase(product: .katakanaPack, originalPurchaseDate: Self.early)
    ])
    #expect(kata.canWrite(word: "ニコ", in: .katakana))
  }

  @Test("すうじ あそびは、パックを持っているか「1」だけ（7・4 は字のおためしだが、あそびは1だけ）")
  func numberPlay() {
    let none = Entitlements(purchases: [])
    #expect(none.canPlayNumber("1"))
    for digit in "0234567 89" where digit != " " {
      #expect(!none.canPlayNumber(digit), "\(digit)")
    }
    #expect(none.canWrite("7", in: .abc))
    let abc = Entitlements(purchases: [
      Purchase(product: .abcPack, originalPurchaseDate: Self.early)
    ])
    #expect("0123456789".allSatisfy { abc.canPlayNumber($0) })
    let kata = Entitlements(purchases: [
      Purchase(product: .katakanaPack, originalPurchaseDate: Self.early)
    ])
    #expect(!kata.canPlayNumber("3"))
    let all = Entitlements(purchases: [
      Purchase(product: .allOpen, originalPurchaseDate: Self.early)
    ])
    #expect(all.canPlayNumber("9"))
  }
}
