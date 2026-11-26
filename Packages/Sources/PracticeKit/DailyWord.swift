import ContentModel

/// 年・月・日（暦の日。`Calendar` に頼らず、Linux でも同じ結果にする）。
public struct CalendarDay: Sendable, Hashable {
  public let year: Int
  public let month: Int
  public let day: Int

  public init(year: Int, month: Int, day: Int) {
    self.year = year
    self.month = month
    self.day = day
  }
}

/// 「きょうの ことば」の選び方（D35・D54・D182）。同じ子・同じ日なら、いつ開いても同じことばになる。
public enum DailyWord {
  /// 季節の印のあることばを選ぶ日の割合（日本のときだけ）。
  static let seasonalChance = 0.5

  /// きょうのことばを選ぶ。
  /// - Parameters:
  ///   - words: 選べることば（絵があって、書けるもの）。
  ///   - writtenBeforeToday: きょうより前に書いたことば。**きょうの分は入れない**（きょう書くと選びが変わるため）。
  ///   - day: きょうの日。
  ///   - childID: 子の ID（子ごとに別のことばになる）。
  ///   - isJapan: iPad の地域が日本か。日本のときだけ季節を見る（D54）。
  /// まだ書いていないことばを先にし、全部書いていれば どれからでも選ぶ。
  public static func pick(
    from words: [String], writtenBeforeToday written: Set<String>, day: CalendarDay,
    childID: String, isJapan: Bool
  ) -> String? {
    var seen = Set<String>()
    var eligible = words.filter { seen.insert($0).inserted }
    let season = Season.of(month: day.month)
    if isJapan {
      // よその季節のことば（冬の すいか、など）は出さない。
      eligible = eligible.filter { WordSeason.season(of: $0).map { $0 == season } ?? true }
    }
    guard !eligible.isEmpty else { return nil }
    let fresh = eligible.filter { !written.contains($0) }
    var pool = fresh.isEmpty ? eligible : fresh
    var rng = SeededGenerator(
      seed: SeededGenerator.seed(from: "\(day.year)-\(day.month)-\(day.day)|\(childID)"))
    if isJapan {
      let seasonal = pool.filter { WordSeason.season(of: $0) == season }
      if !seasonal.isEmpty, Double.random(in: 0..<1, using: &rng) < seasonalChance {
        pool = seasonal
      }
    }
    return pool.randomElement(using: &rng)
  }
}
