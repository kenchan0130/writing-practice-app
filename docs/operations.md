# 運用の手順

設計の方針は `docs/design.md`（§6.5、§7.3）。ここには実際の手順を書く。手順を変えたら、ここを直す。

## 開発

- main からブランチを切り、下書き（draft）のプルリクエストで進める。
- プルリクエストを出す前に、手元で `make lint` と `make test` を通す。
- 下書きを外すと、GitHub Actions の CI（`.github/workflows/ci.yml`）が動く。

## リリース

1. main に入ると、tagpr がリリースのプルリクエスト（版と CHANGELOG の更新）を作る。
2. リリースのプルリクエストをマージすると、tagpr がタグ（`v1.2.3` の形）を打つ。リポジトリにバージョンを書いたファイルはない（`.tagpr` の `versionFile = -`）。
3. Xcode Cloud は、タグを開始条件にしてビルドし、TestFlight に出す。ビルドの前に `App/ci_scripts/ci_pre_xcodebuild.sh` がタグからバージョン（1.2.3）を作り、ビルド番号は Xcode Cloud が付ける（D142）。Xcode Cloud のワークフローはまだ作っていない。
4. TestFlight の内部テスト → 外部テスト → 審査 → 手動で公開。

## バージョンの決まり（D142・D143）

| 場面 | やること | 例 |
|---|---|---|
| 中身（コード・データ）を直した（微修正・審査で戻されたあとの修正も含む） | パッチバージョンを上げる（tagpr の次のリリース） | 1.0.0 (1) → 1.0.1 (2) |
| 機能を足した | マイナーバージョンを上げる（tagpr のラベルで指定） | 1.1.0 |
| 同じコードを作り直すだけ（署名やアップロードの失敗など） | Xcode Cloud でビルドだけやり直す | 1.0.0 (1) → 1.0.0 (2) |

- 同じバージョンのビルドはすべて中身が同じなので、GitHub のタグ（`v1.0.0`）だけで中身が分かる。ビルド番号のタグは作らない（D143）。

## iCloud

- コンテナ: `iCloud.io.github.kenchan0130.mojimachi`（App ID `io.github.kenchan0130.mojimachi`。権利は `App/Mojimachi/Mojimachi.entitlements`）。
- いまは自分の非公開データベースだけ使う。家族の共有（共有データベース）は次の段階。
- **リリースの前に、人が CloudKit Console で、開発環境のデータの形を本番に反映する（Deploy Schema to Production）。** 本番のデータの形は項目の追加だけ（D63）。アプリを署名ありで一度動かして開発環境に形ができたあと（開発ビルドでは `initializeCloudKitSchema` を使うか、記録を1行書けば形ができる）、Console の「Deploy Schema Changes」を押す。AI はできない。
- 同期するかは、サインインの有無ではなく、保存先がファイルかどうかで決める（アカウントがなければ標準のしくみが待つ）。保護者用の画面の状態は `CKContainer.accountStatus()` で出す。テストと `-localOnlyStore YES` の起動では iCloud に触れない。署名なしのビルドは iCloud の権利がなく、CloudKit が落ちるため、Info.plist の `MojimachiCloudKitEnabled`（`App/Config/Info-extra.plist` で `CODE_SIGNING_ALLOWED` から作る）が YES のときだけ同期する。署名なしでも、落ちるのを避けるため同期せず端末の中だけに保存する（`RecordStore.hasCloudEntitlement`）。
- 署名なしのビルド（`CODE_SIGNING_ALLOWED=NO`）とシミュレーターのテストでは同期しない。同期の確認（人が行う）は、iCloud にサインインした iPad 1台と署名ありのビルドで行う。記録を書き、書き出し（保護者用の画面の「さいごに iCloud に ほぞんした じかん」が更新される）を待ち、アプリを削除して入れ直し、記録が戻ること（取り込み）を確かめる。2台での確認は、同時に書いたときや行の ID での二重防止を見たいときだけでよい（任意）。

## 公開ページ

- プライバシーポリシー: `https://kenchan0130.github.io/apps/mojimachi/privacy`（D73）
- サポート: `https://kenchan0130.github.io/apps/mojimachi`。お問い合わせは既存アプリと同じ Google フォーム（D124）

## 公開後（D119）

- お問い合わせ: 3日以内に返事。
- レビュー: 週1回まとめて全部に返事。
- クラッシュ: Sentry と Xcode のクラッシュ報告を週1回。
- ライブラリ: Dependabot の提案を確かめて入れる（原則最新の版。D147）。

## 元データの置き場（D112・D132・D139）

- リポジトリが公開のあいだは、圧縮前の元データと AI で作ったときの記録を、手元と外付けのディスク（または iCloud Drive）だけに置く（`Originals/` は git に入れない）。
- 非公開にしたら、GitHub のリリースにも置く。
