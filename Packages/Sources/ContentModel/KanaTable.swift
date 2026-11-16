/// 文字の地図の並べ方（D101・D125・D146）。画面に頼らない。
/// 壁に貼る50音表と同じ向き。表は行が「あいうえお」の段（上から下）。
/// 列は「あ行」が一番右で、右から左へ「あかさたなはまやらわ」。つまり `cells[行][0]` が見た目の一番左（わ行）。
/// 字のない所は nil。
public enum KanaScript: String, Sendable, Hashable, CaseIterable {
  case hiragana
  case katakana

  /// 文字のデータの ID の頭（例: `hira`）。
  public var packPrefix: String {
    switch self {
    case .hiragana: "hira"
    case .katakana: "kata"
    }
  }
}

/// 字の並びの表。
public struct KanaGrid: Sendable, Hashable {
  /// `cells[行][列]`。
  public let cells: [[Character?]]

  public init(cells: [[Character?]]) { self.cells = cells }

  public var rowCount: Int { cells.count }
  public var columnCount: Int { cells.first?.count ?? 0 }
  /// 字がある所だけを、上の行から、左の列から右の列の順に並べる（見た目の順）。
  public var characters: [Character] { cells.flatMap { $0 }.compactMap { $0 } }

  /// 列の範囲だけを取り出す。
  public func columns(_ range: Range<Int>) -> KanaGrid {
    KanaGrid(cells: cells.map { Array($0[range]) })
  }

  /// 1段の表を、右から左へ読む向きのまま `perRow` 字ずつの段に折り返す（D146）。
  /// 先頭の字が右上。足りない所は左側が nil になる。
  public func wrappedRightToLeft(perRow: Int) -> KanaGrid {
    let logical = Array((cells.first ?? []).reversed())
    let rows = stride(from: 0, to: logical.count, by: perRow).map { start in
      let chunk = Array(logical[start..<min(start + perRow, logical.count)])
      return Array(repeating: nil, count: perRow - chunk.count) + Array(chunk.reversed())
    }
    return KanaGrid(cells: rows)
  }
}

public enum KanaTable {
  /// 50音表（10列×5段。あ行が右。D146）。や行は「い・え」、わ行は「い・え」が空き、「ん」はわ行の「う」の段に置く。
  public static func main(_ script: KanaScript) -> KanaGrid {
    let columns: [[Character?]] =
      switch script {
      case .hiragana:
        [
          ["あ", "い", "う", "え", "お"], ["か", "き", "く", "け", "こ"], ["さ", "し", "す", "せ", "そ"],
          ["た", "ち", "つ", "て", "と"], ["な", "に", "ぬ", "ね", "の"], ["は", "ひ", "ふ", "へ", "ほ"],
          ["ま", "み", "む", "め", "も"], ["や", nil, "ゆ", nil, "よ"], ["ら", "り", "る", "れ", "ろ"],
          ["わ", nil, "ん", nil, "を"],
        ]
      case .katakana:
        [
          ["ア", "イ", "ウ", "エ", "オ"], ["カ", "キ", "ク", "ケ", "コ"], ["サ", "シ", "ス", "セ", "ソ"],
          ["タ", "チ", "ツ", "テ", "ト"], ["ナ", "ニ", "ヌ", "ネ", "ノ"], ["ハ", "ヒ", "フ", "ヘ", "ホ"],
          ["マ", "ミ", "ム", "メ", "モ"], ["ヤ", nil, "ユ", nil, "ヨ"], ["ラ", "リ", "ル", "レ", "ロ"],
          ["ワ", nil, "ン", nil, "ヲ"],
        ]
      }
    return transposed(columns)
  }

  /// 「あ行〜な行」と「は行〜わ行」の2つに分けた表（D125。狭いとき）。
  /// 先に「あ行〜な行」。どちらも右から左の向き（D146）なので、あ行〜な行は表の右半分。
  public static func halves(_ script: KanaScript) -> [KanaGrid] {
    let table = main(script)
    return [table.columns(5..<10), table.columns(0..<5)]
  }

  /// 濁音・半濁音（5列×5段）。が行が右（D146）。
  public static func dakuon(_ script: KanaScript) -> KanaGrid {
    let columns: [[Character?]] =
      switch script {
      case .hiragana:
        [
          ["が", "ぎ", "ぐ", "げ", "ご"], ["ざ", "じ", "ず", "ぜ", "ぞ"], ["だ", "ぢ", "づ", "で", "ど"],
          ["ば", "び", "ぶ", "べ", "ぼ"], ["ぱ", "ぴ", "ぷ", "ぺ", "ぽ"],
        ]
      case .katakana:
        [
          ["ガ", "ギ", "グ", "ゲ", "ゴ"], ["ザ", "ジ", "ズ", "ゼ", "ゾ"], ["ダ", "ヂ", "ヅ", "デ", "ド"],
          ["バ", "ビ", "ブ", "ベ", "ボ"], ["パ", "ピ", "プ", "ペ", "ポ"],
        ]
      }
    return transposed(columns)
  }

  /// 小さい字（と、カタカナの「ヴ」「ー」）。1段に並べる。ぁが右で、右から左（D146）。
  public static func small(_ script: KanaScript) -> KanaGrid {
    switch script {
    case .hiragana:
      KanaGrid(cells: [["ぁ", "ぃ", "ぅ", "ぇ", "ぉ", "っ", "ゃ", "ゅ", "ょ"].reversed()])
    case .katakana:
      KanaGrid(cells: [["ァ", "ィ", "ゥ", "ェ", "ォ", "ッ", "ャ", "ュ", "ョ", "ヴ", "ー"].reversed()])
    }
  }

  /// 地図にのせる字ぜんぶ（50音表 → 濁音 → 小さい字の順）。
  public static func all(_ script: KanaScript) -> [Character] {
    main(script).characters + dakuon(script).characters + small(script).characters
  }

  /// 文字のデータの ID（例: そ → `hira.305d`）。
  public static func characterID(_ char: Character, script: KanaScript) -> String? {
    guard let scalar = char.unicodeScalars.first else { return nil }
    return "\(script.packPrefix).\(String(scalar.value, radix: 16))"
  }

  /// その字がどちらの文字か。
  public static func script(of char: Character) -> KanaScript? {
    KanaScript.allCases.first { all($0).contains(char) }
  }

  /// 行（あ行から順）を、あ行が右になるように並べて表にする。
  private static func transposed(_ columns: [[Character?]]) -> KanaGrid {
    let rows = columns.first?.count ?? 0
    return KanaGrid(cells: (0..<rows).map { row in columns.reversed().map { $0[row] } })
  }
}

/// 文字の地図の大きさの決め方（D125）。
public enum MapLayout {
  /// 字1つの押せる幅の最小。1.5cm はおよそ 78pt（iPad は 1pt が 1/132 インチ）。
  public static let minCell = 78.0
  /// 字の間。見た目は、押せる範囲の中に余白を取って広く見せる。
  public static let gap = 4.0
  /// 画面の両端の余白。
  public static let edge = 8.0
  public static let maxCell = 110.0

  public struct Decision: Sendable, Hashable {
    /// 2つに分けるか。
    public var split: Bool
    /// 字1つの幅。
    public var cell: Double
  }

  /// 幅に 50音表の10列が入るか。入らなければ5列ずつの2つに分ける。
  public static func decide(width: Double, columns: Int = 10) -> Decision {
    let full = fitted(width: width, columns: columns)
    if full >= minCell { return Decision(split: false, cell: min(full, maxCell)) }
    return Decision(
      split: true, cell: min(max(fitted(width: width, columns: columns / 2), minCell), maxCell))
  }

  private static func fitted(width: Double, columns: Int) -> Double {
    (width - 2 * edge - gap * Double(columns - 1)) / Double(columns)
  }
}
