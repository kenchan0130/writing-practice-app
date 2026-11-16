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
- 更新は Renovate（`renovate.json5`。kenchan0130 のほかのリポジトリと同じ形）。公開から2週間待ってから提案される（脆弱性の修正は待たない）。変更内容を読み、テストを通してから人が入れる（自動では入れない）。
- 脆弱性は GitHub の通知と `osv-scanner` で確かめる。

## 公開ごとの確認

- Xcode のプライバシーレポートの前回との違い。
- 実機の「App プライバシーレポート」で、Apple と Sentry 以外への通信がないこと。
- 「このアプリについて」のライセンスの表示を `Package.resolved` から作る。

## 一覧

| 名前 | 版 | ライセンス | 層 | 用途 | 通信の確認日 | 代わりの案 |
|---|---|---|---|---|---|---|
| （まだない） | | | | | | |

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
