import XCTest

/// まちと、鍵つきの字・おためしの字を押して確かめる。
final class FlowTownLockUITests: MojimachiUITestCase {
  // MARK: - 3. まち

  @MainActor func testTownAndBack() {
    tap(button("まち"), "ホームの まち")
    XCTAssertTrue(app.staticTexts["わたしの まち"].waitForExistence(timeout: 10), "まちの看板が出ない")
    tap(button("もどる"), "まちの ←")
    XCTAssertTrue(button("もじ").waitForExistence(timeout: 10), "ホームへ戻らない")
  }

  // MARK: - 4. 鍵つきの字とおためしの字

  @MainActor func testLockedAndTrialCells() {
    openMap()
    tap(button("カタカナ"), "カタカナの つまみ")
    tap(button("カ"), "鍵つきの カ")
    // 鍵の画面（D160）。ダイアログではなく、画面いっぱいに出る。価格や「かう」は出ない。
    let title = app.staticTexts["lockTitle"]
    XCTAssertTrue(title.waitForExistence(timeout: 10), "鍵の画面が出ない")
    XCTAssertEqual(title.label, "この もじは まだ ねむっているよ")
    XCTAssertTrue(button("おとなのひとに おねがいする").exists, "おねがいのボタンが出ない")
    XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS '¥'")).firstMatch.exists)
    // 「←」で、何も記録せずに地図へ戻る。
    tap(button("もどる"), "鍵の画面の ←")
    XCTAssertTrue(button("ニ").waitForExistence(timeout: 10), "地図へ戻らない")
    XCTAssertFalse(title.exists)
    tap(button("ニ"), "おためしの ニ")
    XCTAssertTrue(button("かく").waitForExistence(timeout: 10), "ニのカードが出ない")
  }
}
