import Testing

@testable import ContentModel

@Suite("まちの地図・テーマ（D166）")
struct WordMapTests {
  @Test("場所は12か所と「きせつ の はた」、テーマは38")
  func counts() {
    #expect(WordMap.places.count == 13)
    #expect(WordMap.themes.count == 38)
  }

  @Test("IDは重ならず、テーマの場所はすべて実在する（D114）")
  func ids() {
    #expect(Set(WordMap.places.map(\.id)).count == WordMap.places.count)
    #expect(Set(WordMap.themes.map(\.id)).count == WordMap.themes.count)
    for theme in WordMap.themes {
      #expect(WordMap.place(id: theme.placeID) != nil, "\(theme.id) の場所がない")
    }
  }

  @Test("キャラクターのいえのテーマだけ列を持つ")
  func rows() {
    for theme in WordMap.themes {
      #expect((theme.row != nil) == (theme.placeID == "ie"), "\(theme.id)")
    }
  }

  @Test("1か所のテーマは4つまで（おうちは8つ）、1テーマのことばは12まで（D53・D67）")
  func limits() {
    for place in WordMap.places {
      let count = WordMap.themes.filter { $0.placeID == place.id }.count
      let limit = place.id == "ie" ? WordMap.maxThemesInHouse : WordMap.maxThemesPerPlace
      #expect(count <= limit, "\(place.id) は \(count) テーマ")
    }
    for theme in WordMap.themes {
      #expect(theme.words.count <= WordMap.maxWordsPerTheme, "\(theme.id)")
    }
  }

  @Test("テーマのことばは、ことばの一覧にあり、同じテーマで重ならない")
  func wordsExist() {
    for theme in WordMap.themes {
      #expect(Set(theme.words).count == theme.words.count, "\(theme.id)")
      for word in theme.words {
        #expect(WordCatalog.entry(for: word) != nil, "\(theme.id) の「\(word)」がない")
      }
    }
  }

  @Test("47語は、すべてどれかのテーマに入っている")
  func everyWordHasATheme() {
    for entry in WordCatalog.all {
      #expect(WordMap.themes.contains { $0.words.contains(entry.text) }, "\(entry.text)")
    }
  }

  @Test("47語の割りふり")
  func assignment() {
    func theme(_ id: String) -> [String] { WordMap.theme(id: id)?.words ?? [] }
    #expect(Set(theme("norimono")) == ["そり", "くるま", "ふね", "でんしゃ", "じてんしゃ", "しんかんせん", "いかだ"])
    #expect(Set(theme("hataraku-kuruma")) == ["しょうぼうしゃ", "きゅうきゅうしゃ"])
    #expect(Set(theme("dobutsuen-dobutsu")) == ["さる", "ぞう", "とら", "かば", "きりん", "らくだ"])
    #expect(Set(theme("makiba-dobutsu")) == ["うし", "うま", "ぶた", "ひつじ"])
    #expect(Set(theme("mori-dobutsu")) == ["くま", "しか", "りす", "たぬき", "きつね"])
    #expect(Set(theme("ie-ikimono")) == ["いぬ", "ねこ", "うさぎ"])
    #expect(Set(theme("fuku")) == ["ふく", "ゆかた", "きもの"])
    #expect(Set(theme("oshare-komono")) == ["くつ", "ぼうし", "くつした"])
    #expect(Set(theme("sora-tobu-mono")) == ["ひこうき", "ききゅう"])
    #expect(Set(theme("tori")) == ["はと", "すずめ", "からす"])
    #expect(Set(theme("hana")) == ["さくら", "ひまわり", "たんぽぽ"])
    #expect(Set(theme("kudamono")) == ["りんご", "みかん", "いちご"])
    #expect(Set(theme("yasai")) == ["にんじん", "だいこん", "かぼちゃ"])
  }

  // MARK: - 出し分け

  @Test("今の47語（すべて絵あり）では、えき・みち・そら・どうぶつえん・まきば・もり・おうち・おみせが出る")
  func todayPlaces() {
    let index = WordMapIndex { WordCatalog.entry(for: $0) != nil }
    #expect(
      index.places.map(\.id) == [
        "eki", "michi", "sora", "dobutsuen", "makiba", "mori", "ie", "omise",
      ])
    #expect(
      index.themes(in: WordMap.place(id: "ie")!).map(\.id) == [
        "ie-ikimono", "fuku", "oshare-komono",
      ])
  }

  @Test("1テーマだけの場所は、すぐことばのカード。2つ以上ならテーマ")
  func entrances() {
    let index = WordMapIndex { WordCatalog.entry(for: $0) != nil }
    let eki = WordMap.place(id: "eki")!
    if case .words(let theme) = index.entrance(of: eki) {
      #expect(theme.id == "norimono")
    } else {
      Issue.record("えきはことばのカードへ行くはず")
    }
    let ie = WordMap.place(id: "ie")!
    if case .themes(let themes) = index.entrance(of: ie) {
      #expect(themes.count == 3)
    } else {
      Issue.record("おうちはテーマへ行くはず")
    }
    #expect(index.entrance(of: WordMap.place(id: "umi")!) == nil)
  }

  @Test("絵のないことばは数えない。テーマも場所も、絵のあることばが1つあれば出る")
  func visibilityFollowsArt() {
    // 絵があるのは「くま」だけ。
    let one = WordMapIndex { $0 == "くま" }
    #expect(one.places.map(\.id) == ["mori"])
    #expect(one.words(in: WordMap.theme(id: "mori-dobutsu")!) == ["くま"])
    #expect(one.words(in: WordMap.theme(id: "norimono")!).isEmpty)
    #expect(one.representative(of: WordMap.theme(id: "mori-dobutsu")!) == "くま")
    // 絵が1つもなければ、何も出ない。
    #expect(WordMapIndex { _ in false }.places.isEmpty)
  }

  @Test("絵のあることばが増えると、場所とテーマが自然に増える")
  func growsWithWords() {
    let few = WordMapIndex { ["そり", "いぬ"].contains($0) }
    #expect(few.places.map(\.id) == ["eki", "ie"])
    // おうちは、絵のあるテーマが1つだけなので、すぐことばのカード。
    #expect(few.entrance(of: WordMap.place(id: "ie")!) == .words(WordMap.theme(id: "ie-ikimono")!))
    let more = WordMapIndex { ["そり", "いぬ", "ふく"].contains($0) }
    if case .themes(let themes) = more.entrance(of: WordMap.place(id: "ie")!) {
      #expect(themes.map(\.id) == ["ie-ikimono", "fuku"])
    } else {
      Issue.record("テーマが2つになるはず")
    }
  }

  @Test("場所は地図の順で出す")
  func orderFollowsMap() {
    let index = WordMapIndex { _ in true }
    // テーマにことばがある場所だけ、A.2 の順。
    let ids = index.places.map(\.id)
    let order = WordMap.places.map(\.id)
    #expect(ids == order.filter(ids.contains))
  }
}
