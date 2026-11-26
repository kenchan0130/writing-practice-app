import EntitlementKit
import JudgeKit
import RecordKit
import SwiftUI

/// 保護者用の画面（D116 の8つの項目の枠。試作）。iPad の設定アプリと同じ一覧の作り。
struct ParentAreaView: View {
  var onClose: () -> Void
  /// 操作があったとき（確認の有効な時間を延ばす。D49）。
  var onActivity: () -> Void = {}
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
        wishSection
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
    // 触れるたびに、有効な時間を延ばす。ほかの操作を邪魔しない形で見るだけ。
    .simultaneousGesture(
      DragGesture(minimumDistance: 0).onChanged { _ in onActivity() })
  }

  /// 子どもの「おねがい」のお知らせ（D54・D116・D160）。いつ押したか（最新の日）だけ出し、回数は出さない。
  /// 買ったら自動で消える。「確認した」でも消せる。通知は使わない。
  @ViewBuilder
  private var wishSection: some View {
    let notices = store.wishNotices(isOwned: { item in
      Script(rawValue: item).map(PurchaseStore.shared.entitlements.isUnlocked) ?? false
    })
    if !notices.isEmpty {
      Section {
        ForEach(notices) { notice in
          HStack {
            Label(
              notice.text(
                name: store.profiles.profile(notice.profileID)?.displayName ?? "",
                itemTitle: Script(rawValue: notice.item)?.wishTitle ?? notice.item),
              systemImage: "heart.fill"
            )
            .accessibilityIdentifier("wishNotice")
            Spacer()
            Button("確認した") { store.dismissWishes(profile: notice.profileID, item: notice.item) }
              .buttonStyle(.borderless)
          }
        }
        NavigationLink("購入を見る") { PurchaseView() }
      } header: {
        Text("お子さまからのおねがい")
      } footer: {
        Text("お子さまが鍵のかかった文字を見て、おとなにおねがいしました。購入するかどうかは、保護者の方が決めてください。")
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
        Text("アプリが落ちたときだけ、落ちた場所・アプリの版・iPadOS の版・iPad の種類を、品質を直すために送ります。名前・記録・子どもが書いた線・端末の ID は送りません。くわしくはプライバシーポリシーをごらんください。")
          .font(.footnote)
      } header: {
        Text("不具合の情報")
      }
    }
    .navigationTitle("安心のための設定")
  }

}
