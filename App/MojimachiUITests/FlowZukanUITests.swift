import XCTest

/// ずかんと もじから さがす（D181）を押して確かめる。`-seedZukan YES` で、書いたことばと書けた字を入れる。
final class FlowZukanUITests: MojimachiUITestCase {
  @MainActor private func relaunchSeeded() {
    app.terminate()
    app.launchArguments += ["-seedZukan", "YES"]
    app.launch()
  }

  @MainActor private func card(_ word: String) -> XCUIElement {
    app.descendants(matching: .any)["zukan-\(word)"].firstMatch
  }

  @MainActor func testZukanStarsSilhouetteAndWrite() {
    relaunchSeeded()
    tap(button("ことば"), "ホームの ことば")
    tap(button("ずかん"), "下の帯の ずかん")
    // 書いたことば: ★の数が読み上げに出る（3回以上でも3）。
    XCTAssertTrue(card("くるま").waitForExistence(timeout: 10), "ずかんが出ない")
    XCTAssertEqual(card("くるま").label, "くるま、ほし 2")
    // 地図の場所の順（どうぶつえん → もり → おうち）に、下へ進みながら確かめる。
    scrollTo(card("ぞう"))
    XCTAssertEqual(card("ぞう").label, "ぞう、ほし 3")
    scrollTo(card("きりん"))
    XCTAssertEqual(card("きりん").label, "きりん、ほし 1")
    // まだ書いていないことばは影絵。
    scrollTo(card("くま"))
    XCTAssertEqual(card("くま").label, "まだ かいていない ことば")
    scrollTo(card("いぬ"))
    XCTAssertEqual(card("いぬ").label, "いぬ、ほし 3")
    scrollTo(card("うさぎ"))
    card("うさぎ").tap()
    let write = button("このことばを かく")
    if !write.waitForExistence(timeout: 10) { XCTFail(app.debugDescription) }
    write.tap()
    let header = app.descendants(matching: .any)["wordHeader"].firstMatch
    XCTAssertTrue(header.waitForExistence(timeout: 10), "書く画面が出ない")
    XCTAssertEqual(header.label, "うさぎ")
    // 「←」でずかんへ、もう一度で まちの地図へ。
    tap(button("もどる"), "書く画面の ←")
    XCTAssertTrue(card("くるま").waitForExistence(timeout: 10), "ずかんへ戻らない")
    tap(button("もどる"), "ずかんの ←")
    XCTAssertTrue(button("えき").waitForExistence(timeout: 10), "まちの地図へ戻らない")
  }

  @MainActor private func scrollTo(_ element: XCUIElement) {
    var tries = 0
    while !(element.exists && element.isHittable), tries < 30 {
      app.swipeUp()
      tries += 1
    }
  }

  @MainActor func testSearchByLetter() {
    relaunchSeeded()
    openMap()
    // 書けた字には「ことばを さがす」が出る。
    tap(button("い"), "地図の い")
    let search = app.buttons["searchWords"].firstMatch
    XCTAssertTrue(search.waitForExistence(timeout: 10), "ことばを さがす が出ない")
    search.tap()
    tap(button("いぬ"), "いぬのカード")
    let header = app.descendants(matching: .any)["wordHeader"].firstMatch
    XCTAssertTrue(header.waitForExistence(timeout: 10), "書く画面が出ない")
    XCTAssertEqual(header.label, "いぬ")
    tap(button("もどる"), "書く画面の ←")
    XCTAssertTrue(button("いぬ").waitForExistence(timeout: 10), "さがす画面へ戻らない")
    tap(button("もどる"), "さがす画面の ←")
    XCTAssertTrue(app.buttons["searchWords"].firstMatch.waitForExistence(timeout: 10), "カードへ戻らない")
  }

  @MainActor func testSearchNoWordsForN() {
    relaunchSeeded()
    openMap()
    // 「ん」はわ行。狭い画面では「は〜わ」に切り替える。
    if !button("ん").exists, button("は〜わ").exists { button("は〜わ").tap() }
    tap(button("ん"), "地図の ん")
    tap(app.buttons["searchWords"].firstMatch, "ことばを さがす")
    let empty = app.descendants(matching: .any)["letterWordsEmpty"].firstMatch
    XCTAssertTrue(empty.waitForExistence(timeout: 10), "「ん」の ひとことが出ない")
  }

  /// まだ書いていない字には、「ことばを さがす」を出さない。
  @MainActor func testUnwrittenLetterHasNoSearch() {
    relaunchSeeded()
    openMap()
    tap(button("そ"), "地図の そ")
    XCTAssertTrue(button("かく").waitForExistence(timeout: 10))
    XCTAssertFalse(app.buttons["searchWords"].firstMatch.exists)
  }
}
