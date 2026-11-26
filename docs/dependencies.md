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
| Sentry（sentry-cocoa。https://github.com/getsentry/sentry-cocoa 【TODO 人が URL を開いて本物か確かめる（CLAUDE.md の決まり）】） | 9.36.0（2026-11-27 時点の最新。`exact:`） | MIT | A（アプリだけ。`Packages/` には入れない） | クラッシュの報告（D103・D123・D183）。落ちたときの情報だけを、設定した DSN に送る | 2026-11-27 | なし（Apple のクラッシュ報告だけにする案は、D103 で退けた） |

- 承認: 2026-11-17 ユーザー。方針: 最新版を使う（2026-11-17 ユーザーの方針）。版は `exact:`（`project.pbxproj` の `exactVersion`）で固定し、`App/Mojimachi.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved` をコミットする。
- 通信の確認（2026-11-17）: 上の 12 個（swift-collections と swift-syntax 以外）の `Sources` を `URLSession`・`NWConnection`・`NWPathMonitor`・`URLRequest`・`import Network`・`CFNetwork`・Analytics・telemetry で検索した。通信や送信をするコードはない。見つかったのは、swift-dependencies が「`urlSession` を差し替える」ための入口（`DependencyValues.urlSession`。使わなければ動かない）と、swift-custom-dump が `URLRequest` の値を表示するための型の対応だけ。TCA と swift-sharing は `PrivacyInfo.xcprivacy` を持ち、追跡なし・集める情報なし（使う API は UserDefaults と ファイルの日時）。swift-collections・swift-syntax は検索していない（Apple の公式）。
- 【確認済み 2026-11-17 ユーザー】URL は人が開いて、本物か確かめた（CLAUDE.md の決まり）。pointfreeco の公式（GitHub の星は約 1.5 万、MIT）。
- マクロ: Xcode で入れるときは、マクロの信頼の確認が出る。コマンドでは `-skipMacroValidation`（`Makefile`）で省く。Xcode Cloud の設定（マクロの確認を省く方法）はまだ入れていない（人の判断待ち）。swift-syntax はビルド時に Apple のサーバー（download.swift.org）から作り置きを取ることがある（ビルドの道具の通信。アプリは通信しない）。
- ビルド時間は `docs/reports/tca-build-time.md`。
- **Sentry（D183。承認: 2026-11-27 ユーザー）**:
  - 【TODO 人】https://github.com/getsentry/sentry-cocoa を人が開いて、本物の公式リポジトリか確かめる（getsentry の公式。MIT。似た名前に注意）。確かめたら、上の表の TODO を「確認済み 日付 ユーザー」に直す。
  - 版は `project.pbxproj` の `exactVersion = 9.36.0`。`Package.resolved` に固定した（リビジョン `733cff21…`）。
  - 通信の確認（2026-11-27）: 送り先は、`SentryDSN` に入れた先だけ。**DSN が空のビルド・DEBUG では起動しない**ので何も送らない（`App/Mojimachi/CrashReporting.swift`）。起動したときも、落ちたときの情報（落ちた場所・アプリと OS の版・機種）だけ。セッション・性能・画面の録画・操作の記録・通信の追跡・スクリーンショット・固まりの検知は全部オフ、`sendDefaultPii = false`、`beforeSend` でユーザー・通信・端末の名前・追加の情報を消す。送る内容は `App/MojimachiTests/CrashReportingTests.swift` で固定した。
  - **例外**: 上の A の選び方の「ソースで入れる」に対し、Sentry の SwiftPM は**ビルド済みの xcframework**（バイナリ）を配る。Sentry は自分の `PrivacyInfo.xcprivacy` を中に入れている。承認のうえの例外とする（D132）。公開のたびに、プライバシーレポートで通信先を確かめる。
  - 実機の確認は人（リリースのビルドで、わざと落として Sentry に着くこと。着いたものに ID・端末の名前が入っていないこと）。

## 使う予定（足すときに上の一覧へ移す）

- 道具（C）: swift-format（ツールチェーンに同梱）、SwiftLint、Periphery、xcbeautify、swift-argument-parser、LicensePlist
- テスト（B）: swift-snapshot-testing、swift-custom-dump
- アプリ（A）: TCA、swift-dependencies、swift-sharing、swift-clocks、swift-collections、swift-async-algorithms、swift-numerics、swift-algorithms、Sentry（D103）
- M0 で試す: BezierKit（D106）

## データの出どころ（ライブラリではないが、アプリに入るもの）

| 名前 | 版 | ライセンス | 用途 | 置き場 |
|---|---|---|---|---|
| strokesvg | `e4c2c91` | かなは OFL 1.1（Klee One から作られたもの）、それ以外は MIT | ひらがなの書き順と字の形（D128） | `Content/Packs/hira`（`LICENSE`・`NOTICE.md`） |

| Klee One（Regular・SemiBold。使う字だけに減らしたもの） | google/fonts の `ofl/kleeone`（2026-11-17 に取得。もとの TTF の SHA-1 は `02b7663f…`・`6a12ad3c…`） | SIL OFL 1.1（Copyright 2020 The Klee Project Authors） | 字を学ぶところの書体（D153） | `App/Mojimachi/Resources/Fonts`（`OFL-KleeOne.txt`・`FONTS-NOTICE.txt`） |
| Zen Maru Gothic（Medium・Bold。使う字だけに減らしたもの） | google/fonts の `ofl/zenmarugothic`（2026-11-17 に取得。もとの TTF の SHA-1 は `116bfabf…`・`9471824b…`） | SIL OFL 1.1（Copyright 2021 The Zen Maru Gothic Project Authors） | ボタン・ラベルの書体（D153） | 同上（`OFL-ZenMaruGothic.txt`） |

字を減らすのは `Scripts/subset_fonts.py`（画面の文字列と文字のデータから、使う字を集める）。書体を作り直すときは、画面の言葉を変えたあとに動かす。

## ビルドの道具（C。アプリには入らない）

| 名前 | 版 | ライセンス | 用途 |
|---|---|---|---|
| fonttools（`pyftsubset` の元になる Python のライブラリ） | 4.68.0（2026-11-17 に使用。一時的な venv に入れた。PyPI の `fonttools`） | MIT | 書体を使う字だけに減らす（`Scripts/subset_fonts.py`） |
| numpy | 2.5.5（2026-11-17 に使用。一時的な venv。PyPI の `numpy`） | BSD-3-Clause | 効果音の波形を調べる（`Scripts/analyze_sfx.py`。開発用のみ。`docs/reports/sfx-analysis.md`） |
| scipy | 1.18.1（同上） | BSD-3-Clause | 同上（フィルタ・スペクトル） |
| matplotlib | 3.11.2（同上） | matplotlib のライセンス（PSF 系の寛容なもの） | 同上（波形とスペクトログラムの図） |

## 使わないもの

- Firebase、RevenueCat など、通信やデータ送信をするもの（Sentry はクラッシュの情報だけ）。
