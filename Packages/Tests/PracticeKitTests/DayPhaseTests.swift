import Testing

@testable import PracticeKit

@Suite("まちの時間帯（§3.4）")
struct DayPhaseTests {
  @Test("時から時間帯を決める")
  func phases() {
    #expect(DayPhase.of(hour: 7) == .morning)
    #expect(DayPhase.of(hour: 13) == .day)
    #expect(DayPhase.of(hour: 18) == .evening)
    #expect(DayPhase.of(hour: 21) == .night)
  }

  @Test("さかい目")
  func boundaries() {
    #expect(DayPhase.of(hour: 4) == .night)
    #expect(DayPhase.of(hour: 5) == .morning)
    #expect(DayPhase.of(hour: 9) == .morning)
    #expect(DayPhase.of(hour: 10) == .day)
    #expect(DayPhase.of(hour: 15) == .day)
    #expect(DayPhase.of(hour: 16) == .evening)
    #expect(DayPhase.of(hour: 18) == .evening)
    #expect(DayPhase.of(hour: 19) == .night)
    #expect(DayPhase.of(hour: 0) == .night)
    #expect(DayPhase.of(hour: 23) == .night)
  }

  @Test("どの時にも時間帯があり、4つとも出る。範囲の外の数も受ける")
  func everyHour() {
    #expect(Set((0..<24).map(DayPhase.of(hour:))) == Set(DayPhase.allCases))
    #expect(DayPhase.of(hour: 24) == DayPhase.of(hour: 0))
    #expect(DayPhase.of(hour: 31) == .morning)
    #expect(DayPhase.of(hour: -3) == .night)
  }

  @Test("眠そうにするのは夜だけ")
  func sleepy() {
    #expect(DayPhase.allCases.filter(\.isSleepy) == [.night])
  }
}
