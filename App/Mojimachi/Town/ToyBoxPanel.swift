import PracticeKit
import SwiftUI

/// おもちゃばこの中身（D74・D185）。入りきらなかった物が並び、押すと、出ている物と入れ替わって出てくる。
/// 手に入れた物は消えない。数字やエラーは出さない（D117）。
struct ToyBoxPanel: View {
  /// 中の物（出していた時間が新しい順）。
  var objects: [PlacedObject]
  var onTakeOut: (PlacedObject) -> Void
  var onClose: () -> Void

  private let columns = [GridItem(.adaptive(minimum: 120, maximum: 150), spacing: 16)]

  var body: some View {
    VStack(spacing: 20) {
      HStack(spacing: 16) {
        Image("part-omochabako")
          .resizable()
          .scaledToFit()
          .frame(width: 72, height: 72)
          .accessibilityHidden(true)
        Text("おもちゃばこ")
          .font(.ui(36, bold: true))
          .foregroundStyle(Theme.ink)
          .accessibilityIdentifier("toyBoxTitle")
      }
      if objects.isEmpty {
        VStack(spacing: 12) {
          MainCharacterArt(character: ProgressStore.shared.mainCharacter, size: 120)
          Text("いまは からっぽだよ")
            .font(.ui(30, bold: true))
            .foregroundStyle(Theme.ink)
            .accessibilityIdentifier("toyBoxEmpty")
        }
        .padding(.vertical, 12)
      } else {
        Text("だしたい ものを おしてね")
          .font(.ui(26, bold: true))
          .foregroundStyle(Theme.inkSoft)
        ScrollView {
          LazyVGrid(columns: columns, spacing: 16) {
            ForEach(objects) { object in
              Button {
                SoundPlayer.shared.play(.tap)
                onTakeOut(object)
              } label: {
                VStack(spacing: 4) {
                  Image(WordArt.assetName(for: object.word))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 84, height: 84)
                  Text(object.word)
                    .font(.learning(20))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                }
                .frame(maxWidth: .infinity, minHeight: 124)
                .background(.white, in: .rect(cornerRadius: Theme.Radius.card))
                .softShadow()
              }
              .buttonStyle(.plain)
              .accessibilityLabel("\(object.word)を だす")
              .accessibilityIdentifier("toyBoxItem-\(object.word)")
            }
          }
          .padding(8)
        }
        // 中身が少ないときは、カードを小さくする（3列として数える）。
        .frame(height: min(CGFloat((objects.count + 2) / 3) * 140 + 16, 440))
      }
      Button(action: onClose) { Text("とじる") }
        .buttonStyle(PillButtonStyle(color: Theme.green, minWidth: 240))
        .accessibilityIdentifier("toyBoxClose")
    }
  }
}

/// おもちゃばこのボタン（絵。押せる部分は 104pt 角より大きい。D101）。
struct ToyBoxButton: View {
  var action: () -> Void

  var body: some View {
    Button {
      SoundPlayer.shared.play(.tap)
      action()
    } label: {
      Image("part-omochabako")
        .resizable()
        .scaledToFit()
        .frame(width: 96, height: 96)
        .frame(width: 116, height: 116)
        .background(.white.opacity(0.85), in: .rect(cornerRadius: Theme.Radius.card))
        .softShadow()
    }
    .buttonStyle(.plain)
    .accessibilityLabel("おもちゃばこ")
    .accessibilityIdentifier("toyBoxButton")
  }
}

@MainActor
enum ToyBoxPresenter {
  /// おもちゃばこを開く。物を出すと、すぐ閉じて、まち（いえ）に出るのが見える。
  static func show(groups: [ShelfGroup]) {
    let store = ProgressStore.shared
    PopPresenter.shared.show(id: "toyBox", dismissesOnBackdrop: true) {
      ToyBoxPanel(
        objects: store.board.boxed(groups),
        onTakeOut: { object in
          store.takeOut(object.id)
          PopPresenter.shared.dismiss(id: "toyBox")
          VoicePlayer.shared.speak(object.word)
        },
        onClose: { PopPresenter.shared.dismiss(id: "toyBox") })
    }
  }
}
