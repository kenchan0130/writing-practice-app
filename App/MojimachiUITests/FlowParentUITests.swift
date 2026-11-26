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

/// 保護者用の画面は、操作がなければ閉じる（D49）。有効な時間は `-parentValiditySeconds` で縮める。
final class ParentAreaTimeoutUITests: MojimachiUITestCase {
  override var extraLaunchArguments: [String] { ["-parentValiditySeconds", "10"] }

  @MainActor func testParentAreaClosesAfterInactivity() {
    openGate()
    answerGate()
    let bar = app.navigationBars["保護者用の画面"]
    XCTAssertTrue(bar.waitForExistence(timeout: 10), "保護者用の画面が開かない")
    // 何もしないと、閉じてホームへ戻る。
    let gone = NSPredicate(format: "exists == false")
    expectation(for: gone, evaluatedWith: bar)
    waitForExpectations(timeout: 30)
    XCTAssertTrue(button("もじ").waitForExistence(timeout: 10), "閉じたあとホームへ戻らない")
    // 開き直すには、また確認が要る。
    openGate()
  }

  @MainActor func testTouchingKeepsParentAreaOpen() {
    openGate()
    answerGate()
    let bar = app.navigationBars["保護者用の画面"]
    XCTAssertTrue(bar.waitForExistence(timeout: 10), "保護者用の画面が開かない")
    // 有効な時間（10秒）より長く、2秒おきに触れ続ける。並列で遅くなっても間が10秒を超えないよう、間を短くとる。
    let start = Date()
    while Date().timeIntervalSince(start) < 16 {
      Thread.sleep(forTimeInterval: 2)
      app.swipeUp(velocity: .fast)
    }
    XCTAssertTrue(bar.exists, "操作しているのに閉じた")
  }
}
