import EntitlementKit
import PracticeKit
import RecordKit
import SpriteKit
import SwiftUI

/// わたしのまち（試作。D8・D53）。乗り物と動物は動きまわり、服は横木にかかって揺れる（D53）。
struct TownView: View {
  private let store = ProgressStore.shared
  @State private var scene: TownScene

  /// いえ（いえの なか）へ行く。nil なら、いえの入口を出さない（クローゼット）。
  var onHouse: (() -> Void)?

  /// ステッカーを貼る・はがす あいだ（§3.3・D54）。下の列が、ステッカーの入れ物になる。
  @State private var stickerMode: Bool
  @State private var drag: StickerDrag?
  /// まちの絵の場所（`StickerTray.space` の座標）。
  @State private var sceneFrame: CGRect = .zero
  @State private var tilt = TiltSensor()
  @Environment(\.scenePhase) private var scenePhase

  /// - Parameter startsWithStickers: ステッカーの入れ物を開いて始める（おたのしみ ボックスの「まちに はる」から）。
  init(
    layer: TownScene.Layer = .town, startsWithStickers: Bool = false, onHouse: (() -> Void)? = nil
  ) {
    _scene = State(initialValue: TownScene(layer: layer))
    var stickers = startsWithStickers
    #if DEBUG
      // 確かめ用: `-stickerTray YES` で、ステッカーの入れ物を開いておく。
      if UserDefaults.standard.bool(forKey: "stickerTray") { stickers = true }
    #endif
    _stickerMode = State(initialValue: stickers && layer == .town)
    self.onHouse = onHouse
  }

  /// まちに貼ってあるステッカー。
  private var townStickers: [TownSticker] {
    store.stickers.compactMap { owned in
      guard let place = owned.placement, place.surface == .town else { return nil }
      return TownSticker(id: owned.id, sticker: owned.sticker, x: place.x, y: place.y)
    }
  }

  /// まだ貼っていないステッカー（新しい順）。
  private var looseStickers: [OwnedSticker] {
    store.stickers.filter { $0.placement == nil }.reversed()
  }

  /// 押して貼る: いま見えている空の、あいている所へ。
  private func stick(_ sticker: OwnedSticker) {
    let spot = scene.defaultStickerSpot(index: townStickers.count)
    store.placeSticker(sticker.id, on: .town, x: spot.x, y: spot.y)
    SoundPlayer.shared.play(.appear)
  }

  /// 引っぱって貼る: 指を はなした所へ。まちの絵の外なら、入れ物に もどる。
  private func drop(_ sticker: OwnedSticker, at point: CGPoint) {
    guard sceneFrame.contains(point) else { return }
    let spot = scene.stickerSpot(
      viewPoint: CGPoint(x: point.x - sceneFrame.minX, y: point.y - sceneFrame.minY))
    store.placeSticker(sticker.id, on: .town, x: spot.x, y: spot.y)
    SoundPlayer.shared.play(.appear)
  }

  /// いまの画面の向き（傾きの向きを合わせる）。
  private var orientation: UIInterfaceOrientation {
    scene.view?.window?.windowScene?.effectiveGeometry.interfaceOrientation ?? .portrait
  }

  /// まちの おもちゃばこに、物が入っているか（入りきらない物があるときだけ、おもちゃばこを出す）。
  private var hasBoxed: Bool { !store.board.boxed(ShelfGroup.town).isEmpty }

  /// まちの看板（「ゆうとの まち」。呼び名がなければ「わたしの まち」。§3.9）。
  private var title: String {
    let name = store.currentProfile?.name.trimmingCharacters(in: .whitespaces) ?? ""
    let isCloset = scene.layer == .closet
    if name.isEmpty {
      return isCloset ? String(localized: "わたしの クローゼット") : String(localized: "わたしの まち")
    }
    return isCloset ? String(localized: "\(name)の クローゼット") : String(localized: "\(name)の まち")
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

  /// すうじ あそび（D199）: いちばん新しく書いた数字（1〜9）の数のりんご。書いていなければ 0。
  private var appleCount: Int {
    #if DEBUG
      // 確かめ用: `-apples 5` で、その数を見せる。
      if UserDefaults.standard.object(forKey: "apples") != nil {
        return UserDefaults.standard.integer(forKey: "apples")
      }
    #endif
    return NumberPlay.appleCount(
      in: store.log.currentCharacters.map {
        NumberPlay.WriteRecord(
          characterID: $0.characterID, date: $0.date, passed: $0.passed, rescued: $0.rescued)
      },
      canPlay: { PurchaseStore.shared.entitlements.canPlayNumber($0) })
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
            scene.setApples(appleCount)
            startTreats()
          }
          .onDisappear { tilt.stop() }
          .onChange(of: scenePhase) { _, phase in
            if phase == .active { startTilt() } else { tilt.stop() }
          }
          .onChange(of: store.stickerEvents) { scene.setStickers(townStickers) }
          .onChange(of: stickerMode) { _, on in scene.setStickerMode(on) }
          .onGeometryChange(for: CGRect.self) { $0.frame(in: .named(StickerTray.space)) } action: {
            sceneFrame = $0
          }
          .accessibilityElement()
          .accessibilityLabel(
            scene.layer == .town ? Text("まちの ステッカー") : Text("クローゼット"))
          .accessibilityValue(Text(verbatim: scene.layer == .town ? "\(townStickers.count)" : ""))
          .accessibilityIdentifier("townScene")
          // まちの絵の中のステッカーは VoiceOver で選べないので、はがす操作を別に用意する。
          .accessibilityAction(named: Text("ステッカーを 1まい はがす")) {
            if let last = townStickers.last { store.removeSticker(last.id) }
          }
          .onChange(of: store.placed) { _, placed in scene.show(placed, board: store.board) }
          .onChange(of: store.moves) { scene.show(store.placed, board: store.board) }
          .onChange(of: store.mainCharacter) { _, character in scene.setCharacter(character) }
          .onChange(of: store.log.words) {
            scene.setSky(skyRecords)
            scene.setBody(bodyRecords)
          }
          .onChange(of: store.log.characters) { scene.setApples(appleCount) }
      }
      // キャラクターのいえの入口と おもちゃばこ（§3.1・D185）。まちの物に重ならないよう、まちの下の列に置く。
      if scene.layer == .town, stickerMode {
        StickerTray(
          stickers: looseStickers, hasPlaced: !townStickers.isEmpty, drag: $drag,
          onTap: stick, onDrop: drop, onClose: { stickerMode = false })
      } else if scene.layer == .town, let onHouse {
        HStack(spacing: 16) {
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
          // ステッカーを1枚でも持っていれば出す（何もないのに開く行き止まりを作らない）。
          if !store.stickers.isEmpty {
            StickerButton { stickerMode = true }
          }
          Spacer()
          // 入りきらない物があるときだけ出す（D74）。
          if hasBoxed {
            ToyBoxButton { ToyBoxPresenter.show(groups: ShelfGroup.town) }
          }
        }
      }
    }
    .coordinateSpace(.named(StickerTray.space))
    .overlay { StickerGhost(drag: drag) }
    .padding(32)
  }

  /// ステッカーと傾きの準備（まちだけ）。
  private func startTreats() {
    guard scene.layer == .town else { return }
    scene.setStickers(townStickers)
    scene.setStickerMode(stickerMode)
    // まちの絵（SKScene）が持つ closure は、この View を捕まえない（捕まえると、まちを開くたびに
    // 絵が解放されず溜まる。D194）。必要なものだけを、弱い参照か共有の物で持つ。
    let store = store
    let tilt = tilt
    scene.onStickerPeel = { id in store.removeSticker(id) }
    scene.tiltProvider = { [weak scene] in
      let orientation =
        scene?.view?.window?.windowScene?.effectiveGeometry.interfaceOrientation ?? .portrait
      return tilt.tilt(orientation: orientation)
    }
    startTilt()
    // 夜は、主人公が眠そうにする（§3.5）。声は、アプリを開いてから1回だけ。
    if TownClock.phase().isSleepy, !stickerMode, !Self.saidSleepy {
      Self.saidSleepy = true
      VoicePlayer.shared.speak(.townSleepy)
    }
  }

  /// まちが見えていて、「動きを減らす」がオフのときだけ、傾きを読む。
  private func startTilt() {
    guard scene.layer == .town, !UIAccessibility.isReduceMotionEnabled else { return }
    tilt.start()
  }

  private static var saidSleepy = false
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
      // 季節の飾り（§3.4）。つるす物・立てる物・空の物。
      "こいのぼり", "ゆきだるま", "はなび", "ちょうちん", "かどまつ", "ふうりん",
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
