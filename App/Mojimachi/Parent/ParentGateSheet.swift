import ComposableArchitecture
import ParentGateKit
import SwiftUI

/// 保護者用の確認（D49・D64）。漢数字のかけ算に答える。子どもの画面から開くので、
/// ほかのダイアログと同じポップな見た目で出す（D155）。しくみは変えない。
struct ParentGateSheet: View {
  let store: StoreOf<ParentGateFeature>
  var onPassed: () -> Void
  var onCancel: () -> Void

  var body: some View {
    VStack(spacing: 20) {
      Text("保護者の方へ").font(.ui(30, bold: true)).foregroundStyle(Theme.ink)
      Text(store.gate.question.japanese)
        .font(.ui(28, bold: true))
        .foregroundStyle(Theme.ink)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: 520)
        .accessibilityLabel(store.gate.question.japanese)
      Text(store.input.isEmpty ? " " : store.input)
        .font(.system(size: 48, weight: .bold, design: .monospaced))
        .foregroundStyle(Theme.ink)
        .frame(minWidth: 200)
        .padding(.vertical, 8)
        .background(Color.white, in: .rect(cornerRadius: 20))
      if let message = store.message {
        Text(message).font(.ui(20)).foregroundStyle(Theme.inkSoft)
          .multilineTextAlignment(.center)
      }
      keypad
      Button {
        store.send(.cancelTapped)
      } label: {
        Text("やめる")
      }
      .buttonStyle(PillButtonStyle(color: Theme.blue, minWidth: 200))
    }
    .onAppear { store.send(.opened) }
    .onChange(of: store.outcome) { _, outcome in
      switch outcome {
      case .passed: onPassed()
      case .cancelled: onCancel()
      case nil: break
      }
    }
  }

  private var keypad: some View {
    let rows = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], ["消す", "0", "OK"]]
    return VStack(spacing: 12) {
      ForEach(rows, id: \.self) { row in
        HStack(spacing: 12) {
          ForEach(row, id: \.self) { key in
            Button {
              store.send(.keyPressed(key))
            } label: {
              Text(key)
                .font(.ui(34, bold: true))
                .foregroundStyle(key == "OK" ? Color.white : Theme.ink)
                .frame(width: 112, height: 88)
                .background(
                  key == "OK" ? Theme.green : Color.white, in: .rect(cornerRadius: 24)
                )
                .softShadow()
            }
            .buttonStyle(.plain)
          }
        }
      }
    }
  }
}
