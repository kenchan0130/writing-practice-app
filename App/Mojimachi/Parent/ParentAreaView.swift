import JudgeKit
import SwiftUI

/// 保護者用の画面（D116 の8つの項目の枠。試作）。iPad の設定アプリと同じ一覧の作り。
struct ParentAreaView: View {
  var onClose: () -> Void
  @Bindable private var store = ProgressStore.shared
  @State private var path: [String] = {
    #if DEBUG
      // 確かめ用: `-openParent records`（profiles・data）で、その項目を開いた状態にする。
      if let page = UserDefaults.standard.string(forKey: "openParent") { return [page] }
    #endif
    return []
  }()

  var body: some View {
    NavigationStack(path: $path) {
      List {
        Section {
          NavigationLink("学習記録") { LearningRecordView() }
          NavigationLink("子どもたち") { ProfilesView() }
          NavigationLink("判定") { judgeSettings }
          NavigationLink("購入") { PurchaseView() }
          NavigationLink("音と表示") { SoundDisplayView() }
          NavigationLink("学習記録の管理") { DataSettingsView() }
          NavigationLink("安心のための設定") { safetySettings }
          NavigationLink("サポート") { SupportView() }
        }
      }
      .navigationTitle("保護者用の画面")
      .navigationDestination(for: String.self) { page in
        switch page {
        case "profiles": ProfilesView()
        case "data": DataSettingsView()
        case "sound": SoundDisplayView()
        case "support": SupportView()
        case "purchase": PurchaseView()
        default: LearningRecordView()
        }
      }
      .toolbar {
        ToolbarItem(placement: .confirmationAction) { Button("閉じる", action: onClose) }
      }
    }
  }

  private var judgeSettings: some View {
    Form {
      Section {
        Picker("判定の厳しさ", selection: $store.preset) {
          ForEach(JudgePreset.allCases, id: \.self) { preset in
            presetRow(preset.title, preset.detail).tag(preset)
          }
        }
        .pickerStyle(.inline)
      } footer: {
        Text("迷ったときは「はじめて」から始めてください。上達したら、この画面でお知らせします。")
      }
      Section {
        Toggle("とめ・はね・はらいのヒントを出す", isOn: $store.showsEndingHints)
      } footer: {
        Text("とめ・はね・はらいは、まちがいにはしません（文化庁の考え方）。学校によっては採点することもあるので、気になるときはヒントをオンにしてください。")
      }
    }
    .navigationTitle("判定")
  }

  /// 判定の段階の名前と、その説明（D22・D84）。
  private func presetRow(_ name: String, _ detail: String) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(name)
      Text(detail).font(.footnote).foregroundStyle(.secondary)
    }
  }

  private var safetySettings: some View {
    Form {
      Section {
        Toggle("iPad のパスコードも求める", isOn: $store.requiresDeviceAuth)
      } footer: {
        Text(
          DeviceAuth.isAvailable
            ? "お子さまの指や顔が iPad に登録されていると、お子さまでも通れます。"
            : "この iPad にはパスコードが設定されていないので、かけ算だけで通ります。iPad の設定アプリでパスコードを設定すると使えます。"
        )
      }
      Section {
        Toggle("不具合の情報を送る", isOn: $store.sendsCrashReports)
      } footer: {
        Text("アプリが落ちたときの情報だけを送ります。名前や端末の ID は送りません。")
      }
    }
    .navigationTitle("安心のための設定")
  }

}
