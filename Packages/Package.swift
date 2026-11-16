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
  ],
  swiftLanguageModes: [.v6]
)
