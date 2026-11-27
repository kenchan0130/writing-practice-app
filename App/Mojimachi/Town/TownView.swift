import PracticeKit
import SpriteKit
import SwiftUI

/// わたしのまち（試作。D8・D53）。乗り物と動物は動きまわり、服は横木にかかって揺れる（D53）。
struct TownView: View {
  private let store = ProgressStore.shared
  @State private var scene: TownScene

  /// いえ（いえの なか）へ行く。nil なら、いえの入口を出さない（クローゼット）。
  var onHouse: (() -> Void)?

  init(layer: TownScene.Layer = .town, onHouse: (() -> Void)? = nil) {
    _scene = State(initialValue: TownScene(layer: layer))
    self.onHouse = onHouse
  }

  /// まちの おもちゃばこに、物が入っているか（入りきらない物があるときだけ、おもちゃばこを出す）。
  private var hasBoxed: Bool { !store.board.boxed(ShelfGroup.town).isEmpty }

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
            scene.show(store.placed, board: store.board)
            scene.setSky(skyRecords)
            scene.setBody(bodyRecords)
          }
          .onChange(of: store.placed) { _, placed in scene.show(placed, board: store.board) }
          .onChange(of: store.moves) { scene.show(store.placed, board: store.board) }
          .onChange(of: store.mainCharacter) { _, character in scene.setCharacter(character) }
          .onChange(of: store.log.words) {
            scene.setSky(skyRecords)
            scene.setBody(bodyRecords)
          }
      }
      // キャラクターのいえの入口と おもちゃばこ（§3.1・D185）。まちの物に重ならないよう、まちの下の列に置く。
      if scene.layer == .town, let onHouse {
        HStack {
          Button {
            SoundPlayer.shared.play(.tap)
            onHouse()
          } label: {
            VStack(spacing: 2) {
              Image("place-ie")
                .resizable()
                .scaledToFit()
                .frame(width: 84, height: 72)
              Text("いえ").font(.ui(22, bold: true)).foregroundStyle(Theme.ink)
            }
            .frame(width: 116, height: 116)
            .background(.white.opacity(0.85), in: .rect(cornerRadius: Theme.Radius.card))
            .softShadow()
          }
          .buttonStyle(.plain)
          .accessibilityLabel("いえ")
          .accessibilityIdentifier("houseButton")
          Spacer()
          // 入りきらない物があるときだけ出す（D74）。
          if hasBoxed {
            ToyBoxButton { ToyBoxPresenter.show(groups: ShelfGroup.town) }
          }
        }
      }
    }
    .padding(32)
  }
}

#if DEBUG
  /// 確かめ用: `-seedTown YES` で、8つの型（のりもの・どうぶつ・服・空を飛ぶ物・景色・水の生きもの・こうえんの物・いえの物）を置く（D168・D170・D173・D185）。
  @MainActor func debugSeedTown(_ store: ProgressStore) {
    guard UserDefaults.standard.bool(forKey: "seedTown"), store.placed.isEmpty else { return }
    let seeds = [
      "かたつむり", "てんとうむし", "ちょう", "ほたる", "もも", "すいか", "だんご", "おにぎり",
      "くるま", "いぬ", "ひこうき", "ねこ", "ききゅう", "でんしゃ", "はと", "うま", "すずめ", "ふく", "ぼうし", "ゆかた",
      "にんじゃ", "おひめさま", "おうさま", "まほうつかい", "かいぞく", "だいく", "せんせい", "おいしゃさん", "おまわりさん",
      "しょうぼうし",
      "さくら", "ひまわり", "たんぽぽ", "りんご", "みかん", "いちご", "にんじん", "だいこん", "かぼちゃ",
      "たこ", "さかな", "くじら", "かめ", "くらげ", "かえる",
      "ぶらんこ", "すべりだい", "こま", "たいこ", "ふうせん", "けんだま", "つみき", "もっきん",
      // 景色（D174）。新しい12個まで出るので、これが後ろに来る。
      "やま", "がっこう", "いえ", "しんごう", "ふみきり", "まつ", "きのこ", "どんぐり", "あさがお", "たき",
      // いえの物（D185）。棚4つ・床2つ・壁2つに入りきらない物は、おもちゃばこ。
      "なべ", "おわん", "はし", "おさら", "やかん", "せっけん", "いす", "つくえ", "ふとん", "とけい", "かがみ",
    ]
    // 1つずつ、時間をずらして置く（おもちゃばこの計算は、手に入れた時間の順。D82）。
    let start = Date().addingTimeInterval(-Double(seeds.count) * 60)
    for (index, text) in seeds.enumerated() {
      guard let item = WordArt.words.first(where: { $0.entry.text == text }) else {
        continue
      }
      store.place(
        PlacedObject(
          date: start.addingTimeInterval(Double(index) * 60), word: text, symbol: item.asset,
          kind: item.entry.kind))
    }
  }
#else
  @MainActor func debugSeedTown(_ store: ProgressStore) {}
#endif
