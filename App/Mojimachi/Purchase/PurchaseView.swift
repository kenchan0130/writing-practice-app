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
            Group {
              if purchases.entitlements.isUnlocked(script) {
                Text("使えます").foregroundStyle(.green)
              } else {
                Text("お試し").foregroundStyle(.secondary)
              }
            }
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
              Text(purchases.products[id]?.displayName ?? Self.title(id)).font(.headline)
              if id.isAllOpen {
                Text("いまある文字と、これから追加する文字が、すべて使えます。")
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
                + (Trial.word(for: script).map { String(localized: "・「\($0)」") } ?? ""))
          }
        }
      }
    }
    .navigationTitle("購入")
    .task { await purchases.refresh() }
  }

  static func name(_ script: Script) -> String {
    switch script {
    case .hiragana: String(localized: "ひらがな")
    case .katakana: String(localized: "カタカナ")
    case .abc: String(localized: "ABC・数字")
    }
  }

  static func title(_ id: ProductID) -> String {
    switch id {
    case .allOpen: String(localized: "すべての文字")
    case .allOpenForOneOwner: String(localized: "すべての文字（1つ購入済みの方）")
    case .katakanaPack: String(localized: "カタカナ")
    case .abcPack: String(localized: "アルファベットと数字")
    }
  }
}
