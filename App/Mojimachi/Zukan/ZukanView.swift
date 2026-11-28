import ContentModel
import EntitlementKit
import RecordKit
import SwiftUI

/// ずかん（D35・D74・D82・D181）。集めたことばをテーマごとに見返す。
/// 書いたことばは絵と★（書いた回数。多くても3）。絵を押すと、ひとことの説明を声で読む。
/// まだ書いていないことばは影絵。押すと「かいて みよう」と言い、大きなボタンで書く画面へ行ける。
/// 鍵つきのことばは影絵に鍵。押すと鍵の画面（D3・D160）。子どもの画面なので、エラー・価格は出さない。
struct ZukanView: View {
  /// ことばを書く画面へ。
  var onWrite: (String) -> Void
  /// 鍵つきのことばを押した（鍵の画面へ）。
  var onLocked: (Script) -> Void = { _ in }

  private let store = ProgressStore.shared
  private let purchases = PurchaseStore.shared
  @State private var selected: String?
  /// 表紙にステッカーを貼る・はがす あいだ（§3.3・D54）。
  @State private var stickerMode = false
  @State private var drag: StickerDrag?
  /// 表紙の場所（`StickerTray.space` の座標）。
  @State private var coverFrame: CGRect = .zero

  var body: some View {
    let counts = store.log.wordWriteCounts
    let sections = Zukan.sections(
      index: WordArt.index, writtenCounts: counts, isLocked: isLocked)
    ScrollViewReader { scroll in
      ScrollView {
        VStack(spacing: 28) {
          ZukanCover(
            stickers: coverStickers, stickerMode: stickerMode,
            showsStickerButton: !store.stickers.isEmpty,
            onStickers: {
              selected = nil
              stickerMode = true
              scroll.scrollTo("zukanCover", anchor: .top)
            },
            onPeel: { store.removeSticker($0.id) }
          )
          .id("zukanCover")
          .onGeometryChange(for: CGRect.self) { $0.frame(in: .named(StickerTray.space)) } action: {
            coverFrame = $0
          }
          ForEach(sections) { section in
            sectionView(section)
          }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 12)
        .padding(.bottom, 24)
      }
    }
    .safeAreaInset(edge: .bottom) {
      if stickerMode {
        StickerTray(
          stickers: looseStickers, hasPlaced: !coverStickers.isEmpty, drag: $drag,
          onTap: stick, onDrop: drop, onClose: { stickerMode = false }
        )
        .padding(.horizontal, 32)
        .padding(.bottom, 12)
      } else {
        detail(counts: counts)
      }
    }
    .overlay(alignment: .top) { CaptionBubble().padding(.top, 12) }
    .coordinateSpace(.named(StickerTray.space))
    .overlay { StickerGhost(drag: drag) }
    .accessibilityIdentifier("zukan")
  }

  // MARK: - 表紙のステッカー（§3.3・D54）

  /// 表紙に貼ってあるステッカー。
  private var coverStickers: [OwnedSticker] {
    store.stickers.filter { $0.placement?.surface == .zukan }
  }

  /// まだ貼っていないステッカー（新しい順）。
  private var looseStickers: [OwnedSticker] {
    store.stickers.filter { $0.placement == nil }.reversed()
  }

  /// 押して貼る: 表紙の、題と かさならない所へ（貼ってある数で順に変える）。
  private func stick(_ sticker: OwnedSticker) {
    let count = coverStickers.count
    let spot = ZukanCover.spots[count % ZukanCover.spots.count]
    // 2まわり目からは、少し ずらして重ねる。
    let shift = Double(count / ZukanCover.spots.count) * 0.03
    store.placeSticker(sticker.id, on: .zukan, x: spot.x + shift, y: spot.y + shift)
    SoundPlayer.shared.play(.appear)
  }

  /// 引っぱって貼る: 指を はなした所へ。表紙の外なら、入れ物に もどる。
  private func drop(_ sticker: OwnedSticker, at point: CGPoint) {
    guard coverFrame.contains(point), coverFrame.width > 0, coverFrame.height > 0 else { return }
    let spot = StickerBook.clamped(
      x: Double((point.x - coverFrame.minX) / coverFrame.width),
      y: Double((point.y - coverFrame.minY) / coverFrame.height))
    store.placeSticker(sticker.id, on: .zukan, x: spot.x, y: spot.y)
    SoundPlayer.shared.play(.appear)
  }

  // MARK: - テーマごとの絵

  private func sectionView(_ section: ZukanSection) -> some View {
    VStack(alignment: .leading, spacing: 14) {
      Text(section.theme.name)
        .font(.ui(30, bold: true))
        .foregroundStyle(Theme.ink)
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(
          PlaceStyle.color(section.theme.placeID), in: .capsule)
      LazyVGrid(
        columns: [GridItem(.adaptive(minimum: 190, maximum: 230), spacing: 20)], spacing: 20
      ) {
        ForEach(section.entries) { entry in
          ZukanCard(
            entry: entry, color: PlaceStyle.color(section.theme.placeID),
            selected: selected == entry.word
          ) { tapped(entry) }
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  // MARK: - 選んだことば

  @ViewBuilder
  private func detail(counts: [String: Int]) -> some View {
    if let word = selected {
      let state = Zukan.state(of: word, writtenCounts: counts, isLocked: isLocked)
      HStack(spacing: 24) {
        Image(WordArt.assetName(for: word))
          .renderingMode(state.isWritten ? .original : .template)
          .resizable().scaledToFit()
          .foregroundStyle(Theme.ink.opacity(0.3))
          .frame(width: 96, height: 96)
          .accessibilityHidden(true)
        switch state {
        case .written:
          VStack(alignment: .leading, spacing: 6) {
            Text(word).font(.learning(36)).foregroundStyle(Theme.ink)
            if let note = WordNotes.note(for: word) {
              Text(note).font(.learning(26)).foregroundStyle(Theme.inkSoft)
            }
          }
          Spacer(minLength: 0)
          englishChips(for: word)
          Button("もういちど かく") { onWrite(word) }
            .buttonStyle(PillButtonStyle(color: Theme.blue, minWidth: 200))
            .accessibilityIdentifier("zukanWriteAgain")
        case .unwritten:
          Text("かいて みよう").font(.ui(34, bold: true)).foregroundStyle(Theme.ink)
          Spacer(minLength: 0)
          englishChips(for: word)
          Button("このことばを かく") { onWrite(word) }
            .buttonStyle(PillButtonStyle(color: Theme.accent, minWidth: 260))
            .accessibilityIdentifier("zukanWrite")
        case .locked:
          EmptyView()
        }
      }
      .padding(20)
      .frame(maxWidth: .infinity)
      .background(.white, in: .rect(cornerRadius: Theme.Radius.card))
      .softShadow()
      .padding(.horizontal, 32)
      .padding(.bottom, 12)
      .transition(.move(edge: .bottom).combined(with: .opacity))
    }
  }

  /// 英語のことばがあるときの「ABC」の印（D93・D199）。押すと英語の声で読む。鍵のかかる英語のことばは、鍵の印で、
  /// 押すと「おねがい」。ずかんの★は日本語のことばだけで数える（英語は別の記録）。
  @ViewBuilder
  private func englishChips(for word: String) -> some View {
    let entitlements = purchases.entitlements
    ForEach(EnglishWords.words(for: word), id: \.text) { english in
      let lock = WordAccess.lockedScript(of: english.text, entitlements: entitlements)
      Button {
        SoundPlayer.shared.play(.tap)
        if let lock { onLocked(lock) } else { VoicePlayer.shared.speak(english.text) }
      } label: {
        HStack(spacing: 8) {
          Text("ABC").font(.ui(22, bold: true)).foregroundStyle(Theme.blue)
          if lock != nil {
            Image(systemName: "lock.fill").font(.system(size: 26)).foregroundStyle(Theme.inkSoft)
          } else {
            Text(english.text).font(.learning(34)).foregroundStyle(Theme.ink)
          }
        }
        .padding(.horizontal, 20)
        .frame(minWidth: 104, minHeight: 104)
        .background(Theme.blue.opacity(0.15), in: .rect(cornerRadius: Theme.Radius.button))
      }
      .buttonStyle(.plain)
      .accessibilityLabel(lock == nil ? english.text : String(localized: "ねむっている ことば"))
      .accessibilityIdentifier("zukanEnglish-\(english.text)")
    }
  }

  // MARK: - 押したとき

  private func tapped(_ entry: ZukanEntry) {
    withAnimation(.easeOut(duration: 0.2)) { selected = entry.word }
    switch entry.state {
    case .written:
      if let note = WordNotes.note(for: entry.word) {
        VoicePlayer.shared.speak(note)
      } else {
        VoicePlayer.shared.speak(entry.word)
      }
    case .unwritten:
      VoicePlayer.shared.speak(.zukanHint)
    case .locked:
      selected = nil
      if let script = Self.script(of: entry.word) { onLocked(script) }
    }
  }

  /// ことばを書くのに鍵がかかっているか（字のどれかが書けないとき）。
  /// おためしのことば（バス）は書けるので、鍵ではない（D93）。
  private func isLocked(_ word: String) -> Bool {
    WordAccess.lockedScript(of: word, entitlements: purchases.entitlements) != nil
  }

  private static func script(of word: String) -> Script? {
    WordAccess.script(of: word)
  }
}

/// ずかんのカード1枚。書いたことばは絵と★、まだは影絵。押せる大きさは 190pt 角ほど（104pt 以上。D101）。
private struct ZukanCard: View {
  var entry: ZukanEntry
  var color: Color
  var selected: Bool
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 8) {
        art
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .padding(.horizontal, 12)
        footer
          .frame(height: 44)
      }
      .padding(.top, 14)
      .padding(.bottom, 10)
      .frame(height: 220)
      .background(
        entry.state.isWritten ? color : color.opacity(0.45),
        in: .rect(cornerRadius: Theme.Radius.card)
      )
      .overlay {
        RoundedRectangle(cornerRadius: Theme.Radius.card)
          .stroke(selected ? Theme.accent : .white.opacity(0.8), lineWidth: selected ? 7 : 5)
      }
      .softShadow()
      .overlay(alignment: .topTrailing) {
        // 英語のことばがあるときの「ABC」の印（D93）。
        if !EnglishWords.words(for: entry.word).isEmpty {
          Text("ABC").font(.ui(18, bold: true)).foregroundStyle(.white)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(Theme.blue, in: .capsule)
            .padding(10)
            .accessibilityHidden(true)
        }
      }
    }
    .buttonStyle(.plain)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(label)
    .accessibilityIdentifier("zukan-\(entry.word)")
    .accessibilityAddTraits(.isButton)
  }

  private var label: String {
    switch entry.state {
    case .written(let stars): "\(entry.word)、ほし \(stars)"
    case .unwritten: "まだ かいていない ことば"
    case .locked: "ねむっている ことば"
    }
  }

  /// 書いたことばはもとの絵、まだは1色の影絵（絵の形だけを塗りつぶす。絵づくりの「sil」と同じ）。
  private var art: some View {
    Image(WordArt.assetName(for: entry.word))
      .renderingMode(entry.state.isWritten ? .original : .template)
      .resizable().scaledToFit()
      .foregroundStyle(Theme.ink.opacity(0.28))
      .accessibilityHidden(true)
  }

  @ViewBuilder
  private var footer: some View {
    switch entry.state {
    case .written(let stars):
      HStack(spacing: 4) {
        ForEach(1...Zukan.maxStars, id: \.self) { index in
          Image(systemName: index <= stars ? "star.fill" : "star")
            .font(.system(size: 30))
            .foregroundStyle(index <= stars ? Theme.yellow : Color.gray.opacity(0.4))
        }
      }
      .padding(.horizontal, 14)
      .frame(maxHeight: .infinity)
      .background(.white.opacity(0.9), in: .capsule)
    case .unwritten:
      Text("？").font(.ui(30, bold: true)).foregroundStyle(Theme.inkSoft)
    case .locked:
      Image(systemName: "lock.fill").font(.system(size: 28)).foregroundStyle(Theme.inkSoft)
    }
  }
}

/// ずかんの表紙（§3.3・D54）。本の表紙のような見出し。ステッカーを貼って、じぶんだけの ずかんにできる。
/// 貼る・はがす あいだ（`stickerMode`）は、貼ってあるステッカーを押すと はがれる。
private struct ZukanCover: View {
  /// 表紙に貼ってあるステッカー（位置は、表紙の はばと高さに対する割合。左上が原点）。
  var stickers: [OwnedSticker]
  var stickerMode: Bool
  var showsStickerButton: Bool
  var onStickers: () -> Void
  var onPeel: (OwnedSticker) -> Void

  /// 押して貼るときの場所（題と主人公に かさならない所を、順に使う）。
  static let spots: [(x: Double, y: Double)] = [
    (0.11, 0.27), (0.87, 0.24), (0.12, 0.74), (0.23, 0.50), (0.76, 0.22),
  ]

  private let store = ProgressStore.shared
  private static let side: CGFloat = 92

  private var title: String {
    let name = store.currentProfile?.name.trimmingCharacters(in: .whitespaces) ?? ""
    return name.isEmpty ? String(localized: "わたしの ずかん") : String(localized: "\(name)の ずかん")
  }

  var body: some View {
    ZStack {
      // 本の表紙: あたたかい色の紙と、左の背。
      RoundedRectangle(cornerRadius: 36)
        .fill(
          LinearGradient(
            colors: [Color(red: 1, green: 0.84, blue: 0.52), Color(red: 0.99, green: 0.70, blue: 0.42)],
            startPoint: .top, endPoint: .bottom))
      HStack(spacing: 0) {
        Rectangle().fill(Color(red: 0.86, green: 0.50, blue: 0.26)).frame(width: 34)
        Rectangle().fill(.white.opacity(0.45)).frame(width: 5)
        Spacer(minLength: 0)
      }
      .clipShape(.rect(cornerRadius: 36))
      .accessibilityHidden(true)
      HStack(spacing: 20) {
        VStack(spacing: 6) {
          Text("ずかん")
            .font(.ui(64, bold: true))
            .foregroundStyle(.white)
            .shadow(color: Color(red: 0.6, green: 0.32, blue: 0.1).opacity(0.5), radius: 0, y: 4)
            .accessibilityAddTraits(.isHeader)
          Text(title)
            .font(.ui(24, bold: true))
            .foregroundStyle(Theme.ink)
            .padding(.horizontal, 18)
            .padding(.vertical, 6)
            .background(.white.opacity(0.8), in: .capsule)
        }
        MainCharacterArt(character: store.mainCharacter, size: 150, pose: .wave)
      }
      .padding(.leading, 40)
      GeometryReader { proxy in
        ForEach(stickers) { sticker in
          placed(sticker, in: proxy.size)
        }
      }
    }
    .frame(height: 250)
    .overlay(RoundedRectangle(cornerRadius: 36).stroke(.white.opacity(0.85), lineWidth: 6))
    .softShadow()
    .overlay(alignment: .bottomTrailing) {
      if showsStickerButton, !stickerMode {
        StickerButton(action: onStickers).padding(14)
      }
    }
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier("zukanCover")
  }

  @ViewBuilder
  private func placed(_ sticker: OwnedSticker, in size: CGSize) -> some View {
    if let place = sticker.placement {
      let half = Self.side / 2
      let x = min(max(CGFloat(place.x) * size.width, half), max(size.width - half, half))
      let y = min(max(CGFloat(place.y) * size.height, half), max(size.height - half, half))
      Button {
        SoundPlayer.shared.play(.tap)
        onPeel(sticker)
      } label: {
        Image(StickerArt.assetName(sticker.sticker))
          .resizable().scaledToFit()
          .frame(width: Self.side, height: Self.side)
          .rotationEffect(.radians(Double(StickerArt.tilt(of: sticker.id))))
          .frame(width: StickerArt.minimumTarget, height: StickerArt.minimumTarget)
          .contentShape(.rect)
      }
      .buttonStyle(.plain)
      // ふだんは押せない（まちがえて はがさないように）。貼る・はがす あいだ だけ、押すと はがれる。
      .allowsHitTesting(stickerMode)
      .position(x: x, y: y)
      .accessibilityLabel("ステッカー、\(StickerArt.name(sticker.sticker))")
      .accessibilityHint(stickerMode ? Text("おすと はがせる") : Text(verbatim: ""))
      .accessibilityIdentifier("coverSticker-\(sticker.sticker)")
      .transition(.scale.combined(with: .opacity))
    }
  }
}
