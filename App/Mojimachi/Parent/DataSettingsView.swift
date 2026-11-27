import SwiftUI

/// 保護者用の画面の「学習記録の管理」（D63・D116・§6.3）。同期の状態は保護者用の画面にだけ出す。
struct DataSettingsView: View {
  @Bindable private var store = ProgressStore.shared
  @State private var resetDone = false

  /// 「iCloud のデータを消す」を出す条件（署名ありのビルドで、iCloud が使えるとき。D85）。
  /// 同じ Apple アカウントのどの iPad からでも消せる（家族の共有は作らない。D148）。
  private var canDeleteICloudData: Bool {
    RecordStore.hasCloudEntitlement && !RecordStore.isLocalOnlyRun
      && store.accountState == .available
  }

  private static func format(_ date: Date?) -> String? {
    date?.formatted(date: .abbreviated, time: .shortened)
  }

  private var accountText: String {
    if !RecordStore.hasCloudEntitlement { return String(localized: "このビルドでは iCloud を使いません") }
    switch store.accountState {
    case .checking: return String(localized: "確かめています")
    case .available: return String(localized: "サインイン済み")
    case .noAccount: return String(localized: "サインインしていません")
    case .restricted: return String(localized: "使えません（制限されています）")
    case .temporarilyUnavailable: return String(localized: "今は使えません")
    case .unknown: return String(localized: "確かめられません")
    }
  }

  private var problemMessage: String? {
    switch store.accountState {
    case .noAccount:
      return String(localized: "iCloud にサインインしていないため、同期できません。設定アプリでサインインしてください。")
    case .restricted:
      return String(localized: "この iPad では iCloud が制限されているため、同期できません。")
    default: break
    }
    switch store.syncProblem {
    case .notSignedIn?: return String(localized: "iCloud にサインインしていないため、同期できません。設定アプリでサインインしてください。")
    case .quotaExceeded?: return String(localized: "iCloud の空き容量が足りないため、同期できません。記録はこの iPad に保存しています。")
    case .other?: return String(localized: "iCloud との同期がうまくいっていません。しばらくしてからもう一度試します。")
    case nil: return nil
    }
  }

  private var syncFooter: String {
    if store.accountState == .noAccount {
      return String(localized: "記録はこの iPad の中に保存しています。iCloud にサインインすると、同期できるようになります。")
    }
    if store.syncsWithICloud != store.isSyncRunning {
      return String(localized: "同期の切り替えは、次にアプリを開いたときから効きます。オフにしても、この iPad と iCloud の記録は残ります。")
    }
    return store.isSyncRunning
      ? String(localized: "記録は iCloud で同期しています。オフにしても、この iPad と iCloud の記録は残ります。")
      : String(localized: "同期はオフです。記録はこの iPad の中だけに保存しています。オンに戻すと、この iPad の記録を iCloud に上げます。")
  }

  var body: some View {
    Form {
      Section {
        Toggle("iCloud で同期", isOn: $store.syncsWithICloud)
        LabeledContent("iCloud") {
          Text(accountText)
        }
        LabeledContent("最後に iCloud に保存した時間") {
          Text(Self.format(store.lastExported) ?? String(localized: "まだ"))
        }
        if let imported = Self.format(store.lastImported) {
          LabeledContent("最後に iCloud から取り込んだ時間") { Text(imported) }
        }
        LabeledContent("最後にこの iPad に保存した時間") {
          Text(Self.format(store.lastSaved) ?? String(localized: "この起動ではまだ"))
        }
        LabeledContent("保存している記録") { Text("\(store.savedRowCount) 件") }
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
      if let notice = store.cloudDeletedNotice {
        Section {
          Text("ほかの iPad が iCloud のデータを消したため、この iPad の同期をオフにしました。この iPad の記録は残っています。")
          Text(Self.format(notice) ?? "").foregroundStyle(.secondary)
          Button("OK") { store.dismissCloudDeletedNotice() }
        }
      }
      if canDeleteICloudData {
        Section {
          HoldToConfirmButton(title: "iCloud のデータを消す") {
            Task { await store.deleteICloudData() }
          }
          switch store.cloudDeleteState {
          case .idle: EmptyView()
          case .deleting: Text("消しています…").foregroundStyle(.secondary)
          case .done:
            Text("iCloud のデータを消しました。この iPad の同期はオフです。この iPad の記録は残っています。")
              .foregroundStyle(.secondary)
          case .failed:
            Text("iCloud のデータを消せませんでした。しばらくしてからもう一度試してください。この iPad の同期はオフです。")
              .foregroundStyle(.red)
          }
        } header: {
          Text("ほかの iPad の記録も消えることがあります")
            .foregroundStyle(.red)
        } footer: {
          Text(
            "先にこの iPad の同期をオフにして、iCloud にあるもじまちのデータを消します。この iPad の中の記録は残ります。ほかの iPad は、次に開いたときに保護者用の画面で知らせて、同期をオフにします。3秒長押しで実行します。"
          )
        }
      }
      Section {
        HoldToConfirmButton(title: "全員の記録をリセット") {
          store.resetAllRecords()
          resetDone = true
        }
        if resetDone {
          Text("全員の記録をリセットしました。設定とまちは残っています。").foregroundStyle(.secondary)
        }
      } footer: {
        Text("子ども全員の学習記録・文字の地図・アルバムを最初からにします。設定とまちは残ります。1人だけリセットするときは「子どもたち」から。3秒長押しで実行します。")
      }
    }
    .navigationTitle("学習記録の管理")
    .task { await store.refreshAccountState() }
  }
}

/// 取り返しのつかない操作の赤いボタン。3秒長押しで実行する（D116）。
struct HoldToConfirmButton: View {
  var title: LocalizedStringKey
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
