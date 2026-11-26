/// 種から同じ並びを出す乱数（SplitMix64）。テストと「きょうの ことば」の毎日の選び方に使う。
/// Swift 標準の `hashValue` は起動のたびに変わるので、決まった結果がほしいときはこちらを使う。
public struct SeededGenerator: RandomNumberGenerator, Sendable, Equatable {
  private var state: UInt64

  public init(seed: UInt64) { state = seed }

  public mutating func next() -> UInt64 {
    state = state &+ 0x9E37_79B9_7F4A_7C15
    var z = state
    z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
    z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
    return z ^ (z >> 31)
  }

  /// 文字から決まる種（FNV-1a）。起動しても、どの OS でも同じ値になる。
  public static func seed(from text: String) -> UInt64 {
    var hash: UInt64 = 0xCBF2_9CE4_8422_2325
    for byte in text.utf8 {
      hash ^= UInt64(byte)
      hash = hash &* 0x0000_0100_0000_01B3
    }
    return hash
  }
}
