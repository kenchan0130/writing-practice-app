// swift-tools-version: 6.2
// 画面や端末に頼らない部品（D104・D105）。Mac の `swift test` で確かめる。
import PackageDescription

let package = Package(
  name: "MojimachiKit",
  platforms: [
    .iOS(.v26),
    .macOS(.v26),
  ],
  products: [
    .library(name: "StrokeKit", targets: ["StrokeKit"]),
    .library(name: "ContentModel", targets: ["ContentModel"]),
    .library(name: "JudgeKit", targets: ["JudgeKit"]),
    .library(name: "PracticeKit", targets: ["PracticeKit"]),
    .library(name: "ParentGateKit", targets: ["ParentGateKit"]),
    .library(name: "RecordKit", targets: ["RecordKit"]),
    .library(name: "SupportKit", targets: ["SupportKit"]),
    .library(name: "EntitlementKit", targets: ["EntitlementKit"]),
    .library(name: "SoundKit", targets: ["SoundKit"]),
  ],
  targets: [
    // 線の記録の形（D106）。判定・書く画面・作成の道具・テストのセットで共通に使う。
    .target(name: "StrokeKit"),
    .testTarget(name: "StrokeKitTests", dependencies: ["StrokeKit"]),
    // 文字とことばのデータの形と、その決まりの確かめ（D106・D114）。
    .target(name: "ContentModel"),
    .testTarget(name: "ContentModelTests", dependencies: ["ContentModel"]),
    // 判定（D107・D145）。書き順・向き・鏡の字・形を見る。
    .target(name: "JudgeKit", dependencies: ["ContentModel"]),
    .testTarget(name: "JudgeKitTests", dependencies: ["JudgeKit", "ContentModel"]),
    // 1文字の練習の4ステップの流れ（D46・D47・D56・D76・D105）。
    .target(name: "PracticeKit", dependencies: ["JudgeKit", "ContentModel"]),
    .testTarget(
      name: "PracticeKitTests", dependencies: ["PracticeKit", "JudgeKit", "ContentModel"]),
    // 保護者用の確認（D49・D64）。
    .target(name: "ParentGateKit"),
    .testTarget(name: "ParentGateKitTests", dependencies: ["ParentGateKit"]),
    // 学習記録の計算（D25・D44）。
    .target(name: "RecordKit"),
    .testTarget(name: "RecordKitTests", dependencies: ["RecordKit"]),
    // お問い合わせのフォームと公開ページ（D124）。
    .target(name: "SupportKit"),
    .testTarget(name: "SupportKitTests", dependencies: ["SupportKit"]),
    // 課金の権利の決まり（D89・D95・D96）。
    .target(name: "EntitlementKit"),
    .testTarget(name: "EntitlementKitTests", dependencies: ["EntitlementKit"]),
    // プログラムで作る効果音（§3.9）。
    .target(name: "SoundKit"),
    .testTarget(name: "SoundKitTests", dependencies: ["SoundKit"]),
    // 判定の効き方の表を出す（`make judge-report`）。
    .executableTarget(name: "JudgeReport", dependencies: ["JudgeKit", "ContentModel"]),
  ],
  swiftLanguageModes: [.v6]
)
