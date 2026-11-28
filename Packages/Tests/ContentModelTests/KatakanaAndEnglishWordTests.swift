import Foundation
import Testing

@testable import ContentModel

@Suite("カタカナのことばと えいごの ことば（D199）")
struct KatakanaAndEnglishWordTests {
  @Test("ことばの文字の種類は、字から決まる")
  func scriptFromText() {
    #expect(WordText.script(of: "ねこ") == .hiragana)
    #expect(WordText.script(of: "バス") == .katakana)
    // 長音と小さい字も、カタカナのことばの字
    #expect(WordText.script(of: "パトカー") == .katakana)
    #expect(WordText.script(of: "ジュース") == .katakana)
    #expect(WordText.script(of: "cat") == .abc)
    // まざったことば・空は決まらない
    #expect(WordText.script(of: "バすケ") == nil)
    #expect(WordText.script(of: "") == nil)
  }

  @Test("バスは、カタカナの のりもの。テーマのひらがなの ことばの後ろ")
  func busEntry() {
    let bus = WordCatalog.entry(for: "バス")
    #expect(bus?.kind == .vehicle)
    #expect(bus?.script == .katakana)
    #expect(bus?.isKatakana == true)
    #expect(WordCatalog.entry(for: "ねこ")?.isKatakana == false)
    let norimono = WordMap.theme(id: "norimono")
    #expect(norimono?.words.contains("バス") == true)
    #expect(WordNotes.note(for: "バス") != nil)
    #expect(WordCatalog.batchArtNames["バス"] == "basu")
  }

  @Test("テーマの並び: ひらがな → おためし → 鍵のカタカナ")
  func arrangement() {
    let words = ["タクシー", "くるま", "バス", "でんしゃ", "パトカー"]
    #expect(
      WordMapIndex.arranged(words, trial: ["バス"])
        == ["くるま", "でんしゃ", "バス", "タクシー", "パトカー"])
    // おためしがなければ、ひらがなの後ろに、カタカナが書いた順で並ぶ
    #expect(
      WordMapIndex.arranged(words, trial: []) == ["くるま", "でんしゃ", "タクシー", "バス", "パトカー"])
  }

  @Test("地図のことばも、同じ並び")
  func indexArrangesWords() {
    let index = WordMapIndex(trialWords: ["バス"]) { _ in true }
    let theme = WordMap.theme(id: "norimono")
    let words = theme.map { index.words(in: $0) } ?? []
    let firstKatakana = words.firstIndex { WordText.script(of: $0) == .katakana }
    #expect(firstKatakana != nil)
    #expect(words[firstKatakana ?? 0] == "バス")
    #expect(words[..<(firstKatakana ?? 0)].allSatisfy { WordText.script(of: $0) == .hiragana })
  }

  // MARK: - 英語

  @Test("えいごの ことばは、日本語のことばの絵を借りる")
  func englishMapsToJapanese() {
    #expect(EnglishWords.japanese(of: "cat") == "ねこ")
    #expect(EnglishWords.japanese(of: "bus") == "バス")
    #expect(EnglishWords.japanese(of: "ねこ") == nil)
    #expect(EnglishWords.base(of: "dog") == "いぬ")
    #expect(EnglishWords.base(of: "いぬ") == "いぬ")
    #expect(EnglishWords.words(for: "ねこ").map(\.text) == ["cat"])
    // 動きの種類は、借りる日本語のことばと同じ
    #expect(EnglishWords.entry(for: "cat")?.kind == WordCatalog.entry(for: "ねこ")?.kind)
    #expect(EnglishWords.entry(for: "bus")?.kind == .vehicle)
    #expect(EnglishWords.entry(for: "nothing") == nil)
  }

  @Test("はじめの20語。重ならず、小文字の3〜4文字で、日本語のことばと絵がある")
  func englishSeed() {
    let all = EnglishWords.all
    // あとから約80語が足されても通る: はじめの20語が入っていること。
    let seed =
      "cat dog cow pig fox bear duck hen owl bee ant frog fish egg sun moon star hat car bus"
      .split(separator: " ").map(String.init)
    #expect(all.count >= 20)
    #expect(Set(all.map(\.text)).isSuperset(of: seed))
    #expect(Set(all.map(\.text)).count == all.count)
    #expect(EnglishWords.entries.count == all.count)
    for word in all {
      #expect(EnglishWords.isLowercaseLetters(word.text), "\(word.text)")
      #expect((3...4).contains(word.text.count), "\(word.text)")
      #expect(WordCatalog.entry(for: word.japanese) != nil, "\(word.text) → \(word.japanese)")
      #expect(WordText.script(of: word.text) == .abc)
    }
  }

  @Test("えいごの ことばは、日本語のことばの一覧（しりとりなど）に入らない")
  func englishIsNotJapanese() {
    #expect(WordCatalog.entry(for: "cat") == nil)
    #expect(WordCatalog.all.allSatisfy { !EnglishWords.isEnglish($0.text) })
  }

  @Test("英語のことばは、日本語のことばのテーマに出る。出る順は、おためしが先")
  func englishInThemes() {
    let index = WordMapIndex(trialWords: ["cat", "バス"]) { _ in true }
    let pets = WordMap.theme(id: "ie-ikimono").map { index.englishWords(in: $0) } ?? []
    #expect(pets.first == "cat")
    #expect(pets.contains("dog"))
    // 英語のことばがないテーマには、旗を出さない（空）
    #expect(index.englishWords(in: WordMap.theme(id: "karada")!).isEmpty)
    // 絵のない日本語のことばの英語は出ない
    let noArt = WordMapIndex { $0 != "ねこ" }
    #expect(
      !(WordMap.theme(id: "ie-ikimono").map { noArt.englishWords(in: $0) } ?? []).contains("cat"))
    // バスは、のりもの
    let vehicles = WordMap.theme(id: "norimono").map { index.englishWords(in: $0) } ?? []
    #expect(vehicles.contains("bus"))
    #expect(vehicles.contains("car"))
  }

  @Test("英語のことばの季節は、借りる日本語のことばの季節")
  func englishSeason() {
    #expect(WordSeason.season(of: "sun") == WordSeason.season(of: "たいよう"))
    #expect(WordSeason.season(of: "cat") == nil)
  }

  // MARK: - もじから さがす

  @Test("探す字をそろえる: カタカナはひらがな、英字は小文字")
  func searchNormalization() {
    #expect(WordSearch.normalize("バ") == "ば")
    #expect(WordSearch.normalize("ト") == "と")
    #expect(WordSearch.normalize("C") == "c")
    #expect(WordSearch.normalize("c") == "c")
    #expect(WordSearch.normalize("7") == "7")
    #expect(WordSearch.initial(of: "バス") == "ば")
    #expect(WordSearch.initial(of: "cat") == "c")
  }

  @Test("カタカナの字で、ひらがなのことばもカタカナのことばも見つかる")
  func katakanaSearch() {
    let candidates = ["とら", "トマト", "バス", "ねこ", "トラック"]
    #expect(WordSearch.words(startingWith: "ト", among: candidates) == ["とら", "トマト", "トラック"])
    #expect(WordSearch.words(startingWith: "バ", among: candidates) == ["バス"])
  }

  @Test("英字で、英語のことばが見つかる。大文字でも小文字でも")
  func englishSearch() {
    let candidates = EnglishWords.all.map(\.text)
    let c = WordSearch.words(startingWith: "C", among: candidates)
    #expect(Set(c) == ["cat", "cow", "car"])
    #expect(WordSearch.words(startingWith: "c", among: candidates) == c)
    #expect(WordSearch.words(startingWith: "z", among: candidates).isEmpty)
  }

  @Test("探した結果: 開いていることばが先、鍵のことばは影絵で2枚まで")
  func searchResults() {
    let candidates = ["とら", "トマト", "トラック", "トースト", "とんぼ"]
    let locked: Set<String> = ["トマト", "トラック", "トースト"]
    let results = WordSearch.results(
      startingWith: "ト", among: candidates, isLocked: locked.contains)
    #expect(results.map(\.word) == ["とら", "とんぼ", "トマト", "トラック"])
    #expect(results.map(\.isLocked) == [false, false, true, true])
    // 買ったあとは、鍵がないので全部出る
    let all = WordSearch.results(startingWith: "ト", among: candidates, isLocked: { _ in false })
    #expect(all.count == 5)
    #expect(all.allSatisfy { !$0.isLocked })
  }
}

/// カタカナ・アルファベットのパック（`Content/Packs/<名前>`）を読む。
enum KatakanaWordPacks {
  static func load(_ name: String) throws -> [CharacterData] {
    let directory = URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()  // ContentModelTests
      .deletingLastPathComponent()  // Tests
      .deletingLastPathComponent()  // Packages
      .deletingLastPathComponent()  // リポジトリ
      .appendingPathComponent("Content/Packs/\(name)")
    return try FileManager.default.contentsOfDirectory(
      at: directory, includingPropertiesForKeys: nil
    )
    .filter { $0.pathExtension == "json" && $0.lastPathComponent.hasPrefix(name + ".") }
    .sorted { $0.lastPathComponent < $1.lastPathComponent }
    .map { try JSONDecoder().decode(CharacterData.self, from: Data(contentsOf: $0)) }
  }
}

@Suite("カタカナ・英語のことばの字がパックにある（D199）")
struct WordPackCharacterTests {
  @Test("英語のことばの字が、abc パックの小文字にある")
  func englishLetters() throws {
    let letters = Set(try KatakanaWordPacks.load("abc").map { Character($0.char) })
    for word in EnglishWords.all {
      for char in word.text {
        #expect(letters.contains(char), "\(word.text) の「\(char)」がない")
      }
    }
  }

  @Test("カタカナのことばの字（長音・小さい字をふくむ）が、kata パックにある")
  func katakanaLetters() throws {
    let letters = Set(try KatakanaWordPacks.load("kata").map { Character($0.char) })
    for entry in WordCatalog.all where entry.isKatakana {
      for char in entry.text {
        #expect(letters.contains(char), "\(entry.text) の「\(char)」がない")
      }
    }
    #expect(letters.contains("ー"))
  }
}
