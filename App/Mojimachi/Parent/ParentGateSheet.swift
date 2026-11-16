import ParentGateKit
import SwiftUI

/// 保護者用の確認の画面（D49・D64）。漢数字のかけ算に答える。
struct ParentGateSheet: View {
  @Binding var gate: ParentGate
  var onPassed: () -> Void
  var onCancel: () -> Void

  @State private var input = ""
  @State private var message: String?
  private let store = ProgressStore.shared

  var body: some View {
    VStack(spacing: 24) {
      Text("おとなのひとへ").font(.title2.bold())
      Text(gate.question.japanese)
        .font(.title2.bold())
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: 420)
        .accessibilityLabel(gate.question.japanese)
      Text(input.isEmpty ? " " : input)
        .font(.system(size: 48, weight: .bold, design: .monospaced))
        .frame(minWidth: 160)
        .padding(.vertical, 8)
        .background(.quaternary, in: .rect(cornerRadius: 12))
      if let message {
        Text(message).foregroundStyle(.secondary)
      }
      keypad
      Button("やめる", role: .cancel, action: onCancel)
    }
    .padding(40)
  }

  private var keypad: some View {
    let rows = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], ["けす", "0", "OK"]]
    return VStack(spacing: 12) {
      ForEach(rows, id: \.self) { row in
        HStack(spacing: 12) {
          ForEach(row, id: \.self) { key in
            Button {
              press(key)
            } label: {
              Text(key).font(.title.bold()).frame(width: 96, height: 72)
            }
            .buttonStyle(.bordered)
          }
        }
      }
    }
  }

  private func press(_ key: String) {
    switch key {
    case "けす":
      input = ""
    case "OK":
      submit()
    default:
      if input.count < 3 { input += key }
    }
  }

  private func submit() {
    guard let value = Int(input) else { return }
    input = ""
    let now = Date().timeIntervalSince1970
    switch gate.answer(value, at: now) {
    case .passed:
      if store.requiresDeviceAuth {
        authenticateDevice()
      } else {
        onPassed()
      }
    case .wrong(let remaining):
      message = "ちがいます。あと \(remaining) 回 ためせます"
    case .locked(let until):
      message = "\(Int(until - now) + 1) 秒 まってから ためしてください"
    }
  }

  /// 「iPad のパスコードも もとめる」（D64）。パスコードが設定されていなければ、かけ算だけで通す。
  private func authenticateDevice() {
    Task {
      if await DeviceAuth.confirm(reason: "保護者用の画面を開きます") {
        onPassed()
      } else {
        message = "iPad の確認ができませんでした"
      }
    }
  }

}
