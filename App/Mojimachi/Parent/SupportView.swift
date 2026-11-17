import StoreKit
import SupportKit
import SwiftUI
import UIKit

/// 保護者用の画面の「サポート」（D124・§5.3）。フォームはアプリの中のブラウザで開く。
struct SupportView: View {
  @Environment(\.requestReview) private var requestReview

  var body: some View {
    Form {
      Section {
        formLink("この判定はおかしい", kind: .judge, detail: judgeDetail)
        formLink("ご意見", kind: .opinion)
        formLink("施設でお使いの方へ", kind: .facility)
      } footer: {
        Text("お問い合わせのフォームを開きます。アプリの版と iPadOS の版は、最初から入っています。")
      }
      Section {
        Link("サポートページ", destination: PublicPages.support)
        Link("プライバシーポリシー", destination: PublicPages.privacy)
        NavigationLink("このアプリについて") { AboutView() }
        Button("アプリを評価する") { requestReview() }
      }
    }
    .navigationTitle("サポート")
    .environment(\.openURL, OpenURLAction { .systemAction($0, prefersInApp: true) })
  }

  /// 判定の報告に添える、最後の設定。
  private var judgeDetail: String {
    "設定: \(ProgressStore.shared.preset.rawValue)"
  }

  private func formLink(_ title: String, kind: FeedbackForm.Kind, detail: String? = nil)
    -> some View
  {
    Link(
      title,
      destination: FeedbackForm.url(
        kind: kind,
        context: FeedbackForm.Context(
          appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
          osVersion: "iPadOS \(UIDevice.current.systemVersion)", detail: detail)))
  }
}

/// このアプリについて（ライセンスの表示。D128）。
struct AboutView: View {
  var body: some View {
    List {
      Section("文字のデータ") {
        notice("Packs/hira/NOTICE.md")
        notice("Packs/kata/NOTICE.md")
      }
      Section("ライセンス（strokesvg・Klee One）") {
        notice("Packs/hira/LICENSE")
      }
      // 子どもの画面の書体（D153）。ライセンス文と著作権表示。
      Section("書体（Klee One・Zen Maru Gothic）") {
        notice("FONTS-NOTICE.txt")
        notice("OFL-KleeOne.txt")
        notice("OFL-ZenMaruGothic.txt")
      }
      // 効果音の出どころ（D149）。小森平さん・Freesound（CC0）・OtoLogic（CC BY 4.0。D158）・こんとどぅふぇ。
      Section("効果音（小森平・Freesound・OtoLogic・こんとどぅふぇ）") {
        notice("SOUNDS-NOTICE.txt")
      }
    }
    .navigationTitle("このアプリについて")
  }

  private func notice(_ path: String) -> some View {
    let url = Bundle.main.resourceURL?.appendingPathComponent(path)
    let text = url.flatMap { try? String(contentsOf: $0, encoding: .utf8) } ?? "（見つかりません）"
    return Text(text).font(.footnote).textSelection(.enabled)
  }
}
