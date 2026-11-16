# App

アプリ本体の薄い Xcode プロジェクトを置く（D104）。

Xcode で作る（`.xcodeproj` は手で書かない）。作るときの設定:

- バンドル ID: `io.github.kenchan0130.mojimachi`（D136）
- iPad だけ（Mac は「Designed for iPad」で配信。D100）
- iPadOS 26 以上（D14）
- Swift 6、フォルダの同期を使う
- `../Packages` をローカルのパッケージとして追加する
