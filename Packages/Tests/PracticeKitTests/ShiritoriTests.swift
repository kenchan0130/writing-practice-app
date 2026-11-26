import ContentModel
import Testing

@testable import PracticeKit

@Suite("しりとりの字の決まり（D45）")
struct ShiritoriKanaTests {
  @Test("小さい字で終わることばは、大きい字にして続ける")
  func smallKanaBecomesBig() {
    #expect(ShiritoriKana.tail(of: "でんしゃ") == "や")
    #expect(ShiritoriKana.tail(of: "しょうぼうしゃ") == "や")
    #expect(ShiritoriKana.tail(of: "おたまじゃくし") == "し")
    #expect(ShiritoriKana.tail(of: "ゆっ") == "つ")
    #expect(ShiritoriKana.tail(of: "ふぁ") == "あ")
  }

  @Test("濁音・半濁音は そのまま")
  func dakutenKept() {
    #expect(ShiritoriKana.tail(of: "りんご") == "ご")
    #expect(ShiritoriKana.tail(of: "えんぴつ") == "つ")
    #expect(ShiritoriKana.tail(of: "かっぱ") == "ぱ")
    #expect(ShiritoriKana.tail(of: "ぞう") == "う")
    #expect(ShiritoriKana.head(of: "ごりら") == "ご")
  }

  @Test("長音は、その前の字")
  func longVowel() {
    #expect(ShiritoriKana.tail(of: "カレー") == "れ")
    #expect(ShiritoriKana.tail(of: "ラーメン") == "ん")
    #expect(ShiritoriKana.tail(of: "ケーキー") == "き")
    // 長音の前が小さい字のときは、小さい字の大きい字
    #expect(ShiritoriKana.tail(of: "ちょー") == "よ")
  }

  @Test("カタカナはひらがなとして続く")
  func katakana() {
    #expect(ShiritoriKana.tail(of: "リンゴ") == "ご")
    #expect(ShiritoriKana.head(of: "ゴリラ") == "ご")
    #expect(ShiritoriKana.tail(of: "ジャ") == "や")
    #expect(ShiritoriKana.tail(of: "ミカン") == "ん")
  }

  @Test("「ん」で終わることばは、そう分かる")
  func endsWithN() {
    #expect(ShiritoriWord("みかん")?.endsWithN == true)
    #expect(ShiritoriWord("りんご")?.endsWithN == false)
    #expect(ShiritoriWord("") == nil)
    #expect(ShiritoriWord("ー") == nil)
  }

  @Test("濁点を分けて書いた字も、ひとつの字として読む")
  func decomposedDakuten() {
    #expect(ShiritoriKana.tail(of: "りんこ\u{3099}") == "ご")
    #expect(ShiritoriKana.head(of: "こ\u{3099}りら") == "ご")
  }
}

@Suite("しりとりの候補（D45・D70）")
struct ShiritoriPoolTests {
  /// 小さな世界。あ→い→う のように続く。
  static let small = ShiritoriPool(texts: [
    "あめ", "あり", "あひる", "めだか", "めがね", "りす", "りんご", "りぼん", "ごりら", "ごま", "かば", "かに",
  ])

  @Test("キャラクターは、書ける続きが2つ以上残ることばだけを言う")
  func characterNeedsTwoContinuations() {
    // 「あめ」は め で終わり、め で始まることばは2つ（めだか・めがね）。
    #expect(Self.small.characterChoices(after: "あ", excluding: []).map(\.text).contains("あめ"))
    // 「あり」は り で終わり、り で始まるのは3つ。
    #expect(Self.small.characterChoices(after: "あ", excluding: []).map(\.text).contains("あり"))
    // 「あひる」は る で終わり、る で始まることばがない。
    #expect(!Self.small.characterChoices(after: "あ", excluding: []).map(\.text).contains("あひる"))
    // 使ったことばは減る: めだか を使うと、あめ の続きは1つだけ。
    let choices = Self.small.characterChoices(after: "あ", excluding: ["めだか"]).map(\.text)
    #expect(!choices.contains("あめ"))
  }

  @Test("「ん」で終わることばは、キャラクターも言わず、候補にも出さない")
  func neverEndsWithN() {
    let pool = ShiritoriPool(texts: ["あみ", "みかん", "みそ", "みず", "みち", "そら", "ずかん"])
    var rng = SeededGenerator(seed: 3)
    for _ in 0..<200 {
      let cards = pool.childCards(after: "み", excluding: [], using: &rng)
      #expect(!cards.isEmpty)
      #expect(!cards.contains { $0.endsWithN })
    }
    #expect(!pool.characterChoices(after: nil, excluding: []).contains { $0.endsWithN })
  }

  @Test("キャラクターが言うのは、書けることばだけ。鍵つきは言わない")
  func characterOnlyWritable() {
    let pool = ShiritoriPool(
      texts: ["あめ", "めだか", "めがね", "めじろ", "ろば", "ろうそく"],
      isLocked: { $0 == "あめ" || $0 == "めだか" })
    let choices = pool.characterChoices(after: nil, excluding: [])
    #expect(!choices.contains { $0.isLocked })
    // 鍵つきの めだか は「続き」に数えない: めがね・めじろ だけ（2つ）
    #expect(pool.writableContinuations(from: "め", excluding: []) == 2)
  }

  @Test("候補は3枚。書けることばが2枚以上、鍵つきは多くても1枚")
  func cardsRules() {
    let texts = ["あめ", "あり", "あし", "あさ", "あか", "あお"] + ["めだか", "めがね", "りす", "りんご"]
    let pool = ShiritoriPool(texts: texts, isLocked: { ["あか", "あお"].contains($0) })
    var rng = SeededGenerator(seed: 9)
    var sawLocked = false
    var sawNoLocked = false
    for _ in 0..<300 {
      let cards = pool.childCards(after: "あ", excluding: [], using: &rng)
      #expect(cards.count == 3)
      #expect(cards.filter { !$0.isLocked }.count >= 2)
      #expect(cards.filter(\.isLocked).count <= 1)
      #expect(Set(cards.map(\.text)).count == cards.count)
      if cards.contains(where: \.isLocked) { sawLocked = true } else { sawNoLocked = true }
    }
    #expect(sawLocked && sawNoLocked)
  }

  @Test("候補が足りないときは、少ない枚数になる")
  func fewCards() {
    let pool = ShiritoriPool(texts: ["あめ", "あり", "めだか", "りす"])
    var rng = SeededGenerator(seed: 1)
    #expect(pool.childCards(after: "あ", excluding: [], using: &rng).count == 2)
    #expect(pool.childCards(after: "あ", excluding: ["あめ"], using: &rng).count == 1)
    #expect(pool.childCards(after: "ぬ", excluding: [], using: &rng).isEmpty)
  }

  @Test("同じ回で使ったことばは、候補に出ない")
  func usedWordsExcluded() {
    var rng = SeededGenerator(seed: 5)
    for _ in 0..<50 {
      let cards = Self.small.childCards(after: "り", excluding: ["りす"], using: &rng)
      #expect(!cards.contains { $0.text == "りす" })
    }
  }

  @Test("続けられることばを、候補に必ず入れる")
  func includesContinuable() {
    // あめ → めだか → (かば・かに) と続く。あひる は続けられない。
    let pool = ShiritoriPool(
      texts: ["あめ", "あひる", "あじ", "めだか", "めがね", "かば", "かに", "ねこ", "ねじ"])
    var rng = SeededGenerator(seed: 11)
    for _ in 0..<100 {
      let cards = pool.childCards(after: "あ", excluding: [], using: &rng)
      #expect(cards.contains { pool.canReply(after: $0, excluding: []) })
    }
  }
}

@Suite("しりとり1回（D45・D70）")
struct ShiritoriRoundTests {
  @Test("はじまりは、キャラクターのことば。子どもの番には2枚以上の書ける候補がある")
  func opening() {
    let pool = ShiritoriPool(texts: WordCatalog.all.map(\.text))
    var rng = SeededGenerator(seed: 2)
    let round = ShiritoriRound(pool: pool, using: &rng)
    #expect(round.turns.count == 1)
    #expect(round.turns[0].speaker == .character)
    #expect(round.cards.count >= 2)
    #expect(round.outcome == nil)
    #expect(round.characterWord != nil)
  }

  @Test("候補にないことば・鍵つきのことばは受け取らない")
  func rejectsInvalid() {
    let pool = ShiritoriPool(
      texts: ["あめ", "めだか", "めがね", "めじろ", "ろば"], isLocked: { $0 == "めじろ" })
    var rng = SeededGenerator(seed: 4)
    var round = ShiritoriRound(pool: pool, using: &rng)
    #expect(!round.childWrote("ろば", using: &rng))
    #expect(round.childWordCount == 0)
    #expect(!round.childWrote("めじろ", using: &rng))
  }

  @Test("キャラクターが続けられないときは、子どもの勝ちで終わる")
  func characterGivesUp() {
    let pool = ShiritoriPool(texts: ["あめ", "めだか", "めがね", "ねこ", "ねじ", "ごま"])
    var wins = 0
    for seed in 0..<50 {
      var rng = SeededGenerator(seed: UInt64(seed))
      var round = ShiritoriRound(pool: pool, using: &rng)
      // 続けられない候補を選ぶ
      guard
        let stop = round.cards.first(where: { !pool.canReply(after: $0, excluding: round.used) })
      else { continue }
      #expect(round.childWrote(stop.text, using: &rng))
      #expect(round.outcome == .characterGaveUp)
      #expect(round.cards.isEmpty)
      #expect(round.isOver)
      // 終わったあとは受け取らない
      #expect(!round.childWrote(stop.text, using: &rng))
      wins += 1
    }
    #expect(wins > 0)
  }

  @Test("5語書くと、そこで終わる")
  func endsAfterFive() {
    // 大きな世界で、続けられることばを選び続ける
    let pool = ShiritoriPool(texts: WordCatalog.all.map(\.text))
    var rng = SeededGenerator(seed: 8)
    var finished = 0
    for seed in 0..<200 {
      var rng = SeededGenerator(seed: UInt64(seed))
      var round = ShiritoriRound(pool: pool, using: &rng)
      while !round.isOver {
        let card =
          round.cards.first { pool.canReply(after: $0, excluding: round.used) } ?? round.cards[0]
        round.childWrote(card.text, using: &rng)
      }
      #expect(round.childWordCount <= ShiritoriRound.childWordLimit)
      if round.outcome == .finished {
        #expect(round.childWordCount == ShiritoriRound.childWordLimit)
        finished += 1
      }
    }
    #expect(finished > 0)
    _ = rng.next()
  }

  @Test("ことばが1つもないときは、そっと終わる")
  func emptyPool() {
    var rng = SeededGenerator(seed: 1)
    let round = ShiritoriRound(pool: ShiritoriPool(texts: []), using: &rng)
    #expect(round.outcome == .finished)
    #expect(round.cards.isEmpty)
  }

  @Test("キャラクターが選ぶのは、子どもが続けやすいことば")
  func characterPrefersLively() {
    // あひる(終わり る: 続きなし) は選べない。あめ/あり は続きがある。
    let pool = ShiritoriPool(texts: ["あめ", "めだか", "めがね", "めじろ", "あり", "りす", "りぼん", "りんご"])
    for seed in 0..<50 {
      var rng = SeededGenerator(seed: UInt64(seed))
      let round = ShiritoriRound(pool: pool, using: &rng)
      #expect(round.cards.count >= 2)
    }
  }
}

@Suite("しりとりを自動で何千回も遊ぶ（D70）")
struct ShiritoriSimulationTests {
  /// 起きてはいけないことが、何千回遊んでも一度も起きないことを確かめる。
  static func check(pool: ShiritoriPool, rounds: Int, seed: UInt64) {
    var rng = SeededGenerator(seed: seed)
    var gaveUp = 0
    var finished = 0
    for _ in 0..<rounds {
      var round = ShiritoriRound(pool: pool, using: &rng)
      var seen = Set<String>()
      var previous: ShiritoriWord?
      var guardCount = 0
      var checkedTurns = 0
      func checkTurns() {
        while checkedTurns < round.turns.count {
          let turn = round.turns[checkedTurns]
          checkedTurns += 1
          // 同じことばは、同じ回で2度出ない
          #expect(seen.insert(turn.word).inserted, "ことばが重なった: \(turn.word)")
          let word = ShiritoriWord(turn.word)!
          #expect(!word.endsWithN, "「ん」で終わることば: \(turn.word)")
          if let previous { #expect(word.head == previous.tail, "\(previous.text) → \(turn.word)") }
          if turn.speaker == .character {
            let locked = pool.words.first { $0.text == turn.word }!.isLocked
            #expect(!locked, "キャラクターが鍵つきのことばを言った: \(turn.word)")
            // 言ったあとに、書ける続きが2つ以上ある（D70）
            #expect(
              pool.writableContinuations(from: word.tail, excluding: seen) >= 2,
              "続きが足りない: \(turn.word)")
          }
          previous = word
        }
      }
      checkTurns()
      while !round.isOver {
        guardCount += 1
        #expect(guardCount <= ShiritoriRound.childWordLimit, "終わらない")
        if guardCount > ShiritoriRound.childWordLimit { break }
        // 子どもの番: 候補は3枚まで、書けることばが2枚以上、鍵つきは多くても1枚。行き止まりにならない
        let cards = round.cards
        #expect(cards.count <= 3)
        #expect(cards.filter { !$0.isLocked }.count >= 2, "書ける候補が足りない")
        #expect(cards.filter(\.isLocked).count <= 1)
        #expect(!cards.contains { $0.endsWithN })
        #expect(!cards.contains { seen.contains($0.text) })
        if let previous { #expect(cards.allSatisfy { $0.head == previous.tail }) }
        guard let card = cards.filter({ !$0.isLocked }).randomElement(using: &rng) else { break }
        #expect(round.childWrote(card.text, using: &rng))
        checkTurns()
      }
      #expect(round.childWordCount <= ShiritoriRound.childWordLimit)
      switch round.outcome {
      case .characterGaveUp?: gaveUp += 1
      case .finished?: finished += 1
      case nil: Issue.record("終わっていない")
      }
    }
    #expect(gaveUp + finished == rounds)
  }

  @Test("いまのことば全部で、3000回")
  func currentCatalog() {
    let pool = ShiritoriPool(texts: WordCatalog.all.map(\.text))
    Self.check(pool: pool, rounds: 3000, seed: 20_261_127)
    let result = ShiritoriAnalysis.simulate(pool: pool, rounds: 1000, seed: 7)
    // 5語まで続く回も、まいったで終わる回も、どちらもある
    #expect(result.finished > 0)
    #expect(result.gaveUp > 0)
    #expect(result.rounds == result.finished + result.gaveUp)
  }

  @Test("鍵つきのことばが混ざっても、2000回")
  func withLockedWords() {
    // ことば全体の 1/4 に鍵をかけたとする（決まった印で）
    let texts = WordCatalog.all.map(\.text)
    let locked = Set(texts.enumerated().filter { $0.offset % 4 == 0 }.map(\.element))
    Self.check(
      pool: ShiritoriPool(texts: texts, isLocked: { locked.contains($0) }), rounds: 2000, seed: 3)
  }

  @Test("ことばが少ない世界でも、行き止まりにならない")
  func thinCatalog() {
    for count in [4, 8, 16, 32, 64] {
      let texts = Array(WordCatalog.all.map(\.text).prefix(count))
      Self.check(pool: ShiritoriPool(texts: texts), rounds: 300, seed: UInt64(count))
    }
  }

  @Test("ことばが1つもなくても、1つだけでも、止まらない")
  func degenerate() {
    for texts in [[], ["あめ"], ["あめ", "めだか"], ["みかん", "かんづめ"]] {
      Self.check(pool: ShiritoriPool(texts: texts), rounds: 20, seed: 1)
    }
  }
}

@Suite("しりとりの調べ（D70）")
struct ShiritoriAnalysisTests {
  @Test("字ごとの数と、行き止まりの字")
  func rows() {
    let pool = ShiritoriPool(texts: ["あめ", "めだか", "めがね", "みかん", "かば"])
    let rows = ShiritoriAnalysis.rows(for: pool)
    let me = rows.first { $0.kana == "め" }!
    #expect(me.startCount == 2)
    #expect(me.usableStartCount == 2)
    #expect(me.endCount == 1)
    let mi = rows.first { $0.kana == "み" }!
    #expect(mi.startCount == 1)
    #expect(mi.usableStartCount == 0)  // 「ん」で終わる
    #expect(rows.first { $0.kana == "ん" }!.endCount == 1)
    // か で始まる続きは かば の1つだけ → か は行き止まり
    #expect(rows.first { $0.kana == "か" }!.isDeadEnd)
    #expect(ShiritoriAnalysis.deadEnds(for: pool).contains("か"))
    // め で始まる めだか・めがね は、どちらも続きが か・ね で足りない
    #expect(rows.first { $0.kana == "あ" }!.startCount == 1)
  }

  @Test("いまのことばの表が出せる")
  func currentCatalog() {
    let pool = ShiritoriPool(texts: WordCatalog.all.map(\.text))
    let rows = ShiritoriAnalysis.rows(for: pool)
    #expect(rows.count > 20)
    #expect(rows.map(\.kana) == rows.map(\.kana).sorted())
  }
}
