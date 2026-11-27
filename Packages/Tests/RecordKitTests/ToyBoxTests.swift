import Foundation
import Testing

@testable import RecordKit

@Suite("おもちゃばこの計算（D74・D82・D185）")
struct ToyBoxTests {
  static let base = Date(timeIntervalSince1970: 1_800_000_000)

  static func id(_ n: Int) -> UUID {
    UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", n))!
  }

  /// n 番目に手に入れた物（1分ごと）。
  static func item(_ n: Int, word: String? = nil) -> ToyBoxItem {
    ToyBoxItem(id: id(n), word: word ?? "w\(n)", date: base.addingTimeInterval(Double(n) * 60))
  }

  static func items(_ count: Int) -> [ToyBoxItem] { (0..<count).map { item($0) } }

  @Test("上限までは、手に入れた順に置き場所へ入り、おもちゃばこは空")
  func fills() {
    let shelf = ToyBox.arrange(items: Self.items(3), moves: [], capacity: 4)
    #expect(shelf.slots == [Self.id(0), Self.id(1), Self.id(2), nil])
    #expect(shelf.boxed.isEmpty)
  }

  @Test("上限を超えると、いちばん古い物が おもちゃばこに入り、新しい物が その置き場所に入る")
  func overflow() {
    let shelf = ToyBox.arrange(items: Self.items(6), moves: [], capacity: 4)
    #expect(shelf.slots == [Self.id(4), Self.id(5), Self.id(2), Self.id(3)])
    // おもちゃばこは、出していた時間が新しい順。
    #expect(shelf.boxed == [Self.id(1), Self.id(0)])
    #expect(shelf.slot(of: Self.id(5)) == 1)
    #expect(shelf.slot(of: Self.id(0)) == nil)
  }

  @Test("行がない場所では、出ている物は新しい方から上限の数（今までのまちと同じ）")
  func newestShown() {
    for count in 0...30 {
      for capacity in [1, 6, 8, 12] {
        let shelf = ToyBox.arrange(items: Self.items(count), moves: [], capacity: capacity)
        let expected = Set((0..<count).suffix(capacity).map { Self.id($0) })
        #expect(Set(shelf.shown) == expected)
        #expect(shelf.shown.count + shelf.boxed.count == count)
        // 置き場所は、手に入れた順の番号を上限で割った余り（D173 のこうえんと同じ）。
        for n in (0..<count).suffix(capacity) {
          #expect(shelf.slot(of: Self.id(n)) == n % capacity)
        }
      }
    }
  }

  @Test("出すと、出してからいちばん長い物と入れ替わる。行は「出した」と「しまった」")
  func takeOut() {
    let items = Self.items(6)
    let now = Self.base.addingTimeInterval(3600)
    let rows = ToyBox.takeOut(Self.id(0), items: items, moves: [], capacity: 4, date: now)
    #expect(rows.map(\.action) == [.takeOut, .putAway])
    #expect(rows.map(\.objectID) == [Self.id(0), Self.id(2)])
    let shelf = ToyBox.arrange(items: items, moves: rows, capacity: 4)
    // いちばん長く出ていた 2 の置き場所に、0 が入る。ほかの物は動かない。
    #expect(shelf.slots == [Self.id(4), Self.id(5), Self.id(0), Self.id(3)])
    #expect(shelf.boxed == [Self.id(2), Self.id(1)])
  }

  @Test("もう出ている物・知らない物は、出しても行が増えない")
  func takeOutNothing() {
    let items = Self.items(6)
    let now = Self.base.addingTimeInterval(3600)
    #expect(ToyBox.takeOut(Self.id(5), items: items, moves: [], capacity: 4, date: now).isEmpty)
    #expect(ToyBox.takeOut(Self.id(99), items: items, moves: [], capacity: 4, date: now).isEmpty)
  }

  @Test("時計がずれていても、出した物は出る")
  func takeOutWithOldClock() {
    let items = Self.items(6)
    let rows = ToyBox.takeOut(
      Self.id(0), items: items, moves: [], capacity: 4, date: Self.base.addingTimeInterval(-999))
    let shelf = ToyBox.arrange(items: items, moves: rows, capacity: 4)
    #expect(shelf.shown.contains(Self.id(0)))
  }

  @Test("出したあとで新しい物を手に入れると、出してからいちばん長い物がしまわれる")
  func newItemAfterTakeOut() {
    var items = Self.items(6)
    let rows = ToyBox.takeOut(
      Self.id(0), items: items, moves: [], capacity: 4, date: Self.base.addingTimeInterval(3600))
    items.append(
      ToyBoxItem(id: Self.id(6), word: "w6", date: Self.base.addingTimeInterval(7200)))
    let shelf = ToyBox.arrange(items: items, moves: rows, capacity: 4)
    // 出ていたのは 3・4・5・0。いちばん長いのは 3。
    #expect(Set(shelf.shown) == [Self.id(4), Self.id(5), Self.id(0), Self.id(6)])
    #expect(shelf.slot(of: Self.id(6)) == 3)
    #expect(shelf.boxed.first == Self.id(3))
  }

  @Test("しまうと、おもちゃばこの いちばん新しい物が その置き場所に入る")
  func putAway() {
    let items = Self.items(6)
    let put = ToyBoxMove(
      date: Self.base.addingTimeInterval(3600), objectID: Self.id(5), action: .putAway)
    let shelf = ToyBox.arrange(items: items, moves: [put], capacity: 4)
    #expect(shelf.slots == [Self.id(4), Self.id(1), Self.id(2), Self.id(3)])
    #expect(shelf.boxed.contains(Self.id(5)))
    // おもちゃばこが空なら、置き場所が空く。
    let few = ToyBox.arrange(
      items: Self.items(2),
      moves: [
        ToyBoxMove(date: Self.base.addingTimeInterval(3600), objectID: Self.id(0), action: .putAway)
      ], capacity: 4)
    #expect(few.slots == [nil, Self.id(1), nil, nil])
    #expect(few.boxed == [Self.id(0)])
  }

  @Test("行の並びがちがっても、同じ行なら同じ結果（2台の iPad。D82）")
  func orderIndependent() {
    var generator = SystemRandomNumberGenerator()
    let items = Self.items(14)
    var moves: [ToyBoxMove] = []
    for step in 0..<10 {
      let now = Self.base.addingTimeInterval(4000 + Double(step) * 30)
      let shelf = ToyBox.arrange(items: items, moves: moves, capacity: 5)
      guard let pick = shelf.boxed.randomElement(using: &generator) else { continue }
      moves += ToyBox.takeOut(pick, items: items, moves: moves, capacity: 5, date: now)
    }
    let expected = ToyBox.arrange(items: items, moves: moves, capacity: 5)
    #expect(expected.shown.count == 5)
    for _ in 0..<20 {
      let shelf = ToyBox.arrange(
        items: items.shuffled(using: &generator), moves: moves.shuffled(using: &generator),
        capacity: 5)
      #expect(shelf.slots == expected.slots)
      #expect(shelf.boxed == expected.boxed)
    }
    // 同じ行が2つ届いても、変わらない。
    #expect(ToyBox.arrange(items: items + items, moves: moves + moves, capacity: 5) == expected)
  }

  @Test("時間が同じ行は、物の ID の順")
  func sameTime() {
    let date = Self.base
    let items = [3, 1, 2].map { ToyBoxItem(id: Self.id($0), word: "w\($0)", date: date) }
    let shelf = ToyBox.arrange(items: items, moves: [], capacity: 2)
    #expect(shelf.slots == [Self.id(3), Self.id(2)])
    #expect(shelf.boxed == [Self.id(1)])
  }

  @Test("物は消えない。出ている物と おもちゃばこの物を合わせると、全部")
  func nothingIsLost() {
    var generator = SystemRandomNumberGenerator()
    for count in [0, 1, 7, 8, 9, 25] {
      let items = Self.items(count)
      var moves: [ToyBoxMove] = []
      for step in 0..<12 {
        let shelf = ToyBox.arrange(items: items, moves: moves, capacity: 8)
        #expect(Set(shelf.shown).union(shelf.boxed) == Set(items.map(\.id)))
        #expect(shelf.shown.count == min(count, 8))
        #expect(Set(shelf.shown).count == shelf.shown.count)
        guard let pick = shelf.boxed.randomElement(using: &generator) else { break }
        moves += ToyBox.takeOut(
          pick, items: items, moves: moves, capacity: 8,
          date: Self.base.addingTimeInterval(9000 + Double(step)))
      }
    }
  }

  @Test("同じことばの物は、新しい3つまで（D74）")
  func threePerWord() {
    let items =
      (0..<5).map { Self.item($0, word: "いす") } + [Self.item(5, word: "なべ")]
    let kept = ToyBox.newestPerWord(items)
    #expect(kept.map(\.id) == [2, 3, 4, 5].map { Self.id($0) })
    #expect(ToyBox.newestPerWord([]).isEmpty)
  }

  @Test("知らない物の行は、数えない")
  func unknownMoves() {
    let move = ToyBoxMove(date: Self.base, objectID: Self.id(99), action: .takeOut)
    let shelf = ToyBox.arrange(items: Self.items(2), moves: [move], capacity: 4)
    #expect(shelf.shown == [Self.id(0), Self.id(1)])
  }
}
