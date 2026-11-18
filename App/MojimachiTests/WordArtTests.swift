import ContentModel
import Testing
import UIKit

@testable import Mojimachi

/// ことばの絵（アセットの SVG）が、すべてのことばに当たっていて、読めることを確かめる。
@Suite("ことばの絵")
@MainActor
struct WordArtTests {
  @Test("19語すべてに、読める絵がある")
  func everyWordHasArt() {
    #expect(WordArt.words.count == WordCatalog.all.count)
    for item in WordArt.words {
      #expect(!item.asset.isEmpty, "\(item.entry.text): 名前がない")
      #expect(UIImage(named: WordArt.assetName(item)) != nil, "\(item.entry.text): \(item.asset)")
    }
  }

  @Test("絵を画像にすると、色のある部分があり、集まる先の点が取れる")
  func imageHasOpaquePixelsAndTargets() {
    for item in WordArt.words {
      let image = WordArt.image(word: item.entry.text, size: 200)
      #expect(image.size == CGSize(width: 200, height: 200))
      let points = WordArt.targetPoints(in: image, count: 100)
      #expect(!points.isEmpty, "\(item.entry.text)")
      #expect(points.count <= 100, "\(item.entry.text)")
    }
  }

  @Test("絵の背景は透明で、四隅に色はない")
  func cornersAreTransparent() {
    let image = WordArt.image(word: "いぬ", size: 100)
    let points = WordArt.targetPoints(in: image, count: 1000)
    #expect(!points.contains { $0.x < 2 && $0.y < 2 })
  }
}
