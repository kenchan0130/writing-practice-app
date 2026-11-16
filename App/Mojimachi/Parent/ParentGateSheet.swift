import ComposableArchitecture
import ParentGateKit
import SwiftUI

/// 保護者用の確認の画面（D49・D64）。漢数字のかけ算に答える。
struct ParentGateSheet: View {
  let store: StoreOf<ParentGateFeature>
  var onPassed: () -> Void
  var onCancel: () -> Void

  var body: some View {
    VStack(spacing: 24) {
      Text("おとなのひとへ").font(.title2.bold())
      Text(store.gate.question.japanese)
        .font(.title2.bold())
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: 420)
        .accessibilityLabel(store.gate.question.japanese)
      Text(store.input.isEmpty ? " " : store.input)
        .font(.system(size: 48, weight: .bold, design: .monospaced))
        .frame(minWidth: 160)
        .padding(.vertical, 8)
        .background(.quaternary, in: .rect(cornerRadius: 12))
      if let message = store.message {
        Text(message).foregroundStyle(.secondary)
      }
      keypad
      Button("やめる", role: .cancel) { store.send(.cancelTapped) }
    }
    .padding(40)
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
    let rows = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], ["けす", "0", "OK"]]
    return VStack(spacing: 12) {
      ForEach(rows, id: \.self) { row in
        HStack(spacing: 12) {
          ForEach(row, id: \.self) { key in
            Button {
              store.send(.keyPressed(key))
            } label: {
              Text(key).font(.title.bold()).frame(width: 96, height: 72)
            }
            .buttonStyle(.bordered)
          }
        }
      }
    }
  }
}
