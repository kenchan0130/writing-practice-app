import ContentModel
import Foundation

// しりとりの決まり（D45・D70。§3.10）。画面や端末に頼らない。乱数は呼ぶ側から渡す（テストで決まった並びにできる）。

/// しりとりで使う字の決まり（D45）。
public enum ShiritoriKana {
  private static let smallToBig: [Character: Character] = [
    "ぁ": "あ", "ぃ": "い", "ぅ": "う", "ぇ": "え", "ぉ": "お", "っ": "つ",
    "ゃ": "や", "ゅ": "ゆ", "ょ": "よ", "ゎ": "わ", "ゕ": "か", "ゖ": "け",
  ]
  private static let longVowelMarks: Set<Character> = ["ー", "ｰ"]

  /// カタカナをひらがなにする。ほかの字はそのまま。
  public static func hiragana(_ char: Character) -> Character {
    let scalars = Array(char.unicodeScalars)
    guard scalars.count == 1, (0x30A1...0x30F6).contains(scalars[0].value),
      let scalar = Unicode.Scalar(scalars[0].value - 0x60)
    else { return char }
    return Character(scalar)
  }

  /// 続きの字にそろえる: カタカナはひらがなに、小さい字は大きい字に。濁音・半濁音はそのまま。
  public static func normalized(_ char: Character) -> Character {
    let plain = hiragana(char)
    return smallToBig[plain] ?? plain
  }

  /// ことばの読み（ひらがな）。カタカナのことば（バス・パトカー）はひらがなにする。「ー」と小さい字はそのまま（D199）。
  /// 続けるときの音は `head`・`tail` が決める（「ー」はその前の字の音、小さい字は大きい字の音。D45）。
  public static func reading(of word: String) -> String {
    String(word.precomposedStringWithCanonicalMapping.map(hiragana))
  }

  /// ことばの最初の字（しりとりで、前のことばの最後の字と合わせる字）。
  public static func head(of word: String) -> Character? {
    word.precomposedStringWithCanonicalMapping.first.map(normalized)
  }

  /// ことばの最後の字。小さい字は大きい字にし、長音「ー」はその前の字にする（D45）。
  /// 「ん」で終わることばは `ん` を返す。空なら nil。
  public static func tail(of word: String) -> Character? {
    word.precomposedStringWithCanonicalMapping.reversed()
      .first(where: { !longVowelMarks.contains($0) }).map(normalized)
  }
}

/// しりとりのことば1つ。
public struct ShiritoriWord: Sendable, Hashable, Identifiable {
  public let text: String
  /// 鍵がかかっていて、子どもはまだ書けない（D3）。
  public let isLocked: Bool
  public let head: Character
  public let tail: Character

  public var id: String { text }
  /// 「ん」で終わることばは、しりとりでは使わない（D45）。
  public var endsWithN: Bool { tail == "ん" }

  public init?(_ text: String, isLocked: Bool = false) {
    guard let head = ShiritoriKana.head(of: text), let tail = ShiritoriKana.tail(of: text)
    else { return nil }
    self.text = text
    self.isLocked = isLocked
    self.head = head
    self.tail = tail
  }
}

/// しりとりで使えることばの集まり。キャラクターの番と子どもの候補は、ここから選ぶ。
public struct ShiritoriPool: Sendable, Equatable {
  /// 候補に出す最大の数と、そのうち書けることばの最小・鍵つきの最大（D45）。
  public static let cardCount = 3
  public static let minWritableCards = 2
  public static let maxLockedCards = 1
  /// キャラクターが言うことばには、書ける続きがこの数以上ほしい（D70）。
  public static let minContinuations = 2

  public let words: [ShiritoriWord]
  /// 「ん」で終わらないことばを、最初の字ごとに。
  private let usableByHead: [Character: [ShiritoriWord]]

  public init(words: [ShiritoriWord]) {
    var seen = Set<String>()
    let unique = words.filter { seen.insert($0.text).inserted }
    self.words = unique
    usableByHead = Dictionary(grouping: unique.filter { !$0.endsWithN }, by: \.head)
  }

  /// ことばの文字から作る。`isLocked` は鍵のかかったことばを答える。
  public init(texts: [String], isLocked: (String) -> Bool = { _ in false }) {
    self.init(words: texts.compactMap { ShiritoriWord($0, isLocked: isLocked($0)) })
  }

  public static func == (lhs: ShiritoriPool, rhs: ShiritoriPool) -> Bool { lhs.words == rhs.words }

  /// `kana` で始まり、「ん」で終わらず、まだ使っていないことば。
  public func usable(startingWith kana: Character, excluding used: Set<String>) -> [ShiritoriWord] {
    (usableByHead[kana] ?? []).filter { !used.contains($0.text) }
  }

  /// `kana` で始まる、書ける続きの数。
  public func writableContinuations(from kana: Character, excluding used: Set<String>) -> Int {
    countWritable(from: kana, excluding: used)
  }

  /// 数えるだけなので、配列を作らない（何千回も遊ぶテストが速く終わるように）。
  /// `a`・`b` は、まだ使っていないが、使ったものとして扱うことば。
  private func countWritable(
    from kana: Character, excluding used: Set<String>, and a: String? = nil, _ b: String? = nil
  ) -> Int {
    var count = 0
    for word in usableByHead[kana] ?? []
    where !word.isLocked && !used.contains(word.text) && word.text != a && word.text != b {
      count += 1
    }
    return count
  }

  /// キャラクターが言ってよいことば（D70）。書けることばで、まだ使っておらず、「ん」で終わらず、
  /// 最後の字で始まる書けることばが、この回にまだ2つ以上残っているもの。
  /// `kana` が nil なら、最初のことば（始まりの字は決まっていない）。
  public func characterChoices(after kana: Character?, excluding used: Set<String>)
    -> [ShiritoriWord]
  {
    characterChoices(after: kana, excluding: used, and: nil)
  }

  private func characterChoices(
    after kana: Character?, excluding used: Set<String>, and extra: String?
  )
    -> [ShiritoriWord]
  {
    let starts = kana.map { usableByHead[$0] ?? [] } ?? words.filter { !$0.endsWithN }
    return starts.filter { word in
      guard !word.isLocked, !used.contains(word.text), word.text != extra else { return false }
      return countWritable(from: word.tail, excluding: used, and: extra, word.text)
        >= Self.minContinuations
    }
  }

  /// そのことばを言ったあと、キャラクターが続けられるか。
  public func canReply(after word: ShiritoriWord, excluding used: Set<String>) -> Bool {
    !characterChoices(after: word.tail, excluding: used, and: word.text).isEmpty
  }

  /// そのことばを言ったあと、子どもの候補のうち、キャラクターが続けられることばの数。
  /// キャラクターは、これが多くなることばを選び、しりとりが続くようにする。
  public func continuableCards(after word: ShiritoriWord, excluding used: Set<String>) -> Int {
    let next = used.union([word.text])
    return (usableByHead[word.tail] ?? [])
      .filter { !$0.isLocked && !next.contains($0.text) && canReply(after: $0, excluding: next) }
      .count
  }

  /// 子どもの候補（多くても3枚）。書けることばを2枚以上、鍵つきは多くても1枚（D45）。
  /// ことばが足りないときは、少ない枚数で返す。
  /// 話が続くように、キャラクターが続けられることばを先に入れる。続けられないことば（選ぶと子どもの勝ち）は、
  /// 3回に1回ほど1枚だけ混ぜ、続けられることばが足りないときは、足りない分に使う。
  public func childCards<G: RandomNumberGenerator>(
    after kana: Character, excluding used: Set<String>, using rng: inout G
  ) -> [ShiritoriWord] {
    let all = usable(startingWith: kana, excluding: used)
    let writable = all.filter { !$0.isLocked }.shuffled(using: &rng)
    let locked = all.filter(\.isLocked).shuffled(using: &rng)
    let withLocked =
      !locked.isEmpty && writable.count >= Self.minWritableCards && Bool.random(using: &rng)
    let slots = withLocked ? Self.cardCount - Self.maxLockedCards : Self.cardCount
    let going = writable.filter { canReply(after: $0, excluding: used) }
    let stopping = writable.filter { !going.contains($0) }
    var picked = Array(going.prefix(slots))
    if picked.count < slots {
      picked += stopping.prefix(slots - picked.count)
    } else if let win = stopping.first, !picked.isEmpty, Int.random(in: 0..<3, using: &rng) == 0 {
      picked[picked.count - 1] = win
    }
    if withLocked { picked.append(locked[0]) }
    return picked.shuffled(using: &rng)
  }
}

/// しりとり1回分の状態（D45・D70）。キャラクターが先に言い、子どもが5語まで書く。
public struct ShiritoriRound: Sendable, Equatable {
  /// 1回に子どもが書くことばの数の上限（D70）。
  public static let childWordLimit = 5

  public enum Speaker: Sendable, Hashable { case character, child }
  public struct Turn: Sendable, Hashable {
    public let speaker: Speaker
    public let word: String
  }
  public enum Outcome: Sendable, Hashable {
    /// キャラクターが続けられず「うーん……まいった！」。子どもの勝ち（D70）。
    case characterGaveUp
    /// 子どもが5語書いた（または、ことばが足りなくなった）。「きょうは ここまで！」。
    case finished
  }

  public let pool: ShiritoriPool
  public private(set) var turns: [Turn] = []
  public private(set) var used: Set<String> = []
  /// いま子どもに見せる候補。終わったら空。
  public private(set) var cards: [ShiritoriWord] = []
  public private(set) var outcome: Outcome?

  /// キャラクターが最初のことばを言って、子どもの番になる。
  public init<G: RandomNumberGenerator>(pool: ShiritoriPool, using rng: inout G) {
    self.pool = pool
    characterSpeaks(after: nil, using: &rng)
  }

  public var isOver: Bool { outcome != nil }
  public var childWordCount: Int { turns.filter { $0.speaker == .child }.count }
  /// 最後にキャラクターが言ったことば。
  public var characterWord: String? { turns.last(where: { $0.speaker == .character })?.word }

  /// 子どもがことばを書き終えた。候補にあって鍵のないことばだけ受け取る（受け取れたら true）。
  /// 続けて、キャラクターが言う（言えなければ負けを認める。5語めなら、そこで終わる）。
  @discardableResult
  public mutating func childWrote<G: RandomNumberGenerator>(
    _ text: String, using rng: inout G
  ) -> Bool {
    guard outcome == nil, let card = cards.first(where: { $0.text == text && !$0.isLocked })
    else { return false }
    turns.append(Turn(speaker: .child, word: card.text))
    used.insert(card.text)
    cards = []
    if childWordCount >= Self.childWordLimit {
      outcome = .finished
    } else {
      characterSpeaks(after: card.tail, using: &rng)
    }
    return true
  }

  private mutating func characterSpeaks<G: RandomNumberGenerator>(
    after kana: Character?, using rng: inout G
  ) {
    var choices = pool.characterChoices(after: kana, excluding: used)
    // 子どもが続けやすいことば（続けられる候補が2枚以上できるもの）があれば、そちらを先に選ぶ。
    let lively = choices.filter {
      pool.continuableCards(after: $0, excluding: used) >= ShiritoriPool.minWritableCards
    }
    if !lively.isEmpty { choices = lively }
    guard let word = choices.randomElement(using: &rng) else {
      // 最初のことばが選べないのは、ことばがない異常なとき。まいったではなく、そっと終わる。
      outcome = kana == nil ? .finished : .characterGaveUp
      return
    }
    turns.append(Turn(speaker: .character, word: word.text))
    used.insert(word.text)
    cards = pool.childCards(after: word.tail, excluding: used, using: &rng)
    // 候補が出せないことは、キャラクターの選び方からは起きない。念のため行き止まりにしない。
    if cards.isEmpty { outcome = .finished }
  }
}
