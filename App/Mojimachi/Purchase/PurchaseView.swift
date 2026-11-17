import EntitlementKit
import SwiftUI

/// 保護者用の画面の「購入」（D95・§5.3）。子どもの画面には価格や購入を出さない（D3）。
struct PurchaseView: View {
  private let purchases = PurchaseStore.shared
  private let store = ProgressStore.shared

  var body: some View {
    Form {
      Section {
        LabeledContent("使える文字") {
          Text("\(purchases.entitlements.unlockedScriptCount) / \(Script.allCases.count)")
        }
        ForEach(Script.allCases, id: \.self) { script in
          LabeledContent(Self.name(script)) {
            Text(purchases.entitlements.isUnlocked(script) ? "使えます" : "お試し")
              .foregroundStyle(purchases.entitlements.isUnlocked(script) ? .green : .secondary)
          }
        }
      }
      Section {
        if purchases.entitlements.offers.isEmpty {
          Text("すべて開いています").font(.headline)
        }
        ForEach(purchases.entitlements.offers, id: \.self) { id in
          HStack {
            VStack(alignment: .leading, spacing: 4) {
              Text(Self.title(id)).font(.headline)
              if id.isAllOpen {
                Text("これから増える文字のパックも、追加の料金なしで使えます（文字以外の機能は含みません）")
                  .font(.caption).foregroundStyle(.secondary)
              }
            }
            Spacer()
            Button(purchases.price(id)) { Task { await purchases.buy(id) } }
              .buttonStyle(.borderedProminent)
              .disabled(purchases.isWorking || purchases.products[id] == nil)
          }
        }
        if let message = purchases.message {
          Text(message).foregroundStyle(.secondary)
        }
      } header: {
        Text("商品")
      } footer: {
        Text("ひらがなはずっと無料です。ファミリー共有で家族も使えます。")
      }
      Section {
        Button("購入を復元") { Task { await purchases.restore() } }
          .disabled(purchases.isWorking)
      }
      Section("お試しで書けるもの") {
        ForEach(Script.paid, id: \.self) { script in
          LabeledContent(Self.name(script)) {
            Text(
              String(Trial.characters(for: script))
                + (Trial.word(for: script).map { "・「\($0)」" } ?? ""))
          }
        }
      }
    }
    .navigationTitle("購入")
    .task { await purchases.refresh() }
  }

  static func name(_ script: Script) -> String {
    switch script {
    case .hiragana: "ひらがな"
    case .katakana: "カタカナ"
    case .abc: "ABC・数字"
    }
  }

  static func title(_ id: ProductID) -> String {
    switch id {
    case .allOpen: "すべての文字（これから追加する文字も）"
    case .allOpenForOneOwner: "すべての文字（パックを1つ購入済みの方）"
    case .katakanaPack: "カタカナパック"
    case .abcPack: "ABC・数字パック"
    }
  }
}
