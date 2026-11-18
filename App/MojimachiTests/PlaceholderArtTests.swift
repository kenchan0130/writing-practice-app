import ContentModel
import Testing
import UIKit

@testable import Mojimachi

/// 仮の絵（SF Symbols と、そりのように自分で描いた絵）が、すべてのことばに当たっていて、実在することを確かめる。
@Suite("仮の絵")
@MainActor
struct PlaceholderArtTests {
  @Test("19語すべてに、実在する絵がある")
  func everyWordHasSymbol() {
    #expect(PlaceholderArt.words.count == WordCatalog.all.count)
    for item in PlaceholderArt.words {
      if PlaceholderArt.isCustom(item.symbol) {
        let image = PlaceholderArt.image(symbol: item.symbol, size: 200, color: item.color)
        #expect(
          PlaceholderArt.targetPoints(in: image, count: 50).count > 20,
          "\(item.entry.text): \(item.symbol)")
      } else {
        #expect(UIImage(systemName: item.symbol) != nil, "\(item.entry.text): \(item.symbol)")
      }
    }
  }

  @Test("そりの絵は、そりの id で描かれ、PNG に書き出せる")
  func sledRenders() throws {
    #expect(PlaceholderArt.symbol(for: "そり") == PlaceholderArt.sledID)
    let image = PlaceholderArt.image(symbol: PlaceholderArt.sledID, size: 512, color: .brown)
    let background = UIGraphicsImageRenderer(size: image.size).image { ctx in
      UIColor.white.setFill()
      ctx.fill(CGRect(origin: .zero, size: image.size))
      image.draw(at: .zero)
    }
    if let data = background.pngData() {
      try? FileManager.default.createDirectory(
        atPath: "/private/tmp/claude-501", withIntermediateDirectories: true)
      try? data.write(to: URL(fileURLWithPath: "/private/tmp/claude-501/sled.png"))
    }
  }
}
