import RecordKit
import SwiftUI
import UIKit

extension PenColor {
  var color: Color {
    let c = rgb
    return Color(red: c.red, green: c.green, blue: c.blue)
  }

  var uiColor: UIColor {
    let c = rgb
    return UIColor(red: c.red, green: c.green, blue: c.blue, alpha: 1)
  }
}

/// 書く画面の隅のペン立て（D88）。押すと8色から選べる。押せる部分は 2cm 角以上（D101）。
struct PenStandButton: View {
  var body: some View {
    let store = ProgressStore.shared
    Button {
      SoundPlayer.shared.play(.tap)
      PopPresenter.shared.show(id: "penPicker", dismissesOnBackdrop: true) {
        PenColorPicker(
          title: "ペンの いろを えらぼう",
          onClose: {
            PopPresenter.shared.dismiss(id: "penPicker")
          }
        ) { color in
          store.setPenColor(color)
          PopPresenter.shared.dismiss(id: "penPicker")
        }
      }
    } label: {
      VStack(spacing: 4) {
        Image(systemName: "pencil.tip")
          .font(.system(size: 40, weight: .bold))
          .foregroundStyle(store.penColor.color)
        Text("ペンたて").font(.ui(14, bold: true))
      }
      .frame(minWidth: 112, minHeight: 112)
    }
    .buttonStyle(.plain)
    .background(Color.white.opacity(0.85), in: .rect(cornerRadius: 24))
    .softShadow()
    .accessibilityLabel("ペンたて")
  }
}

/// 8色から選ぶ画面。色のボタンは 104pt 以上。
struct PenColorPicker: View {
  var title: String
  /// 閉じるボタン（なければ出さない。最初の起動では色を選んでもらう）。
  var onClose: (() -> Void)?
  var onPick: (PenColor) -> Void

  private let columns = Array(repeating: GridItem(.fixed(120), spacing: 24), count: 4)

  var body: some View {
    let store = ProgressStore.shared
    let current: PenColor? = store.needsPenColorChoice ? nil : store.penColor
    VStack(spacing: 32) {
      Text(title).font(.ui(36, bold: true)).foregroundStyle(Theme.ink)
      LazyVGrid(columns: columns, spacing: 24) {
        ForEach(PenColor.allCases, id: \.self) { color in
          Button {
            onPick(color)
          } label: {
            ZStack {
              Circle().fill(color.color)
              if color == current {
                Image(systemName: "checkmark")
                  .font(.system(size: 44, weight: .heavy))
                  .foregroundStyle(.white)
              }
            }
            .frame(width: 112, height: 112)
            .overlay(Circle().stroke(.white.opacity(0.9), lineWidth: 4))
            .shadow(radius: 3)
          }
          .buttonStyle(.plain)
          .accessibilityLabel(color.label)
        }
      }
      if let onClose {
        Button(action: onClose) { Text("とじる") }
          .buttonStyle(PillButtonStyle(color: Theme.blue, minWidth: 200))
          .accessibilityIdentifier("popDialogButton")
      }
    }
  }
}

/// ペン立てを置く隅（利き手の反対側）。
func penStandAlignment() -> Alignment {
  ProgressStore.shared.currentProfile?.handedness == .left ? .bottomTrailing : .bottomLeading
}
