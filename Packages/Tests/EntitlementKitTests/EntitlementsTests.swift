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

  @Test("どの順で買っても合計は同じ（D91）")
  func samePriceAnyOrder() {
    #expect(ProductID.allOpen.yen == ProductID.katakanaPack.yen + ProductID.allOpenForOneOwner.yen)
    #expect(ProductID.katakanaPack.yen + ProductID.abcPack.yen == ProductID.allOpen.yen)
  }
}
