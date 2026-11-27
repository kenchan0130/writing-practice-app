import Foundation
import Testing

@testable import SupportKit

@Suite("お問い合わせのフォーム")
struct FeedbackFormTests {
  static let context = FeedbackForm.Context(
    appVersion: "1.0 (27)", os: "iPadOS 27.0", detail: "字: そ / 設定: はじめて")

  @Test("アプリの情報の欄に、アプリ・種類・詳しいことを1行ずつ書く")
  func appInfo() {
    #expect(
      FeedbackForm.appInfo(kind: .judge, context: Self.context)
        == "アプリ: もじまち\n種類: 判定\nアプリの版: 1.0 (27)\niPadOS 27.0\n字: そ / 設定: はじめて")
  }

  @Test("URL に、アプリの版と OS の版を入れる（D193）")
  func versionsInURL() throws {
    let url = FeedbackForm.url(kind: .opinion, context: Self.context)
    let items = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems)
    let info = try #require(items.first { $0.name == FeedbackForm.appInfoEntry }?.value)
    #expect(info.contains("アプリの版: 1.0 (27)"))
    #expect(info.contains("iPadOS 27.0"))
  }

  @Test("版がわからないときは、その行を書かない")
  func missingVersions() {
    #expect(
      FeedbackForm.appInfo(kind: .opinion, context: FeedbackForm.Context())
        == "アプリ: もじまち\n種類: ご意見")
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
