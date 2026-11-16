import Foundation

/// ペンの色（8色。D55・D88）。色の見分けにくい子でも区別しやすいよう、
/// 色相と明るさを離している。`rawValue` が保存する色の名前。
public enum PenColor: String, Sendable, Hashable, Codable, CaseIterable {
  case blue
  case red
  case green
  case orange
  case sky
  case pink
  case purple
  case black

  /// 選んでいないときの色。
  public static let `default`: PenColor = .blue

  /// 色の値（0〜1）。画面の部品が使う。
  public var rgb: (red: Double, green: Double, blue: Double) {
    switch self {
    case .blue: (0.0, 0.33, 0.70)
    case .red: (0.84, 0.18, 0.15)
    case .green: (0.0, 0.58, 0.36)
    case .orange: (0.95, 0.55, 0.0)
    case .sky: (0.34, 0.70, 0.92)
    case .pink: (0.90, 0.40, 0.65)
    case .purple: (0.47, 0.31, 0.64)
    case .black: (0.15, 0.15, 0.15)
    }
  }

  /// 読み上げ・ラベル用の名前（ひらがな）。
  public var label: String {
    switch self {
    case .blue: "あお"
    case .red: "あか"
    case .green: "みどり"
    case .orange: "オレンジ"
    case .sky: "みずいろ"
    case .pink: "ピンク"
    case .purple: "むらさき"
    case .black: "くろ"
    }
  }
}

/// 子どものプロフィール（D16・D19・§5.3）。
public struct Profile: Sendable, Hashable, Codable, Identifiable {
  /// 呼び名に付けることば（§3.9）。
  public enum Honorific: String, Sendable, Hashable, Codable, CaseIterable {
    case kun
    case chan
    case san
    case none

    public var suffix: String {
      switch self {
      case .kun: "くん"
      case .chan: "ちゃん"
      case .san: "さん"
      case .none: ""
      }
    }
  }

  public enum Handedness: String, Sendable, Hashable, Codable, CaseIterable {
    case right
    case left
  }

  /// きょうの もくひょうに選べる字の数。
  public static let dailyGoals = [3, 5, 10]

  public var id: UUID
  public var name: String
  public var honorific: Honorific
  /// 顔（絵の名前）。
  public var face: String
  public var handedness: Handedness
  public var dailyGoal: Int
  /// ペンの色（D88）。まだ選んでいない子は nil（はじめての起動で選ぶ）。
  public var penColor: PenColor?

  public init(
    id: UUID = UUID(), name: String, honorific: Honorific = .none, face: String,
    handedness: Handedness = .right, dailyGoal: Int = 5,
    penColor: PenColor? = nil
  ) {
    self.id = id
    self.name = name
    self.honorific = honorific
    self.face = face
    self.handedness = handedness
    self.dailyGoal = Self.dailyGoals.contains(dailyGoal) ? dailyGoal : 5
    self.penColor = penColor
  }

  /// 画面に出す呼び名（「ゆうとくん」）。声は呼び名を読まない（D76）。
  public var displayName: String {
    let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? "" : trimmed + honorific.suffix
  }
}

/// プロフィールの一覧（最大6人。D19）。
public struct ProfileList: Sendable, Hashable, Codable {
  public static let maxCount = 6

  public private(set) var profiles: [Profile]

  public init(profiles: [Profile] = []) {
    self.profiles = Array(profiles.prefix(Self.maxCount))
  }

  public var canAdd: Bool { profiles.count < Self.maxCount }

  /// 足す。6人を超えるときは足さずに false。
  @discardableResult
  public mutating func add(_ profile: Profile) -> Bool {
    guard canAdd, !profiles.contains(where: { $0.id == profile.id }) else { return false }
    profiles.append(profile)
    return true
  }

  public mutating func update(_ profile: Profile) {
    guard let index = profiles.firstIndex(where: { $0.id == profile.id }) else { return }
    profiles[index] = profile
  }

  /// 消す。最後の1人は消さない（いつも誰かが使えるようにする）。
  @discardableResult
  public mutating func remove(_ id: UUID) -> Bool {
    guard profiles.count > 1, let index = profiles.firstIndex(where: { $0.id == id }) else {
      return false
    }
    profiles.remove(at: index)
    return true
  }

  public func profile(_ id: UUID?) -> Profile? {
    profiles.first { $0.id == id }
  }

  /// いつも使う子。決まっていないか、いなくなっていれば最初の子。
  public func current(preferred id: UUID?) -> Profile? {
    profile(id) ?? profiles.first
  }
}
