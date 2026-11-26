import Foundation
import Sentry

/// クラッシュの報告（D103・D123・D183）。落ちたときの情報だけを Sentry に送る。
/// 子ども向けのアプリなので、利用者の情報・操作の記録・性能・セッション・画面の録画は送らない。
/// 送り先（DSN）は `Info.plist` の `SentryDSN`（ビルド設定 `SENTRY_DSN`）。**空なら Sentry を動かさない**
/// （DSN を入れていないビルドと、DEBUG・UI テストは、何も送らない）。
enum CrashReporting {
  /// DSN を読む。空・未設定は nil。
  static func configuredDSN(from info: [String: Any]? = Bundle.main.infoDictionary) -> String? {
    guard let dsn = (info?["SentryDSN"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines),
      !dsn.isEmpty, !dsn.hasPrefix("$(")
    else { return nil }
    return dsn
  }

  /// アプリの起動のできるだけ早くに呼ぶ。
  static func start() {
    #if DEBUG
      return
    #else
      guard let dsn = configuredDSN() else { return }
      SentrySDK.start { options in
        configure(options)
        options.dsn = dsn
      }
    #endif
  }

  /// 送る内容を絞る設定。テストでも同じ関数を使って確かめる。
  static func configure(_ options: Options) {
    options.sendDefaultPii = false
    options.debug = false
    // 落ちたときの情報だけ。
    options.enableAutoSessionTracking = false
    options.enableAutoPerformanceTracing = false
    options.tracesSampleRate = nil
    options.enableUserInteractionTracing = false
    options.enableUIViewControllerTracing = false
    options.enableNetworkTracking = false
    options.enableFileIOTracing = false
    options.enableCoreDataTracing = false
    options.enableAppHangTracking = false
    options.enableWatchdogTerminationTracking = false
    options.enableLogs = false
    options.enableSwizzling = false
    options.sendClientReports = false
    // 操作の記録（パンくず）は、子どもの操作が入りうるので持たない。
    options.enableAutoBreadcrumbTracking = false
    options.enableNetworkBreadcrumbs = false
    options.maxBreadcrumbs = 0
    // 画面の絵・画面の構造・録画は取らない。
    options.attachScreenshot = false
    options.attachViewHierarchy = false
    options.reportAccessibilityIdentifier = false
    options.sessionReplay.sessionSampleRate = 0
    options.sessionReplay.onErrorSampleRate = 0
    options.beforeSend = { scrub($0) }
    options.beforeBreadcrumb = { _ in nil }
  }

  /// 送る前に、利用者・通信・端末の名前などを消す。落ちた場所・アプリと OS の版・機種は残す。
  static func scrub(_ event: Event) -> Event? {
    event.user = nil
    event.request = nil
    event.serverName = nil
    event.breadcrumbs = nil
    event.extra = nil
    event.tags = nil
    if var context = event.context {
      if var device = context["device"] {
        device["name"] = nil
        context["device"] = device
      }
      context["culture"] = nil
      event.context = context
    }
    return event
  }
}
