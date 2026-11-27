import Foundation
import PracticeKit

/// まちの時刻（§3.4）。端末の時刻から、朝・昼・夕方・夜を決める（決め方は `DayPhase`）。
enum TownClock {
  /// いまの時（0〜23）。
  static func hour(now: Date = Date(), calendar: Calendar = .current) -> Int {
    #if DEBUG
      // 確かめ用: `-townHour 21` で、その時刻のまちにする。
      if UserDefaults.standard.object(forKey: "townHour") != nil {
        return UserDefaults.standard.integer(forKey: "townHour")
      }
    #endif
    return calendar.component(.hour, from: now)
  }

  static func phase(now: Date = Date(), calendar: Calendar = .current) -> DayPhase {
    DayPhase.of(hour: hour(now: now, calendar: calendar))
  }
}
