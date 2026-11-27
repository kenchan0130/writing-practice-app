import Testing

@testable import ContentModel

@Suite("ことばの一覧（D78）")
struct WordCatalogTests {
  @Test("305語で、種類ごとの数が合う")
  func counts() {
    #expect(WordCatalog.all.count == 305)
    #expect(Set(WordCatalog.all.map(\.text)).count == 305)
    #expect(WordCatalog.all.filter { $0.kind == .vehicle }.count == 13)
    #expect(WordCatalog.all.filter { $0.kind == .animal }.count == 45)
    #expect(WordCatalog.all.filter { $0.kind == .clothes }.count == 16)
    #expect(WordCatalog.all.filter { $0.kind == .flyer }.count == 19)
    #expect(WordCatalog.all.filter { $0.kind == .scenery }.count == 101)
    #expect(WordCatalog.all.filter { $0.kind == .swimmer }.count == 25)
    #expect(WordCatalog.all.filter { $0.kind == .sky }.count == 10)
    #expect(WordCatalog.all.filter { $0.kind == .plaything }.count == 28)
    #expect(WordCatalog.all.filter { $0.kind == .bodyAction }.count == 8)
    #expect(WordCatalog.all.filter { $0.kind == .furniture }.count == 23)
    #expect(WordCatalog.all.filter { $0.kind == .seasonal }.count == 17)
  }

  @Test("種類が正しい")
  func kinds() {
    #expect(WordCatalog.entry(for: "そり")?.kind == .vehicle)
    #expect(WordCatalog.entry(for: "しんかんせん")?.kind == .vehicle)
    #expect(WordCatalog.entry(for: "りす")?.kind == .animal)
    #expect(WordCatalog.entry(for: "うま")?.kind == .animal)
    #expect(WordCatalog.entry(for: "くつした")?.kind == .clothes)
    #expect(WordCatalog.entry(for: "きもの")?.kind == .clothes)
    // へんしん・おしごと も「着る」（D178）。
    #expect(WordCatalog.entry(for: "にんじゃ")?.kind == .clothes)
    #expect(WordCatalog.entry(for: "おまわりさん")?.kind == .clothes)
    #expect(WordCatalog.entry(for: "しょうぼうしゃ")?.kind == .vehicle)
    #expect(WordCatalog.entry(for: "ぞう")?.kind == .animal)
    #expect(WordCatalog.entry(for: "ひこうき")?.kind == .flyer)
    #expect(WordCatalog.entry(for: "こま")?.kind == .plaything)
    #expect(WordCatalog.entry(for: "ぶらんこ")?.kind == .plaything)
    #expect(WordCatalog.entry(for: "もっきん")?.kind == .plaything)
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
    #expect(WordCatalog.entry(for: "たこ")?.kind == .swimmer)
    #expect(WordCatalog.entry(for: "くじら")?.kind == .swimmer)
    #expect(WordCatalog.entry(for: "かえる")?.kind == .swimmer)
    #expect(WordCatalog.entry(for: "おたまじゃくし")?.kind == .swimmer)
    #expect(WordCatalog.entry(for: "くも")?.kind == .sky)
    #expect(WordCatalog.entry(for: "うちゅうじん")?.kind == .sky)
    #expect(WordCatalog.entry(for: "て")?.kind == .bodyAction)
    #expect(WordCatalog.entry(for: "ほっぺ")?.kind == .bodyAction)
    // いえの物（D185）。
    #expect(WordCatalog.entry(for: "なべ")?.kind == .furniture)
    #expect(WordCatalog.entry(for: "とけい")?.kind == .furniture)
    #expect(WordCatalog.entry(for: "せっけん")?.kind == .furniture)
    // めぐり School2: ぶんぼうぐ は いえの物、季節の ぎょうじ は 季節の飾り。
    #expect(WordCatalog.entry(for: "えんぴつ")?.kind == .furniture)
    #expect(WordCatalog.entry(for: "かざぐるま")?.kind == .plaything)
    #expect(WordCatalog.entry(for: "きかんしゃ")?.kind == .vehicle)
    #expect(WordCatalog.entry(for: "ひこうせん")?.kind == .flyer)
    #expect(WordCatalog.entry(for: "こうばん")?.kind == .scenery)
    #expect(WordCatalog.entry(for: "こいのぼり")?.kind == .seasonal)
    #expect(WordCatalog.entry(for: "ゆきだるま")?.kind == .seasonal)
    // めぐり food2（D189）は、どれも景色になる物。
    #expect(WordCatalog.entry(for: "なし")?.kind == .scenery)
    #expect(WordCatalog.entry(for: "おべんとう")?.kind == .scenery)
    #expect(WordCatalog.entry(for: "き")?.kind == .scenery)
    #expect(WordCatalog.entry(for: "みずたまり")?.kind == .scenery)
  }

  @Test("はう物は、むしの動物だけ（D169）。はねる動物や空の虫は はわない")
  func crawlers() {
    #expect(
      WordCatalog.crawlers == [
        "かぶとむし", "てんとうむし", "かたつむり",
        "へび", "わに", "もぐら", "あり", "かまきり", "くわがた", "すずむし",
      ])
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
