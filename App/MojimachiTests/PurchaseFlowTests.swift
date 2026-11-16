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

  static func session() throws -> SKTestSession {
    let session = try SKTestSession(contentsOf: configuration)
    session.resetToDefaultState()
    session.disableDialogs = true
    session.clearTransactions()
    return session
  }

  @Test("何も持っていなければ、4つの商品が読めて「ぜんぶ」とパック2つを出す")
  func products() async throws {
    _ = try Self.session()
    let store = PurchaseStore(observesStore: false)
    await store.refresh()
    #expect(store.products.count == ProductID.allCases.count)
    #expect(store.entitlements.offers == [.allOpen, .katakanaPack, .abcPack])
    #expect(store.price(.allOpen).contains("500"))
  }

  @Test("カタカナを買うとカタカナが開き、持っている人向けの「ぜんぶ」だけ出す。返金すると戻る")
  func buyAndRefund() async throws {
    let session = try Self.session()
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

  @Test("アプリの購入の処理で「ぜんぶ」を買うと、全部開いて商品が出なくなる")
  func buyAllInApp() async throws {
    _ = try Self.session()
    let store = PurchaseStore(observesStore: false)
    await store.refresh()
    await store.buy(.allOpen)
    #expect(store.entitlements.allOpen)
    #expect(store.entitlements.offers.isEmpty)
    #expect(store.message == "購入しました")
  }
}
