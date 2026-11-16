import EntitlementKit
import Foundation
import Observation
import StoreKit

/// 購入（StoreKit 2）。Apple の購入記録を読み、権利の決まり（EntitlementKit）に渡す（D89・D95・D96）。
@Observable
final class PurchaseStore {
  static let shared = PurchaseStore()

  private(set) var entitlements = Entitlements(purchases: [])
  /// App Store の商品（読めなければ空）。
  private(set) var products: [ProductID: Product] = [:]
  /// 子どもには見せない。保護者用の画面にだけ出す（D117）。
  private(set) var message: String?
  private(set) var isWorking = false

  private var updates: Task<Void, Never>?
  /// 確かめ用に、持っていることにしているか。
  private var isFake = false

  /// `observesStore: false` は試験用。自動の読み込みと更新の見張りをしない。
  init(observesStore: Bool = true) {
    #if DEBUG
      // 確かめ用: `-fakePurchases katakana,abc,all` で、持っていることにする。
      if let fake = UserDefaults.standard.string(forKey: "fakePurchases") {
        entitlements = Entitlements(purchases: Self.fake(fake))
        isFake = true
        return
      }
    #endif
    guard observesStore else { return }
    updates = Task { [weak self] in
      for await _ in Transaction.updates { await self?.refresh() }
    }
    Task { await refresh() }
  }

  /// 商品と購入記録を読み直す。
  func refresh() async {
    guard !isFake else { return }
    if products.isEmpty {
      let loaded = (try? await Product.products(for: ProductID.allCases.map(\.rawValue))) ?? []
      products = Dictionary(
        loaded.compactMap { p in ProductID(rawValue: p.id).map { ($0, p) } },
        uniquingKeysWith: { a, _ in a })
    }
    var purchases: [Purchase] = []
    for await result in Transaction.all {
      guard case .verified(let transaction) = result,
        let id = ProductID(rawValue: transaction.productID)
      else { continue }
      purchases.append(
        Purchase(
          product: id, originalPurchaseDate: transaction.originalPurchaseDate,
          revoked: transaction.revocationDate != nil))
    }
    entitlements = Entitlements(purchases: purchases)
  }

  func buy(_ id: ProductID) async {
    guard let product = products[id] else { return }
    isWorking = true
    defer { isWorking = false }
    do {
      switch try await product.purchase() {
      case .success(.verified(let transaction)):
        await transaction.finish()
        message = "購入しました"
      case .success(.unverified):
        message = "購入を確かめられませんでした"
      case .pending:
        message = "承認を待っています"
      case .userCancelled:
        message = nil
      @unknown default:
        message = nil
      }
    } catch {
      message = "購入できませんでした。時間をおいて試してください。"
    }
    await refresh()
  }

  /// 購入を復元（D95）。
  func restore() async {
    isWorking = true
    defer { isWorking = false }
    try? await AppStore.sync()
    await refresh()
    message = "購入を復元しました"
  }

  /// 価格の表示。App Store の商品が読めなければ、決まりの価格（確かめ用）。
  func price(_ id: ProductID) -> String {
    products[id]?.displayPrice ?? "¥\(id.yen)"
  }

  #if DEBUG
    private static func fake(_ text: String) -> [Purchase] {
      text.split(separator: ",").compactMap { name -> Purchase? in
        let id: ProductID? =
          switch name {
          case "katakana": .katakanaPack
          case "abc": .abcPack
          case "all": .allOpen
          default: nil
          }
        return id.map { Purchase(product: $0, originalPurchaseDate: Date()) }
      }
    }
  #endif
}
