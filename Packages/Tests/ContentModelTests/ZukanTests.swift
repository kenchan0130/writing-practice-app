import Testing

@testable import ContentModel

@Suite("ずかん・ひとこと説明・もじから さがす（D35・D181）")
struct ZukanTests {
  @Test("★は書いた回数。0なら書いていない、3回以上でも3")
  func stars() {
    #expect(Zukan.stars(writtenCount: 0) == 0)
    #expect(Zukan.stars(writtenCount: 1) == 1)
    #expect(Zukan.stars(writtenCount: 2) == 2)
    #expect(Zukan.stars(writtenCount: 3) == 3)
    #expect(Zukan.stars(writtenCount: 9) == 3)
    #expect(Zukan.stars(writtenCount: -1) == 0)
  }

  @Test("書いたことばは★、まだは影絵、鍵つきは鍵")
  func states() {
    let counts = ["いぬ": 2, "ねこ": 0]
    let locked: (String) -> Bool = { $0 == "くま" }
    #expect(Zukan.state(of: "いぬ", writtenCounts: counts, isLocked: locked) == .written(stars: 2))
    #expect(Zukan.state(of: "ねこ", writtenCounts: counts, isLocked: locked) == .unwritten)
    #expect(Zukan.state(of: "くま", writtenCounts: counts, isLocked: locked) == .locked)
    // 鍵つきでも、書いたことがあれば書いたものとして見せる。
    #expect(
      Zukan.state(of: "くま", writtenCounts: ["くま": 1], isLocked: locked) == .written(stars: 1))
  }

  @Test("ずかんは地図と同じ場所・テーマの順で、絵のあることばだけ")
  func sections() {
    let index = WordMapIndex { $0 != "ねこ" }
    let sections = Zukan.sections(index: index, writtenCounts: ["いぬ": 5])
    let ie = sections.first { $0.theme.id == "ie-ikimono" }
    #expect(
      ie?.entries.map(\.word) == [
        "いぬ", "うさぎ", "こいぬ", "こねこ", "ことり", "おうむ", "きんぎょ", "すずむし", "ハムスター", "インコ",
      ])
    #expect(ie?.entries.first?.state == .written(stars: 3))
    #expect(ie?.entries.last?.state == .unwritten)
    let order = sections.map(\.theme.id)
    let expected = WordMap.themes.map(\.id).filter { order.contains($0) }
    // 場所の順なので、テーマの並びは場所ごとにまとまる。
    #expect(Set(order) == Set(expected))
    #expect(sections.allSatisfy { !$0.entries.isEmpty })
  }

  @Test("どのことばにも、ひとこと説明があり、短く、重ならない")
  func notesCoverCatalog() {
    for entry in WordCatalog.all {
      let note = WordNotes.note(for: entry.text)
      #expect(note != nil, "説明がない: \(entry.text)")
      if let note {
        #expect(note.count <= WordNotes.maxLength, "長すぎる: \(entry.text) \(note.count)字")
      }
    }
    let words = Set(WordCatalog.all.map(\.text))
    for key in WordNotes.all.keys { #expect(words.contains(key), "ことばにない説明: \(key)") }
    // 同じ文は声が1つしか割りふれないので、重ならない。
    #expect(Set(WordNotes.all.values).count == WordNotes.all.count)
  }

  @Test("カタカナで押しても、ひらがなのことばを探す。濁音は別の字")
  func search() {
    let words = ["あり", "あひる", "かば", "がっこう", "くま"]
    #expect(WordSearch.words(startingWith: "あ", among: words) == ["あり", "あひる"])
    #expect(WordSearch.words(startingWith: "ア", among: words) == ["あり", "あひる"])
    #expect(WordSearch.words(startingWith: "か", among: words) == ["かば"])
    #expect(WordSearch.words(startingWith: "が", among: words) == ["がっこう"])
    #expect(WordSearch.words(startingWith: "ゃ", among: words).isEmpty)
    #expect(WordSearch.initial(of: "ガッコウ") == "が")
  }

  @Test("「ん」と「を」で始まることばはない")
  func rules() {
    #expect(WordSearch.rule(for: "ん") == .n)
    #expect(WordSearch.rule(for: "ン") == .n)
    #expect(WordSearch.rule(for: "を") == .wo)
    #expect(WordSearch.rule(for: "あ") == nil)
    for entry in WordCatalog.all {
      #expect(WordSearch.rule(for: WordSearch.initial(of: entry.text)!) == nil, "\(entry.text)")
    }
  }
}
