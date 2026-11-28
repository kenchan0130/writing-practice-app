import Foundation

/// すうじ あそび（D45・D67・D199）。文字の地図のすうじのページで、数字の1〜9を書けたら、
/// その数のりんごを、まちの かごに見せる。
/// 空のことば（`SkyWeather`）と同じく、物としては置かない。書いた記録から「いちばん新しく書いた数字」を決めるだけ。
/// 画面や端末に頼らない。
public enum NumberPlay {
  /// まちに出すりんごの数の上限（9）。
  public static let maxApples = 9

  /// その字を書けたときの、りんごの数。1〜9 はその数、0 は 0（ゼロは「ない」ので、出さない）、
  /// 数字でない字も 0。子どもの画面にエラーは出さない（D117）ので、0 のときは何もしないだけ。
  public static func apples(for char: Character) -> Int {
    guard char.isASCII, let value = char.wholeNumberValue else { return 0 }
    return min(max(value, 0), maxApples)
  }

  /// まちに置くことば（絵は「りんご」。D199）。
  public static let appleWord = "りんご"

  /// 学習記録の字の行（`CharacterRecord`）のうち、数字に要る部分。
  public struct WriteRecord: Sendable, Hashable {
    public let characterID: String
    public let date: Date
    public let passed: Bool
    public let rescued: Bool

    public init(characterID: String, date: Date, passed: Bool, rescued: Bool) {
      self.characterID = characterID
      self.date = date
      self.passed = passed
      self.rescued = rescued
    }
  }

  /// 字のデータの ID（例: `abc.33`）から、数字の字。数字でなければ nil。
  public static func digit(fromCharacterID id: String) -> Character? {
    let parts = id.split(separator: ".")
    guard parts.count == 2, parts[0] == "abc", let code = UInt32(parts[1], radix: 16),
      (0x30...0x39).contains(code), let scalar = Unicode.Scalar(code)
    else { return nil }
    return Character(scalar)
  }

  /// いまの かごの りんごの数。書けた数字（合格して、助けなしで書けたもの）のうち、あそべるもの
  /// （`canPlay`。おためしでは「1」だけ）で、いちばん新しく書いたものの数。なければ 0。
  /// 書けなかった数字・助けて進んだ数字・あそべない数字は、数を変えない。
  public static func appleCount(
    in records: [WriteRecord], canPlay: (Character) -> Bool = { _ in true }
  ) -> Int {
    let latest =
      records
      .filter { $0.passed && !$0.rescued }
      .compactMap { record in digit(fromCharacterID: record.characterID).map { (record.date, $0) } }
      .filter { canPlay($0.1) }
      .max { $0.0 < $1.0 }
    return latest.map { apples(for: $0.1) } ?? 0
  }
}
