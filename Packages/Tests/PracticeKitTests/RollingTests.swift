import ContentModel
import Testing

@testable import PracticeKit

@Suite("傾けると転がる（§3.3・D133）")
struct RollingTests {
  private func run(
    _ start: RollState = RollState(), tilt: Double, seconds: Double, limit: Double = 100
  ) -> RollState {
    var state = start
    for _ in 0..<Int(seconds * 60) {
      state = Rolling.step(state, tilt: tilt, dt: 1.0 / 60, limit: limit)
    }
    return state
  }

  @Test("転がる物は、どれも まちの景色になることば")
  func wordsAreScenery() {
    for word in Rolling.words {
      #expect(
        WordCatalog.all.contains { $0.text == word && $0.kind == .scenery }, "\(word)")
    }
    #expect(Rolling.isRollable("りんご"))
    #expect(!Rolling.isRollable("いぬ"))
  }

  @Test("少しの傾きでは動かない")
  func deadZone() {
    #expect(Rolling.push(tilt: 0) == 0)
    #expect(Rolling.push(tilt: 0.05) == 0)
    #expect(Rolling.push(tilt: -0.09) == 0)
    #expect(run(tilt: 0.05, seconds: 3) == RollState())
  }

  @Test("傾けた向きへ転がる。強い傾きは同じ強さ")
  func rollsTowardTilt() {
    #expect(run(tilt: 0.3, seconds: 0.5).offset > 0)
    #expect(run(tilt: -0.3, seconds: 0.5).offset < 0)
    #expect(Rolling.push(tilt: 0.3) > 0)
    #expect(Rolling.push(tilt: 0.3) < 1)
    #expect(Rolling.push(tilt: 0.9) == 1)
    #expect(Rolling.push(tilt: -2) == -1)
    #expect(Rolling.push(tilt: .nan) == 0)
  }

  @Test("はしより遠くへは行かない。傾けたままなら、はしで止まる")
  func bounded() {
    var state = RollState()
    for _ in 0..<600 {
      state = Rolling.step(state, tilt: 1, dt: 1.0 / 60, limit: 100)
      #expect(abs(state.offset) <= 100)
    }
    #expect(state.offset == 100)
    #expect(state.isResting)
    let left = run(tilt: -1, seconds: 10)
    #expect(left.offset == -100)
    #expect(left.isResting)
  }

  @Test("傾きを もどすと、少し進んで止まる（その場に残る）")
  func stopsWhenLevel() {
    let moving = run(tilt: 0.5, seconds: 0.3)
    #expect(moving.velocity > 0)
    let rest = run(moving, tilt: 0, seconds: 5)
    #expect(rest.isResting)
    #expect(rest.offset >= moving.offset)
    #expect(rest.offset <= 100)
  }

  @Test("押すと、押したところの反対へ少し転がって止まる")
  func tap() {
    let range = -100.0...100.0
    let pushed = Rolling.tapped(RollState(), tappedRightSide: false, range: range)
    #expect(pushed.velocity > 0)
    let rest = run(pushed, tilt: 0, seconds: 5)
    #expect(rest.isResting)
    #expect(rest.offset > 20)
    #expect(rest.offset <= 100)
    #expect(Rolling.tapped(RollState(), tappedRightSide: true, range: range).velocity < 0)
    // はしにいるときは、中へ もどる。
    #expect(
      Rolling.tapped(RollState(offset: 100), tappedRightSide: false, range: range).velocity < 0)
    #expect(
      Rolling.tapped(RollState(offset: -100), tappedRightSide: true, range: range).velocity > 0)
  }

  @Test("左右で動ける はばが ちがっても、はんいの中")
  func unevenRange() {
    var state = RollState()
    for _ in 0..<600 {
      state = Rolling.step(state, tilt: -1, dt: 1.0 / 60, range: -20...100)
      #expect(state.offset >= -20)
    }
    #expect(state.offset == -20)
  }

  @Test("長い止まりのあとでも、飛ばない")
  func bigTimeStep() {
    let state = Rolling.step(RollState(velocity: 200), tilt: 0, dt: 30, limit: 100)
    #expect(state.offset <= 10)
  }

  @Test("転がった分だけ回る。右へは時計回り")
  func angle() {
    #expect(Rolling.angle(offset: 50, radius: 25) == -2)
    #expect(Rolling.angle(offset: -50, radius: 25) == 2)
    #expect(Rolling.angle(offset: 10, radius: 0) == -10)
  }
}
