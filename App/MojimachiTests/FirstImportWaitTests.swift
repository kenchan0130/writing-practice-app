import Foundation
import Testing

@testable import Mojimachi

/// 2台目の最初の取り込み待ち（D63）。時計と出来事を渡して確かめる。
@Suite("最初の取り込み待ち")
struct FirstImportWaitTests {
  let start = Date(timeIntervalSince1970: 1_000_000)

  @Test("待つ必要がなければ、はじめから待たない")
  func notNeeded() {
    let wait = FirstImportWait(needed: false, now: start)
    #expect(!wait.isWaiting)
    #expect(wait.phase == .finished(.notNeeded))
  }

  @Test("取り込みが終わったら、すぐ待つのをやめる")
  func imported() {
    var wait = FirstImportWait(needed: true, now: start)
    #expect(wait.isWaiting)
    wait.tick(now: start.addingTimeInterval(3))
    #expect(wait.isWaiting)
    wait.importFinished()
    #expect(wait.phase == .finished(.imported))
  }

  @Test("10秒たったら、取り込みが来なくても待つのをやめる")
  func timesOut() {
    var wait = FirstImportWait(needed: true, now: start)
    wait.tick(now: start.addingTimeInterval(9.9))
    #expect(wait.isWaiting)
    #expect(wait.remaining(now: start.addingTimeInterval(9)) == 1)
    wait.tick(now: start.addingTimeInterval(10))
    #expect(wait.phase == .finished(.timedOut))
    #expect(wait.remaining(now: start) == 0)
  }

  @Test("取り込みがエラーで終わったら、待たない")
  func failed() {
    var wait = FirstImportWait(needed: true, now: start)
    wait.importFailed()
    #expect(wait.phase == .finished(.failed))
  }

  @Test("終わったあとの出来事では、理由が変わらない")
  func finishedStays() {
    var wait = FirstImportWait(needed: true, now: start)
    wait.importFinished()
    wait.tick(now: start.addingTimeInterval(60))
    wait.importFailed()
    #expect(wait.phase == .finished(.imported))
  }
}
