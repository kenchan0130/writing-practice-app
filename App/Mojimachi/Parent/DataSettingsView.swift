import SwiftUI

/// 保護者用の画面の「iCloud とデータ」（D63・D116・§6.3）。同期の状態は保護者用の画面にだけ出す。
struct DataSettingsView: View {
  private let store = ProgressStore.shared
  @State private var resetDone = false

  var body: some View {
    Form {
      Section {
        LabeledContent("iCloud") {
          Text(FileManager.default.ubiquityIdentityToken == nil ? "サインインしていません" : "サインイン済み")
        }
        LabeledContent("さいごに ほぞんした じかん") {
          Text(store.lastSaved?.formatted(date: .abbreviated, time: .shortened) ?? "この起動では まだ")
        }
        LabeledContent("ほぞんしている記録") { Text("\(store.savedRowCount) 件") }
        if RecordStore.lastError != nil {
          Text("保存に失敗したことがあります。iPad の空き容量を確かめてください。")
            .foregroundStyle(.red)
        }
      } footer: {
        Text("記録はこの iPad の中に保存しています。iCloud での同期と家族との共有は、準備ができしだい使えるようにします。")
      }
      Section {
        HoldToConfirmButton(title: "全員の記録を リセット") {
          store.resetAllRecords()
          resetDone = true
        }
        if resetDone {
          Text("全員の記録をリセットしました。設定とまちは残っています。").foregroundStyle(.secondary)
        }
      } footer: {
        Text("子ども全員の学習記録・もじの地図・アルバムを最初からにします。設定とまちは残ります。1人だけリセットするときは「子どもたち」から。3秒長押しで実行します。")
      }
    }
    .navigationTitle("iCloud とデータ")
  }
}

/// 取り返しのつかない操作の赤いボタン。3秒長押しで実行する（D116）。
struct HoldToConfirmButton: View {
  var title: String
  var action: () -> Void
  @State private var progress = 0.0

  var body: some View {
    Text(title)
      .font(.headline)
      .foregroundStyle(.white)
      .frame(maxWidth: .infinity, minHeight: 52)
      .background(alignment: .leading) {
        GeometryReader { proxy in
          ZStack(alignment: .leading) {
            Color.red.opacity(0.7)
            Color.red.frame(width: proxy.size.width * progress)
          }
        }
      }
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .onLongPressGesture(minimumDuration: 3) {
        progress = 0
        Task {
          // 「iPad のパスコードも求める」なら、もう一度 iPad の認証を求める（§5.3）。
          if await DeviceAuth.confirmIfRequired() { action() }
        }
      } onPressingChanged: { isPressing in
        withAnimation(isPressing ? .linear(duration: 3) : .easeOut(duration: 0.2)) {
          progress = isPressing ? 1 : 0
        }
      }
      .accessibilityAddTraits(.isButton)
      .accessibilityHint("3秒長押しで実行します")
      .accessibilityAction {
        Task { if await DeviceAuth.confirmIfRequired() { action() } }
      }
  }
}
