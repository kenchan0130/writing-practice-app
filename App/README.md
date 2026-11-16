# App

アプリ本体の薄い Xcode プロジェクト（D104）。コードの大半は `../Packages` に置く。

- バンドル ID: `io.github.kenchan0130.mojimachi`（D136）
- iPad だけ（`TARGETED_DEVICE_FAMILY = 2`）。Apple シリコンの Mac には「Designed for iPad」で配信し、Vision Pro には出さない（D100）
- iPadOS 26 以上（D14）。起動画面とシーンは自動で作る（iPadOS 27 で必須）
- Swift 6、画面まわりの既定の分離は MainActor（D105）
- `Mojimachi/` はフォルダの同期（ファイルを足しても `project.pbxproj` は変わらない）
- `../Packages` をローカルのパッケージとして参照する

- バージョンは `Config/Version.xcconfig`（手元は 0.0.0）。リリースのビルドでは Xcode Cloud がタグから書き換え、ビルド番号は Xcode Cloud が付ける（`ci_scripts/ci_pre_xcodebuild.sh`。D142）

ビルド: `make app-build`（iPad のシミュレータ向け、署名なし）
