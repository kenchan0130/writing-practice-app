import Foundation
import Sentry
import Testing

@testable import Mojimachi

/// クラッシュの報告で送る内容を固定する（D103・D123・D183）。
@Suite("クラッシュの報告")
@MainActor
struct CrashReportingTests {
  @Test("DSN が空・未設定・展開されていないときは、Sentry を動かさない")
  func emptyDSNDisables() {
    #expect(CrashReporting.configuredDSN(from: nil) == nil)
    #expect(CrashReporting.configuredDSN(from: [:]) == nil)
    #expect(CrashReporting.configuredDSN(from: ["SentryDSN": ""]) == nil)
    #expect(CrashReporting.configuredDSN(from: ["SentryDSN": "  "]) == nil)
    #expect(CrashReporting.configuredDSN(from: ["SentryDSN": "$(SENTRY_DSN)"]) == nil)
    #expect(
      CrashReporting.configuredDSN(from: ["SentryDSN": "https://key@example.invalid/1"])
        == "https://key@example.invalid/1")
  }

  @Test("設定は、落ちたときの情報だけにする")
  func optionsAreCrashOnly() {
    let options = Options()
    CrashReporting.configure(options)
    #expect(!options.sendDefaultPii)
    #expect(!options.enableAutoSessionTracking)
    #expect(!options.enableAutoPerformanceTracing)
    #expect(options.tracesSampleRate == nil)
    #expect(!options.isTracingEnabled)
    #expect(!options.enableAppHangTracking)
    #expect(!options.enableWatchdogTerminationTracking)
    #expect(!options.enableAutoBreadcrumbTracking)
    #expect(!options.enableNetworkBreadcrumbs)
    #expect(options.maxBreadcrumbs == 0)
    #expect(!options.attachScreenshot)
    #expect(!options.attachViewHierarchy)
    #expect(options.sessionReplay.sessionSampleRate == 0)
    #expect(options.sessionReplay.onErrorSampleRate == 0)
    #expect(!options.enableLogs)
    #expect(options.beforeSend != nil)
  }

  @Test("送る前に、利用者・通信・端末の名前・操作の記録を消し、場所と版と機種は残す")
  func scrubRemovesIdentity() throws {
    let event = Event()
    event.user = User(userId: "u1")
    event.request = SentryRequest()
    event.serverName = "ゆうとの iPad"
    event.breadcrumbs = [Breadcrumb(level: .info, category: "ui")]
    event.extra = ["name": "ゆうと"]
    event.tags = ["a": "b"]
    event.releaseName = "app@1.0.0"
    event.context = [
      "device": ["name": "ゆうとの iPad", "model": "iPad16,3", "family": "iPad"],
      "os": ["name": "iOS", "version": "26.1"],
      "culture": ["locale": "ja_JP"],
      "app": [
        "device_app_hash": "abc123", "app_start_time": "2026-01-01", "app_version": "1.0.0",
        "app_build": "7", "app_identifier": "jp.example.app",
      ],
      "memory": ["size": 1],
      "extra_thing": ["x": 1],
    ]
    event.context?["device"]?["locale"] = "ja_JP"
    event.context?["device"]?["memory_size"] = 123
    let result = try #require(CrashReporting.scrub(event))
    #expect(result.user == nil)
    #expect(result.request == nil)
    #expect(result.serverName == nil)
    #expect(result.breadcrumbs == nil)
    #expect(result.extra == nil)
    #expect(result.tags == nil)
    #expect(result.context?["device"]?["name"] == nil)
    #expect(result.context?["device"]?["model"] as? String == "iPad16,3")
    #expect(result.context?["os"]?["version"] as? String == "26.1")
    #expect(result.context?["culture"] == nil)
    #expect(result.context?["device"]?["locale"] == nil)
    #expect(result.context?["device"]?["memory_size"] == nil)
    #expect(result.context?["device"]?["family"] as? String == "iPad")
    #expect(result.context?["app"]?["device_app_hash"] == nil)
    #expect(result.context?["app"]?["app_start_time"] == nil)
    #expect(result.context?["app"]?["app_identifier"] == nil)
    #expect(result.context?["app"]?["app_version"] as? String == "1.0.0")
    #expect(result.context?["app"]?["app_build"] as? String == "7")
    #expect(result.context?["memory"] == nil)
    #expect(result.context?["extra_thing"] == nil)
    #expect(result.releaseName == "app@1.0.0")
  }
}
