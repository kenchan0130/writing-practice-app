import ContentModel
import Foundation

extension Judge {
  /// ②なぞる・③うすく で、途中でペンを離した線の判定（D56 ③・D191）。
  /// 書き始めが合っていて、お手本のその画の「はじめの部分」と形が合うなら、続きから書ける。
  /// 返すのは、お手本の画のどこまで書けたか（0〜1）。当てはまらなければ nil。
  public func partialProgress(_ written: Polyline, expected index: Int, preset: JudgePreset)
    -> Double?
  {
    guard character.strokes.indices.contains(index), written.count > 1 else { return nil }
    let modelLine = Geometry.polyline(of: character.strokes[index], stepsPerSegment: 32)
    let modelLength = Geometry.length(of: modelLine)
    guard modelLine.count > 1, modelLength > 0 else { return nil }
    let writtenLength = Geometry.length(of: written)
    // 短すぎる線は、続きとして残さない（ぐるぐる・ちょん、は ふつうの書き直し）。
    guard writtenLength >= modelLength * Self.minPartialRatio else { return nil }
    let config = JudgeConfig.preset(preset)
    let tolerance = config.shapeTolerance * 1.4
    let deviationLimit = config.maxDeviation * 1.4
    // 書き始めがお手本の書き始めの近くであること。
    guard let first = written.first, first.distance(to: modelLine[0]) <= tolerance * 1.5 else {
      return nil
    }
    guard let last = written.last else { return nil }
    let resampled = Geometry.resample(written)
    // 輪のある字（の・あ・ね）では、書き終わりに近い場所が何か所もある。形が合うところを選ぶ。
    for fraction in Self.arcFractions(
      of: last, along: modelLine, total: modelLength, within: deviationLimit)
    where fraction >= Self.minPartialRatio && fraction < Self.maxPartialRatio {
      // 書いた線が、お手本のその部分より ずっと長いときは、ぐるぐる書きとして残さない。
      guard writtenLength <= modelLength * fraction * Self.maxLengthRatio else { continue }
      let prefix = Self.prefix(of: modelLine, fraction: fraction, total: modelLength)
      let shape = Geometry.shapeDifference(resampled, Geometry.resample(prefix))
      if shape.mean <= tolerance, shape.max <= deviationLimit { return fraction }
    }
    return nil
  }

  /// 続きの線を前の線につなげた線。つなげてよいときだけ返す（D191）。
  /// 続きの書き始めが、前の線の書き終わりの近く、または前の線の終わりの部分の上（少し戻って書き始めた）なら、つなげる。
  /// お手本の書き始めのほうが近いときは、書き直し（nil）。
  public func joined(
    _ partial: Polyline, with next: Polyline, expected index: Int
  ) -> Polyline? {
    guard let end = partial.last, let start = next.first,
      character.strokes.indices.contains(index),
      let modelStart = Geometry.polyline(of: character.strokes[index], stepsPerSegment: 1).first
    else { return nil }
    let toEnd = start.distance(to: end)
    // 書き始めからの書き直しは、つなげない。
    guard start.distance(to: modelStart) > min(toEnd, Self.joinDistance * 0.5) else { return nil }
    // 少し戻って書き始めた（前の線の終わりの部分に重なる）ときは、重なった分を切ってつなげる。
    let modelLength = Geometry.length(
      of: Geometry.polyline(of: character.strokes[index], stepsPerSegment: 16))
    if let cut = Self.cutIndex(of: partial, near: start, within: modelLength * Self.overlapRatio),
      cut < partial.count - 1, start.distance(to: partial[cut]) < toEnd
    {
      return Array(partial[...cut]) + next
    }
    guard toEnd <= Self.joinDistance else { return nil }
    return partial + next
  }

  /// 続きの線を、前の線につなげてよいか。
  public func continues(_ partial: Polyline, with next: Polyline, expected index: Int) -> Bool {
    joined(partial, with: next, expected: index) != nil
  }

  /// 続きとして残す線の、お手本の画に対する長さの下限（割合）。
  static let minPartialRatio = 0.2
  /// これ以上書けていれば、もう「途中」ではない（形が合わなければ書き直し）。
  static let maxPartialRatio = 0.92
  /// 書いた線の長さの上限（お手本のその部分の長さに対する倍率）。
  static let maxLengthRatio = 1.5
  /// 続きの書き始めと、前の線の書き終わりの許す距離（マス 0〜1000）。
  static let joinDistance = 130.0
  /// 少し戻って書き始めてよい長さ（お手本の画の長さに対する割合）。
  static let overlapRatio = 0.15
  /// 重なりを数えるときの、前の線の上からの距離（マス 0〜1000）。
  static let overlapTolerance = 60.0

  /// 前の線の終わりのほうで、点にいちばん近い頂点の番号（戻れる長さの範囲で、近さが許す範囲のとき）。
  static func cutIndex(of line: Polyline, near point: Point, within back: Double) -> Int? {
    var walked = 0.0
    var best: (index: Int, distance: Double)?
    var index = line.count - 1
    while index >= 0 {
      let distance = point.distance(to: line[index])
      if distance <= overlapTolerance, distance < (best?.distance ?? .infinity) {
        best = (index, distance)
      }
      if index > 0 { walked += line[index].distance(to: line[index - 1]) }
      if walked > back { break }
      index -= 1
    }
    return best?.index
  }

  /// 点に近いお手本上の位置（画の長さの何割か）。いちばん近い距離から 25 以内のものを、近い順に。
  /// `limit` より遠い点は、空。
  static func arcFractions(
    of point: Point, along line: Polyline, total: Double, within limit: Double
  ) -> [Double] {
    var walked = 0.0
    var samples: [(arc: Double, distance: Double)] = [(0, point.distance(to: line[0]))]
    for (a, b) in zip(line, line.dropFirst()) {
      walked += a.distance(to: b)
      samples.append((walked, point.distance(to: b)))
    }
    guard let best = samples.map(\.distance).min(), best <= limit else { return [] }
    var result: [Double] = []
    for sample in samples.sorted(by: { $0.distance < $1.distance })
    where sample.distance <= best + 25 {
      let fraction = sample.arc / total
      if !result.contains(where: { abs($0 - fraction) < 0.03 }) { result.append(fraction) }
    }
    return result
  }

  /// お手本の線の、はじめから `fraction`（0〜1）のところまで。
  static func prefix(of line: Polyline, fraction: Double, total: Double) -> Polyline {
    let target = total * fraction
    var result = [line[0]]
    var walked = 0.0
    for (a, b) in zip(line, line.dropFirst()) {
      let segment = a.distance(to: b)
      if walked + segment >= target {
        let t = segment > 0 ? (target - walked) / segment : 0
        result.append(a + (b - a) * t)
        return result
      }
      result.append(b)
      walked += segment
    }
    return result
  }
}
