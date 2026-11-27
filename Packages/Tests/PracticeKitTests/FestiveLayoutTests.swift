import ContentModel
import Testing

@testable import PracticeKit

@Suite("季節の飾りの置き場所（§3.4）")
struct FestiveLayoutTests {
  static let words = WordCatalog.all.filter { $0.kind == .seasonal }.map(\.text)
  static let area = FestiveLayout.area(landMinX: 900, landWidth: 2000, screenWidth: 1000)

  @Test("季節の飾りは、どれも置き方が決まっている。ほかのことばには ない")
  func everyWord() {
    #expect(Self.words.count == 17)
    for word in Self.words {
      #expect(FestiveLayout.style(for: word) != nil, "\(word)")
    }
    for entry in WordCatalog.all where entry.kind != .seasonal {
      #expect(FestiveLayout.style(for: entry.text) == nil, "\(entry.text)")
    }
    #expect(FestiveLayout.style(for: "ふうりん") == .hang)
    #expect(FestiveLayout.style(for: "こいのぼり") == .stand)
    #expect(FestiveLayout.style(for: "ゆきだるま") == .stand)
    #expect(FestiveLayout.style(for: "はなび") == .sky)
    // どの置き方にも、ことばがある。
    for style in FestiveStyle.allCases {
      #expect(Self.words.contains { FestiveLayout.style(for: $0) == style })
    }
  }

  @Test("季節の飾りは まちの おもちゃばこに入る場所で、6つまで。同じことばは 1つだけ")
  func shelfGroup() {
    #expect(ShelfGroup.group(kind: .seasonal, word: "うちわ") == .festive)
    #expect(ShelfGroup.festive.capacity == FestiveLayout.capacity)
    #expect(FestiveLayout.capacity == 6)
    #expect(ShelfGroup.town.contains(.festive))
    #expect(!ShelfGroup.house.contains(.festive))
    #expect(ShelfGroup.festive.perWord == 1)
    #expect(ShelfGroup.park.perWord == 3)
  }

  @Test("はた は陸のまちの中に収まる。まちが せまくても はみ出さない")
  func areaInsideLand() {
    #expect(Self.area.lowerBound > 900)
    #expect(Self.area.upperBound <= 2900)
    #expect(abs((Self.area.upperBound - Self.area.lowerBound) - 1200) < 0.001)
    let narrow = FestiveLayout.area(landMinX: 0, landWidth: 600, screenWidth: 1000)
    #expect(narrow.lowerBound >= 0)
    #expect(narrow.upperBound <= 600)
    let none = FestiveLayout.area(landMinX: 0, landWidth: 0, screenWidth: 1000)
    #expect(none.lowerBound == none.upperBound)
  }

  @Test("置き場所は6つで、はた の下に左から並び、物の幅より はなれている")
  func spots() {
    let xs = (0..<FestiveLayout.capacity).map { FestiveLayout.spotX(index: $0, in: Self.area) }
    #expect(xs == xs.sorted())
    #expect(Set(xs).count == FestiveLayout.capacity)
    for x in xs { #expect(Self.area.contains(x)) }
    // 物の絵（まちの高さ 700 のとき 約160。倍率 0.85）より、となりとの間が広い。
    for (a, b) in zip(xs, xs.dropFirst()) { #expect(b - a > 160 * 0.85) }
    // 番号が 6 を超えても、6つの場所を回る。
    #expect(FestiveLayout.spotX(index: 6, in: Self.area) == xs[0])
    #expect(FestiveLayout.spotX(index: -1, in: Self.area) == xs[5])
  }

  @Test("つるす物は ひもの少し下、立てる物は草の奥、空の物は ひもより上")
  func heights() {
    for index in 0..<FestiveLayout.capacity {
      let hang = FestiveLayout.spot(index: index, style: .hang, in: Self.area)
      let stand = FestiveLayout.spot(index: index, style: .stand, in: Self.area)
      let sky = FestiveLayout.spot(index: index, style: .sky, in: Self.area)
      #expect(hang.x == stand.x && stand.x == sky.x)
      #expect(hang.ropeY == FestiveLayout.ropeY(at: hang.x, in: Self.area))
      #expect(hang.yFraction < hang.ropeY ?? 0)
      #expect(stand.ropeY == nil && sky.ropeY == nil)
      #expect(stand.yFraction < FestiveLayout.poleBaseY)
      // 動物の通る草（いちばん奥が 0.32）より奥。
      #expect(stand.yFraction > TownLayout.animalLaneY.max() ?? 0)
      #expect(sky.yFraction > FestiveLayout.poleTopY)
      #expect(sky.yFraction < 1)
      for spot in [hang, stand, sky] { #expect(spot.scale > 0.5 && spot.scale <= 1) }
    }
  }

  @Test("ひもは 柱で高く、間の真ん中で いちばん低い")
  func rope() {
    let garland = FestiveLayout.garland(in: Self.area)
    #expect(garland.poles.count == FestiveLayout.spans + 1)
    #expect(garland.poles.first == Self.area.lowerBound)
    #expect(abs((garland.poles.last ?? 0) - Self.area.upperBound) < 0.001)
    for pole in garland.poles {
      #expect(abs(FestiveLayout.ropeY(at: pole, in: Self.area) - FestiveLayout.poleTopY) < 0.0001)
    }
    for (a, b) in zip(garland.poles, garland.poles.dropFirst()) {
      let middle = FestiveLayout.ropeY(at: (a + b) / 2, in: Self.area)
      #expect(abs(middle - (FestiveLayout.poleTopY - FestiveLayout.sag)) < 0.0001)
    }
    // はんいの外でも、柱の高さを超えない。
    #expect(FestiveLayout.ropeY(at: -50, in: Self.area) == FestiveLayout.poleTopY)
    #expect(FestiveLayout.ropeY(at: 9999, in: Self.area) <= FestiveLayout.poleTopY)
  }

  @Test("旗は ひもの上に並び、となりと色がちがい、置き場所の真上と柱には来ない")
  func flags() {
    let garland = FestiveLayout.garland(in: Self.area)
    #expect(garland.flags.count == FestiveLayout.spans * FestiveLayout.flagsPerSpan)
    let spots = (0..<FestiveLayout.capacity).map { FestiveLayout.spotX(index: $0, in: Self.area) }
    for (a, b) in zip(garland.flags, garland.flags.dropFirst()) {
      #expect(a.x < b.x)
      #expect(a.color != b.color)
    }
    for flag in garland.flags {
      #expect(flag.yFraction == FestiveLayout.ropeY(at: flag.x, in: Self.area))
      #expect((0..<FestiveLayout.flagColors).contains(flag.color))
      for x in spots { #expect(abs(flag.x - x) > 10) }
      for pole in garland.poles { #expect(abs(flag.x - pole) > 10) }
    }
  }

  @Test("立てる物の はばは、置き場所を真ん中にする")
  func standSpan() {
    let spot = FestiveLayout.spot(index: 2, style: .stand, in: Self.area)
    let span = FestiveLayout.standSpan(spot, objectWidth: 160)
    #expect(abs((span.lowerBound + span.upperBound) / 2 - spot.x) < 0.001)
    #expect(span.upperBound - span.lowerBound > 100)
  }

  @Test("動きを減らすときは止まる。つるす物は、立てる物より大きく ゆれる")
  func motion() {
    for style in FestiveStyle.allCases {
      #expect(FestiveLayout.motion(style, reduceMotion: true) == nil)
      let motion = FestiveLayout.motion(style, reduceMotion: false)
      #expect(motion != nil)
      #expect((motion?.period ?? 0) >= 2)
      // ゆっくり・小さく（光の点滅にしない）。
      #expect((motion?.angle ?? 1) <= 0.12)
      #expect((motion?.pulse ?? 1) <= 0.1)
    }
    let hang = FestiveLayout.motion(.hang, reduceMotion: false)
    let stand = FestiveLayout.motion(.stand, reduceMotion: false)
    #expect((hang?.angle ?? 0) > (stand?.angle ?? 0))
    #expect((FestiveLayout.motion(.sky, reduceMotion: false)?.pulse ?? 0) > 0)
  }
}
