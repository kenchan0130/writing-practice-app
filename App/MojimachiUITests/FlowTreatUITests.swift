import XCTest

/// おたのしみ ボックスとステッカー（§3.3・§3.5・D54・D190）を押して確かめる。
final class FlowTreatUITests: MojimachiUITestCase {
  @MainActor private func relaunch(_ arguments: [String]) {
    app.terminate()
    app.launchArguments += arguments
    app.launch()
  }

  @MainActor private func element(_ id: String) -> XCUIElement {
    app.descendants(matching: .any)[id].firstMatch
  }

  /// 見えない SpriteKit のまちに貼ってあるステッカーの数（アクセシビリティの値）が `count` になるまで待つ。
  @MainActor private func waitForTownStickers(_ count: Int, _ message: String) {
    let scene = element("townScene")
    let predicate = NSPredicate(format: "value == %@", "\(count)")
    let expectation = XCTNSPredicateExpectation(predicate: predicate, object: scene)
    XCTAssertEqual(XCTWaiter().wait(for: [expectation], timeout: 10), .completed, message)
  }

  /// 目標に届くと、おたのしみ ボックスを あけられる。ステッカーが出て、まちに貼れる。あけられるのは 1日に1回だけ。
  @MainActor func testOpenBoxAndStickInTown() {
    // 目標に届く前は、あけられない（押しても、あける画面は出ない）。
    tap(element("treatBox-notYet"), "ホームの おたのしみ ボックス")
    XCTAssertFalse(element("treatBoxOpening").waitForExistence(timeout: 1), "届く前に あける画面が出た")
    // きょうの字を 5つ書いたことにする（目標は 5字）。
    relaunch(["-seedRecords", "5"])
    tap(element("treatBox-ready"), "あけられる おたのしみ ボックス")
    XCTAssertTrue(element("treatBoxOpening").waitForExistence(timeout: 10), "あける画面が出ない")
    tap(element("treatBoxOpen"), "箱")
    XCTAssertTrue(element("treatSticker").waitForExistence(timeout: 10), "ステッカーが出ない")
    tap(element("treatBoxToTown"), "まちに はる")
    // まちが、ステッカーの入れ物を開いて始まる。
    XCTAssertTrue(element("stickerTrayItem-0").waitForExistence(timeout: 10), "入れ物にステッカーがない")
    waitForTownStickers(0, "まだ貼っていないのに、まちにステッカーがある")
    // 押すだけで貼れる。
    tap(element("stickerTrayItem-0"), "入れ物のステッカー")
    waitForTownStickers(1, "まちに貼れない")
    XCTAssertTrue(element("stickerTrayEmpty").waitForExistence(timeout: 10), "入れ物が空にならない")
    tap(element("stickerTrayClose"), "入れ物の できた")
    XCTAssertTrue(element("stickerButton").waitForExistence(timeout: 10), "ステッカーのボタンが出ない")
    tap(button("もどる"), "まちの ←")
    // きょうは もう あけた。押しても、あける画面は出ない。
    tap(element("treatBox-opened"), "あけたあとの おたのしみ ボックス")
    XCTAssertFalse(element("treatBoxOpening").waitForExistence(timeout: 1), "2回目が あけられた")
    // 貼ったステッカーは、まちに残っている。
    tap(button("まち"), "ホームの まち")
    waitForTownStickers(1, "貼ったステッカーが残っていない")
  }

  /// 入れ物から引っぱって まちに貼る。入れ物を開いているあいだに押すと、はがれる。
  @MainActor func testDragStickerToTownAndPeel() {
    relaunch(["-seedStickers", "3"])
    tap(button("まち"), "ホームの まち")
    tap(element("stickerButton"), "まちの ステッカー")
    let scene = element("townScene")
    let item = element("stickerTrayItem-0")
    XCTAssertTrue(item.waitForExistence(timeout: 10), "入れ物にステッカーがない")
    XCTAssertTrue(element("stickerTrayItem-2").exists, "3枚 並んでいない")
    let spot = scene.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3))
    item.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
      .press(forDuration: 0.3, thenDragTo: spot)
    waitForTownStickers(1, "引っぱって貼れない")
    XCTAssertFalse(element("stickerTrayItem-2").exists, "貼ったステッカーが入れ物に残っている")
    // 貼ったところを押すと、はがれて 入れ物に もどる。
    spot.tap()
    waitForTownStickers(0, "押しても はがれない")
    XCTAssertTrue(element("stickerTrayItem-2").waitForExistence(timeout: 10), "入れ物に もどらない")
    // まちの絵の外で はなすと、貼られない（入れ物に もどる）。
    item.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
      .press(forDuration: 0.3, thenDragTo: element("stickerTrayClose").coordinate(
        withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)))
    waitForTownStickers(0, "まちの外で はなしたのに貼られた")
    // 入れ物を閉じたあとは、押しても はがれない。
    tap(item, "入れ物のステッカー")
    waitForTownStickers(1, "押して貼れない")
    tap(element("stickerTrayClose"), "入れ物の できた")
    XCTAssertTrue(element("houseButton").waitForExistence(timeout: 10), "下の列が もどらない")
  }

  /// ずかんの表紙に貼る。入れ物を開いているあいだに押すと、はがれる。
  @MainActor func testStickerOnZukanCover() {
    relaunch(["-seedStickers", "2"])
    tap(button("ことば"), "ホームの ことば")
    tap(button("ずかん"), "下の帯の ずかん")
    XCTAssertTrue(app.staticTexts["わたしの ずかん"].waitForExistence(timeout: 10), "ずかんが出ない")
    tap(element("stickerButton"), "表紙の ステッカー")
    // 新しい順に並ぶ（ハート、ほし）。
    tap(element("stickerTrayItem-0"), "入れ物のステッカー")
    XCTAssertTrue(element("coverSticker-heart").waitForExistence(timeout: 10), "表紙に貼れない")
    tap(element("coverSticker-heart"), "表紙のステッカー")
    XCTAssertFalse(element("coverSticker-heart").waitForExistence(timeout: 1), "はがれない")
    XCTAssertTrue(element("stickerTrayItem-1").waitForExistence(timeout: 10), "入れ物に もどらない")
    tap(element("stickerTrayClose"), "入れ物の できた")
    XCTAssertTrue(element("stickerButton").waitForExistence(timeout: 10), "ステッカーのボタンが もどらない")
  }

  /// 夜のまち（星・月・あかりのついた窓・眠そうな主人公）が、止まらずに開く（§3.4）。転がる物を押しても止まらない。
  @MainActor func testNightTownOpens() {
    relaunch(["-townHour", "21", "-seedTown", "YES"])
    tap(button("まち"), "ホームの まち")
    let scene = element("townScene")
    XCTAssertTrue(scene.waitForExistence(timeout: 10), "夜のまちが出ない")
    // 景色のあたりを 何か所か押す（転がる物があれば転がる。D133）。
    for dx in [0.2, 0.4, 0.6, 0.8] {
      scene.coordinate(withNormalizedOffset: CGVector(dx: dx, dy: 0.62)).tap()
    }
    XCTAssertTrue(element("houseButton").exists, "まちが止まった")
    tap(button("もどる"), "まちの ←")
    XCTAssertTrue(button("もじ").waitForExistence(timeout: 10), "ホームへ戻らない")
  }
}
