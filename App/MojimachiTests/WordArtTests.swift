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

  @Test("バスに絵がある。英語のことばは、日本語のことばの絵を使う（D199）")
  func busAndEnglishArt() {
    #expect(WordArt.hasArt("バス"))
    #expect(WordArt.assetName(for: "バス") == "word-basu")
    #expect(WordArt.assetName(for: "cat") == WordArt.assetName(for: "ねこ"))
    #expect(WordArt.assetName(for: "bus") == "word-basu")
    #expect(WordArt.englishItems.count == EnglishWords.all.count)
    for item in WordArt.englishItems {
      #expect(UIImage(named: WordArt.assetName(item)) != nil, "\(item.entry.text)")
      #expect(WordArt.hasArt(item.entry.text), "\(item.entry.text)")
    }
    #expect(WordArt.item(named: "cat")?.entry.kind == WordArt.item(named: "ねこ")?.entry.kind)
    // 日本語のことばの一覧には、英語を入れない
    #expect(!WordArt.words.contains { $0.entry.text == "cat" })
  }

  @Test("テーマの並び: バスは、のりもののひらがなの後ろ。cat は ねこの テーマの英語の最初")
  func themes() {
    let norimono = WordMap.theme(id: "norimono").map { WordArt.index.words(in: $0) } ?? []
    // バスは、ひらがなのことばの後ろ、ほかのカタカナのことばの前（あとから足されても通る）。
    let bus = norimono.firstIndex(of: "バス")
    #expect(bus != nil)
    let b = bus ?? 0
    #expect(norimono[..<b].allSatisfy { WordText.script(of: $0) == .hiragana })
    #expect(norimono[b...].dropFirst().allSatisfy { WordText.script(of: $0) == .katakana })
    let pets = WordMap.theme(id: "ie-ikimono").map { WordArt.index.englishWords(in: $0) } ?? []
    #expect(pets.first == "cat")
  }
}
