import ContentModel
import Foundation

/// 書いた画の終わり方（とめ・はね・はらい）を見る（D107 ⑤・D145）。合否には使わず、ヒントとほめ方にだけ使う。
public enum EndingAnalysis {
  /// 書いた画の終わり方を見分ける。はっきりしないときは nil（ヒントを出さない）。
  /// - Parameters:
  ///   - line: 書いた線（マス 0〜1000）。
  ///   - times: 各点の時刻（秒）。`line` と同じ数。
  public static func classify(_ line: Polyline, times: [Double]) -> CharacterData.Ending? {
    guard line.count >= 6, times.count == line.count else { return nil }
    var lengths: [Double] = [0]
    for (a, b) in zip(line, line.dropFirst()) { lengths.append(lengths.last! + a.distance(to: b)) }
    let total = lengths.last!
    guard total > 40 else { return nil }
    func index(at ratio: Double) -> Int {
      lengths.firstIndex { $0 >= total * ratio } ?? line.count - 1
    }

    // はね: 終わり近くで、向きが急に変わる（D107 ⑤ の「向き」）。
    let bodyStart = line[index(at: 0.7)]
    let bend = line[index(at: 0.9)]
    let tip = line[line.count - 1]
    let hookLength = bend.distance(to: tip)
    if hookLength >= 15, turnAngle(bodyStart, bend, tip) > 70 { return .hane }

    // とめ・はらい: 終わり約15% の速さを、なかほどの速さと比べる（D107 ⑤ の「速さ」）。
    let mid = speed(from: index(at: 0.3), to: index(at: 0.7), lengths: lengths, times: times)
    let tail = speed(from: index(at: 0.85), to: line.count - 1, lengths: lengths, times: times)
    guard let mid, let tail, mid > 0 else { return nil }
    let ratio = tail / mid
    if ratio >= 0.75 { return .harai }
    if ratio <= 0.45 { return .tome }
    return nil
  }

  /// お手本と違う終わり方の、最初の画の番号。ヒントを出す画がなければ nil。
  /// お手本の終わり方が決まっていない画と、見分けられなかった画は見ない。
  public static func hintStroke(model: [CharacterData.Ending?], written: [CharacterData.Ending?])
    -> Int?
  {
    guard model.count == written.count else { return nil }
    return zip(model, written).enumerated().first { _, pair in
      guard let expected = pair.0, let actual = pair.1 else { return false }
      return expected != actual
    }?.offset
  }

  /// お手本の終わり方が決まっている画が、すべてお手本どおりか（はなまるの条件の1つ。D145）。
  public static func allMatch(model: [CharacterData.Ending?], written: [CharacterData.Ending?])
    -> Bool
  {
    guard model.count == written.count, model.contains(where: { $0 != nil }) else { return false }
    return zip(model, written).allSatisfy { expected, actual in
      expected == nil || expected == actual
    }
  }

  private static func speed(from a: Int, to b: Int, lengths: [Double], times: [Double]) -> Double? {
    guard b > a else { return nil }
    let dt = times[b] - times[a]
    guard dt > 0 else { return nil }
    return (lengths[b] - lengths[a]) / dt
  }

  /// a→b と b→c の向きの違い（度）。
  private static func turnAngle(_ a: Point, _ b: Point, _ c: Point) -> Double {
    let v1 = (b.x - a.x, b.y - a.y)
    let v2 = (c.x - b.x, c.y - b.y)
    let n1 = (v1.0 * v1.0 + v1.1 * v1.1).squareRoot()
    let n2 = (v2.0 * v2.0 + v2.1 * v2.1).squareRoot()
    guard n1 > 0, n2 > 0 else { return 0 }
    let cosine = max(-1, min(1, (v1.0 * v2.0 + v1.1 * v2.1) / (n1 * n2)))
    return acos(cosine) * 180 / .pi
  }
}
