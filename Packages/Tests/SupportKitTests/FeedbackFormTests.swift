import Foundation
import Testing

@testable import SupportKit

@Suite("お問い合わせのフォーム")
struct FeedbackFormTests {
  static let context = FeedbackForm.Context(
    appVersion: "1.0.0", osVersion: "iPadOS 26.1", detail: "字: そ / 設定: はじめて")

  @Test("アプリの情報の欄に、アプリ・種類・詳しいこと・OS を1行ずつ書く")
  func appInfo() {
    #expect(
      FeedbackForm.appInfo(kind: .judge, context: Self.context)
        == "アプリ: もじまち 1.0.0\n種類: 判定\n字: そ / 設定: はじめて\niPadOS 26.1")
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
