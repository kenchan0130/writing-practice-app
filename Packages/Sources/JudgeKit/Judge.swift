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
  /// 1画の中でいちばん離れた点の距離がこれ以下なら合格（ゆがみ・途中で止めた画を見つける）。
  public var maxDeviation: Double
  /// 書き順を見るか（D22）。
  public var checksOrder: Bool
  /// 向きを見るか（D22）。
  public var checksDirection: Bool
  /// 鏡の字を見るか（D22）。
  public var checksMirror: Bool
  /// 1画を分けて書いた線・2画をつなげた線を合格にするか（D56・D84）。
  public var allowsSplitAndJoin: Bool
  /// 字全体が斜めに傾いても許す角度（度）。0 なら傾きは許さない（D192）。
  public var rotationTolerance: Double

  public init(
    shapeTolerance: Double, maxDeviation: Double? = nil, checksOrder: Bool = true,
    checksDirection: Bool = true, checksMirror: Bool = true, allowsSplitAndJoin: Bool = true,
    rotationTolerance: Double = 0
  ) {
    self.shapeTolerance = shapeTolerance
    self.maxDeviation = maxDeviation ?? shapeTolerance * 1.7
    self.checksOrder = checksOrder
    self.checksDirection = checksDirection
    self.checksMirror = checksMirror
    self.allowsSplitAndJoin = allowsSplitAndJoin
    self.rotationTolerance = rotationTolerance
  }

  /// わざと崩した線（`make judge-report`）で合わせた仮の値。M0 で正解の付いた線（D79・D120）で合わせ直す。
  public static func preset(_ preset: JudgePreset) -> JudgeConfig {
    switch preset {
    case .hajimete: JudgeConfig(shapeTolerance: 70, maxDeviation: 125, rotationTolerance: 12)
    case .naretekita: JudgeConfig(shapeTolerance: 55, maxDeviation: 105, rotationTolerance: 6)
    case .shikkari: JudgeConfig(shapeTolerance: 45, maxDeviation: 90, allowsSplitAndJoin: false)
    case .kicchiri: JudgeConfig(shapeTolerance: 35, maxDeviation: 75, allowsSplitAndJoin: false)
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
  /// 画の一部が大きく離れている（ゆがみ・途中で止めた画など）。
  case deviation(model: Int, distance: Double)
}

public struct JudgeResult: Sendable, Hashable {
  public var passed: Bool
  public var rating: Rating?
  public var issues: [JudgeIssue]
  /// 画ごとの形の違い（お手本の画の順）。
  public var shapeDistances: [Double]
  /// 画ごとのいちばん離れた点の距離（お手本の画の順）。
  public var maxDistances: [Double] = []
  /// 1画を分けて書いた線、または2画をつなげた線として読みとったか（D77）。
  public var splitOrJoined = false
  /// お手本とは別の、正解にする書き方（書き順や画数がちがう。D66）で合格したか。
  public var usedAlternate = false
  /// 書いた画（書いた順）が、お手本のどの画に当たったか（D195）。画数が合ったときだけ入る。
  public var assignment: [Int] = []
}

/// 不合格のとき、子どもに見せる「どの画がちがったか」（D195）。純粋なデータ。
public struct JudgeFeedback: Sendable, Hashable {
  public enum Kind: Sendable, Hashable {
    /// 書く順番がちがう。
    case order
    /// 向きがぎゃく。
    case direction
    /// 形がちがう（ずれ・途中で止めた画も含む）。
    case shape
    /// 画が足りない。
    case missingStroke
    /// 画が多い。
    case extraStroke
    /// 鏡の字。
    case mirrored
  }

  public var kind: Kind
  /// 色をつける、子どもが書いた画の番号（0 から）。見つけられないときは nil。
  public var writtenStroke: Int?
  /// 正しい書き方を動かして見せる、お手本の画の番号（0 から）。
  public var modelStroke: Int?

  public init(kind: Kind, writtenStroke: Int?, modelStroke: Int?) {
    self.kind = kind
    self.writtenStroke = writtenStroke
    self.modelStroke = modelStroke
  }

  /// 結果から、いちばん前の（書き順で最初の）ちがう画を選ぶ。合格のときや理由がないときは nil。
  /// - Parameters:
  ///   - writtenCount: 子どもが書いた画の数。
  ///   - modelCount: お手本の画の数。
  public init?(result: JudgeResult, writtenCount: Int, modelCount: Int) {
    guard !result.passed, modelCount > 0 else { return nil }
    // 画数がちがう（分けた線・つなげた線の読みとりに失敗したときも含む）。
    if result.issues.contains(where: {
      if case .strokeCount = $0 { true } else { false }
    }) {
      if writtenCount > modelCount {
        self.init(kind: .extraStroke, writtenStroke: modelCount, modelStroke: nil)
      } else {
        self.init(
          kind: .missingStroke, writtenStroke: nil, modelStroke: min(writtenCount, modelCount - 1))
      }
      return
    }
    if result.issues.contains(.mirrored) {
      self.init(kind: .mirrored, writtenStroke: nil, modelStroke: 0)
      return
    }
    // 書いた画の番号 → お手本の画の番号（分けた線・つなげた線をまとめ直したときは、書いた画に戻せない）。
    let usable = !result.splitOrJoined && result.assignment.count == writtenCount
    var best: JudgeFeedback?
    func consider(_ candidate: JudgeFeedback, at written: Int) {
      if best == nil || written < (best?.writtenStroke ?? Int.max) { best = candidate }
    }
    for issue in result.issues {
      switch issue {
      case .order(let written, _):
        // 「この順番で書く画」は、お手本の written 番目。
        consider(
          JudgeFeedback(kind: .order, writtenStroke: usable ? written : nil, modelStroke: written),
          at: written)
      case .direction(let model):
        let w = usable ? result.assignment.firstIndex(of: model) : nil
        consider(
          JudgeFeedback(kind: .direction, writtenStroke: w, modelStroke: model), at: w ?? model)
      case .shape(let model, _), .deviation(let model, _):
        let w = usable ? result.assignment.firstIndex(of: model) : nil
        consider(
          JudgeFeedback(kind: .shape, writtenStroke: w, modelStroke: model), at: w ?? model)
      case .strokeCount, .mirrored:
        break
      }
    }
    guard let best else { return nil }
    self = best
  }
}

/// ②③の1画ずつの判定の結果（D47）。
public enum StrokeCheck: Sendable, Hashable {
  case ok
  /// 書くべき画ではない画を書いた（書き順のまちがい）。
  case wrongStroke
  case direction
  case shape
}

/// 判定（D107）。画面や端末に頼らない（D104）。
public struct Judge: Sendable {
  public let character: CharacterData
  private let model: [Polyline]
  /// 置き直す前のお手本の線（画の長さを見るため）。
  private let modelRaw: [Polyline]
  /// お手本の字の大きさに合わせた、しきい値の倍率（D192）。
  private let sizeScale: Double
  /// お手本とは別の、正解にする書き方（D66）。書き順の入れ替え（`orders` の2つ目から）と、
  /// 画数や画の分け方がちがう書き方（`alternates`）。それぞれを、別のお手本として見る。
  private let variants: [Judge]

  public init(character: CharacterData) {
    self.init(character: character, withVariants: true)
  }

  private init(character: CharacterData, withVariants: Bool) {
    self.character = character
    let model = character.strokes.map { Geometry.resample(Geometry.polyline(of: $0)) }
    self.model = model
    self.modelRaw = character.strokes.map { Geometry.polyline(of: $0) }
    self.sizeScale = Self.sizeScale(of: model)
    guard withVariants else {
      self.variants = []
      return
    }
    let identity = Array(character.strokes.indices)
    var others: [[CharacterData.Stroke]] = character.orders.dropFirst()
      .filter { $0 != identity && $0.sorted() == identity }
      .map { order in order.map { character.strokes[$0] } }
    others += (character.alternates ?? []).filter { !$0.isEmpty }
    self.variants = others.map { strokes in
      var other = character
      other.strokes = strokes
      other.orders = [Array(strokes.indices)]
      other.alternates = nil
      return Judge(character: other, withVariants: false)
    }
  }

  /// しきい値の基準にする字の大きさ（マス 0〜1000 での、字の外枠の長い辺）。ひらがな・カタカナの多くはこれ以上。
  static let referenceSize = 700.0
  /// 小さい字（アルファベットの小文字など）でも、倍率はここより小さくしない。
  static let minimumScale = 0.6
  /// 倍率を掛けたあとの、しきい値の下限（小さい点や短い画で厳しくなりすぎないように）。
  static let minimumShape = 24.0
  static let minimumDeviation = 48.0

  /// お手本の字の大きさに合わせた倍率（大きい字は 1）。字の形の違いは、字全体を合わせたあとの
  /// マス上の距離で比べるので、小さい字ほど同じ距離が大きな違いになる（D192）。
  static func sizeScale(of model: [Polyline]) -> Double {
    guard let b = Geometry.bounds(of: model) else { return 1 }
    let size = max(b.max.x - b.min.x, b.max.y - b.min.y)
    return max(minimumScale, min(1, size / referenceSize))
  }

  /// この字での、形の違いのしきい値（平均・いちばん離れた点）。
  private func limits(_ config: JudgeConfig, scale: Double? = nil) -> (
    shape: Double, deviation: Double
  ) {
    let k = scale ?? sizeScale
    return (
      max(config.shapeTolerance * k, min(config.shapeTolerance, Self.minimumShape)),
      max(config.maxDeviation * k, min(config.maxDeviation, Self.minimumDeviation))
    )
  }

  /// 手書きのぶれに近い、決まった揺れを足す（確かめ用の道具。`make judge-report` とテストで同じ式を使う）。
  /// `phase` を変えると、同じ大きさでも別の揺れ方になる。
  public static func jittered(_ lines: [Polyline], amplitude: Double, phase: Int = 0) -> [Polyline]
  {
    lines.enumerated().map { s, line in
      line.enumerated().map { i, p in
        Point(
          p.x + amplitude * sin(Double(i) * 0.9 + Double(s) + Double(phase) * 1.3),
          p.y + amplitude * cos(Double(i) * 1.3 + Double(s) + Double(phase) * 0.7))
      }
    }
  }

  /// 2本の線の形の違い（いちばん離れた点の距離）。確かめ用の道具で、崩し方の大きさを測るのに使う。
  public static func deviation(_ a: Polyline, _ b: Polyline) -> Double {
    Geometry.shapeDifference(Geometry.resample(a), Geometry.resample(b)).max
  }

  /// ④じぶんで の判定。字全体の位置と大きさをお手本に合わせてから比べる。
  /// お手本の書き方で合格しなければ、別の正解の書き方（D66）でも見る。どれにも合わなければ、お手本と比べた結果を返す。
  public func judge(written: [Polyline], preset: JudgePreset) -> JudgeResult {
    let primary = judgeAgainstModel(written: written, preset: preset)
    // お手本の画数どおりに合格したら、それで決まり。
    // 分けた線・つなげた線として合格したとき（D77）は、別の正解の書き方にそのまま合うほうを先に取る。
    if primary.passed, !primary.splitOrJoined { return primary }
    for variant in variants {
      var result = variant.judgeAgainstModel(written: written, preset: preset)
      if result.passed, !result.splitOrJoined {
        result.usedAlternate = true
        return result
      }
    }
    if primary.passed { return primary }
    for variant in variants {
      var result = variant.judgeAgainstModel(written: written, preset: preset)
      if result.passed {
        result.usedAlternate = true
        return result
      }
    }
    return primary
  }

  private func judgeAgainstModel(written: [Polyline], preset: JudgePreset) -> JudgeResult {
    let config = JudgeConfig.preset(preset)
    let resampled = written.map { Geometry.resample($0) }
    var aligned = Geometry.align(resampled, to: model)
    var splitOrJoined = false
    if aligned.count != model.count, let regrouped = regroup(aligned) {
      // 分けた線・つなげた線を、お手本の画数にまとめ直して読みとる（D77）。
      // まとめ直しても形が合わなければ、画数がちがうものとして扱う。
      let trial = evaluate(regrouped, config: config)
      let shapeOK = !trial.issues.contains {
        switch $0 {
        case .shape, .deviation: true
        default: false
        }
      }
      if shapeOK {
        aligned = regrouped
        splitOrJoined = true
      }
    }
    var result = evaluate(aligned, config: config)
    result.splitOrJoined = splitOrJoined
    if splitOrJoined, !config.allowsSplitAndJoin {
      result.issues.insert(
        .strokeCount(expected: model.count, actual: written.count), at: 0)
      result.passed = false
    }
    guard result.passed else { return result }
    var stricterConfig = JudgeConfig.stricter(than: preset)
    stricterConfig.allowsSplitAndJoin = true
    let stricter = evaluate(aligned, config: stricterConfig)
    let maxDistance = result.shapeDistances.max() ?? 0
    let maxDeviation = result.maxDistances.max() ?? 0
    let limit = limits(config)
    let roomy = maxDistance <= limit.shape * 0.7 && maxDeviation <= limit.deviation * 0.7
    let topTier = maxDistance <= limit.shape * 0.6 && maxDeviation <= limit.deviation * 0.6
    if stricter.passed, preset != .kicchiri || topTier {
      result.rating = .hanamaru
    } else if roomy {
      result.rating = .nijumaru
    } else {
      result.rating = .maru
    }
    return result
  }

  /// ④じぶんで の書き終わりの合図（D77）。1画書き終えるたびに呼ぶ。
  public enum EndSignal: Sendable, Equatable {
    /// お手本のすべての画に線が当てはまった。1秒止まったら自動で判定する。
    case judgeAfterPause
    /// 当てはまらない画が残っている。3秒止まったら「できた！」を光らせる。
    case highlightAfterPause
    /// 書いた画がお手本より3つ以上多い。すぐに「できた！」を光らせる。
    case highlightNow
  }

  /// 書いた線がお手本のすべての画に当てはまるかを見て、書き終わりの合図を決める（D77）。
  /// 分けた線・つなげた線も、まとめ直して形が合えば当てはまったとみなす。
  /// 別の正解の書き方（D66）に当てはまったときも、判定に進む。
  public func endSignal(for written: [Polyline]) -> EndSignal {
    let primary = endSignalAgainstModel(for: written)
    if primary == .judgeAfterPause { return primary }
    for variant in variants where variant.matchesShape(written) { return .judgeAfterPause }
    return primary
  }

  /// 書いた線が、この書き方のすべての画に、形で当てはまるか（画数が同じとき）。
  private func matchesShape(_ written: [Polyline]) -> Bool {
    guard written.count == model.count else { return false }
    let aligned = Geometry.align(written.map { Geometry.resample($0) }, to: model)
    let trial = evaluate(aligned, config: JudgeConfig.preset(.hajimete))
    return !trial.issues.contains {
      switch $0 {
      case .shape, .deviation: true
      default: false
      }
    }
  }

  private func endSignalAgainstModel(for written: [Polyline]) -> EndSignal {
    guard !written.isEmpty else { return .highlightAfterPause }
    if written.count >= model.count + 3 { return .highlightNow }
    let aligned = Geometry.align(written.map { Geometry.resample($0) }, to: model)
    let lines = aligned.count == model.count ? aligned : regroup(aligned)
    guard let lines else { return .highlightAfterPause }
    // 当てはまったかどうかは、いちばんやさしい設定の形の基準で見る（判定そのものは別）。
    let trial = evaluate(lines, config: JudgeConfig.preset(.hajimete))
    let shapeOK = !trial.issues.contains {
      switch $0 {
      case .shape, .deviation: true
      default: false
      }
    }
    // 画数どおりに書いたときは、形が合わなくても判定に進める（結果で伝える）。
    return shapeOK || aligned.count == model.count ? .judgeAfterPause : .highlightAfterPause
  }

  /// ②なぞる・③うすく の1画ずつの判定（D47）。マスの中の位置で比べる（字全体を合わせない）。
  public func judgeStroke(_ written: Polyline, expected index: Int, preset: JudgePreset)
    -> StrokeCheck
  {
    guard model.indices.contains(index), !written.isEmpty else { return .wrongStroke }
    let config = JudgeConfig.preset(preset)
    if isDot(index) {
      // 点（i・j の点など）: 短いタップや短い線を、お手本の位置の近くなら通す（向きは見ない。D192）。
      return judgeDot(written, expected: index, config: config)
    }
    guard written.count > 1 else { return .wrongStroke }
    let line = Geometry.resample(written)
    // なぞる・うすく はお手本の上をたどるので、形の違いは ④ より広めに許す。
    // 小さい字でも、お手本をたどる画は、倍率を 0.7 より小さくしない。
    let traced = limits(config, scale: max(sizeScale, 0.7))
    let tolerance = traced.shape * 1.4
    let deviationLimit = traced.deviation * 1.4
    let ends = Geometry.endpointDifference(line, model[index])
    var shape = Geometry.shapeDifference(line, model[index])
    // 濁点・半濁点のような短い画は、お手本の上に乗る短い線も通す（書いた線から、お手本までの距離だけ見る）。
    let modelLength = Geometry.length(of: modelRaw[index])
    let writtenLength = Geometry.length(of: written)
    // しっかり以上は、お手本の3割以上の長さがいる。
    let tickRatio = (preset == .shikkari || preset == .kicchiri) ? 0.3 : 0.15
    let shortTick = modelLength < 250 && writtenLength >= modelLength * tickRatio
    if shortTick {
      let d = line.map { Geometry.distance(from: $0, to: model[index]) }
      shape = (d.reduce(0, +) / Double(d.count), d.max() ?? 0)
    }
    if shape.mean > tolerance || shape.max > deviationLimit {
      // 別の画に近ければ「ちがう画」、どれにも近くなければ「形」。
      let other = model.indices.filter { $0 != index }.contains {
        let d = Geometry.shapeDifference(line, model[$0])
        return d.mean <= tolerance && d.max <= deviationLimit
      }
      return other ? .wrongStroke : .shape
    }
    if config.checksDirection, !shortTick || writtenLength >= modelLength * 0.6,
      ends.backward < ends.forward * 0.6
    {
      return .direction
    }
    return .ok
  }

  /// お手本の画が点か（長さがほぼ 0 のもの。i・j の点）。
  func isDot(_ index: Int) -> Bool {
    Geometry.length(of: modelRaw[index]) < Self.dotLength
  }

  /// 点を受けとる半径の下限（指で打つ点が、字の大きさでせまくなりすぎないように）。
  static let minimumDotRadius = 50.0

  /// これより短いお手本の画は、点として見る。
  static let dotLength = 40.0

  private func judgeDot(_ written: Polyline, expected index: Int, config: JudgeConfig)
    -> StrokeCheck
  {
    let target = model[index][0]
    let traced = limits(config, scale: max(sizeScale, 0.7))
    // 点は、お手本の位置から外れすぎず、長く引きずらない線。
    let length = Geometry.length(of: written)
    let center = Point(
      written.reduce(0) { $0 + $1.x } / Double(written.count),
      written.reduce(0) { $0 + $1.y } / Double(written.count))
    if length <= 150, center.distance(to: target) <= max(traced.shape * 1.4, Self.minimumDotRadius)
    {
      return .ok
    }
    return .shape
  }

  /// 先に傾けずに見て、合わなければ小さな傾きを直して見直す。どちらかで合えば合格（D192）。
  /// 傾きを直したほうが悪くなる字（回すと一部の画だけ外れる）が、傾けなければ合格だったのに落ちることがないように。
  func evaluate(_ original: [Polyline], config: JudgeConfig) -> JudgeResult {
    let plain = evaluateAligned(original, config: config)
    guard !plain.passed, original.count == model.count, config.rotationTolerance > 0 else {
      return plain
    }
    let tilted = tiltCorrected(original, tolerance: config.rotationTolerance)
    if tilted == original { return plain }
    let retry = evaluateAligned(tilted, config: config)
    return retry.passed ? retry : plain
  }

  private func evaluateAligned(_ written: [Polyline], config: JudgeConfig) -> JudgeResult {
    var issues: [JudgeIssue] = []
    guard written.count == model.count else {
      issues.append(.strokeCount(expected: model.count, actual: written.count))
      return JudgeResult(passed: false, rating: nil, issues: issues, shapeDistances: [])
    }
    let limit = limits(config)
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
    var maxDistances = Array(repeating: 0.0, count: model.count)
    for (w, m) in assignment.enumerated() {
      if config.checksOrder, w != m { issues.append(.order(written: w, model: m)) }
      let ends = Geometry.endpointDifference(written[w], model[m])
      if config.checksDirection, ends.backward < ends.forward * 0.6 {
        issues.append(.direction(model: m))
      }
      let shape = Geometry.shapeDifference(written[w], model[m])
      distances[m] = shape.mean
      maxDistances[m] = shape.max
      if shape.mean > limit.shape {
        issues.append(.shape(model: m, distance: shape.mean))
      } else if shape.max > limit.deviation {
        issues.append(.deviation(model: m, distance: shape.max))
      } else if let gap = endpointExcess(written[w], model: m, limit: limit.deviation) {
        issues.append(.deviation(model: m, distance: gap))
      }
    }
    return JudgeResult(
      passed: issues.isEmpty, rating: nil, issues: issues, shapeDistances: distances,
      maxDistances: maxDistances, assignment: assignment)
  }

  /// 長い画（150 以上）の書き始め・書き終わりが、お手本から離れすぎていないか（D192）。
  /// お手本が閉じた画（始めと終わりの間が画の大きさの25%未満。o や 0 など）は、書いた画も閉じていればよい。
  /// 閉じていない画は、始めの点と終わりの点の、離れが大きいほうで見る。離れすぎなら、その距離を返す。
  private func endpointExcess(_ line: Polyline, model index: Int, limit: Double) -> Double? {
    let raw = modelRaw[index]
    guard Geometry.length(of: raw) >= 150, let m0 = model[index].first, let m1 = model[index].last,
      let w0 = line.first, let w1 = line.last, let b = Geometry.bounds(of: [raw])
    else { return nil }
    let size = max(b.max.x - b.min.x, b.max.y - b.min.y)
    let allowed = limit * 1.5
    if m0.distance(to: m1) < size * 0.25 {
      let gap = w0.distance(to: w1)
      return gap > allowed ? gap : nil
    }
    let forward = max(w0.distance(to: m0), w1.distance(to: m1))
    let backward = max(w0.distance(to: m1), w1.distance(to: m0))
    let worst = min(forward, backward)
    return worst > allowed ? worst : nil
  }

  /// 字全体の小さな傾き（`tolerance` 度まで）を直す。いちばんお手本に合う角度で回す。
  /// 画ごとには回さず、画どうしの位置関係は変えない（D192）。
  private func tiltCorrected(_ written: [Polyline], tolerance: Double) -> [Polyline] {
    guard tolerance > 0, let b = Geometry.bounds(of: written) else { return written }
    let center = (b.min + b.max) * 0.5
    var best = written
    var bestCost = totalDistance(written, assignment: Array(model.indices))
    // すでによく合っているときは、回して試さない（時間をかけない）。
    if bestCost / Double(max(1, written.count)) < 10 { return written }
    var angle = -tolerance
    while angle <= tolerance + 1e-9 {
      if abs(angle) > 1e-9 {
        let radians = angle * .pi / 180
        let c = cos(radians)
        let s = sin(radians)
        let rotated = written.map { line in
          line.map { p -> Point in
            let d = p - center
            return Point(center.x + d.x * c - d.y * s, center.y + d.x * s + d.y * c)
          }
        }
        let cost = totalDistance(rotated, assignment: Array(model.indices))
        if cost < bestCost * 0.97 {
          bestCost = cost
          best = rotated
        }
      }
      angle += 2
    }
    return best
  }

  /// 当てはめに使う、1画どうしの違い（形と、書き始め・書き終わりの位置。向きは問わない）。
  private func cost(_ line: Polyline, _ m: Int) -> Double {
    let ends = Geometry.endpointDifference(line, model[m])
    return Geometry.shapeDifference(line, model[m]).mean + min(ends.forward, ends.backward) / 4
  }

  private func totalDistance(_ written: [Polyline], assignment: [Int]) -> Double {
    zip(written, assignment).reduce(0) { $0 + cost($1.0, $1.1) }
  }

  /// 書いた線を、書いた順のままお手本の画に当て直す（D77）。
  /// 1画を2〜3本に分けて書いた線はつなげ、2画を1本でつなげて書いた線は2つに分ける。
  /// うまく当てられなければ nil（画数がちがう）。
  func regroup(_ written: [Polyline]) -> [Polyline]? {
    let n = written.count
    let m = model.count
    guard n > 0, m > 0 else { return nil }
    // best[i][j]: 書いた線の i 本目までで、お手本の j 画目までを当てたときの違いの合計。
    var best = Array(repeating: Array(repeating: Double.infinity, count: m + 1), count: n + 1)
    var step = Array(repeating: Array(repeating: (0, 0), count: m + 1), count: n + 1)
    best[0][0] = 0
    let gapLimit = 150.0
    func joined(_ lines: ArraySlice<Polyline>) -> Polyline? {
      var out: Polyline = []
      for line in lines {
        if let last = out.last, let first = line.first, last.distance(to: first) > gapLimit {
          return nil
        }
        out += line
      }
      return out
    }
    for i in 0..<n {
      for j in 0..<m where best[i][j].isFinite {
        // 書いた k 本（1〜3）を、お手本の1画に当てる。
        for k in 1...3 where i + k <= n {
          guard let line = joined(written[i..<(i + k)]) else { break }
          let c = best[i][j] + cost(line, j)
          if c < best[i + k][j + 1] {
            best[i + k][j + 1] = c
            step[i + k][j + 1] = (k, 1)
          }
        }
        // 書いた1本を、お手本の2画に当てる。
        if j + 2 <= m, let parts = split(written[i], at: j) {
          let c = best[i][j] + cost(parts.0, j) + cost(parts.1, j + 1)
          if c < best[i + 1][j + 2] {
            best[i + 1][j + 2] = c
            step[i + 1][j + 2] = (1, 2)
          }
        }
      }
    }
    guard best[n][m].isFinite else { return nil }
    var result: [Polyline] = []
    var i = n
    var j = m
    while i > 0 || j > 0 {
      let (k, l) = step[i][j]
      if l == 1 {
        guard let line = joined(written[(i - k)..<i]) else { return nil }
        result.insert(line, at: 0)
      } else {
        guard let parts = split(written[i - 1], at: j - 2) else { return nil }
        result.insert(contentsOf: [parts.0, parts.1], at: 0)
      }
      i -= k
      j -= l
    }
    return result
  }

  /// 書いた1本を、お手本の `j` 画目と `j + 1` 画目に分ける。前の部分は `j` 画目の終わりに
  /// いちばん近いところまで、後ろの部分は `j + 1` 画目の始まりにいちばん近いところから。
  /// あいだの「つなぎの線」は、どちらの画にも入れない。
  private func split(_ line: Polyline, at j: Int) -> (Polyline, Polyline)? {
    guard line.count >= 4, let end = model[j].last, let start = model[j + 1].first else {
      return nil
    }
    guard
      let k1 = (1..<(line.count - 2)).min(by: {
        line[$0].distance(to: end) < line[$1].distance(to: end)
      })
    else { return nil }
    guard
      let k2 = ((k1 + 1)..<(line.count - 1)).min(by: {
        line[$0].distance(to: start) < line[$1].distance(to: start)
      })
    else { return nil }
    return (Array(line[...k1]), Array(line[k2...]))
  }

  /// 書いた画とお手本の画の1対1の当て方のうち、形の違いの合計がいちばん小さいもの。
  /// 画数は多くても 7 程度なので、すべての並べ方を比べる。
  private func bestAssignment(_ written: [Polyline]) -> [Int] {
    let n = written.count
    var cost = Array(repeating: Array(repeating: 0.0, count: n), count: n)
    for w in 0..<n {
      for m in 0..<n {
        cost[w][m] = self.cost(written[w], m)
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
