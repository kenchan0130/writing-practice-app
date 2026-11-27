import Testing

@testable import StrokeKit

@Suite("PalmRejection")
struct PalmRejectionTests {
  let rule = PalmRejection()

  func finger(radius: Double = 10, y: Double = 100, time: Double = 10) -> TouchCandidate {
    TouchCandidate(input: .finger, majorRadius: radius, y: y, areaHeight: 1000, time: time)
  }

  @Test("ふつうの指の接触は受け付ける")
  func acceptsFinger() {
    #expect(rule.accepts(finger(), lastPencilTime: nil, strokeInProgress: false))
  }

  @Test("面が大きい指の接触は手のひらとして捨てる")
  func rejectsLargeContact() {
    #expect(!rule.accepts(finger(radius: 60), lastPencilTime: nil, strokeInProgress: false))
  }

  @Test("下の端の帯から始まった指の接触は捨てる")
  func rejectsBottomBand() {
    #expect(!rule.accepts(finger(y: 970), lastPencilTime: nil, strokeInProgress: false))
  }

  @Test("Pencil を使ったすぐあとの指の接触は捨てる")
  func rejectsFingerAfterPencil() {
    #expect(!rule.accepts(finger(time: 10.5), lastPencilTime: 10, strokeInProgress: false))
    #expect(rule.accepts(finger(time: 12), lastPencilTime: 10, strokeInProgress: false))
  }

  @Test("書いている途中に増えた接触は捨てる")
  func rejectsWhileWriting() {
    let pencil = TouchCandidate(input: .pencil, majorRadius: 1, y: 100, areaHeight: 1000, time: 0)
    #expect(!rule.accepts(pencil, lastPencilTime: nil, strokeInProgress: true))
  }

  @Test("Pencil はいつも受け付ける（面の大きさや位置を見ない）")
  func acceptsPencil() {
    let pencil = TouchCandidate(input: .pencil, majorRadius: 0, y: 990, areaHeight: 1000, time: 0)
    #expect(rule.accepts(pencil, lastPencilTime: nil, strokeInProgress: false))
  }

  @Test("マウスなどで面の大きさが 0 でも受け付ける")
  func acceptsZeroRadius() {
    #expect(rule.accepts(finger(radius: 0), lastPencilTime: nil, strokeInProgress: false))
  }

  @Test("触れてすぐ面が広がった指の線は取り消す")
  func cancelsGrowingContact() {
    #expect(rule.shouldCancel(input: .finger, majorRadius: 50, elapsed: 0.03))
    #expect(!rule.shouldCancel(input: .finger, majorRadius: 50, elapsed: 0.5))
    #expect(!rule.shouldCancel(input: .pencil, majorRadius: 50, elapsed: 0.03))
  }
}

@Suite("PalmRejection の Pencil 優先（D191）")
struct PalmRejectionPencilFirstTests {
  let rule = PalmRejection()
  let pencil = TouchCandidate(input: .pencil, majorRadius: 1, y: 100, areaHeight: 1000, time: 5)
  let finger = TouchCandidate(input: .finger, majorRadius: 10, y: 100, areaHeight: 1000, time: 5)

  @Test("指の線を書いている途中に Pencil が触れたら、指の線を取り消して Pencil を書く")
  func pencilReplacesFinger() {
    #expect(rule.decide(pencil, lastPencilTime: nil, activeInput: .finger) == .replaceActive)
  }

  @Test("Pencil を書いている途中に増えた接触は、Pencil でも指でも捨てる")
  func ignoresExtraWhilePencil() {
    #expect(rule.decide(pencil, lastPencilTime: 4, activeInput: .pencil) == .reject)
    #expect(rule.decide(finger, lastPencilTime: 4, activeInput: .pencil) == .reject)
  }

  @Test("指の線を書いている途中に増えた指は捨てる")
  func ignoresExtraFinger() {
    #expect(rule.decide(finger, lastPencilTime: nil, activeInput: .finger) == .reject)
  }

  @Test("書いていないときは、これまでの決まりどおり")
  func idleFollowsAccepts() {
    #expect(rule.decide(finger, lastPencilTime: nil, activeInput: nil) == .accept)
    #expect(rule.decide(finger, lastPencilTime: 4.5, activeInput: nil) == .reject)
    #expect(rule.decide(pencil, lastPencilTime: 4.5, activeInput: nil) == .accept)
  }

  @Test("手のひらは、触れてから 0.3 秒のうちに広がれば取り消す")
  func growthWindowIsRealistic() {
    #expect(rule.growthWindow >= 0.2)
    #expect(rule.shouldCancel(input: .finger, majorRadius: 60, elapsed: 0.15))
    #expect(!rule.shouldCancel(input: .finger, majorRadius: 10, elapsed: 0.15))
    #expect(!rule.shouldCancel(input: .finger, majorRadius: 60, elapsed: 0.5))
  }

  @Test("太い指でしっかり動かして書いている線は、面が大きくても取り消さない")
  func keepsMovingFatFinger() {
    #expect(rule.shouldCancel(input: .finger, majorRadius: 60, elapsed: 0.1, travel: 5))
    #expect(!rule.shouldCancel(input: .finger, majorRadius: 60, elapsed: 0.1, travel: 80))
    #expect(!rule.shouldCancel(input: .finger, majorRadius: 45, elapsed: 0.1, travel: 0))
  }
}

@Suite("StrokeGeometry")
struct StrokeGeometryTests {
  @Test("マスの座標と 0〜1000 の座標を行き来できる")
  func gridRoundTrip() {
    let mapping = GridMapping(side: 500)
    let grid = mapping.toGrid(x: 250, y: 100)
    #expect(grid.x == 500 && grid.y == 200)
    let back = mapping.fromGrid(x: grid.x, y: grid.y)
    #expect(back.x == 250 && back.y == 100)
  }

  @Test("筆圧があれば筆圧で太さが変わる")
  func widthFromForce() {
    let width = StrokeWidth(base: 10, minRatio: 0.5, maxRatio: 1.5)
    #expect(width.width(force: 0, speed: 0) == 5)
    #expect(width.width(force: 1, speed: 0) == 15)
    #expect(width.width(force: 2, speed: 0) == 15)
  }

  @Test("筆圧がなければ速いほど細くなる")
  func widthFromSpeed() {
    let width = StrokeWidth(base: 10, minRatio: 0.5, fastSpeed: 1000)
    #expect(width.width(force: nil, speed: 0) == 10)
    #expect(width.width(force: nil, speed: 1000) == 5)
    #expect(width.width(force: nil, speed: 5000) == 5)
  }
}
