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
  @State private var showsPicker = false

  var body: some View {
    let store = ProgressStore.shared
    Button {
      SoundPlayer.shared.play(.tap)
      showsPicker = true
    } label: {
      VStack(spacing: 4) {
        Image(systemName: "pencil.tip")
          .font(.system(size: 40, weight: .bold))
          .foregroundStyle(store.penColor.color)
        Text("ペンたて").font(.footnote.bold())
      }
      .frame(minWidth: 112, minHeight: 112)
    }
    .buttonStyle(.bordered)
    .buttonBorderShape(.roundedRectangle(radius: 24))
    .accessibilityLabel("ペンたて")
    .sheet(isPresented: $showsPicker) {
      PenColorPicker(title: "ペンの いろを えらぼう") { color in
        store.setPenColor(color)
        showsPicker = false
      }
      .presentationDetents([.medium])
    }
  }
}

/// 8色から選ぶ画面。色のボタンは 104pt 以上。
struct PenColorPicker: View {
  var title: String
  var onPick: (PenColor) -> Void

  private let columns = Array(repeating: GridItem(.fixed(120), spacing: 24), count: 4)

  var body: some View {
    let store = ProgressStore.shared
    let current: PenColor? = store.needsPenColorChoice ? nil : store.penColor
    VStack(spacing: 32) {
      Text(title).font(.system(size: 36, weight: .heavy))
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
    }
    .padding(32)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

/// ペン立てを置く隅（利き手の反対側）。
func penStandAlignment() -> Alignment {
  ProgressStore.shared.currentProfile?.handedness == .left ? .bottomTrailing : .bottomLeading
}
