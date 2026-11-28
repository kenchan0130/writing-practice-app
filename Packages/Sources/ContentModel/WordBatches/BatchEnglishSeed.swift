/// めぐり「EnglishSeed」（D199）: えいごの ことばの はじめの20語。ことば（日本語）は足さない。
/// 絵は、日本語のことばの絵を使い回す（cat は「ねこ」、bus は「バス」）。書くのは `abc` パックの小文字。
/// どれも3〜4文字のやさしいことば。このあとの約80語は、同じ形のめぐりの `english` に足す（`Content/README.md`）。
/// 「cat」は、おためしのことば（D90・D92）。パックがなくても書ける。
extension WordBatch {
  static let englishSeed = WordBatch(
    name: "englishSeed",
    entries: [],
    themeWords: [:],
    notes: [:],
    english: [
      EnglishWord("cat", japanese: "ねこ"),
      EnglishWord("dog", japanese: "いぬ"),
      EnglishWord("cow", japanese: "うし"),
      EnglishWord("pig", japanese: "ぶた"),
      EnglishWord("fox", japanese: "きつね"),
      EnglishWord("bear", japanese: "くま"),
      EnglishWord("duck", japanese: "あひる"),
      EnglishWord("hen", japanese: "にわとり"),
      EnglishWord("owl", japanese: "ふくろう"),
      EnglishWord("bee", japanese: "はち"),
      EnglishWord("ant", japanese: "あり"),
      EnglishWord("frog", japanese: "かえる"),
      EnglishWord("fish", japanese: "さかな"),
      EnglishWord("egg", japanese: "たまご"),
      EnglishWord("sun", japanese: "たいよう"),
      EnglishWord("moon", japanese: "つき"),
      EnglishWord("star", japanese: "ほし"),
      EnglishWord("hat", japanese: "ぼうし"),
      EnglishWord("car", japanese: "くるま"),
      EnglishWord("bus", japanese: "バス"),
    ]
  )
}
