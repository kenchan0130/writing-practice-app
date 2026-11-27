import RecordKit
import SwiftUI

/// 引っぱっているステッカー（指の場所は、`StickerTray.space` の座標）。
struct StickerDrag: Equatable {
  var sticker: OwnedSticker
  var location: CGPoint
}

/// ステッカーの入れ物（§3.3・D54）。まだ貼っていないステッカーが並ぶ。
/// 引っぱって貼る。押すだけでも貼れる（引っぱるのが むずかしい子のため）。
/// 貼る先は、まちか ずかんの表紙。どこに貼るかは、呼ぶ側が `onDrop` で決める。
/// 子どもの画面なので、数字・エラー・価格は出さない（D3・D117）。
struct StickerTray: View {
  /// 指の場所を はかる座標の名前。貼る先を含む いちばん外の View に付ける。
  static let space = "stickerBoard"

  /// まだ貼っていないステッカー。
  var stickers: [OwnedSticker]
  /// 貼ってあるステッカーがあるか（はがし方の案内を出す）。
  var hasPlaced: Bool
  @Binding var drag: StickerDrag?
  var onTap: (OwnedSticker) -> Void
  var onDrop: (OwnedSticker, CGPoint) -> Void
  var onClose: () -> Void

  @State private var page = 0
  private let cell = StickerArt.minimumTarget

  var body: some View {
    HStack(spacing: 12) {
      ChildToolButton(title: "できた", systemImage: "checkmark", color: Theme.green) { onClose() }
        .accessibilityIdentifier("stickerTrayClose")
      GeometryReader { proxy in
        let perPage = max(Int((proxy.size.width - (needsPaging(proxy.size.width) ? 116 : 0)) / (cell + 8)), 1)
        let pages = max((stickers.count + perPage - 1) / perPage, 1)
        let current = min(page, pages - 1)
        let shown = Array(stickers.dropFirst(current * perPage).prefix(perPage))
        HStack(spacing: 8) {
          if stickers.isEmpty {
            Text(
              hasPlaced
                ? LocalizedStringKey("はった ステッカーを おすと、はがせるよ")
                : LocalizedStringKey("ステッカーは まだ ないよ"))
              .font(.ui(24, bold: true))
              .foregroundStyle(Theme.inkSoft)
              .frame(maxWidth: .infinity)
              .accessibilityIdentifier("stickerTrayEmpty")
          } else {
            ForEach(Array(shown.enumerated()), id: \.element.id) { index, sticker in
              item(sticker, index: current * perPage + index)
            }
            Spacer(minLength: 0)
            if pages > 1 {
              Button {
                SoundPlayer.shared.play(.tap)
                page = (current + 1) % pages
              } label: {
                Image(systemName: "chevron.right.circle.fill")
                  .font(.system(size: 56, weight: .bold))
                  .foregroundStyle(Theme.accent)
                  .frame(width: cell, height: cell)
              }
              .buttonStyle(.plain)
              .accessibilityLabel("つぎの ステッカー")
              .accessibilityIdentifier("stickerTrayNext")
            }
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
    .padding(.horizontal, 12)
    .frame(height: cell + 20)
    .background(.white.opacity(0.92), in: .rect(cornerRadius: Theme.Radius.card))
    .softShadow()
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier("stickerTray")
  }

  private func needsPaging(_ width: CGFloat) -> Bool {
    CGFloat(stickers.count) * (cell + 8) > width
  }

  private func item(_ sticker: OwnedSticker, index: Int) -> some View {
    Image(StickerArt.assetName(sticker.sticker))
      .resizable()
      .scaledToFit()
      .frame(width: cell - 8, height: cell - 8)
      .frame(width: cell, height: cell)
      .contentShape(.rect)
      .opacity(drag?.sticker.id == sticker.id ? 0 : 1)
      .gesture(
        DragGesture(minimumDistance: 0, coordinateSpace: .named(Self.space))
          .onChanged { value in
            // 少し動かしてから、指についてくる（押しただけのときは動かさない）。
            if hypot(value.translation.width, value.translation.height) > 10 || drag != nil {
              drag = StickerDrag(sticker: sticker, location: value.location)
            }
          }
          .onEnded { value in
            let moved = drag != nil
            drag = nil
            if moved {
              onDrop(sticker, value.location)
            } else {
              onTap(sticker)
            }
          }
      )
      .accessibilityElement()
      .accessibilityLabel("ステッカー、\(StickerArt.name(sticker.sticker))")
      .accessibilityHint("おすと はれる")
      .accessibilityAddTraits(.isButton)
      .accessibilityAction { onTap(sticker) }
      .accessibilityIdentifier("stickerTrayItem-\(index)")
  }
}

/// 引っぱっているステッカー。指についてくる。`StickerTray.space` を付けた View に重ねる。
struct StickerGhost: View {
  var drag: StickerDrag?

  var body: some View {
    if let drag {
      Image(StickerArt.assetName(drag.sticker.sticker))
        .resizable()
        .scaledToFit()
        .frame(width: 128, height: 128)
        .rotationEffect(.degrees(-6))
        .softShadow(Theme.Shadow(color: .black.opacity(0.25), radius: 10, y: 8))
        .position(drag.location)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
  }
}

/// ステッカーの入れ物を開くボタン（押せる部分は 104pt 角より大きい。D101）。
struct StickerButton: View {
  var action: () -> Void

  var body: some View {
    Button {
      SoundPlayer.shared.play(.tap)
      action()
    } label: {
      VStack(spacing: 2) {
        Image(StickerArt.assetName("hoshi"))
          .resizable()
          .scaledToFit()
          .frame(width: 76, height: 72)
        Text("ステッカー").font(.ui(20, bold: true)).foregroundStyle(Theme.ink)
          .lineLimit(1).minimumScaleFactor(0.7)
      }
      .frame(width: 116, height: 116)
      .background(.white.opacity(0.85), in: .rect(cornerRadius: Theme.Radius.card))
      .softShadow()
    }
    .buttonStyle(.plain)
    .accessibilityLabel("ステッカー")
    .accessibilityIdentifier("stickerButton")
  }
}
