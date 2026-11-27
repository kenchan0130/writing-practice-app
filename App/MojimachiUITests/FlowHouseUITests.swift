import XCTest

/// キャラクターのいえ（いえの なか）と おもちゃばこ（D185）を押して確かめる。
final class FlowHouseUITests: MojimachiUITestCase {
  @MainActor private func relaunch(_ arguments: [String]) {
    app.terminate()
    app.launchArguments += arguments
    app.launch()
  }

  @MainActor private func element(_ id: String) -> XCUIElement {
    app.descendants(matching: .any)[id].firstMatch
  }

  /// まち → いえ → クローゼット。「←」で1つずつ戻る（§3.1）。
  @MainActor func testHouseFromTownAndCloset() {
    tap(button("まち"), "ホームの まち")
    // 入りきらない物がないときは、まちに おもちゃばこを出さない。
    XCTAssertTrue(element("houseButton").waitForExistence(timeout: 10), "いえの入口が出ない")
    XCTAssertFalse(element("toyBoxButton").exists, "まちに おもちゃばこが出ている")
    tap(element("houseButton"), "まちの いえ")
    XCTAssertTrue(app.staticTexts["わたしの いえ"].waitForExistence(timeout: 10), "いえが出ない")
    // おもちゃばこは、からっぽ。エラーは出さない（D117）。
    tap(element("toyBoxButton"), "いえの おもちゃばこ")
    XCTAssertTrue(element("toyBoxEmpty").waitForExistence(timeout: 10), "おもちゃばこが開かない")
    tap(element("toyBoxClose"), "おもちゃばこの とじる")
    tap(element("closetButton"), "いえの クローゼット")
    XCTAssertTrue(
      app.staticTexts["わたしの クローゼット"].waitForExistence(timeout: 10), "クローゼットが出ない")
    tap(button("もどる"), "クローゼットの ←")
    XCTAssertTrue(app.staticTexts["わたしの いえ"].waitForExistence(timeout: 10), "いえへ戻らない")
    tap(button("もどる"), "いえの ←")
    XCTAssertTrue(app.staticTexts["わたしの まち"].waitForExistence(timeout: 10), "まちへ戻らない")
    tap(button("もどる"), "まちの ←")
    XCTAssertTrue(button("もじ").waitForExistence(timeout: 10), "ホームへ戻らない")
  }

  /// 入りきらない物は おもちゃばこに入り、押すと、出してからいちばん長い物と入れ替わる（D74・D82）。
  @MainActor func testToyBoxSwap() {
    // 棚の物を 6つ置く（なべ・おわん・はし・おさら・やかん・せっけん の順）。棚は 4つなので、古い 2つが おもちゃばこ。
    relaunch(["-seedTown", "YES"])
    tap(button("まち"), "ホームの まち")
    // まちにも、入りきらない物があるので、おもちゃばこが出る。
    XCTAssertTrue(element("toyBoxButton").waitForExistence(timeout: 10), "まちの おもちゃばこが出ない")
    tap(element("houseButton"), "まちの いえ")
    XCTAssertTrue(element("houseTitle").waitForExistence(timeout: 10), "いえが出ない")
    tap(element("toyBoxButton"), "いえの おもちゃばこ")
    XCTAssertTrue(element("toyBoxItem-なべ").waitForExistence(timeout: 10), "なべ が おもちゃばこにない")
    XCTAssertTrue(element("toyBoxItem-おわん").exists, "おわん が おもちゃばこにない")
    XCTAssertFalse(element("toyBoxItem-はし").exists, "はし は出ているはず")
    // なべ を出す。出してからいちばん長い はし が、入れ替わりでしまわれる。
    tap(element("toyBoxItem-なべ"), "おもちゃばこの なべ")
    XCTAssertTrue(element("toyBoxButton").waitForExistence(timeout: 10))
    XCTAssertFalse(element("toyBoxTitle").waitForExistence(timeout: 1), "おもちゃばこが閉じない")
    tap(element("toyBoxButton"), "いえの おもちゃばこ")
    XCTAssertTrue(element("toyBoxItem-はし").waitForExistence(timeout: 10), "はし がしまわれていない")
    XCTAssertTrue(element("toyBoxItem-おわん").exists)
    XCTAssertFalse(element("toyBoxItem-なべ").exists, "なべ が出ていない")
    tap(element("toyBoxClose"), "おもちゃばこの とじる")
  }

  /// いえの物を書くと、変身のあとで「いえを みる」が出て、いえへ行く（D185）。
  @MainActor func testFurnitureWordGoesToHouse() {
    relaunch(["-screen", "word", "-startWord", "いす", "-simulateWord", "YES"])
    // 自動で書いて変身が終わるまで待つ（起動したての シミュレータでは時間がかかる）。
    XCTAssertTrue(button("いえを みる").waitForExistence(timeout: 40), "いえを みる が出ない")
    tap(button("いえを みる"), "いえを みる")
    XCTAssertTrue(app.staticTexts["わたしの いえ"].waitForExistence(timeout: 10), "いえが出ない")
    tap(button("もどる"), "いえの ←")
    XCTAssertTrue(app.staticTexts["わたしの まち"].waitForExistence(timeout: 10), "まちへ戻らない")
  }
}
