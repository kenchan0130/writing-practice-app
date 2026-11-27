import Foundation

/// 途中でペンを離した線（続きから書く。D56 ③・D191）を、画面の線の並びの中で扱う道具。
/// いま書き終えた線は並びの最後、それより前の途中の線は `pieces` 個。
extension Array {
  /// 最後の `pieces + 1` 個を、1つにまとめる。
  mutating func mergeTail(pieces: Int, using merge: ([Element]) -> Element) {
    let count = pieces + 1
    guard pieces > 0, self.count >= count else { return }
    let tail = Array(suffix(count))
    removeLast(count)
    append(merge(tail))
  }

  /// 最後の `pieces + 1` 個を消す（書き直しのとき）。
  mutating func removeTail(pieces: Int) {
    removeLast(Swift.min(pieces + 1, count))
  }

  /// 最後より前の `pieces` 個だけ消す（最後は新しい線として残す）。
  mutating func removeBeforeLast(pieces: Int) {
    guard pieces > 0, count > pieces, let last else { return }
    removeLast(pieces + 1)
    append(last)
  }
}
