/// 小学校の教科書の画数（D66。KanjiVG と教科書で確かめる表の土台）。
/// 濁音は元の字に2画、半濁音は1画を足す。小さい字は元の字と同じ。
public enum StrokeCounts {
  public static let hiraganaBase: [Character: Int] = [
    "あ": 3, "い": 2, "う": 2, "え": 2, "お": 3,
    "か": 3, "き": 4, "く": 1, "け": 3, "こ": 2,
    "さ": 3, "し": 1, "す": 2, "せ": 3, "そ": 1,
    "た": 4, "ち": 2, "つ": 1, "て": 1, "と": 2,
    "な": 4, "に": 3, "ぬ": 2, "ね": 2, "の": 1,
    "は": 3, "ひ": 1, "ふ": 4, "へ": 1, "ほ": 4,
    "ま": 3, "み": 2, "む": 3, "め": 2, "も": 3,
    "や": 3, "ゆ": 2, "よ": 2,
    "ら": 2, "り": 2, "る": 1, "れ": 2, "ろ": 1,
    "わ": 2, "を": 3, "ん": 1,
  ]

  private static let dakuten: [Character: Character] = [
    "が": "か", "ぎ": "き", "ぐ": "く", "げ": "け", "ご": "こ",
    "ざ": "さ", "じ": "し", "ず": "す", "ぜ": "せ", "ぞ": "そ",
    "だ": "た", "ぢ": "ち", "づ": "つ", "で": "て", "ど": "と",
    "ば": "は", "び": "ひ", "ぶ": "ふ", "べ": "へ", "ぼ": "ほ",
  ]

  private static let handakuten: [Character: Character] = [
    "ぱ": "は", "ぴ": "ひ", "ぷ": "ふ", "ぺ": "へ", "ぽ": "ほ",
  ]

  private static let small: [Character: Character] = [
    "ぁ": "あ", "ぃ": "い", "ぅ": "う", "ぇ": "え", "ぉ": "お",
    "っ": "つ", "ゃ": "や", "ゅ": "ゆ", "ょ": "よ",
  ]

  public static let katakanaBase: [Character: Int] = [
    "ア": 2, "イ": 2, "ウ": 3, "エ": 3, "オ": 3,
    "カ": 2, "キ": 3, "ク": 2, "ケ": 3, "コ": 2,
    "サ": 3, "シ": 3, "ス": 2, "セ": 2, "ソ": 2,
    "タ": 3, "チ": 3, "ツ": 3, "テ": 3, "ト": 2,
    "ナ": 2, "ニ": 2, "ヌ": 2, "ネ": 4, "ノ": 1,
    "ハ": 2, "ヒ": 2, "フ": 1, "ヘ": 1, "ホ": 4,
    "マ": 2, "ミ": 3, "ム": 2, "メ": 2, "モ": 3,
    "ヤ": 2, "ユ": 2, "ヨ": 3,
    "ラ": 2, "リ": 2, "ル": 2, "レ": 1, "ロ": 3,
    "ワ": 2, "ヲ": 3, "ン": 2, "ー": 1,
  ]

  /// カタカナの画数。濁音は元の字に2画、半濁音は1画を足す。小さい字は元の字と同じ。
  public static func katakana(_ char: Character) -> Int? {
    if let count = katakanaBase[char] { return count }
    if char == "ヴ", let count = katakanaBase["ウ"] { return count + 2 }
    // カタカナとひらがなは同じ並びなので、ひらがなの表で元の字を探し、カタカナに戻して数える。
    guard let hira = shift(char, by: -0x60) else { return nil }
    if let base = dakuten[hira], let kata = shift(base, by: 0x60), let count = katakanaBase[kata] {
      return count + 2
    }
    if let base = handakuten[hira], let kata = shift(base, by: 0x60),
      let count = katakanaBase[kata]
    {
      return count + 1
    }
    if let base = small[hira], let kata = shift(base, by: 0x60), let count = katakanaBase[kata] {
      return count
    }
    return nil
  }

  private static func shift(_ char: Character, by offset: Int) -> Character? {
    guard char.unicodeScalars.count == 1, let scalar = char.unicodeScalars.first,
      let shifted = Unicode.Scalar(UInt32(Int(scalar.value) + offset))
    else { return nil }
    return Character(shifted)
  }

  /// ひらがなの画数。表にない字は nil。
  public static func hiragana(_ char: Character) -> Int? {
    if let count = hiraganaBase[char] { return count }
    if let base = dakuten[char], let count = hiraganaBase[base] { return count + 2 }
    if let base = handakuten[char], let count = hiraganaBase[base] { return count + 1 }
    if let base = small[char], let count = hiraganaBase[base] { return count }
    return nil
  }
}
