import Foundation

/// 学習記録の計算（D25・§3.8）。画面や保存の仕組みに頼らない部品。
///
/// 記録は「追加するだけの行」で持つ（D44）。リセットは行を消さず、リセットの回数（`generation`）を
/// 1つ上げ、それより前の行を数えない。保存は Core Data（D44）が受け持つ。

/// 1文字を1回書いた記録。
public struct CharacterRecord: Sendable, Hashable, Codable, Identifiable {
  public enum Stage: String, Sendable, Hashable, Codable, Comparable {
    case nazoru
    case usuku
    case jibunde

    var rank: Int {
      switch self {
      case .nazoru: 0
      case .usuku: 1
      case .jibunde: 2
      }
    }

    public static func < (a: Stage, b: Stage) -> Bool { a.rank < b.rank }
  }

  /// 書き直しになった理由（保護者に見せる。§3.8「にがてな もじ」）。
  public enum Reason: String, Sendable, Hashable, Codable, CaseIterable {
    case strokeCount
    case order
    case direction
    case mirrored
    case shape
    case ending
  }

  public var id: UUID
  public var date: Date
  public var characterID: String
  public var stage: Stage
  /// 合格したか（救済で先に進んだときは false）。
  public var passed: Bool
  /// 救済で先に進んだか（D46）。
  public var rescued: Bool
  public var reasons: [Reason]
  /// ことばの中で書いたときの、ことば。
  public var word: String?
  /// 書いた線（マス 0〜1000。アルバムと再生に使う。§3.8）。
  public var strokes: [[[Double]]]?
  /// この行を書いたときのリセットの回数（D44）。
  public var generation: Int

  public init(
    id: UUID = UUID(), date: Date, characterID: String, stage: Stage, passed: Bool,
    rescued: Bool = false, reasons: [Reason] = [], word: String? = nil,
    strokes: [[[Double]]]? = nil, generation: Int = 0
  ) {
    self.id = id
    self.date = date
    self.characterID = characterID
    self.stage = stage
    self.passed = passed
    self.rescued = rescued
    self.reasons = reasons
    self.word = word
    self.strokes = strokes
    self.generation = generation
  }
}

/// ことばを1つ書き終えた記録。
public struct WordRecord: Sendable, Hashable, Codable, Identifiable {
  public var id: UUID
  public var date: Date
  public var word: String
  public var generation: Int

  public init(id: UUID = UUID(), date: Date, word: String, generation: Int = 0) {
    self.id = id
    self.date = date
    self.word = word
    self.generation = generation
  }
}

/// もじの地図の4つの状態（§3.8）。
public enum MapState: Int, Sendable, Hashable, Codable, Comparable {
  case notYet
  case practicing
  case traced
  case wroteAlone

  public static func < (a: MapState, b: MapState) -> Bool { a.rawValue < b.rawValue }
}

/// にがてな もじ（§3.8）。
public struct WeakCharacter: Sendable, Hashable {
  public var characterID: String
  /// 最近の記録のうち、書き直しになった回数。
  public var misses: Int
  /// 多い順の理由。
  public var reasons: [CharacterRecord.Reason]
  /// 書いた動きの再生に使う、最近の書き直しの記録。
  public var latestMiss: CharacterRecord
}

/// せいちょう アルバムの1文字（§3.8・D83）。
public struct AlbumEntry: Sendable, Hashable {
  public var characterID: String
  /// はじめて書いた線（段階を問わない）。
  public var first: CharacterRecord
  /// 最近書いた線のうち、いちばん先の段階のもの。
  public var latest: CharacterRecord
  /// ④ に初めて合格した日（はなまるの印）。
  public var firstSoloPass: Date?

  /// 「なぞって かいたよ」の印（はじめての線がなぞった線）。
  public var firstWasTraced: Bool { first.stage == .nazoru }
}

/// 「きょう / こんしゅう」（§3.8）。
public struct PeriodSummary: Sendable, Hashable {
  /// 練習した文字の数（同じ字は1つ）。
  public var characters: Int
  /// 書けたことばの数。
  public var words: Int
  /// 練習した日の数。
  public var days: Int
}

/// 学習記録。子ども1人ぶん。
public struct LearningLog: Sendable, Hashable, Codable {
  public var characters: [CharacterRecord]
  public var words: [WordRecord]
  /// いまのリセットの回数（D44）。
  public var generation: Int

  /// 「にがてな もじ」で見る、字ごとの最近の記録の数。
  public static let recentWindow = 10

  public init(characters: [CharacterRecord] = [], words: [WordRecord] = [], generation: Int = 0) {
    self.characters = characters
    self.words = words
    self.generation = generation
  }

  public mutating func append(_ record: CharacterRecord) {
    var record = record
    record.generation = generation
    characters.append(record)
  }

  public mutating func append(_ record: WordRecord) {
    var record = record
    record.generation = generation
    words.append(record)
  }

  /// 「記録だけリセット」（§6.3）。行は消さず、リセットの回数を上げる（D44）。
  public mutating func reset() {
    generation += 1
  }

  /// いまのリセットの回数の行だけ（日付の順）。
  public var currentCharacters: [CharacterRecord] {
    characters.filter { $0.generation == generation }.sorted { $0.date < $1.date }
  }

  public var currentWords: [WordRecord] {
    words.filter { $0.generation == generation }.sorted { $0.date < $1.date }
  }

  // MARK: - きょう / こんしゅう

  /// `interval` の間の練習のまとめ。
  public func summary(in interval: DateInterval, calendar: Calendar) -> PeriodSummary {
    let chars = currentCharacters.filter { interval.contains($0.date) }
    let words = currentWords.filter { interval.contains($0.date) }
    let days = Set((chars.map(\.date) + words.map(\.date)).map { calendar.startOfDay(for: $0) })
    return PeriodSummary(
      characters: Set(chars.map(\.characterID)).count, words: words.count, days: days.count)
  }

  /// きょうのまとめ。
  public func today(now: Date, calendar: Calendar) -> PeriodSummary {
    let start = calendar.startOfDay(for: now)
    let end = calendar.date(byAdding: .day, value: 1, to: start) ?? now
    return summary(in: DateInterval(start: start, end: end), calendar: calendar)
  }

  /// こんしゅうのまとめ（週の始まりは `calendar` に従う）。
  public func thisWeek(now: Date, calendar: Calendar) -> PeriodSummary {
    guard let week = calendar.dateInterval(of: .weekOfYear, for: now) else {
      return today(now: now, calendar: calendar)
    }
    return summary(in: week, calendar: calendar)
  }

  // MARK: - もじの地図

  /// 字の地図の状態。
  public func mapState(of characterID: String) -> MapState {
    var state = MapState.notYet
    for record in currentCharacters where record.characterID == characterID {
      let reached: MapState
      if record.passed, !record.rescued {
        reached = record.stage == .jibunde ? .wroteAlone : .traced
      } else {
        reached = .practicing
      }
      state = max(state, reached)
    }
    return state
  }

  /// 字ごとの地図の状態（記録のある字だけ）。
  public var map: [String: MapState] {
    Dictionary(
      Set(currentCharacters.map(\.characterID)).map { ($0, mapState(of: $0)) },
      uniquingKeysWith: { a, _ in a })
  }

  // MARK: - にがてな もじ

  /// よく書き直しになる字。最近 `recentWindow` 回のうち2回以上、かつ4割以上が書き直しの字。
  /// 書き直しの多い順。
  public var weakCharacters: [WeakCharacter] {
    let grouped = Dictionary(grouping: currentCharacters, by: \.characterID)
    var result: [WeakCharacter] = []
    for (id, records) in grouped {
      let recent = records.suffix(Self.recentWindow)
      let misses = recent.filter { !$0.passed || $0.rescued }
      guard misses.count >= 2, Double(misses.count) >= Double(recent.count) * 0.4,
        let latestMiss = misses.last
      else { continue }
      var counts: [CharacterRecord.Reason: Int] = [:]
      for reason in misses.flatMap(\.reasons) { counts[reason, default: 0] += 1 }
      let reasons = counts.sorted {
        $0.value != $1.value
          ? $0.value > $1.value
          : CharacterRecord.Reason.allCases.firstIndex(of: $0.key)!
            < CharacterRecord.Reason.allCases.firstIndex(of: $1.key)!
      }.map(\.key)
      result.append(
        WeakCharacter(
          characterID: id, misses: misses.count, reasons: reasons, latestMiss: latestMiss))
    }
    return result.sorted {
      $0.misses != $1.misses ? $0.misses > $1.misses : $0.characterID < $1.characterID
    }
  }

  // MARK: - せいちょう アルバム

  /// 1回でも書いた字（線のある記録）を、はじめて書いた順に並べる（D83）。
  public var album: [AlbumEntry] {
    let withStrokes = currentCharacters.filter { $0.strokes?.isEmpty == false }
    let grouped = Dictionary(grouping: withStrokes, by: \.characterID)
    let entries = grouped.compactMap { id, records -> AlbumEntry? in
      guard let first = records.first else { return nil }
      // 最近の記録のうち、いちばん先の段階で、その中でいちばん新しいもの。
      let recent = records.suffix(Self.recentWindow)
      let best = recent.map(\.stage).max() ?? first.stage
      let latest = recent.last { $0.stage == best } ?? first
      let firstSoloPass =
        currentCharacters.first {
          $0.characterID == id && $0.stage == .jibunde && $0.passed && !$0.rescued
        }?.date
      return AlbumEntry(characterID: id, first: first, latest: latest, firstSoloPass: firstSoloPass)
    }
    return entries.sorted { $0.first.date < $1.first.date }
  }
}
