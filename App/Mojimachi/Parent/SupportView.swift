import StoreKit
import SupportKit
import SwiftUI
import UIKit

/// 保護者用の画面の「サポート」（D124・§5.3）。フォームやページは Safari で開く（D193）。
struct SupportView: View {
  @Environment(\.requestReview) private var requestReview

  var body: some View {
    Form {
      Section {
        formLink("この判定はおかしい", kind: .judge, detail: judgeDetail)
        formLink("ご意見", kind: .opinion)
        formLink("施設でお使いの方へ", kind: .facility)
      } footer: {
        Text("お問い合わせのフォームを Safari で開きます。調べるために、アプリの版と iPadOS の版を入れておきます。")
      }
      Section {
        Link("サポートページ", destination: PublicPages.support)
        Link(
          "プライバシーポリシー",
          destination: AppLanguage.isEnglish ? PublicPages.privacyEnglish : PublicPages.privacy)
        // ライセンスと出どころは、iOS の「設定」アプリの もじまち のページに出す（D196）。
        Button("このアプリについて") { openAppSettings() }
        Button("アプリを評価する") { requestReview() }
      }
    }
    .navigationTitle("サポート")
  }

  /// 「設定」アプリの もじまち のページ（ライセンス）を開く。ブラウザでは開かない（D196）。
  private func openAppSettings() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(url)
  }

  /// 判定の報告に添える、最後の設定。
  private var judgeDetail: String {
    "設定: \(ProgressStore.shared.preset.rawValue)"
  }

  /// フォームに入れる、アプリの版（例 "1.0 (27)"）。
  private var appVersion: String {
    let info = Bundle.main.infoDictionary
    let version = info?["CFBundleShortVersionString"] as? String ?? ""
    let build = info?["CFBundleVersion"] as? String ?? ""
    return build.isEmpty ? version : "\(version) (\(build))"
  }

  private func formLink(_ title: LocalizedStringKey, kind: FeedbackForm.Kind, detail: String? = nil)
    -> some View
  {
    Link(
      title,
      destination: FeedbackForm.url(
        kind: kind,
        context: FeedbackForm.Context(
          appVersion: appVersion, os: "iPadOS \(UIDevice.current.systemVersion)", detail: detail)))
  }
}
