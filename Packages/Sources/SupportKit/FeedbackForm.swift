import Foundation

/// お問い合わせの Google フォーム（D124）。既存アプリ（p-info-exam-app）と同じフォームを、アプリをまたいで使う。
/// フォームの選択肢を変えずに使うため、このアプリの種類は「アプリの情報」の欄に書く。
public enum FeedbackForm {
  public static let baseURL = URL(
    string:
      "https://docs.google.com/forms/d/e/1FAIpQLSeKlnlVv1q5MRZm_DbZSmy-qpvAEYGkrueaeATx9xJyeY3j8g/viewform"
  )!

  /// フォームの各欄の ID（フォームを作り直したら、公開ページの FB_PUBLIC_LOAD_DATA_ から取り直す）。
  static let kindEntry = "entry.1067856002"
  static let appInfoEntry = "entry.1362759248"

  /// このアプリのお問い合わせの種類（D124）。
  public enum Kind: Sendable, CaseIterable {
    /// 「この はんていは おかしい」。
    case judge
    /// ご意見。
    case opinion
    /// 施設でお使いの方へ（施設向け版の要望）。
    case facility

    /// フォームの「お問い合わせの種類」の選択肢（フォームの文言と完全に一致させる）。
    var formChoice: String {
      switch self {
      case .judge: "アプリの不具合"
      case .opinion, .facility: "ご要望"
      }
    }

    /// 「アプリの情報」の欄に書く種類。
    var label: String {
      switch self {
      case .judge: "判定"
      case .opinion: "ご意見"
      case .facility: "施設向け版"
      }
    }
  }

  public struct Context: Sendable {
    public var appVersion: String
    public var osVersion: String
    /// 判定の報告のときの、字と判定の設定など（短く）。
    public var detail: String?

    public init(appVersion: String, osVersion: String, detail: String? = nil) {
      self.appVersion = appVersion
      self.osVersion = osVersion
      self.detail = detail
    }
  }

  /// 「アプリの情報」の欄（1項目1行）。
  public static func appInfo(kind: Kind, context: Context) -> String {
    [
      "アプリ: もじまち \(context.appVersion)",
      "種類: \(kind.label)",
      context.detail,
      context.osVersion,
    ]
    .compactMap { $0 }
    .joined(separator: "\n")
  }

  /// 値を入れた状態で開くフォームの URL。
  public static func url(kind: Kind, context: Context) -> URL {
    var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
    components.queryItems = [
      URLQueryItem(name: "usp", value: "pp_url"),
      URLQueryItem(name: kindEntry, value: kind.formChoice),
      URLQueryItem(name: appInfoEntry, value: appInfo(kind: kind, context: context)),
    ]
    return components.url!
  }
}

/// 公開ページ（docs/operations.md）。
public enum PublicPages {
  public static let support = URL(string: "https://kenchan0130.github.io/apps/mojimachi")!
  public static let privacy = URL(string: "https://kenchan0130.github.io/apps/mojimachi/privacy")!
}
