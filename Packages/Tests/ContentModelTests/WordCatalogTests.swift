import Testing

@testable import ContentModel

@Suite("ことばの一覧（D78）")
struct WordCatalogTests {
  @Test("419語で、種類ごとの数が合う")
  func counts() {
    #expect(WordCatalog.all.count == 419)
    #expect(Set(WordCatalog.all.map(\.text)).count == 419)
    #expect(WordCatalog.all.filter { $0.kind == .vehicle }.count == 17)
    #expect(WordCatalog.all.filter { $0.kind == .animal }.count == 61)
    #expect(WordCatalog.all.filter { $0.kind == .clothes }.count == 16)
    #expect(WordCatalog.all.filter { $0.kind == .flyer }.count == 25)
    #expect(WordCatalog.all.filter { $0.kind == .scenery }.count == 127)
    #expect(WordCatalog.all.filter { $0.kind == .swimmer }.count == 37)
    #expect(WordCatalog.all.filter { $0.kind == .sky }.count == 10)
    #expect(WordCatalog.all.filter { $0.kind == .plaything }.count == 40)
    #expect(WordCatalog.all.filter { $0.kind == .bodyAction }.count == 10)
    #expect(WordCatalog.all.filter { $0.kind == .furniture }.count == 46)
    #expect(WordCatalog.all.filter { $0.kind == .seasonal }.count == 30)
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
    // めぐり life3（D200）: くらしの物は いえの物、てんきの物は景色、行事は季節の飾り、からだは体のことば。
    #expect(WordCatalog.entry(for: "かさ")?.kind == .furniture)
    #expect(WordCatalog.entry(for: "れいぞうこ")?.kind == .furniture)
    #expect(WordCatalog.entry(for: "おぼん")?.kind == .furniture)
    #expect(WordCatalog.entry(for: "こおり")?.kind == .scenery)
    #expect(WordCatalog.entry(for: "つらら")?.kind == .seasonal)
    #expect(WordCatalog.entry(for: "おにのめん")?.kind == .seasonal)
    #expect(WordCatalog.entry(for: "ひざ")?.kind == .bodyAction)
    #expect(WordCatalog.entry(for: "ゆび")?.kind == .bodyAction)
    // めぐり nature3（D201）。
    #expect(WordCatalog.entry(for: "たい")?.kind == .swimmer)
    #expect(WordCatalog.entry(for: "おしどり")?.kind == .swimmer)
    #expect(WordCatalog.entry(for: "うぐいす")?.kind == .flyer)
    #expect(WordCatalog.entry(for: "かわせみ")?.kind == .flyer)
    #expect(WordCatalog.entry(for: "だちょう")?.kind == .animal)
    #expect(WordCatalog.entry(for: "こうし")?.kind == .animal)
    #expect(WordCatalog.entry(for: "こおろぎ")?.kind == .animal)
    #expect(WordCatalog.entry(for: "うみ")?.kind == .scenery)
    #expect(WordCatalog.entry(for: "ひがんばな")?.kind == .scenery)
    #expect(WordCatalog.entry(for: "さぎ")?.kind == .animal)
    #expect(WordCatalog.entry(for: "たか")?.kind == .flyer)
  }

  @Test("はう物は、むしの動物だけ（D169）。はねる動物や空の虫は はわない")
  func crawlers() {
    #expect(
      WordCatalog.crawlers == [
        "かぶとむし", "てんとうむし", "かたつむり",
        "へび", "わに", "もぐら", "あり", "かまきり", "くわがた", "すずむし",
        "だんごむし", "あおむし", "みのむし", "みみず", "かみきりむし", "しゃくとりむし", "かいこ", "なめくじ",
      ])
    for text in WordCatalog.crawlers {
      #expect(WordCatalog.entry(for: text)?.kind == .animal, "\(text)")
    }
    #expect(WordCatalog.crawls("かたつむり"))
    #expect(!WordCatalog.crawls("うさぎ"))
    #expect(!WordCatalog.crawls("ちょう"))
  }

  @Test("すべてのことばの字が、文字のパックにある（ひらがなのことばはひらがな、カタカナのことばはカタカナ。D199）")
  func charactersExist() throws {
    let hira = Set(try HiraganaPackTests.loadAll().map { Character($0.char) })
    let kata = Set(try KatakanaWordPacks.load("kata").map { Character($0.char) })
    for entry in WordCatalog.all {
      let chars = entry.isKatakana ? kata : hira
      for char in entry.text {
        #expect(chars.contains(char), "\(entry.text) の「\(char)」がない")
      }
    }
  }
}
