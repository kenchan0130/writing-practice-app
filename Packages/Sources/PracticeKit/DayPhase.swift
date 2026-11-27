/// まちの時間帯（§3.4・§3.5）。端末の時刻に合わせて、朝・昼・夕方・夜で景色が変わる。
/// 演出であって、使えなくする仕組みではない（D17）。
public enum DayPhase: String, Sendable, CaseIterable, Hashable {
  /// 朝（5時〜9時台）。
  case morning
  /// 昼（10時〜15時台）。
  case day
  /// 夕方（16時〜18時台）。夕やけの色。
  case evening
  /// 夜（19時〜4時台）。星と、あかりのついた窓。
  case night

  /// 時（0〜23）から時間帯を決める。範囲の外の数は 24 で割った余りで見る。
  public static func of(hour: Int) -> DayPhase {
    let hour = ((hour % 24) + 24) % 24
    switch hour {
    case 5..<10: return .morning
    case 10..<16: return .day
    case 16..<19: return .evening
    default: return .night
    }
  }

  /// 主人公が眠そうにする時間帯か（夜だけ）。
  public var isSleepy: Bool { self == .night }
}
