import Observation
import SwiftUI

/// 書いている間と、書き終えた直後の1秒は「←」を効かせないための印（D101）。
@MainActor
@Observable
final class WritingActivity {
  static let lockSeconds: TimeInterval = 1
  private(set) var isWriting = false
  private(set) var lastEnd: Date?

  func began() { isWriting = true }

  func ended(at date: Date = Date()) {
    isWriting = false
    lastEnd = date
  }

  func isLocked(at date: Date = Date()) -> Bool {
    if isWriting { return true }
    guard let lastEnd else { return false }
    return date.timeIntervalSince(lastEnd) < Self.lockSeconds
  }

  /// 入力の出来事から印を更新する。
  func track(_ event: StrokeInputEvent) {
    switch event {
    case .began: began()
    case .ended, .cancelled: ended()
    default: break
    }
  }
}

/// 「←」（D101）。利き手によらず左上に置く。押せる部分は 104pt 角。書いている間は効かない。
struct BackButton: View {
  var activity: WritingActivity
  var action: () -> Void

  var body: some View {
    TimelineView(.periodic(from: .now, by: 0.2)) { timeline in
      let locked = activity.isLocked(at: timeline.date)
      Button {
        guard !activity.isLocked() else { return }
        action()
      } label: {
        Image(systemName: "arrow.left")
          .font(.system(size: 40, weight: .bold))
          .frame(width: 104, height: 104)
          .background(Color.gray.opacity(0.15), in: .rect(cornerRadius: 24))
      }
      .buttonStyle(.plain)
      .opacity(locked ? 0.35 : 1)
    }
    .accessibilityLabel("もどる")
  }
}
