# 運用の手順

設計の方針は `docs/design.md`（§6.5、§7.3）。ここには実際の手順を書く。手順を変えたら、ここを直す。

## 開発

- main からブランチを切り、下書き（draft）のプルリクエストで進める。
- プルリクエストを出す前に、手元で `make lint` と `make test` を通す。
- 下書きを外すと、GitHub Actions の CI（`.github/workflows/ci.yml`）が動く。

## リリース

1. main に入ると、tagpr がリリースのプルリクエスト（版と CHANGELOG の更新）を作る。
2. リリースのプルリクエストをマージすると、tagpr がタグ（`v0.0.0` の形）を打つ。
3. Xcode Cloud は、タグを開始条件にしてビルドし、TestFlight に出す（Xcode Cloud のワークフローの設定は、アプリの Xcode プロジェクトを作ったあとに足す）。
4. TestFlight の内部テスト → 外部テスト → 審査 → 手動で公開。

## 公開ページ

- プライバシーポリシー: `https://kenchan0130.github.io/apps/mojimachi/privacy`（D73）
- サポート: `https://kenchan0130.github.io/apps/mojimachi`。お問い合わせは既存アプリと同じ Google フォーム（D124）

## 公開後（D119）

- お問い合わせ: 3日以内に返事。
- レビュー: 週1回まとめて全部に返事。
- クラッシュ: Sentry と Xcode のクラッシュ報告を週1回。
- ライブラリ: Renovate の提案を確かめて入れる。

## 元データの置き場（D112・D132・D139）

- リポジトリが公開のあいだは、圧縮前の元データと AI で作ったときの記録を、手元と外付けのディスク（または iCloud Drive）だけに置く（`Originals/` は git に入れない）。
- 非公開にしたら、GitHub のリリースにも置く。
