import Testing

@testable import RecordKit

@Suite("字の育ち方の名前（D151）")
struct GrowthTests {
  @Test("地図の4つの状態に、たね・め・つぼみ・はなの名前が付く")
  func names() {
    #expect(MapState.notYet.growth.name == "たね")
    #expect(MapState.practicing.growth.name == "め")
    #expect(MapState.traced.growth.name == "つぼみ")
    #expect(MapState.wroteAlone.growth.name == "はな")
    #expect(GrowthStage.allCases.map(\.meaning) == ["まだ", "れんしゅうちゅう", "なぞって かけた", "ひとりで かけた"])
  }

  @Test("文字の種類の段階は、はなの割合で決まる（80字）")
  func stagesFor80() {
    #expect(ScriptGrowth.stage(flowers: 0, total: 80) == .seed)
    #expect(ScriptGrowth.stage(flowers: 7, total: 80) == .seed)
    #expect(ScriptGrowth.stage(flowers: 8, total: 80) == .sprout2)
    #expect(ScriptGrowth.stage(flowers: 31, total: 80) == .sprout2)
    #expect(ScriptGrowth.stage(flowers: 32, total: 80) == .bud)
    #expect(ScriptGrowth.stage(flowers: 63, total: 80) == .bud)
    #expect(ScriptGrowth.stage(flowers: 64, total: 80) == .garden)
    #expect(ScriptGrowth.stage(flowers: 80, total: 80) == .garden)
  }

  @Test("字の数が違っても、同じ割合で上がる（26字）")
  func stagesFor26() {
    #expect(ScriptGrowth.stage(flowers: 2, total: 26) == .seed)  // 7.7%
    #expect(ScriptGrowth.stage(flowers: 3, total: 26) == .sprout2)  // 11.5%
    #expect(ScriptGrowth.stage(flowers: 10, total: 26) == .sprout2)  // 38%
    #expect(ScriptGrowth.stage(flowers: 11, total: 26) == .bud)  // 42%
    #expect(ScriptGrowth.stage(flowers: 20, total: 26) == .bud)  // 77%
    #expect(ScriptGrowth.stage(flowers: 21, total: 26) == .garden)  // 81%
  }

  @Test("字が0でも壊れない。はなが増えると段階は下がらない")
  func edges() {
    #expect(ScriptGrowth.stage(flowers: 0, total: 0) == .seed)
    #expect(ScriptGrowth.stage(flowers: -1, total: 10) == .seed)
    var last = ScriptGrowth.seed
    for flowers in 0...71 {
      let now = ScriptGrowth.stage(flowers: flowers, total: 71)
      #expect(now >= last)
      last = now
    }
  }

  @Test("地図の状態の一覧から、はなだけを数える")
  func fromStates() {
    let states: [MapState] = [.wroteAlone, .wroteAlone, .traced, .practicing, .notYet]
    #expect(ScriptGrowth.stage(of: states, total: 5) == .bud)  // 2/5 = 40%
    #expect(ScriptGrowth.stage(of: states, total: 50) == .seed)
  }

  @Test("次の段階まであと何輪か")
  func toNext() {
    #expect(ScriptGrowth.flowersToNext(flowers: 0, total: 80) == 8)
    #expect(ScriptGrowth.flowersToNext(flowers: 8, total: 80) == 24)
    #expect(ScriptGrowth.flowersToNext(flowers: 32, total: 80) == 32)
    #expect(ScriptGrowth.flowersToNext(flowers: 64, total: 80) == nil)
    // 26字: 10% は 2.6 → 3輪
    #expect(ScriptGrowth.flowersToNext(flowers: 0, total: 26) == 3)
    for flowers in 0..<26 {
      if let more = ScriptGrowth.flowersToNext(flowers: flowers, total: 26) {
        #expect(
          ScriptGrowth.stage(flowers: flowers + more, total: 26)
            > ScriptGrowth.stage(flowers: flowers, total: 26))
      }
    }
  }

  @Test("行の字がすべてはなになったら、はなばたけ")
  func rowGarden() {
    #expect(RowGrowth.isGarden([.wroteAlone, .wroteAlone, .wroteAlone]))
    #expect(!RowGrowth.isGarden([.wroteAlone, .traced, .wroteAlone]))
    #expect(!RowGrowth.isGarden([]))
  }
}
