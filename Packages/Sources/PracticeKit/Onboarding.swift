import ContentModel
import Foundation

/// 主人公のキャラクター3人（D39）。絵はアプリ側で用意する。
public enum MainCharacter: String, Sendable, CaseIterable, Codable {
  case ton
  case run
  case hira

  /// 子どもの画面に出す名前（ひらがな）。
  public var name: String {
    switch self {
    case .ton: "とん"
    case .run: "るん"
    case .hira: "ひら"
    }
  }
}

/// はじめての流れのどこから始めるか（D23）。
public enum OnboardingStage: Sendable, Hashable {
  /// 前半: おとなの設定。
  case adult
  /// 後半: 子どもの体験。
  case child
}

/// はじめての流れの決まり（D23・D46・D63・D78）。画面や端末に頼らない。
public enum Onboarding {
  /// いまの様子。画面側が集めて渡す。
  public struct Situation: Sendable, Hashable {
    /// 前半（おとなの設定）を終えた、または飛ばした。
    public var adultDone: Bool
    /// iCloud からの最初の取り込みを待っている（D63）。
    public var waitingForFirstImport: Bool
    /// 登録している子の数。
    public var profileCount: Int
    /// いまの子に呼び名が入っている。
    public var currentHasName: Bool
    /// いまの子が1字でも1語でも練習したことがある。
    public var currentHasPractice: Bool
    /// いまの子は、後半（子どもの体験）を終えた、または飛ばした。
    public var currentChildDone: Bool

    public init(
      adultDone: Bool, waitingForFirstImport: Bool, profileCount: Int, currentHasName: Bool,
      currentHasPractice: Bool, currentChildDone: Bool
    ) {
      self.adultDone = adultDone
      self.waitingForFirstImport = waitingForFirstImport
      self.profileCount = profileCount
      self.currentHasName = currentHasName
      self.currentHasPractice = currentHasPractice
      self.currentChildDone = currentChildDone
    }
  }

  /// 出す流れ。出さないときは nil。
  /// - iCloud の取り込みを待っているあいだは出さない（子がすでにいるかが分からないため。D63）。
  /// - 前半は、まだ設定をしていない最初の1人だけのとき。複数の子や、呼び名・記録がすでにある iPad には出さない。
  /// - 後半は、まだ何も練習していない子を選んだとき（新しく足した子、記録だけリセットした子も。D23）。
  public static func stage(for situation: Situation) -> OnboardingStage? {
    guard !situation.waitingForFirstImport else { return nil }
    let untouched =
      situation.profileCount <= 1 && !situation.currentHasName && !situation.currentHasPractice
    if !situation.adultDone, untouched { return .adult }
    if !situation.currentHasPractice, !situation.currentChildDone { return .child }
    return nil
  }

  /// 最初の1字（D23・D46）。呼び名の最初の字。ひらがなで書けない字（空・漢字・英字・小さい字など）は「あ」。
  /// カタカナは同じ音のひらがなにする。
  public static func firstLetter(nickname: String) -> Character {
    let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
    guard let first = trimmed.first else { return fallbackLetter }
    var text = String(first).precomposedStringWithCanonicalMapping
    if text.unicodeScalars.count == 1, let scalar = text.unicodeScalars.first,
      (0x30A1...0x30F3).contains(scalar.value),
      let hira = Unicode.Scalar(scalar.value - 0x60)
    {
      text = String(Character(hira))
    }
    guard text.count == 1, let char = text.first, writableLetters.contains(char) else {
      return fallbackLetter
    }
    return char
  }

  public static let fallbackLetter: Character = "あ"

  /// 最初の1字にできる字（50音と濁音・半濁音。小さい字は除く）。
  private static let writableLetters: Set<Character> = Set(
    KanaTable.main(.hiragana).characters + KanaTable.dakuon(.hiragana).characters)

  /// 「なにが すき？」で選べるテーマ（M0 は3つ。D53・D78）。
  public static let themes: [WordKind] = [.vehicle, .animal, .clothes]

  /// テーマごとの最初のことば。ひらがな2文字で、書きやすい字だけ（D78）。
  public static func starterWord(for kind: WordKind) -> String {
    switch kind {
    case .vehicle: "そり"
    case .animal: "うし"
    case .clothes: "くつ"
    // 「なにが すき？」には出さない（D168）。
    case .flyer: "はと"
    case .scenery: "さくら"
    case .swimmer: "たこ"
    case .sky: "くも"
    case .plaything: "こま"
    }
  }
}
