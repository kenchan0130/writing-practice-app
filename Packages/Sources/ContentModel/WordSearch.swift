/// 「もじから さがす」（D35・D45・D181）。押した字で始まることばを探す。画面に頼らない。
public enum WordSearch {
  /// 字をそろえる: カタカナはひらがなにする（音で探す。バスは「ば」）。英字は小文字にする（D199）。
  /// 濁音・小さい字はそのまま。
  /// 「が」で始まることばは「か」では出さず、「ゃ」のような小さい字で始まることばはない。
  public static func normalize(_ char: Character) -> Character {
    if char.isASCII, char.isLetter { return Character(char.lowercased()) }
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

  /// 探した結果の1つ。
  public struct Result: Sendable, Hashable {
    public let word: String
    /// 鍵のことば（影絵で見せる。押すと「おねがい」）。
    public let isLocked: Bool
  }

  /// 鍵のことばを、結果に出す数の上限（D93）。
  public static let maxLockedResults = 2

  /// 結果を並べる（D93）: 開いていることばを先に（`candidates` の順のまま）、鍵のことばはそのあとに、
  /// 上限（既定は2枚）まで。ことばを買ったあとは、鍵がないので全部出る。
  public static func results(
    startingWith char: Character, among candidates: [String], isLocked: (String) -> Bool,
    maxLocked: Int = maxLockedResults
  ) -> [Result] {
    arranged(words(startingWith: char, among: candidates), isLocked: isLocked, maxLocked: maxLocked)
  }

  /// 開いていることばを先に、鍵のことばをあとに（上限まで）並べる（字のカードの「この もじの ことば」にも使う）。
  public static func arranged(
    _ words: [String], isLocked: (String) -> Bool, maxLocked: Int = maxLockedResults
  ) -> [Result] {
    let open = words.filter { !isLocked($0) }
    let locked = words.filter(isLocked).prefix(maxLocked)
    return open.map { Result(word: $0, isLocked: false) }
      + locked.map { Result(word: $0, isLocked: true) }
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
