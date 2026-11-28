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

  @Test("306語は、すべてどれかのテーマに入っている")
  func everyWordHasATheme() {
    for entry in WordCatalog.all {
      #expect(WordMap.themes.contains { $0.words.contains(entry.text) }, "\(entry.text)")
    }
  }

  @Test("306語の割りふり")
  func assignment() {
    func theme(_ id: String) -> [String] { WordMap.theme(id: id)?.words ?? [] }
    // のりもの（あとから足されても通る）: 土台のことばと、バスが入っている。
    #expect(
      Set(theme("norimono")).isSuperset(of: [
        "そり", "くるま", "ふね", "でんしゃ", "じてんしゃ", "しんかんせん", "いかだ", "ばしゃ", "きかんしゃ", "バス",
      ]))
    #expect(Set(theme("hataraku-kuruma")) == ["しょうぼうしゃ", "きゅうきゅうしゃ", "はしごしゃ", "ゆうびんしゃ"])
    #expect(
      theme("dobutsuen-dobutsu") == [
        "さる", "ぞう", "とら", "かば", "きりん", "らくだ",
        "しまうま", "さい", "わに", "へび", "くじゃく", "あざらし",
      ])
    #expect(
      theme("makiba-dobutsu") == [
        "うし", "うま", "ぶた", "ひつじ",
        "やぎ", "ろば", "にわとり", "ひよこ", "あひる",
      ])
    #expect(
      theme("mori-dobutsu") == [
        "くま", "しか", "りす", "たぬき", "きつね",
        "いのしし", "おおかみ", "ねずみ", "はりねずみ", "もぐら", "こうもり", "むささび",
      ])
    #expect(
      theme("ie-ikimono") == [
        "いぬ", "ねこ", "うさぎ",
        "こいぬ", "こねこ", "ことり", "おうむ", "きんぎょ", "すずむし",
      ])
    #expect(Set(theme("fuku")) == ["ふく", "ゆかた", "きもの"])
    #expect(Set(theme("oshare-komono")) == ["くつ", "ぼうし", "くつした"])
    // 着る ひとそろい（D178）。
    #expect(theme("henshin") == ["にんじゃ", "おひめさま", "おうさま", "まほうつかい", "かいぞく"])
    #expect(theme("oshigoto") == ["だいく", "せんせい", "おいしゃさん", "おまわりさん", "しょうぼうし"])
    #expect(Set(theme("sora-tobu-mono")) == ["ひこうき", "ききゅう", "ひこうせん"])
    #expect(
      theme("tori") == [
        "はと", "すずめ", "からす",
        "にわとり", "ふくろう", "つる", "わし", "つばめ", "かもめ", "きじ", "きつつき", "はくちょう",
      ])
    #expect(
      theme("hana") == [
        "さくら", "ひまわり", "たんぽぽ", "あさがお", "ばら",
        "あじさい", "すみれ", "ゆり", "つばき", "うめ", "なのはな", "すいせん",
      ])
    #expect(
      theme("kudamono") == [
        "りんご", "みかん", "いちご", "もも", "ぶどう", "すいか", "くり",
        "なし", "かき", "さくらんぼ", "びわ", "いちじく",
      ])
    #expect(
      theme("mushi") == [
        "ちょう", "とんぼ", "はち", "ほたる", "せみ", "かぶとむし", "てんとうむし", "かたつむり",
        "あり", "ばった", "かまきり", "くわがた",
      ])
    #expect(
      theme("okashi") == [
        "だんご", "せんべい", "わたあめ",
        "かきごおり", "どらやき", "たいやき", "まんじゅう", "ようかん", "おはぎ", "やきいも", "こんぺいとう", "かしわもち",
      ])
    #expect(
      theme("gohan-nomimono") == [
        "おにぎり", "すし", "うどん",
        "ごはん", "たまご", "ぎゅうにゅう", "おちゃ", "おもち", "おべんとう", "てんぷら", "たまごやき", "おでん",
      ])
    #expect(
      theme("yasai") == [
        "にんじん", "だいこん", "かぼちゃ",
        "なす", "きゅうり", "ねぎ", "たまねぎ", "じゃがいも", "さつまいも", "とうもろこし", "れんこん", "えだまめ",
      ])
    #expect(
      theme("umi-ikimono") == [
        "たこ", "いか", "かに", "かめ", "くじら", "くらげ", "いるか", "さかな", "ひとで",
        "えび", "さめ", "ふぐ",
      ])
    #expect(
      theme("kawa-ikimono") == [
        "かえる", "めだか", "ざりがに", "おたまじゃくし",
        "こい", "なまず", "うなぎ", "かも", "はくちょう", "かわうそ", "あめんぼ", "きんぎょ",
      ])
    // 空のことば（D172）。ほし・つきは、そら・てんきと うちゅうの両方に入る。
    #expect(
      Set(theme("sora-tenki")) == ["くも", "にじ", "あめ", "ゆき", "かみなり", "かぜ", "ほし", "つき"])
    #expect(Set(theme("uchu")) == ["たいよう", "ほし", "つき", "うちゅうじん"])
    // こうえんの物（D173）。
    #expect(
      Set(theme("omocha")) == [
        "つみき", "こま", "けんだま", "ふうせん", "にんぎょう", "おりがみ", "たけうま", "ぬいぐるみ", "かざぐるま", "かみひこうき",
      ])
    #expect(Set(theme("gakki")) == ["たいこ", "ふえ", "すず", "もっきん", "こと", "てっきん"])
    #expect(Set(theme("sports")) == ["なわとび", "てつぼう", "とびばこ", "うきわ", "たまいれ", "つなひき"])
    #expect(
      Set(theme("koen-asobi")) == ["ぶらんこ", "すべりだい", "すなば", "うんてい", "ふんすい", "さんりんしゃ"])
    // 体のことば（D175）。
    #expect(
      Set(theme("karada")) == ["て", "あし", "め", "みみ", "くち", "あたま", "おなか", "ほっぺ"])
    // 景色になる物（D174）。
    #expect(
      theme("shizen") == [
        "やま", "たき", "いし", "いけ",
        "いわ", "もり", "しま", "はたけ", "かいがら", "きりかぶ", "みずたまり", "おちば",
      ])
    #expect(
      theme("ki-kusa-kinoko") == [
        "くさ", "まつ", "どんぐり", "はっぱ", "きのこ",
        "き", "たけ", "たけのこ", "もみじ", "いちょう", "まつぼっくり", "つくし",
      ])
    #expect(
      Set(theme("tatemono")) == [
        "いえ", "がっこう", "びょういん", "おしろ", "じんじゃ", "こうばん", "としょかん", "ようちえん", "ゆうびんきょく",
      ])
    #expect(
      Set(theme("machi-no-mono")) == [
        "しんごう", "ふみきり", "がいとう", "かんばん", "でんちゅう", "ほどうきょう", "じどうはんばいき",
      ])
    // めぐり School2: ぶんぼうぐ と 季節の ぎょうじ（季節の飾り）。テーマの中は、土台のことば、めぐりの順。
    #expect(theme("bunbogu") == ["のり", "ふで", "ほん", "はさみ", "えのぐ", "ねんど", "えんぴつ", "ふでばこ", "じょうぎ"])
    #expect(
      theme("haru-natsu-gyoji") == [
        "はなび", "うちわ", "ふうりん", "たなばた", "ちょうちん", "こいのぼり", "おひなさま", "てるてるぼうず",
      ])
    #expect(
      theme("aki-fuyu-gyoji") == [
        "すすき", "かかし", "だるま", "おつきみ", "かまくら", "かどまつ", "ちとせあめ", "ゆきだるま", "かがみもち",
      ])
    for word in theme("haru-natsu-gyoji") + theme("aki-fuyu-gyoji") {
      #expect(WordCatalog.entry(for: word)?.kind == .seasonal, "\(word)")
    }
    // いえの物（D185）。
    #expect(theme("daidokoro") == ["なべ", "おわん", "はし", "おさら", "やかん"])
    #expect(theme("ie-no-mono") == ["いす", "つくえ", "とけい", "ふとん", "たんす"])
    #expect(theme("ofuro-mijitaku") == ["せっけん", "はぶらし", "くし", "かがみ"])
  }

  @Test("おうちは、いえの なか 4つ・クローゼット 4つの 2列（D67・D185）")
  func houseRows() {
    let index = WordMapIndex { WordCatalog.entry(for: $0) != nil }
    let themes = index.themes(in: WordMap.place(id: "ie")!)
    #expect(
      themes.filter { $0.row == .inside }.map(\.id) == [
        "ie-ikimono", "daidokoro", "ie-no-mono", "ofuro-mijitaku",
      ])
    #expect(
      themes.filter { $0.row == .closet }.map(\.id) == [
        "fuku", "oshare-komono", "henshin", "karada",
      ])
  }

  // MARK: - 出し分け

  @Test("今の306語（すべて絵あり）では、えき・みち・そら・どうぶつえん・まきば・もり・おうち・うみ・かわ・おみせ・こうえん・うちゅう・きせつ の はた が出る")
  func todayPlaces() {
    let index = WordMapIndex { WordCatalog.entry(for: $0) != nil }
    #expect(
      index.places.map(\.id) == [
        "eki", "michi", "sora", "dobutsuen", "makiba", "mori", "ie", "umi", "kawa", "omise", "koen",
        "uchu", "kisetsu",
      ])
    #expect(
      index.themes(in: WordMap.place(id: "ie")!).map(\.id) == [
        "ie-ikimono", "fuku", "oshare-komono", "henshin", "karada", "daidokoro", "ie-no-mono",
        "ofuro-mijitaku",
      ])
  }

  @Test("1テーマだけの場所は、すぐことばのカード。2つ以上ならテーマ")
  func entrances() {
    let index = WordMapIndex { WordCatalog.entry(for: $0) != nil }
    // えきは、のりものと たてもの（D174）で、テーマが2つ。
    let eki = WordMap.place(id: "eki")!
    #expect(index.themes(in: eki).map(\.id) == ["norimono", "tatemono"])
    #expect(
      index.themes(in: WordMap.place(id: "michi")!).map(\.id) == [
        "hataraku-kuruma", "oshigoto", "machi-no-mono",
      ])
    // もりは、テーマが4つ（上限）。かわは、しぜんが足されて2つ。
    #expect(
      index.themes(in: WordMap.place(id: "mori")!).map(\.id) == [
        "mori-dobutsu", "mushi", "hana", "ki-kusa-kinoko",
      ])
    #expect(
      index.themes(in: WordMap.place(id: "kawa")!).map(\.id) == ["kawa-ikimono", "shizen"])
    let ie = WordMap.place(id: "ie")!
    if case .themes(let themes) = index.entrance(of: ie) {
      // いえで かう いきもの・ふく・おしゃれ こもの・へんしん（D178）・からだ（D175）と、いえの なかの 3つ（D185）。
      #expect(themes.count == 8)
    } else {
      Issue.record("おうちはテーマへ行くはず")
    }
    // うみは、テーマが1つだけなので、すぐことばのカード（D67）。
    #expect(
      index.entrance(of: WordMap.place(id: "umi")!)
        == .words(WordMap.theme(id: "umi-ikimono")!))
    // うちゅうも、テーマが1つだけ（D172）。こうえんは、テーマが4つ（D173）。
    #expect(
      index.entrance(of: WordMap.place(id: "uchu")!) == .words(WordMap.theme(id: "uchu")!))
    #expect(
      index.themes(in: WordMap.place(id: "koen")!).map(\.id) == [
        "omocha", "gakki", "sports", "koen-asobi",
      ])
    // そらは、テーマが3つ（そらを とぶ もの・とり・そら・てんき）。
    #expect(
      index.themes(in: WordMap.place(id: "sora")!).map(\.id) == [
        "sora-tobu-mono", "tori", "sora-tenki",
      ])
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
