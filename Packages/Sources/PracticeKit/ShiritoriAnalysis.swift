import ContentModel

/// しりとりのことばの調べ（D70）。字ごとに、始まることばの数と行き止まりを出す。
/// `make shiritori-report` が表にする。ことばを足したときに、薄い字を見つけるために使う。
public enum ShiritoriAnalysis {
  public struct Row: Sendable, Hashable {
    public let kana: Character
    /// この字で始まることばの数（「ん」で終わるものも数える）。
    public let startCount: Int
    /// そのうち、しりとりで使えるもの（「ん」で終わらず、鍵がない）。
    public let usableStartCount: Int
    /// この字で終わることばの数。
    public let endCount: Int
    /// 子どもがこの字で終わることばを書くと、キャラクターが続けられない（回のはじめの状態で。D70）。
    public let isDeadEnd: Bool
  }

  /// ことばの最初か最後に出てくる字の表。五十音の順。
  public static func rows(for pool: ShiritoriPool) -> [Row] {
    let heads = Set(pool.words.map(\.head))
    let tails = Set(pool.words.map(\.tail))
    return heads.union(tails).sorted().map { kana in
      Row(
        kana: kana,
        startCount: pool.words.filter { $0.head == kana }.count,
        usableStartCount: pool.words.filter { $0.head == kana && !$0.endsWithN && !$0.isLocked }
          .count,
        endCount: pool.words.filter { $0.tail == kana }.count,
        isDeadEnd: pool.characterChoices(after: kana, excluding: []).isEmpty)
    }
  }

  /// 子どもがことばを書いて、その字で終わったとき、キャラクターが続けられない字（ことばの終わりに出てくるもの）。
  public static func deadEnds(for pool: ShiritoriPool) -> [Character] {
    rows(for: pool).filter { $0.isDeadEnd && $0.endCount > 0 }.map(\.kana)
  }

  /// 自動で何回も遊んだ結果。
  public struct Simulation: Sendable, Equatable {
    public var rounds = 0
    /// キャラクターが「まいった」になった回。
    public var gaveUp = 0
    /// 5語まで書いて終わった回（ことばが足りなくなった回も含む）。
    public var finished = 0
    /// 子どもが書いたことばの数の合計。
    public var childWords = 0
  }

  /// 子どもが候補からでたらめに選ぶしりとりを `rounds` 回、自動で遊ぶ（D70）。
  public static func simulate(pool: ShiritoriPool, rounds: Int, seed: UInt64) -> Simulation {
    var rng = SeededGenerator(seed: seed)
    var result = Simulation()
    for _ in 0..<rounds {
      var round = ShiritoriRound(pool: pool, using: &rng)
      while !round.isOver {
        guard let card = round.cards.filter({ !$0.isLocked }).randomElement(using: &rng),
          round.childWrote(card.text, using: &rng)
        else { break }
      }
      result.rounds += 1
      result.childWords += round.childWordCount
      if round.outcome == .characterGaveUp { result.gaveUp += 1 } else { result.finished += 1 }
    }
    return result
  }
}
