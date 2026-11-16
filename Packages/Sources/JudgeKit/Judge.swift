import ContentModel
import Foundation

/// おまかせ設定の4段階（D22）。
public enum JudgePreset: String, Sendable, CaseIterable, Codable {
  case hajimete
  case naretekita
  case shikkari
  case kicchiri
}

/// 判定のしきい値（D107 ⑥）。値は M0 で正解の付いた線のセット（D79・D120）から合わせる。
public struct JudgeConfig: Sendable, Hashable, Codable {
  /// 1画の形の違い（点どうしの平均の距離。マス 0〜1000）がこれ以下なら合格。
  public var shapeTolerance: Double
  /// 書き順を見るか（D22）。
  public var checksOrder: Bool
  /// 向きを見るか（D22）。
  public var checksDirection: Bool
  /// 鏡の字を見るか（D22）。
  public var checksMirror: Bool

  public init(
    shapeTolerance: Double, checksOrder: Bool = true, checksDirection: Bool = true,
    checksMirror: Bool = true
  ) {
    self.shapeTolerance = shapeTolerance
    self.checksOrder = checksOrder
    self.checksDirection = checksDirection
    self.checksMirror = checksMirror
  }

  /// 仮の値。M0 で合わせる。
  public static func preset(_ preset: JudgePreset) -> JudgeConfig {
    switch preset {
    case .hajimete: JudgeConfig(shapeTolerance: 150)
    case .naretekita: JudgeConfig(shapeTolerance: 120)
    case .shikkari: JudgeConfig(shapeTolerance: 95)
    case .kicchiri: JudgeConfig(shapeTolerance: 75)
    }
  }

  /// 1つ上の設定（はなまるの判定に使う。D107）。いちばん上は自分。
  public static func stricter(than preset: JudgePreset) -> JudgeConfig {
    switch preset {
    case .hajimete: .preset(.naretekita)
    case .naretekita: .preset(.shikkari)
    case .shikkari, .kicchiri: .preset(.kicchiri)
    }
  }
}

/// ほめ方の3段階（D107 ⑥）。
public enum Rating: String, Sendable, Codable {
  /// 合格（または行き止まりにしないための救済。D46）。
  case maru
  /// 余裕を持って合格。
  case nijumaru
  /// 1つ上の設定でも合格。
  case hanamaru
}

/// 違っていたところ。画の番号は 0 から（お手本の画の番号）。
public enum JudgeIssue: Sendable, Hashable, Codable {
  case strokeCount(expected: Int, actual: Int)
  /// 書いた画 `written` 番目が、お手本の `model` 番目に当たった（順番が違う）。
  case order(written: Int, model: Int)
  case direction(model: Int)
  case mirrored
  case shape(model: Int, distance: Double)
}

public struct JudgeResult: Sendable, Hashable {
  public var passed: Bool
  public var rating: Rating?
  public var issues: [JudgeIssue]
  /// 画ごとの形の違い（お手本の画の順）。
  public var shapeDistances: [Double]
}

/// 判定（D107）。画面や端末に頼らない（D104）。
public struct Judge: Sendable {
  public var character: CharacterData
  private let model: [Polyline]

  public init(character: CharacterData) {
    self.character = character
    self.model = character.strokes.map { Geometry.resample(Geometry.polyline(of: $0)) }
  }

  /// ④じぶんで の判定。字全体の位置と大きさをお手本に合わせてから比べる。
  public func judge(written: [Polyline], preset: JudgePreset) -> JudgeResult {
    let config = JudgeConfig.preset(preset)
    let resampled = written.map { Geometry.resample($0) }
    let aligned = Geometry.align(resampled, to: model)
    var result = evaluate(aligned, config: config)
    guard result.passed else { return result }
    let stricter = evaluate(aligned, config: .stricter(than: preset))
    let maxDistance = result.shapeDistances.max() ?? 0
    if stricter.passed, preset != .kicchiri || maxDistance <= config.shapeTolerance * 0.6 {
      result.rating = .hanamaru
    } else if maxDistance <= config.shapeTolerance * 0.7 {
      result.rating = .nijumaru
    } else {
      result.rating = .maru
    }
    return result
  }

  func evaluate(_ written: [Polyline], config: JudgeConfig) -> JudgeResult {
    var issues: [JudgeIssue] = []
    guard written.count == model.count else {
      issues.append(.strokeCount(expected: model.count, actual: written.count))
      return JudgeResult(passed: false, rating: nil, issues: issues, shapeDistances: [])
    }
    // 鏡の字: 左右を反転したほうが、はっきりよく合う（左右対称に近い字は対象外。D107 ④）。
    if config.checksMirror, character.mirrorCheck ?? true {
      let normal = totalDistance(written, assignment: Array(model.indices))
      let flipped = totalDistance(
        Geometry.align(Geometry.mirrored(written), to: model), assignment: Array(model.indices))
      if flipped < normal * 0.6 {
        issues.append(.mirrored)
        return JudgeResult(passed: false, rating: nil, issues: issues, shapeDistances: [])
      }
    }
    // 書き順を気にせず、いちばん合う当て方を探す（D107 ③④）。
    let assignment = bestAssignment(written)
    var distances = Array(repeating: 0.0, count: model.count)
    for (w, m) in assignment.enumerated() {
      if config.checksOrder, w != m { issues.append(.order(written: w, model: m)) }
      let forward = Geometry.meanDistance(written[w], model[m])
      let backward = Geometry.meanDistance(written[w].reversed(), model[m])
      if config.checksDirection, backward < forward * 0.6 {
        issues.append(.direction(model: m))
      }
      let distance = min(forward, backward)
      distances[m] = distance
      if distance > config.shapeTolerance { issues.append(.shape(model: m, distance: distance)) }
    }
    return JudgeResult(
      passed: issues.isEmpty, rating: nil, issues: issues, shapeDistances: distances)
  }

  private func totalDistance(_ written: [Polyline], assignment: [Int]) -> Double {
    zip(written, assignment).reduce(0) { total, pair in
      let line = pair.0
      let m = model[pair.1]
      return total + min(Geometry.meanDistance(line, m), Geometry.meanDistance(line.reversed(), m))
    }
  }

  /// 書いた画とお手本の画の1対1の当て方のうち、形の違いの合計がいちばん小さいもの。
  /// 画数は多くても 7 程度なので、すべての並べ方を比べる。
  private func bestAssignment(_ written: [Polyline]) -> [Int] {
    let n = written.count
    var cost = Array(repeating: Array(repeating: 0.0, count: n), count: n)
    for w in 0..<n {
      for m in 0..<n {
        cost[w][m] = min(
          Geometry.meanDistance(written[w], model[m]),
          Geometry.meanDistance(written[w].reversed(), model[m]))
      }
    }
    var best = Array(0..<n)
    var bestCost = Double.infinity
    var current = Array(0..<n)
    func permute(_ k: Int) {
      if k == n {
        let total = (0..<n).reduce(0) { $0 + cost[$1][current[$1]] }
        // 合計が同じなら、お手本の順に近いほうを選ぶ。
        if total < bestCost - 1e-9 {
          bestCost = total
          best = current
        }
        return
      }
      for i in k..<n {
        current.swapAt(k, i)
        permute(k + 1)
        current.swapAt(k, i)
      }
    }
    permute(0)
    return best
  }
}
