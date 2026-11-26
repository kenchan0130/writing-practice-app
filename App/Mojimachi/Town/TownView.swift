import PracticeKit
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

  /// 空のことばを書いた記録（まちの空が しばらく変わる。D172）。
  private var skyRecords: [SkyRecord] {
    #if DEBUG
      // 確かめ用: `-skyWord くも` で、そのことばを いま書いたことにする。
      if let word = UserDefaults.standard.string(forKey: "skyWord") {
        return [SkyRecord(word: word, date: Date())]
      }
    #endif
    return store.log.currentWords.map { SkyRecord(word: $0.word, date: $0.date) }
  }

  /// 体のことばを書いた記録（まちで主人公が その動きを見せる。D175）。
  private var bodyRecords: [BodyRecord] {
    #if DEBUG
      // 確かめ用: `-bodyWord て` で、そのことばを いま書いたことにする。
      if let word = UserDefaults.standard.string(forKey: "bodyWord") {
        return [BodyRecord(word: word, date: Date())]
      }
    #endif
    return store.log.currentWords.map { BodyRecord(word: $0.word, date: $0.date) }
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
            scene.setCharacter(store.mainCharacter)
            scene.show(store.placed)
            scene.setSky(skyRecords)
            scene.setBody(bodyRecords)
          }
          .onChange(of: store.placed) { _, placed in scene.show(placed) }
          .onChange(of: store.mainCharacter) { _, character in scene.setCharacter(character) }
          .onChange(of: store.log.words) {
            scene.setSky(skyRecords)
            scene.setBody(bodyRecords)
          }
      }
    }
    .padding(32)
  }
}

#if DEBUG
  /// 確かめ用: `-seedTown YES` で、7つの型（のりもの・どうぶつ・服・空を飛ぶ物・景色・水の生きもの・こうえんの物）を置く（D168・D170・D173）。
  @MainActor func debugSeedTown(_ store: ProgressStore) {
    guard UserDefaults.standard.bool(forKey: "seedTown"), store.placed.isEmpty else { return }
    let seeds = [
      "かたつむり", "てんとうむし", "ちょう", "ほたる", "もも", "すいか", "だんご", "おにぎり",
      "くるま", "いぬ", "ひこうき", "ねこ", "ききゅう", "でんしゃ", "はと", "うま", "すずめ", "ふく", "ぼうし", "ゆかた",
      "さくら", "ひまわり", "たんぽぽ", "りんご", "みかん", "いちご", "にんじん", "だいこん", "かぼちゃ",
      "たこ", "さかな", "くじら", "かめ", "くらげ", "かえる",
      "ぶらんこ", "すべりだい", "こま", "たいこ", "ふうせん", "けんだま", "つみき", "もっきん",
      // 景色（D174）。新しい12個まで出るので、これが後ろに来る。
      "やま", "がっこう", "いえ", "しんごう", "ふみきり", "まつ", "きのこ", "どんぐり", "あさがお", "たき",
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
