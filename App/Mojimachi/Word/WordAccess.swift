import ContentModel
import EntitlementKit

/// ことばが書けるか・鍵がかかっているかの決まり（D7・D90・D93・D199）。
/// 決まりは `EntitlementKit` の `Entitlements`。ここは、ことばの字から文字の種類を決めて、つなぐだけ。
enum WordAccess {
  /// ことばの文字の種類（権利の決まり側。ひらがな・カタカナ・英語）。字がまざったことばは nil。
  static func script(of word: String) -> Script? {
    WordText.script(of: word)?.entitlementScript
  }

  /// そのことばが書けるか。ひらがなは いつも書ける。パックを持っているか、おためしのことば（バス・cat）なら書ける。
  static func canWrite(_ word: String, entitlements: Entitlements) -> Bool {
    guard let script = script(of: word) else { return true }
    return entitlements.canWrite(word: word, in: script)
  }

  /// 鍵がかかっているときの、鍵の画面に出す文字の種類。書けるなら nil。
  static func lockedScript(of word: String, entitlements: Entitlements) -> Script? {
    guard let script = script(of: word), !entitlements.canWrite(word: word, in: script) else {
      return nil
    }
    return script
  }

  /// この字を書いたとき、文字の地図のスタンプ（記録）を付けてよいか（D93）。
  /// おためしのことばの中だけで書いた字（バスの「バ」「ス」）には付けない。おためしの字には付ける。
  static func stamps(_ char: Character, entitlements: Entitlements) -> Bool {
    guard let script = KanaTable.script(of: char)?.entitlementScript else { return true }
    return entitlements.canWrite(char, in: script)
  }
}
