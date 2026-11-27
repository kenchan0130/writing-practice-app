import XCTest

/// 横向きで、大事なものが画面に入っていて押せることを確かめる（11インチの横向きは高さがいちばん足りない）。
/// 向きは DEBUG の起動の引数 `-orientation landscape` で決める。
final class LandscapeUITests: MojimachiUITestCase {
  override var extraLaunchArguments: [String] {
    ["-orientation", "landscape", "-seedRecords", "3", "-seedGrowth", "YES"]
  }

  @MainActor override func setUp() async throws {
    // 窓のモード（iPadOS 26）だとアプリの要求では向きが変わらないので、端末の向きも横にしておく。
    XCUIDevice.shared.orientation = .landscapeLeft
    try await super.setUp()
  }

  @MainActor override func tearDown() async throws {
    XCUIDevice.shared.orientation = .portrait
    try await super.tearDown()
  }

  /// 要素が画面の中に収まっていて、押せる。
  @MainActor private func assertOnScreen(_ element: XCUIElement, _ name: String) {
    XCTAssertTrue(element.waitForExistence(timeout: 10), "\(name) が見つからない")
    let window = app.windows.firstMatch.frame
    let frame = element.frame
    XCTAssertTrue(
      frame.minX >= window.minX - 1 && frame.maxX <= window.maxX + 1
        && frame.minY >= window.minY - 1 && frame.maxY <= window.maxY + 1,
      "\(name) が画面からはみ出している: \(frame) / 画面 \(window)")
    XCTAssertTrue(element.isHittable, "\(name) が押せない")
  }

  @MainActor private func assertIsLandscape() {
    let window = app.windows.firstMatch.frame
    XCTAssertGreaterThan(window.width, window.height, "横向きになっていない: \(window)")
  }

  @MainActor func testHomeFitsInLandscape() {
    assertOnScreen(button("もじ"), "ホームの もじ")
    assertIsLandscape()
    assertOnScreen(button("ことば"), "ホームの ことば")
    assertOnScreen(button("まち"), "ホームの まち")
    // ふきだしの文は、省かずにぜんぶ出る（「…」で切れない）。
    let bubble = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'かこうね' OR label CONTAINS 'できたね'"))
      .firstMatch
    if bubble.waitForExistence(timeout: 5) {
      XCTAssertFalse(bubble.label.contains("…"), "ふきだしが切れている: \(bubble.label)")
    }
  }

  @MainActor func testMapFitsInLandscape() {
    tap(button("もじ"), "ホームの もじ")
    assertIsLandscape()
    // 5行目（あ行の「お」・わ行の「を」）と凡例まで、画面に入る。
    assertOnScreen(button("あ"), "あ")
    assertOnScreen(button("お"), "お（5行目）")
    assertOnScreen(button("を"), "を（5行目）")
    assertOnScreen(app.staticTexts["はなばたけ"].firstMatch, "凡例")
  }

  @MainActor func testWordWritingFitsInLandscape() {
    app.terminate()
    app.launchArguments += ["-screen", "word", "-startWord", "でんしゃ", "-simulateWord", "YES"]
    app.launch()
    assertIsLandscape()
    let header = app.descendants(matching: .any)["wordHeader"].firstMatch
    XCTAssertTrue(header.waitForExistence(timeout: 10), "書く画面が出ない")
    // 変身が終わると「まちを みる」と「もういっこ」が出る。どちらも画面に入っている。
    assertOnScreen(button("まちを みる"), "まちを みる")
    assertOnScreen(button("もういっこ"), "もういっこ")
    assertOnScreen(button("もどる"), "もどる")
  }

  /// 見本の記録を、ほかの `-seed…` と一緒に入れても、成長アルバムに字が並ぶ（入れる順の確かめ）。
  @MainActor func testSampleSeedFillsAlbumTogetherWithOtherSeeds() {
    app.terminate()
    app.launchArguments += ["-openParent", "records", "-seedSamples", "YES"]
    app.launch()
    XCTAssertTrue(app.navigationBars["学習記録"].waitForExistence(timeout: 10), "学習記録が出ない")
    // 成長アルバムは下のほうにあるので、送って見に行く。
    let footer = app.staticTexts["はじめて書いた字と、最近の字を並べています。"]
    for _ in 0..<8 where !footer.exists { app.swipeUp() }
    XCTAssertTrue(footer.exists, "成長アルバムまで行けない")
    XCTAssertFalse(app.staticTexts["字を書くと、ここに並びます"].exists, "成長アルバムが空のまま")
  }
}
