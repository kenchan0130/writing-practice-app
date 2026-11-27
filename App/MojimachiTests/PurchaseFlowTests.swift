import EntitlementKit
import Foundation
import StoreKitTest
import Testing

@testable import Mojimachi

/// 購入の流れを、StoreKit の試し用の設定（`App/Mojimachi.storekit`）で確かめる（D95・D96）。
/// シミュレータで `xcodebuild test` を動かす（実機は要らない）。
@Suite("購入の流れ", .serialized)
@MainActor
struct PurchaseFlowTests {
  static let configuration = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()  // MojimachiTests
    .deletingLastPathComponent()  // App
    .appendingPathComponent("Mojimachi.storekit")

  /// 戻り値を持ち続けること。手放すと試験用の接続が切れ、本物の App Store に繋がってしまう。
  static func session() throws -> SKTestSession {
    let session = try SKTestSession(contentsOf: configuration)
    session.resetToDefaultState()
    session.disableDialogs = true
    session.clearTransactions()
    return session
  }

  @Test("何も持っていなければ、4つの商品が読めて「ぜんぶ」とパック2つを出す", .timeLimit(.minutes(1)))
  func products() async throws {
    let session = try Self.session()
    defer { withExtendedLifetime(session) {} }
    let store = PurchaseStore(observesStore: false)
    await store.refresh()
    #expect(store.products.count == ProductID.allCases.count)
    #expect(store.entitlements.offers == [.allOpen, .katakanaPack, .abcPack])
    #expect(store.price(.allOpen)?.contains("500") == true)
  }

  @Test("カタカナを買うとカタカナが開き、持っている人向けの「ぜんぶ」だけ出す。返金すると戻る", .timeLimit(.minutes(1)))
  func buyAndRefund() async throws {
    let session = try Self.session()
    defer { withExtendedLifetime(session) {} }
    let store = PurchaseStore(observesStore: false)
    let transaction = try await session.buyProduct(identifier: ProductID.katakanaPack.rawValue)
    await store.refresh()
    #expect(store.entitlements.isUnlocked(.katakana))
    #expect(store.entitlements.offers == [.allOpenForOneOwner])

    try session.refundTransaction(identifier: UInt(transaction.id))
    // 返金の反映は少し遅れるので、待ちながら読み直す。
    for _ in 0..<20 where store.entitlements.isUnlocked(.katakana) {
      try await Task.sleep(for: .milliseconds(250))
      await store.refresh()
    }
    #expect(!store.entitlements.isUnlocked(.katakana))
  }

  /// 購入の画面（Apple Account のサインイン）を出さずに、試験用の接続で買う処理。
  /// 買ったあとの取引を、`Product.purchase()` の結果と同じ形で返す。
  private static func sessionPurchase(_ session: SKTestSession) -> PurchaseStore.PurchaseAction {
    { product in
      _ = try await session.buyProduct(identifier: product.id)
      // 取引が StoreKit に届くまで、少し待ちながら探す。
      for _ in 0..<40 {
        if let latest = await Transaction.latest(for: product.id) { return .success(latest) }
        try await Task.sleep(for: .milliseconds(250))
      }
      throw CocoaError(.fileNoSuchFile)
    }
  }

  @Test("アプリの購入の処理で「ぜんぶ」を買うと、全部開いて商品が出なくなる", .timeLimit(.minutes(1)))
  func buyAllInApp() async throws {
    let session = try Self.session()
    defer { withExtendedLifetime(session) {} }
    let store = PurchaseStore(observesStore: false, purchase: Self.sessionPurchase(session))
    await store.refresh()
    // 商品が読めていなければ、買う前に分かるようにする（買うのが黙って何もしないのを防ぐ）。
    #expect(store.products[.allOpen] != nil)
    await store.buy(.allOpen)
    #expect(store.entitlements.allOpen)
    #expect(store.entitlements.offers.isEmpty)
    #expect(store.message == "購入しました")
  }

  /// 本物の `Product.purchase()`（購入の画面つき）で買う。シミュレータの状態によっては
  /// サインインの画面で止まるので、`MOJIMACHI_STOREKIT_PURCHASE_UI=1` のときだけ動かす。
  @Test(
    "本物の購入の処理でも「ぜんぶ」が買える（手動）",
    .enabled(if: ProcessInfo.processInfo.environment["MOJIMACHI_STOREKIT_PURCHASE_UI"] == "1"),
    .timeLimit(.minutes(1)))
  func buyAllWithRealPurchase() async throws {
    let session = try Self.session()
    defer { withExtendedLifetime(session) {} }
    let store = PurchaseStore(observesStore: false)
    await store.refresh()
    #expect(store.products[.allOpen] != nil)
    await store.buy(.allOpen)
    #expect(store.entitlements.allOpen)
    #expect(store.message == "購入しました")
  }
}
