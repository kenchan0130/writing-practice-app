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

  /// 商品を買う処理。既定は本物の `Product.purchase()`。試験では、購入の画面を出さない処理に差し替える。
  typealias PurchaseAction = @MainActor (Product) async throws -> Product.PurchaseResult
  private let purchaseAction: PurchaseAction

  /// `observesStore: false` は試験用。自動の読み込みと更新の見張りをしない。
  init(
    observesStore: Bool = true,
    purchase: @escaping PurchaseAction = { try await $0.purchase() }
  ) {
    purchaseAction = purchase
    #if DEBUG
      // 確かめ用: `-fakePurchases katakana,abc,all` で、持っていることにする。
      if let fake = UserDefaults.standard.string(forKey: "fakePurchases") {
        entitlements = Entitlements(purchases: Self.fake(fake))
        isFake = true
        return
      }
    #endif
    // テストの土台のアプリ（`XCTestConfigurationFilePath` がある）は、本物の App Store に触れない。
    // StoreKit の試し用の設定がないと、「Apple Account にサインイン」の画面が出て止まるため。
    guard observesStore, !Self.isTestHost else { return }
    updates = Task { [weak self] in
      for await _ in Transaction.updates { await self?.refresh() }
    }
    Task { await refresh() }
  }

  /// 単体テストの土台として起動したか。
  private static var isTestHost: Bool {
    ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
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
    var bought: Purchase?
    do {
      switch try await purchaseAction(product) {
      case .success(.verified(let transaction)):
        await transaction.finish()
        bought = Purchase(
          product: id, originalPurchaseDate: transaction.originalPurchaseDate, revoked: false)
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
    // 買った直後は、購入の一覧（`Transaction.all`）にまだ入っていないことがある。
    // 確かめられた購入は、一覧を待たずにすぐ開く（買ったのに開かないように見せない）。
    if let bought, !entitlements.purchases.contains(where: { $0.product == bought.product }) {
      entitlements = Entitlements(
        purchases: entitlements.purchases + [bought], priceRiseDate: entitlements.priceRiseDate)
    }
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
