import ContentModel
import Testing
import UIKit

@testable import Mojimachi

/// 仮の絵（SF Symbols）が、すべてのことばに当たっていて、実在することを確かめる。
@Suite("仮の絵")
@MainActor
struct PlaceholderArtTests {
  @Test("19語すべてに、実在する絵がある")
  func everyWordHasSymbol() {
    #expect(PlaceholderArt.words.count == WordCatalog.all.count)
    for item in PlaceholderArt.words {
      #expect(UIImage(systemName: item.symbol) != nil, "\(item.entry.text): \(item.symbol)")
    }
  }
}
