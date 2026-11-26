import Testing

@testable import ContentModel

@Suite("ことばの季節（D54・D182）")
struct WordSeasonTests {
  @Test("月から季節が決まる")
  func monthToSeason() {
    #expect(Season.of(month: 3) == .spring)
    #expect(Season.of(month: 5) == .spring)
    #expect(Season.of(month: 6) == .summer)
    #expect(Season.of(month: 8) == .summer)
    #expect(Season.of(month: 9) == .autumn)
    #expect(Season.of(month: 11) == .autumn)
    #expect(Season.of(month: 12) == .winter)
    #expect(Season.of(month: 1) == .winter)
    #expect(Season.of(month: 2) == .winter)
  }

  @Test("印はことばの一覧にあることばだけに付く。四季がそろっている")
  func tagsAreInCatalog() {
    let all = Set(WordCatalog.all.map(\.text))
    for (word, _) in WordSeason.tagged { #expect(all.contains(word), "\(word)") }
    #expect(Set(WordSeason.tagged.values) == Set(Season.allCases))
    #expect(WordSeason.season(of: "すいか") == .summer)
    #expect(WordSeason.season(of: "ゆき") == .winter)
    #expect(WordSeason.season(of: "さくら") == .spring)
    #expect(WordSeason.season(of: "くるま") == nil)
  }
}
