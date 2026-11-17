import Foundation

/// 2台目の最初の起動で、iCloud からの最初の取り込みを待つ決まり（D63）。
///
/// 時計と出来事は外から渡すので、そのままテストできる。CloudKit には触れない。
struct FirstImportWait: Equatable {
  /// 待つ最長の時間（D63）。
  static let timeout: TimeInterval = 10

  enum Phase: Equatable {
    case waiting
    case finished(Reason)
  }

  enum Reason: Equatable {
    /// 待たなくてよかった（同期していない、最初の起動ではない、記録がすでにある）。
    case notNeeded
    /// 最初の取り込みが終わった。
    case imported
    /// 取り込みがうまくいかなかった（サインインなし、通信なしなど）。待たない。
    case failed
    /// 10秒たった。
    case timedOut
  }

  private(set) var phase: Phase
  private let deadline: Date

  /// - Parameters:
  ///   - needed: 待つ必要があるか（同期が動いていて、最初の起動で、端末に記録がない）。
  ///   - now: 待ち始める時刻。
  init(needed: Bool, now: Date, timeout: TimeInterval = FirstImportWait.timeout) {
    deadline = now.addingTimeInterval(timeout)
    phase = needed ? .waiting : .finished(.notNeeded)
  }

  var isWaiting: Bool { phase == .waiting }

  /// 最初の取り込みが終わった。
  mutating func importFinished() { finish(.imported) }

  /// 取り込みの出来事がエラーで終わった。
  mutating func importFailed() { finish(.failed) }

  /// 時刻が進んだ。期限を過ぎたら待つのをやめる。
  mutating func tick(now: Date) {
    if now >= deadline { finish(.timedOut) }
  }

  /// 期限までの残りの秒数（待っていなければ 0）。
  func remaining(now: Date) -> TimeInterval {
    isWaiting ? max(0, deadline.timeIntervalSince(now)) : 0
  }

  private mutating func finish(_ reason: Reason) {
    guard isWaiting else { return }
    phase = .finished(reason)
  }
}
