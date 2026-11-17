/// 字の育ち方の名前（D151）。文字の地図の4つの状態（`MapState`）に、育つ名前を付ける。
/// たね（まだ）→ め（れんしゅうちゅう）→ つぼみ（なぞって かけた）→ はな（ひとりで かけた）。
public enum GrowthStage: Int, Sendable, Hashable, CaseIterable {
  case seed
  case sprout
  case bud
  case flower

  public init(_ state: MapState) {
    switch state {
    case .notYet: self = .seed
    case .practicing: self = .sprout
    case .traced: self = .bud
    case .wroteAlone: self = .flower
    }
  }

  /// 子どもに見せる名前（ひらがな）。
  public var name: String {
    switch self {
    case .seed: "たね"
    case .sprout: "め"
    case .bud: "つぼみ"
    case .flower: "はな"
    }
  }

  /// この名前の意味（凡例に添える）。これまでの地図の言い方。
  public var meaning: String {
    switch self {
    case .seed: "まだ"
    case .sprout: "れんしゅうちゅう"
    case .bud: "なぞって かけた"
    case .flower: "ひとりで かけた"
    }
  }
}

extension MapState {
  /// 育ち方の名前。
  public var growth: GrowthStage { GrowthStage(self) }
}

/// 文字の種類（ひらがな・カタカナ …）ごとの育ちの段階（D151）。「はな」の数で決める。
public enum ScriptGrowth: Int, Sendable, Hashable, CaseIterable, Comparable {
  case seed
  case sprout2
  case bud
  case garden

  public static func < (a: ScriptGrowth, b: ScriptGrowth) -> Bool { a.rawValue < b.rawValue }

  /// 段階の名前（「ひらがなの たね」のように、文字の種類の名前に続ける）。
  public var name: String {
    switch self {
    case .seed: "たね"
    case .sprout2: "ふたば"
    case .bud: "つぼみ"
    case .garden: "はなばたけ"
    }
  }

  /// 「はな」の数（`flowers`）が、字の数（`total`）の何割かで決める。
  /// 0〜9% たね / 10〜39% ふたば / 40〜79% つぼみ / 80〜100% はなばたけ。
  /// 字の数が違う文字の種類（ひらがな・カタカナ・アルファベット）でも、同じ割合で段階が上がる。
  /// 整数だけで比べ、割り算の丸めでずれないようにする。
  public static func stage(flowers: Int, total: Int) -> ScriptGrowth {
    guard total > 0 else { return .seed }
    let scaled = max(flowers, 0) * 100
    if scaled >= total * 80 { return .garden }
    if scaled >= total * 40 { return .bud }
    if scaled >= total * 10 { return .sprout2 }
    return .seed
  }

  /// 地図の状態の一覧から段階を決める。
  public static func stage(of states: [MapState], total: Int) -> ScriptGrowth {
    stage(flowers: states.filter { $0 == .wroteAlone }.count, total: total)
  }

  /// 次の段階まであと何輪か。はなばたけなら nil。
  public static func flowersToNext(flowers: Int, total: Int) -> Int? {
    let current = stage(flowers: flowers, total: total)
    guard let next = ScriptGrowth(rawValue: current.rawValue + 1) else { return nil }
    let percent = next == .sprout2 ? 10 : next == .bud ? 40 : 80
    // flowers * 100 >= total * percent を満たす最小の flowers。
    let needed = (total * percent + 99) / 100
    return max(needed - flowers, 0)
  }
}

/// 行（あ行・か行 …）の育ち（D151）。行の字がすべて「はな」になったら「はなばたけ」。
public enum RowGrowth {
  public static func isGarden(_ states: [MapState]) -> Bool {
    !states.isEmpty && states.allSatisfy { $0 == .wroteAlone }
  }
}
