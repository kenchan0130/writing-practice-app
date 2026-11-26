import XCTest

/// おねがいの知らせと、保護者用の確認を押して確かめる。
final class FlowParentUITests: MojimachiUITestCase {
  // MARK: - 4b. おねがいを押す → 保護者用の画面のお知らせ（D54・D160）

  @MainActor func testWishShowsInParentArea() {
    openMap()
    tap(button("カタカナ"), "カタカナの つまみ")
    tap(button("カ"), "鍵つきの カ")
    tap(button("おとなのひとに おねがいする"), "おねがいのボタン")
    XCTAssertEqual(app.staticTexts["lockTitle"].label, "おねがい できたよ")
    // しばらくすると、地図へ戻る。
    let gone = NSPredicate(format: "exists == false")
    expectation(for: gone, evaluatedWith: app.staticTexts["lockTitle"])
    waitForExpectations(timeout: 10)
    XCTAssertTrue(button("ニ").exists, "おねがいのあと地図へ戻らない")
    tap(button("もどる"), "地図の ←")
    openGate()
    answerGate()
    let notice = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'カタカナをやりたがっています'"))
      .firstMatch
    XCTAssertTrue(notice.waitForExistence(timeout: 10), "おねがいのお知らせが出ない")
    XCTAssertFalse(notice.label.contains("回"), "回数を出してはいけない")
  }

  // MARK: - 5. 保護者用の確認

  @MainActor func testParentGateCancel() {
    openGate()
    app.buttons["やめる"].tap()
    let gone = NSPredicate(format: "exists == false")
    expectation(for: gone, evaluatedWith: app.staticTexts["保護者の方へ"])
    waitForExpectations(timeout: 10)
    XCTAssertTrue(button("もじ").exists)
  }

  @MainActor func testParentGateAnswer() {
    openGate()
    answerGate()
    XCTAssertTrue(
      app.navigationBars["保護者用の画面"].waitForExistence(timeout: 10), "保護者用の画面が開かない")
  }
}
