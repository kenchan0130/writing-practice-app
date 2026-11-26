import Foundation
import Testing

@testable import SupportKit

@Suite("お問い合わせのフォーム")
struct FeedbackFormTests {
  static let context = FeedbackForm.Context(detail: "字: そ / 設定: はじめて")

  @Test("アプリの情報の欄に、アプリ・種類・詳しいことを1行ずつ書く")
  func appInfo() {
    #expect(
      FeedbackForm.appInfo(kind: .judge, context: Self.context)
        == "アプリ: もじまち\n種類: 判定\n字: そ / 設定: はじめて")
  }

  @Test("URL に、アプリの版・OS の版・機種を入れない（Kids 1.3）")
  func noDeviceInfoInURL() {
    for kind in FeedbackForm.Kind.allCases {
      let text =
        FeedbackForm.url(kind: kind, context: Self.context).absoluteString
        .removingPercentEncoding ?? ""
      for word in ["iPadOS", "iOS", "iPad ", "1.0.0", "UIDevice"] {
        #expect(!text.contains(word), "\(word) が入っている")
      }
    }
  }

  @Test("版の文は、保護者が書き足すためのもの")
  func deviceInfoText() {
    #expect(
      FeedbackForm.deviceInfoText(appVersion: "1.0.0", osVersion: "iPadOS 26.1")
        == "アプリの版: 1.0.0 / iPadOS 26.1")
  }

  @Test("フォームの選択肢は既存のものに当てはめる（D124）")
  func formChoice() throws {
    for (kind, choice) in [
      (FeedbackForm.Kind.judge, "アプリの不具合"), (.opinion, "ご要望"), (.facility, "ご要望"),
    ] {
      let url = FeedbackForm.url(kind: kind, context: Self.context)
      let items = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems)
      #expect(items.first { $0.name == "usp" }?.value == "pp_url")
      #expect(items.first { $0.name == FeedbackForm.kindEntry }?.value == choice)
      #expect(items.first { $0.name == FeedbackForm.appInfoEntry }?.value?.contains("種類:") == true)
    }
  }

  @Test("フォームの URL は既存アプリと同じ")
  func baseURL() {
    let url = FeedbackForm.url(kind: .opinion, context: Self.context)
    #expect(url.absoluteString.hasPrefix(FeedbackForm.baseURL.absoluteString + "?"))
    #expect(url.host() == "docs.google.com")
  }
}
