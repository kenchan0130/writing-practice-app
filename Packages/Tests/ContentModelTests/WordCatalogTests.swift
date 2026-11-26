import Testing

@testable import ContentModel

@Suite("ことばの一覧（D78）")
struct WordCatalogTests {
  @Test("65語で、種類ごとの数が合う")
  func counts() {
    #expect(WordCatalog.all.count == 65)
    #expect(Set(WordCatalog.all.map(\.text)).count == 65)
    #expect(WordCatalog.all.filter { $0.kind == .vehicle }.count == 9)
    #expect(WordCatalog.all.filter { $0.kind == .animal }.count == 21)
    #expect(WordCatalog.all.filter { $0.kind == .clothes }.count == 6)
    #expect(WordCatalog.all.filter { $0.kind == .flyer }.count == 10)
    #expect(WordCatalog.all.filter { $0.kind == .scenery }.count == 19)
  }

  @Test("種類が正しい")
  func kinds() {
    #expect(WordCatalog.entry(for: "そり")?.kind == .vehicle)
    #expect(WordCatalog.entry(for: "しんかんせん")?.kind == .vehicle)
    #expect(WordCatalog.entry(for: "りす")?.kind == .animal)
    #expect(WordCatalog.entry(for: "うま")?.kind == .animal)
    #expect(WordCatalog.entry(for: "くつした")?.kind == .clothes)
    #expect(WordCatalog.entry(for: "きもの")?.kind == .clothes)
    #expect(WordCatalog.entry(for: "しょうぼうしゃ")?.kind == .vehicle)
    #expect(WordCatalog.entry(for: "ぞう")?.kind == .animal)
    #expect(WordCatalog.entry(for: "ひこうき")?.kind == .flyer)
    #expect(WordCatalog.entry(for: "ききゅう")?.kind == .flyer)
    #expect(WordCatalog.entry(for: "すずめ")?.kind == .flyer)
    #expect(WordCatalog.entry(for: "さくら")?.kind == .scenery)
    #expect(WordCatalog.entry(for: "だいこん")?.kind == .scenery)
    #expect(WordCatalog.entry(for: "かぼちゃ")?.kind == .scenery)
    #expect(WordCatalog.entry(for: "ちょう")?.kind == .flyer)
    #expect(WordCatalog.entry(for: "ほたる")?.kind == .flyer)
    #expect(WordCatalog.entry(for: "かたつむり")?.kind == .animal)
    #expect(WordCatalog.entry(for: "てんとうむし")?.kind == .animal)
    #expect(WordCatalog.entry(for: "すし")?.kind == .scenery)
    #expect(WordCatalog.entry(for: "わたあめ")?.kind == .scenery)
  }

  @Test("はう物は、むしの動物だけ（D169）。はねる動物や空の虫は はわない")
  func crawlers() {
    #expect(WordCatalog.crawlers == ["かぶとむし", "てんとうむし", "かたつむり"])
    for text in WordCatalog.crawlers {
      #expect(WordCatalog.entry(for: text)?.kind == .animal, "\(text)")
    }
    #expect(WordCatalog.crawls("かたつむり"))
    #expect(!WordCatalog.crawls("うさぎ"))
    #expect(!WordCatalog.crawls("ちょう"))
  }

  @Test("すべてのことばの字が、ひらがなのパックにある")
  func charactersExist() throws {
    let chars = Set(try HiraganaPackTests.loadAll().map { Character($0.char) })
    for entry in WordCatalog.all {
      for char in entry.text {
        #expect(chars.contains(char), "\(entry.text) の「\(char)」がない")
      }
    }
  }
}
