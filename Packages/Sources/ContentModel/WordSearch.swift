/// 「もじから さがす」（D35・D45・D181）。押した字で始まることばを探す。画面に頼らない。
public enum WordSearch {
  /// 字をそろえる: カタカナはひらがなにする（ことばはひらがなで持つ）。濁音・小さい字はそのまま。
  /// 「が」で始まることばは「か」では出さず、「ゃ」のような小さい字で始まることばはない。
  public static func normalize(_ char: Character) -> Character {
    guard let scalar = char.unicodeScalars.first, char.unicodeScalars.count == 1,
      (0x30A1...0x30F6).contains(scalar.value),
      let folded = Unicode.Scalar(scalar.value - 0x60)
    else { return char }
    return Character(folded)
  }

  /// ことばの最初の字（そろえたもの）。
  public static func initial(of word: String) -> Character? {
    word.first.map(normalize)
  }

  /// `candidates` のうち、`char` で始まることば。順は `candidates` のまま。
  public static func words(startingWith char: Character, among candidates: [String]) -> [String] {
    let target = normalize(char)
    return candidates.filter { initial(of: $0) == target }
  }

  /// その字で始まることばがないと、言葉の決まりで分かっている字（「ん」・「を」）。
  public enum Rule: Sendable, Hashable {
    /// 「ん」で始まることばはない。
    case n
    /// 「を」は ことばの はじめに使わない（「を」は つなぐ字）。
    case wo
  }

  public static func rule(for char: Character) -> Rule? {
    switch normalize(char) {
    case "ん": .n
    case "を": .wo
    default: nil
    }
  }
}
