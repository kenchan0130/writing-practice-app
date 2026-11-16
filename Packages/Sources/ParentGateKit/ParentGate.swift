/// 保護者用の確認（D49・D64）。画面や端末に頼らない部品。
///
/// - 問題は漢数字で書いた「2桁 × 1桁」のかけ算（12〜19 × 3〜9）。英語は英語の数の言葉で書く。
/// - 3回まちがえると30秒待つ。
/// - 確認を通ったら、5分間操作がないか画面を閉じるまで有効。

/// かけ算の問題。
public struct GateQuestion: Sendable, Hashable {
  public var left: Int
  public var right: Int

  public init(left: Int, right: Int) {
    self.left = left
    self.right = right
  }

  public var answer: Int { left * right }

  /// 日本語の問題文（例:「十四 かける 六 の こたえを いれてください」）。
  public var japanese: String {
    "\(KanjiNumeral.string(left)) かける \(KanjiNumeral.string(right)) の こたえを いれてください"
  }

  /// 英語の問題文（例: "Enter fourteen times six"）。
  public var english: String {
    "Enter \(EnglishNumeral.string(left)) times \(EnglishNumeral.string(right))"
  }

  /// 決まった範囲（12〜19 × 3〜9）から作る。`random` は 0..<1 の数を返す。
  public static func make(random: () -> Double) -> GateQuestion {
    let left = 12 + min(Int(random() * 8), 7)
    let right = 3 + min(Int(random() * 7), 6)
    return GateQuestion(left: left, right: right)
  }
}

/// 漢数字（1〜99）。
public enum KanjiNumeral {
  static let digits = ["", "一", "二", "三", "四", "五", "六", "七", "八", "九"]

  public static func string(_ n: Int) -> String {
    precondition((1...99).contains(n), "1〜99 だけを扱う")
    let tens = n / 10
    let ones = n % 10
    var result = ""
    if tens > 0 { result += (tens == 1 ? "" : digits[tens]) + "十" }
    result += digits[ones]
    return result
  }
}

/// 英語の数の言葉（1〜99）。
public enum EnglishNumeral {
  static let small = [
    "", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven",
    "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen",
  ]
  static let tens = [
    "", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety",
  ]

  public static func string(_ n: Int) -> String {
    precondition((1...99).contains(n), "1〜99 だけを扱う")
    if n < 20 { return small[n] }
    let t = tens[n / 10]
    return n % 10 == 0 ? t : "\(t)-\(small[n % 10])"
  }
}

/// 保護者用の確認の状態。時刻は秒（呼ぶ側が決める）。
public struct ParentGate: Sendable {
  public static let maxMistakes = 3
  public static let lockSeconds = 30.0
  public static let validSeconds = 5 * 60.0

  public private(set) var question: GateQuestion
  public private(set) var mistakes = 0
  /// この時刻までは答えを受け付けない（3回まちがえたあと）。
  public private(set) var lockedUntil: Double?
  /// 確認を通った最後の操作の時刻。nil は通っていない。
  public private(set) var lastActivity: Double?

  private var random: @Sendable () -> Double

  public init(random: @escaping @Sendable () -> Double) {
    self.random = random
    self.question = GateQuestion.make(random: random)
  }

  public enum AnswerResult: Sendable, Equatable {
    case passed
    case wrong(remaining: Int)
    case locked(until: Double)
  }

  /// 答えを確かめる。まちがえたら問題を変える。
  public mutating func answer(_ value: Int, at now: Double) -> AnswerResult {
    if let lockedUntil, now < lockedUntil { return .locked(until: lockedUntil) }
    lockedUntil = nil
    if value == question.answer {
      mistakes = 0
      lastActivity = now
      question = GateQuestion.make(random: random)
      return .passed
    }
    mistakes += 1
    question = GateQuestion.make(random: random)
    if mistakes >= Self.maxMistakes {
      mistakes = 0
      let until = now + Self.lockSeconds
      lockedUntil = until
      return .locked(until: until)
    }
    return .wrong(remaining: Self.maxMistakes - mistakes)
  }

  /// いま確認が有効か（5分間操作がなければ切れる）。
  public func isOpen(at now: Double) -> Bool {
    guard let lastActivity else { return false }
    return now - lastActivity < Self.validSeconds
  }

  /// 保護者用の画面で操作したとき（有効な時間を延ばす）。
  public mutating func touch(at now: Double) {
    if isOpen(at: now) { lastActivity = now }
  }

  /// 保護者用の画面を閉じたとき。
  public mutating func close() {
    lastActivity = nil
  }
}
