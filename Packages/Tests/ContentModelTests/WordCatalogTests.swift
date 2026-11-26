import Testing

@testable import ContentModel

@Suite("ことばの一覧（D78）")
struct WordCatalogTests {
  @Test("47語で、種類ごとの数が合う")
  func counts() {
    #expect(WordCatalog.all.count == 47)
    #expect(Set(WordCatalog.all.map(\.text)).count == 47)
    #expect(WordCatalog.all.filter { $0.kind == .vehicle }.count == 9)
    #expect(WordCatalog.all.filter { $0.kind == .animal }.count == 18)
    #expect(WordCatalog.all.filter { $0.kind == .clothes }.count == 6)
    #expect(WordCatalog.all.filter { $0.kind == .flyer }.count == 5)
    #expect(WordCatalog.all.filter { $0.kind == .scenery }.count == 9)
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
