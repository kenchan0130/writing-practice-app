# TCA を入れたときのビルド時間（2026-11-17）

D105 の「M0 で測る」の最初の測定。TCA 1.26.2（2026-08-28 公開。最新）を、アプリの本体だけに入れた。

## 環境

- Mac: MacBookPro17,1（Apple M1）
- Xcode 27.2（27B52）
- 測り方: `xcodebuild build -scheme Mojimachi -destination 'generic/platform=iOS Simulator'`（Debug、署名なし）。`-derivedDataPath` を毎回消して「全部作り直し」を測った。パッケージの取得（git clone）は含めない（`-clonedSourcePackagesDirPath` で先に取っておく）。
- 前も後も、コミット済みの内容（HEAD）の写しで測った。マップの作業中のファイルは入れていない。
- 前の最初の1回は、Xcode のモジュールのキャッシュが冷たかった。

## 結果（秒）

| | 前（TCA なし） | 後（TCA あり） |
|---|---|---|
| 全部作り直し | 69.8（冷たいキャッシュ）、26.3、17.1 | 56.7、56.7、56.0 |
| 差分（アプリの Swift 1ファイルを触る） | 3.2、3.3 | 8.4（アプリの別のファイル）、8.4（`ParentGateFeature.swift`）、7.7 |

- 全部作り直しの増えは、キャッシュの温まった前（17〜26 秒）と比べて約 30〜40 秒。TCA と、マクロ（swift-syntax の作り置きを使う）の分。
- 差分の増えは約 5 秒（リンクのやり直しとマクロの確認が主）。リデューサのファイルを触っても、ほかのファイルと変わらない。
- 後の3回は 56 秒前後でそろった。前は 17〜70 秒とばらつき、増えの幅は「約 30〜40 秒」としか言えない。

## D105 の目安との比べ

- 目安は「Xcode Cloud のビルドの増加が1回 3〜5 分以内」。この測定は手元の Mac（M1）の Debug で、Xcode Cloud ではない。増えは1分未満で、M0 の段階では許せる範囲と読める。
- 実際の画面が増えると（リデューサとマクロの展開が増えると）差分ビルドの増えは大きくなりうる。Xcode Cloud の実測は、ワークフローを作ってから測り直す。

## 注意

- マクロは信頼の確認が要る。コマンドでは `-skipMacroValidation`（`Makefile` に入れた）。Xcode Cloud で省く方法はまだ入れていない。
- 【人の確認待ち】CLAUDE.md の決まりどおり、パッケージの URL を人が開いて、本物か確かめる: https://github.com/pointfreeco/swift-composable-architecture
- 版・ライセンス・通信の確認は `docs/dependencies.md`。
