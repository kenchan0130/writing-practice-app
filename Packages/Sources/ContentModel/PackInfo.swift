/// パックの情報（D106。`Content/Packs/<パック>/pack.json`）。
/// いまはアルファベットと数字のパック（D180）だけが持つ。
public struct PackInfo: Sendable, Hashable, Codable {
  public var schema: Int
  /// パックの ID（変えない。D114）。
  public var id: String
  public var version: Int
  /// 文字の種類（`KanaScript` の名前）。
  public var script: String
  /// このパックを開く商品の ID。
  public var product: String
  public var trial: Trial
  /// 声の方式（`prebuilt` は、前もって作った声をアプリに入れる。D27）。
  public var voice: String
  /// おすすめ順（§4.1）。1つの文字列が1つの段階。
  public var order: [String]
  /// 形が似ていて、まちがえやすい字の組。同じ段階に置かない。
  public var similar: [[String]]

  /// おためし（D94）。公開後は減らさない。
  public struct Trial: Sendable, Hashable, Codable {
    public var characters: [String]
    public var word: String?
  }
}

extension PackInfo {
  /// 決まりに合わないところを返す（`content-check` で使う）。`characters` はパックにある字。
  public func problems(characters: [Character]) -> [String] {
    var result: [String] = []
    let ordered = order.flatMap { Array($0) }
    if ordered.count != Set(ordered).count { result.append("おすすめ順に同じ字が2回ある") }
    let missing = Set(characters).subtracting(ordered)
    if !missing.isEmpty { result.append("おすすめ順にない字: \(String(missing.sorted()))") }
    let extra = Set(ordered).subtracting(characters)
    if !extra.isEmpty { result.append("おすすめ順に、パックにない字がある: \(String(extra.sorted()))") }
    for char in trial.characters where !characters.contains(where: { String($0) == char }) {
      result.append("おためしの字 \(char) がパックにない")
    }
    for group in similar {
      for char in group where !characters.contains(where: { String($0) == char }) {
        result.append("似た字 \(char) がパックにない")
      }
      for stage in order where group.filter({ stage.contains($0) }).count > 1 {
        result.append("似た字 \(group.joined(separator: "・")) が同じ段階（\(stage)）にある")
      }
    }
    return result
  }
}
