import XCTest

/// しりとりの1ターンと、きょうの ことばを押して確かめる（D35・D45・D70・D182）。
/// `-simulateWord YES` で、書く画面はお手本どおりに自動で書く。`-today` と `-todayRegion` で日と地域を決める。
final class FlowShiritoriUITests: MojimachiUITestCase {
  override var extraLaunchArguments: [String] {
    ["-simulateWord", "YES", "-today", "2026-07-20", "-todayRegion", "JP"]
  }

  @MainActor private func wordHeader() -> XCUIElement {
    app.descendants(matching: .any)["wordHeader"].firstMatch
  }

  @MainActor func testShiritoriOneTurn() {
    tap(button("ことば"), "ホームの ことば")
    tap(button("しりとり"), "まちの地図の しりとり")
    let board = app.descendants(matching: .any)["shiritoriBoard"].firstMatch
    XCTAssertTrue(board.waitForExistence(timeout: 10), "しりとりの画面が出ない")
    let characterWord = app.descendants(matching: .any)["shiritoriCharacterWord"].firstMatch
    XCTAssertTrue(characterWord.waitForExistence(timeout: 10), "主人公のことばが出ない")
    // 候補は2〜3枚。
    let cards = app.buttons.matching(identifier: "shiritoriCard")
    XCTAssertTrue(cards.firstMatch.waitForExistence(timeout: 10), "候補が出ない")
    XCTAssertGreaterThanOrEqual(cards.count, 2)
    XCTAssertLessThanOrEqual(cards.count, 3)
    let picked = cards.firstMatch.label
    cards.firstMatch.tap()
    // 選んだことばだけを書く。書き終えたら「つぎへ」。
    XCTAssertTrue(wordHeader().waitForExistence(timeout: 10), "書く画面が出ない")
    XCTAssertEqual(wordHeader().label, picked)
    // 「←」で戻ると、選び直せる。
    tap(button("もどる"), "書く画面の ←")
    XCTAssertTrue(cards.firstMatch.waitForExistence(timeout: 10), "しりとりへ戻らない")
    cards.firstMatch.tap()
    XCTAssertTrue(wordHeader().waitForExistence(timeout: 10))
    tap(button("つぎへ"), "つぎへ")
    // しりとりの画面に戻り、書いたことばが つながっている。
    let history = app.descendants(matching: .any)["shiritoriHistory"].firstMatch
    XCTAssertTrue(history.waitForExistence(timeout: 10), "ことばのつながりが出ない")
    XCTAssertTrue(history.label.contains(picked), "書いたことばがつながらない")
    // 次の候補が出るか、まいった・おわりで「もういっかい」が出る。
    let again = app.buttons["shiritoriAgain"].firstMatch
    XCTAssertTrue(
      cards.firstMatch.waitForExistence(timeout: 10) || again.waitForExistence(timeout: 10),
      "次の番も、おわりも出ない")
    // 「←」でまちの地図へ。
    tap(button("もどる"), "しりとりの ←")
    XCTAssertTrue(button("えき").waitForExistence(timeout: 10), "まちの地図へ戻らない")
  }

  @MainActor func testTodayWordOpensWriting() {
    let card = app.buttons["todayWordCard"].firstMatch
    XCTAssertTrue(card.waitForExistence(timeout: 10), "きょうの ことばが出ない")
    let word = try! XCTUnwrap(card.value as? String)
    XCTAssertFalse(word.isEmpty)
    card.tap()
    XCTAssertTrue(wordHeader().waitForExistence(timeout: 10), "書く画面が出ない")
    XCTAssertEqual(wordHeader().label, word)
    // 「←」でホームへ。同じことばのまま。
    tap(button("もどる"), "書く画面の ←")
    let again = app.buttons["todayWordCard"].firstMatch
    XCTAssertTrue(again.waitForExistence(timeout: 10), "ホームへ戻らない")
    XCTAssertEqual(again.value as? String, word, "開き直すと、ことばが変わった")
  }
}
