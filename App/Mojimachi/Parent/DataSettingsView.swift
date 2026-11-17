import SwiftUI

/// 保護者用の画面の「iCloud とデータ」（D63・D116・§6.3）。同期の状態は保護者用の画面にだけ出す。
struct DataSettingsView: View {
  @Bindable private var store = ProgressStore.shared
  @State private var resetDone = false

  private static func format(_ date: Date?) -> String? {
    date?.formatted(date: .abbreviated, time: .shortened)
  }

  private var accountText: String {
    if !RecordStore.hasCloudEntitlement { return "この ビルドでは iCloud を 使いません" }
    switch store.accountState {
    case .checking: return "確かめています"
    case .available: return "サインイン済み"
    case .noAccount: return "サインインしていません"
    case .restricted: return "使えません（制限されています）"
    case .temporarilyUnavailable: return "いまは使えません"
    case .unknown: return "確かめられません"
    }
  }

  private var problemMessage: String? {
    switch store.accountState {
    case .noAccount:
      return "iCloud にサインインしていないため、同期できません。設定アプリでサインインしてください。"
    case .restricted:
      return "この iPad では iCloud が制限されているため、同期できません。"
    default: break
    }
    switch store.syncProblem {
    case .notSignedIn?: return "iCloud にサインインしていないため、同期できません。設定アプリでサインインしてください。"
    case .quotaExceeded?: return "iCloud の空き容量が足りないため、同期できません。記録はこの iPad に保存しています。"
    case .other?: return "iCloud との同期がうまくいっていません。しばらくしてからもう一度ためします。"
    case nil: return nil
    }
  }

  private var syncFooter: String {
    if store.accountState == .noAccount {
      return "記録はこの iPad の中に保存しています。iCloud にサインインすると、同期できるようになります。"
    }
    if store.syncsWithICloud != store.isSyncRunning {
      return "同期の切り替えは、つぎに アプリを ひらいたときから 効きます。オフにしても、この iPad と iCloud の記録は残ります。"
    }
    return store.isSyncRunning
      ? "記録は iCloud で同期しています。オフにしても、この iPad と iCloud の記録は残ります。"
      : "同期はオフです。記録はこの iPad の中だけに保存しています。オンに戻すと、この iPad の記録を iCloud に上げます。"
  }

  var body: some View {
    Form {
      Section {
        Toggle("iCloud で 同期", isOn: $store.syncsWithICloud)
        LabeledContent("iCloud") {
          Text(accountText)
        }
        LabeledContent("さいごに iCloud に ほぞんした じかん") {
          Text(Self.format(store.lastExported) ?? "まだ")
        }
        if let imported = Self.format(store.lastImported) {
          LabeledContent("さいごに iCloud から とりこんだ じかん") { Text(imported) }
        }
        LabeledContent("さいごに この iPad に ほぞんした じかん") {
          Text(Self.format(store.lastSaved) ?? "この起動では まだ")
        }
        LabeledContent("ほぞんしている記録") { Text("\(store.savedRowCount) 件") }
        if let message = problemMessage {
          Text(message).foregroundStyle(.red)
        }
        if RecordStore.lastError != nil {
          Text("保存に失敗したことがあります。iPad の空き容量を確かめてください。")
            .foregroundStyle(.red)
        }
      } footer: {
        Text(syncFooter)
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
    .task { await store.refreshAccountState() }
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
