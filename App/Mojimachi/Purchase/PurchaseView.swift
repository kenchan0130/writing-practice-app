import EntitlementKit
import SwiftUI

/// 保護者用の画面の「購入」（D95・§5.3）。子どもの画面には価格や購入を出さない（D3）。
struct PurchaseView: View {
  private let purchases = PurchaseStore.shared
  private let store = ProgressStore.shared

  var body: some View {
    Form {
      Section {
        LabeledContent("使えるもじ") {
          Text("\(purchases.entitlements.unlockedScriptCount) / \(Script.allCases.count)")
        }
        ForEach(Script.allCases, id: \.self) { script in
          LabeledContent(Self.name(script)) {
            Text(purchases.entitlements.isUnlocked(script) ? "つかえます" : "おためし")
              .foregroundStyle(purchases.entitlements.isUnlocked(script) ? .green : .secondary)
          }
        }
      }
      Section {
        if purchases.entitlements.offers.isEmpty {
          Text("ぜんぶ ひらいています").font(.headline)
        }
        ForEach(purchases.entitlements.offers, id: \.self) { id in
          HStack {
            VStack(alignment: .leading, spacing: 4) {
              Text(Self.title(id)).font(.headline)
              if id.isAllOpen {
                Text("これから ふえる もじの パック も、ついかの おかねなしで つかえます（もじ いがいの きのうは ふくみません）")
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
        Text("ひらがなは ずっと無料です。ファミリー共有で家族も使えます。")
      }
      Section {
        Button("購入を復元") { Task { await purchases.restore() } }
          .disabled(purchases.isWorking)
      }
      Section("おためしで書けるもの") {
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
    case .abc: "ABC・すうじ"
    }
  }

  static func title(_ id: ProductID) -> String {
    switch id {
    case .allOpen: "ぜんぶ ひらく（これからの もじも）"
    case .allOpenForOneOwner: "ぜんぶ ひらく（パックを 1つ もっている ひと）"
    case .katakanaPack: "カタカナ パック"
    case .abcPack: "ABC・すうじ パック"
    }
  }
}
