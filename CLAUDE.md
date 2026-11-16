# もじまち（writing-practice-app）

4〜7歳の子ども向けの、iPad で文字を書く練習をするアプリ。設計は `docs/design.md`（決定は D 番号）、事実確認は `docs/research-*.md`。

## 方針

- 品質が高く、子ども向けで親しめるアプリを作るためなら、どんな方法でも使う（D132）。迷ったら品質と子どもが親しめるかを優先する。ライセンスは素材やデータを選ぶ判断の材料にしない（D144）。
- 設計を変えるときは `docs/design.md` の決定表に新しい D 番号を足し、関係する章も直す。古い決定には「D〇〇 で変更」と書き添える。

## コマンド

- `make test`: 画面や端末に頼らない部品（`Packages/`）のテスト。**プルリクエストの前に必ず通す**（D129・D130）。
- `make build` / `make lint` / `make format`
- `make app-test`: アプリの購入の流れと、押して画面を行き来する流れ（XCUITest。`App/MojimachiUITests`）を、iPad のシミュレータで確かめる。StoreKit の試し用の設定は `App/Mojimachi.storekit`（Mac だけ。CI では動かさない。約2分）。
- `make content-check`: 文字のデータを確かめる（画数が教科書と合うか など）。
- `make judge-report`: 判定の部品ができたら実装する。
- KanjiVG との照らし合わせ: `python3 -I Scripts/compare_kanjivg.py <KanjiVG の kanji フォルダ> Content/Packs/hira Content/Packs/hira/kanjivg-check.md`（カタカナは `kata`。データを作り直したら必ず動かす）
- 文字のデータの作り直し: `python3 -I Scripts/import_strokesvg.py <strokesvg の dist/hiragana> Content/Packs/hira <コミット> hira`（カタカナは `dist/katakana` と `Content/Packs/kata`、最後を `kata`）。続けて `python3 -I Scripts/make_small_kana.py Content/Packs`（っ・ッ）と `python3 -I Scripts/set_endings.py Content/Packs/hira`（終わり方の下書き）を動かす。

## 作り（D104・D105・D109）

- Swift 6（厳しい並行処理のチェック）。SwiftUI のアプリで、画面と流れの状態は TCA。
- `Packages/` の部品（線の記録、判定、文字とことばのデータ、記録の計算、課金の権利、動きの計算）は、画面や端末に頼らない普通の Swift にし、Mac の `swift test` で確かめる。**Linux の Swift でも動くようにする**（CI は Linux。D141）。UIKit・SwiftUI・SpriteKit・Core Data・StoreKit を `Packages/` の部品に入れない。Apple だけの Foundation の機能を使うときは `#if canImport` で分ける。
- UIKit は、書く画面の入力の受け取り、iCloud の共有の招待画面、メールの下書きだけ。
- 書式は swift-format（`.swift-format`）。

## ライブラリ（D104。詳しくは `docs/dependencies.md`）

- **AI はライブラリを勝手に足さない。** 足すときは人の承認を受け、`docs/dependencies.md` に名前・版・ライセンス・用途・層・通信の確認日を書く。
- URL は人が開いて実在を確かめる（似た名前のパッケージに注意）。
- アプリに入るライブラリは、MIT・BSD・Apache-2.0 などで、通信や情報送信をしないもの（例外は Sentry のクラッシュの情報だけ。D103・D123）。版を固定し、`Package.resolved` をコミットする。

## 子ども向けの決まり

- Kids カテゴリ（5歳以下）。外部の分析・広告は入れない。子どもの画面に価格や購入を出さない（D3）。
- 子どもの画面にはエラーを出さない（D117）。押せる部分は 2cm 角（約104pt）以上（文字の地図は 1.5cm 角。D101・D125）。

## 進め方

- 作業は main からブランチを切り、**下書き（draft）のプルリクエスト**で進める（D130）。CI は下書きでなくなったときだけ動く。
- リリースは tagpr（`.tagpr`）。main への push でリリースのプルリクエストができ、マージでタグが打たれ、Xcode Cloud のビルドが動く。
- 文書は日本語で、短い文・普通の言葉で書く。
