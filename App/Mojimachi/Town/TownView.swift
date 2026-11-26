import SpriteKit
import SwiftUI

/// わたしのまち（試作。D8・D53）。乗り物と動物は動きまわり、服は横木にかかって揺れる（D53）。
struct TownView: View {
  private let store = ProgressStore.shared
  @State private var scene: TownScene

  init(layer: TownScene.Layer = .town) {
    _scene = State(initialValue: TownScene(layer: layer))
  }

  /// まちの看板（「ゆうとの まち」。呼び名がなければ「わたしの まち」。§3.9）。
  private var title: String {
    let name = store.currentProfile?.name.trimmingCharacters(in: .whitespaces) ?? ""
    let base = scene.layer == .closet ? "クローゼット" : "まち"
    return name.isEmpty ? (scene.layer == .closet ? "わたしの クローゼット" : "わたしの まち") : "\(name)の \(base)"
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(title).font(.learning(40)).foregroundStyle(Theme.ink)
      GeometryReader { proxy in
        SpriteView(scene: scene)
          .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.paper))
          .softShadow()
          .onAppear {
            scene.size = proxy.size
            #if DEBUG
              debugSeedTown(store)
            #endif
            scene.show(store.placed)
          }
          .onChange(of: store.placed) { _, placed in scene.show(placed) }
      }
    }
    .padding(32)
  }
}

#if DEBUG
  /// 確かめ用: `-seedTown YES` で、5つの型（のりもの・どうぶつ・服・空を飛ぶ物・景色）を置く（D168）。
  @MainActor func debugSeedTown(_ store: ProgressStore) {
    guard UserDefaults.standard.bool(forKey: "seedTown"), store.placed.isEmpty else { return }
    let seeds = [
      "かたつむり", "てんとうむし", "ちょう", "ほたる", "もも", "すいか", "だんご", "おにぎり",
      "くるま", "いぬ", "ひこうき", "ねこ", "ききゅう", "でんしゃ", "はと", "うま", "すずめ", "ふく", "ぼうし", "ゆかた",
      "さくら", "ひまわり", "たんぽぽ", "りんご", "みかん", "いちご", "にんじん", "だいこん", "かぼちゃ",
    ]
    for text in seeds {
      guard let item = WordArt.words.first(where: { $0.entry.text == text }) else {
        continue
      }
      store.place(PlacedObject(word: text, symbol: item.asset, kind: item.entry.kind))
    }
  }
#else
  @MainActor func debugSeedTown(_ store: ProgressStore) {}
#endif
