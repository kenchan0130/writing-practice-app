# ライブラリの一覧と方針（D104）

## 層

| 層 | 中身 | 厳しさ |
|---|---|---|
| A | アプリに入って配布されるもの | 下の基準をすべて満たす |
| B | テストだけで使うもの | ライセンスと手入れを確かめる |
| C | 開発の道具・CI・スクリプト（アプリにリンクしない） | ライセンスを確かめる |

## A の選び方

- ライセンス: MIT・BSD・Apache-2.0・ISC・zlib など。GPL・AGPL・LGPL・CC BY-SA・非商用限定・独自のランタイムライセンスは使わない（MPL-2.0 は個別に判断）。
- 通信や情報送信をしない（ソースを `URLSession`・`Network`・分析の語で検索し、プライバシーの申告ファイルを読む）。例外は Sentry のクラッシュの情報だけ（D103・D123）。
- 直近1年に更新がある。Swift 6 に対応している。
- ソースで入れる（バイナリの xcframework は原則使わない）。自分のアカウントに写しを持つ。
- マクロとビルドプラグインは数を絞る。

## 固定と更新

- A は `exact:` で版を固定し、`Package.resolved` をコミットする。CI では自動で版を上げない。
- 更新は Dependabot（`.github/dependabot.yml`。D147）。ライブラリは足すとき原則最新の版を使う。更新は公開から7日たった版が提案される（脆弱性の修正は待たない）。変更内容を読み、テストを通してから人が入れる（自動では入れない）。
- 脆弱性は GitHub の通知と `osv-scanner` で確かめる。

## 公開ごとの確認

- Xcode のプライバシーレポートの前回との違い。
- 実機の「App プライバシーレポート」で、Apple と Sentry 以外への通信がないこと。
- 「このアプリについて」のライセンスの表示を `Package.resolved` から作る。

## 一覧

| 名前 | 版 | ライセンス | 層 | 用途 | 通信の確認日 | 代わりの案 |
|---|---|---|---|---|---|---|
| TCA（swift-composable-architecture。https://github.com/pointfreeco/swift-composable-architecture 【確認済み 2026-11-17 ユーザー】） | 1.26.2（2026-08-28 公開。最新） | MIT | A | 画面と流れの状態（D105）。いまは保護者用の確認の流れ（`ParentGateFeature`）だけ。アプリの本体だけに入れ、`Packages/` には入れない | 2026-11-17（ソース検索: 通信・分析なし。下の注） | @Observable の上の自前の小さな仕組み（D105 の切り替え先） |
| swift-dependencies | 1.17.2 | MIT | A | TCA が使う。時刻などを差し替える | 2026-11-17 | TCA と一緒 |
| swift-case-paths | 1.10.0 | MIT | A | TCA が使う | 2026-11-17 | TCA と一緒 |
| swift-identified-collections | 1.1.1 | MIT | A | TCA が使う | 2026-11-17 | TCA と一緒 |
| swift-perception | 2.0.12 | MIT | A | TCA が使う（@Observable の代わり） | 2026-11-17 | TCA と一緒 |
| swift-navigation | 2.11.2 | MIT | A | TCA が使う | 2026-11-17 | TCA と一緒 |
| swift-sharing | 2.10.1 | MIT | A | TCA が使う（UserDefaults・ファイルの共有。いまは使っていない） | 2026-11-17 | TCA と一緒 |
| swift-custom-dump | 1.7.3 | MIT | A | TCA が使う（テストの差分の表示） | 2026-11-17 | TCA と一緒 |
| swift-concurrency-extras | 1.4.3 | MIT | A | TCA が使う | 2026-11-17 | TCA と一緒 |
| swift-issue-reporting | 2.1.2 | MIT | A | TCA が使う（旧 xctest-dynamic-overlay） | 2026-11-17 | TCA と一緒 |
| combine-schedulers | 1.2.2 | MIT | A | TCA が使う | 2026-11-17 | TCA と一緒 |
| swift-clocks | 1.1.1 | MIT | A | TCA が使う | 2026-11-17 | TCA と一緒 |
| swift-collections | 1.7.6 | Apache-2.0 | A | TCA が使う | 2026-11-17 | TCA と一緒 |
| swift-syntax | 604.0.0 | Apache-2.0 | A（ビルド時のマクロだけ） | TCA のマクロが使う。アプリには入らない | 2026-11-17 | TCA と一緒 |

- 承認: 2026-11-17 ユーザー。方針: 最新版を使う（2026-11-17 ユーザーの方針）。版は `exact:`（`project.pbxproj` の `exactVersion`）で固定し、`App/Mojimachi.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved` をコミットする。
- 通信の確認（2026-11-17）: 上の 12 個（swift-collections と swift-syntax 以外）の `Sources` を `URLSession`・`NWConnection`・`NWPathMonitor`・`URLRequest`・`import Network`・`CFNetwork`・Analytics・telemetry で検索した。通信や送信をするコードはない。見つかったのは、swift-dependencies が「`urlSession` を差し替える」ための入口（`DependencyValues.urlSession`。使わなければ動かない）と、swift-custom-dump が `URLRequest` の値を表示するための型の対応だけ。TCA と swift-sharing は `PrivacyInfo.xcprivacy` を持ち、追跡なし・集める情報なし（使う API は UserDefaults と ファイルの日時）。swift-collections・swift-syntax は検索していない（Apple の公式）。
- 【確認済み 2026-11-17 ユーザー】URL は人が開いて、本物か確かめた（CLAUDE.md の決まり）。pointfreeco の公式（GitHub の星は約 1.5 万、MIT）。
- マクロ: Xcode で入れるときは、マクロの信頼の確認が出る。コマンドでは `-skipMacroValidation`（`Makefile`）で省く。Xcode Cloud の設定（マクロの確認を省く方法）はまだ入れていない（人の判断待ち）。swift-syntax はビルド時に Apple のサーバー（download.swift.org）から作り置きを取ることがある（ビルドの道具の通信。アプリは通信しない）。
- ビルド時間は `docs/reports/tca-build-time.md`。

## 使う予定（足すときに上の一覧へ移す）

- 道具（C）: swift-format（ツールチェーンに同梱）、SwiftLint、Periphery、xcbeautify、swift-argument-parser、LicensePlist
- テスト（B）: swift-snapshot-testing、swift-custom-dump
- アプリ（A）: TCA、swift-dependencies、swift-sharing、swift-clocks、swift-collections、swift-async-algorithms、swift-numerics、swift-algorithms、Sentry（D103）
- M0 で試す: BezierKit（D106）

## データの出どころ（ライブラリではないが、アプリに入るもの）

| 名前 | 版 | ライセンス | 用途 | 置き場 |
|---|---|---|---|---|
| strokesvg | `e4c2c91` | かなは OFL 1.1（Klee One から作られたもの）、それ以外は MIT | ひらがなの書き順と字の形（D128） | `Content/Packs/hira`（`LICENSE`・`NOTICE.md`） |

## 使わないもの

- Firebase、RevenueCat など、通信やデータ送信をするもの（Sentry はクラッシュの情報だけ）。
