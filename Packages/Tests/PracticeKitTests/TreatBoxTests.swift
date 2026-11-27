import Testing

@testable import PracticeKit

@Suite("おたのしみ ボックスの中身（§3.3・D54）")
struct TreatBoxTests {
  let day = CalendarDay(year: 2026, month: 11, day: 27)

  @Test("ステッカーは 24枚で、名前は かぶらない")
  func catalog() {
    #expect(TreatBox.stickers.count == 24)
    #expect(Set(TreatBox.stickers).count == 24)
  }

  @Test("同じ子・同じ日なら、いつ あけても同じ")
  func deterministic() {
    let a = TreatBox.nextSticker(owned: [], day: day, childID: "child-a")
    let b = TreatBox.nextSticker(owned: [], day: day, childID: "child-a")
    #expect(a != nil)
    #expect(a == b)
  }

  @Test("子や日がちがえば、ちがう並びになる")
  func variesByChildAndDay() {
    var byDay = Set<String>()
    var byChild = Set<String>()
    for offset in 1...28 {
      let other = CalendarDay(year: 2026, month: 12, day: offset)
      byDay.insert(TreatBox.nextSticker(owned: [], day: other, childID: "child-a") ?? "")
      byChild.insert(TreatBox.nextSticker(owned: [], day: day, childID: "child-\(offset)") ?? "")
    }
    #expect(byDay.count > 6)
    #expect(byChild.count > 6)
  }

  @Test("まだ持っていないものを先に出す")
  func prefersUnseen() {
    for missing in TreatBox.stickers {
      let owned = Set(TreatBox.stickers).subtracting([missing])
      #expect(TreatBox.nextSticker(owned: owned, day: day, childID: "c") == missing)
    }
    // 毎日あけると、24日で全部そろう。
    var owned = Set<String>()
    for offset in 0..<24 {
      let next = TreatBox.nextSticker(
        owned: owned, day: CalendarDay(year: 2027, month: 1, day: 1 + offset), childID: "c")
      #expect(next.map { !owned.contains($0) } == true)
      if let next { owned.insert(next) }
    }
    #expect(owned == Set(TreatBox.stickers))
  }

  @Test("全部持っていれば、どれからでも出す")
  func allOwned() {
    let next = TreatBox.nextSticker(owned: Set(TreatBox.stickers), day: day, childID: "c")
    #expect(next.map(TreatBox.stickers.contains) == true)
  }

  @Test("ステッカーがなければ nil")
  func empty() {
    #expect(TreatBox.nextSticker(from: [], owned: [], day: day, childID: "c") == nil)
  }
}
