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
    .library(name: "StrokeKit", targets: ["StrokeKit"])
  ],
  targets: [
    // 線の記録の形（D106）。判定・書く画面・作成の道具・テストのセットで共通に使う。
    .target(name: "StrokeKit"),
    .testTarget(name: "StrokeKitTests", dependencies: ["StrokeKit"]),
  ],
  swiftLanguageModes: [.v6]
)
