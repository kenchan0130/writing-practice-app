import XCTest

/// もじの地図 → カード → 書く画面と、書く画面のパネルを押して確かめる。
final class FlowLetterUITests: MojimachiUITestCase {
  // MARK: - 1. もじ → 地図 → カード → かく → もどる

  @MainActor func testMapCardWriteAndBack() {
    openMap()
    tap(button("そ"), "地図の そ")
    let write = button("かく")
    XCTAssertTrue(write.waitForExistence(timeout: 10), "字のカードが出ない")
    write.tap()
    XCTAssertTrue(
      app.otherElements["もじを かく ばしょ"].firstMatch.waitForExistence(timeout: 10),
      "書く画面が出ない")
    tap(button("もどる"), "書く画面の ←")
    XCTAssertTrue(button("かく").waitForExistence(timeout: 10), "カードへ戻らない")
    tap(button("もどる"), "カードの ←")
    XCTAssertTrue(button("そ").waitForExistence(timeout: 10), "地図へ戻らない")
    tap(button("もどる"), "地図の ←")
    XCTAssertTrue(button("まち").waitForExistence(timeout: 10), "ホームへ戻らない")
    XCTAssertTrue(button("ことば").exists)
  }

  // MARK: - 1b. 書く画面のパネル（D154）

  @MainActor private func openWriting(_ char: String) {
    openMap()
    tap(button(char), "地図の \(char)")
    tap(button("かく"), "カードの かく")
    XCTAssertTrue(
      app.otherElements["もじを かく ばしょ"].firstMatch.waitForExistence(timeout: 10), "書く画面が出ない")
  }

  @MainActor func testWritingPanelRowCellAndArrows() {
    openWriting("そ")
    let current = app.staticTexts["panelChar"].firstMatch
    XCTAssertTrue(current.waitForExistence(timeout: 10), "パネルの字が出ない")
    XCTAssertEqual(current.label, "そ")
    XCTAssertTrue(button("やりなおす").exists, "やりなおす が出ない")
    // 行の表の字を押すと、その字へ移る。
    tap(button("し"), "行の表の し")
    let shi = NSPredicate(format: "label == %@", "し")
    expectation(for: shi, evaluatedWith: current)
    waitForExpectations(timeout: 10)
    // 矢印で次の字へ。
    tap(button("つぎの もじ"), "つぎへの矢印")
    let moved = NSPredicate(format: "label != %@", "し")
    expectation(for: moved, evaluatedWith: current)
    waitForExpectations(timeout: 10)
    tap(button("まえの もじ"), "まえへの矢印")
    expectation(for: shi, evaluatedWith: current)
    waitForExpectations(timeout: 10)
  }
}
