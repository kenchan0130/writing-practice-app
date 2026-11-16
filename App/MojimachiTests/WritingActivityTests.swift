import Foundation
import Testing

@testable import Mojimachi

/// 「←」を効かせない時間（D101）。書いている間と、書き終えた直後の1秒。
@Suite("もどるボタンのロック")
@MainActor
struct WritingActivityTests {
  @Test("書く前は効く。書いている間は効かない")
  func whileWriting() {
    let activity = WritingActivity()
    #expect(!activity.isLocked())
    activity.began()
    #expect(activity.isLocked())
  }

  @Test("書き終えてから1秒は効かず、1秒たてば効く")
  func oneSecondAfter() {
    let activity = WritingActivity()
    let end = Date(timeIntervalSince1970: 1_000)
    activity.began()
    activity.ended(at: end)
    #expect(activity.isLocked(at: end.addingTimeInterval(0.5)))
    #expect(!activity.isLocked(at: end.addingTimeInterval(1.01)))
  }
}
