/// おたのしみ ボックスの中身（§3.3・D54）。画面に頼らない計算。
///
/// 中身はステッカー。課金では手に入らず、練習でしか あけられない。
public enum TreatBox {
  /// ステッカーの絵の名前（24枚。絵は `Scripts/art/stickers.py`、アセットは `sticker-<名前>`）。
  /// 並びは変えない（選び方が変わらないように、足すときは後ろに足す）。
  public static let stickers: [String] = [
    "hoshi", "heart", "hana", "niji", "kumo", "taiyou", "tsuki", "onpu",
    "ribbon", "oukan", "cake", "ice", "ame", "donut", "ringo", "ichigo",
    "sakuranbo", "kinoko", "clover", "rocket", "fuusen", "present", "enpitsu", "hanamaru",
  ]

  /// つぎに出るステッカー。同じ子・同じ日なら、いつ あけても同じ。
  /// まだ持っていないものを先に出し、全部持っていれば どれからでも出す。
  /// - Parameters:
  ///   - owned: もう持っているステッカーの絵の名前。
  ///   - day: きょうの日。
  ///   - childID: 子の ID（子ごとに別の並びになる）。
  public static func nextSticker(
    from all: [String] = stickers, owned: Set<String>, day: CalendarDay, childID: String
  ) -> String? {
    var seen = Set<String>()
    let all = all.filter { seen.insert($0).inserted }
    guard !all.isEmpty else { return nil }
    let fresh = all.filter { !owned.contains($0) }
    let pool = fresh.isEmpty ? all : fresh
    var rng = SeededGenerator(
      seed: SeededGenerator.seed(from: "treat|\(day.year)-\(day.month)-\(day.day)|\(childID)"))
    return pool.randomElement(using: &rng)
  }
}
