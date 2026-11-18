import XCTest

/// はじめての流れ（おとなの前半 → 子どもの後半の入口）を、シミュレータで実際に押して確かめる（D23）。
final class OnboardingUITests: XCTestCase {
  private var app: XCUIApplication!

  @MainActor override func setUp() async throws {
    continueAfterFailure = false
    app = XCUIApplication()
    // `-resetOnboarding YES`: 前に動かした分の「終わった」印を消して、最初の起動にする。
    app.launchArguments = [
      "-inMemoryStore", "YES", "-localOnlyStore", "YES", "-penColor", "blue", "-fakePurchases",
      "none", "-resetOnboarding", "YES",
    ]
    app.launch()
  }

  @MainActor private func tap(_ element: XCUIElement, _ name: String) {
    XCTAssertTrue(element.waitForExistence(timeout: 10), "\(name) が見つからない")
    element.tap()
  }

  @MainActor func testAdultPartThenChildPartStarts() {
    // 1 プロフィール
    XCTAssertTrue(
      app.staticTexts["おとなのひとと いっしょに はじめてね"].waitForExistence(timeout: 15), "最初の画面が出ない")
    let nickname = app.textFields["onboardingNickname"]
    tap(nickname, "呼び名の欄")
    nickname.typeText("そら")
    tap(app.buttons["onboardingNext"], "次へ（プロフィール）")

    // 2 判定のきびしさ（動かさなければ「はじめて」）
    tap(app.buttons["onboardingPreset-naretekita"], "なれてきた のカード")
    tap(app.buttons["onboardingNext"], "次へ（判定）")

    // 3 保護者用の画面と iCloud
    XCTAssertTrue(
      app.staticTexts["記録は この iPad と あなたの iCloud にだけ保存します"].waitForExistence(timeout: 10),
      "iCloud の説明が出ない")
    XCTAssertTrue(app.switches["onboardingICloud"].exists, "iCloud のスイッチが出ない")
    tap(app.buttons["onboardingNext"], "次へ（保護者用の画面）")

    // 4 わたす
    XCTAssertTrue(
      app.staticTexts["お子さんに iPad をわたしてください"].waitForExistence(timeout: 10), "わたす画面が出ない")
    tap(app.buttons["onboardingStart"], "はじめる")

    // 子どもの後半: キャラクター選び → あいさつ（呼び名は画面だけ）→ 最初の1字（書く画面）
    XCTAssertTrue(
      app.staticTexts["だれと いっしょに かく？"].waitForExistence(timeout: 10), "キャラクター選びが出ない")
    tap(app.buttons["onboardingCharacter-run"], "キャラクター")
    XCTAssertTrue(
      app.staticTexts["そら、こんにちは！"].waitForExistence(timeout: 10), "あいさつに呼び名が出ない")
    tap(app.buttons["onboardingGo"], "いこう！")
    XCTAssertTrue(
      app.otherElements["もじを かく ばしょ"].firstMatch.waitForExistence(timeout: 10), "書く画面が出ない")
    // 書く画面の横のパネル（前後の矢印）は出さない。
    XCTAssertFalse(app.buttons["つぎの もじ"].exists, "パネルが出ている")
  }

  /// 「あとで設定する」で飛ばしても、わたす画面まで進める。
  @MainActor func testSkippingEveryAdultScreen() {
    XCTAssertTrue(
      app.staticTexts["おとなのひとと いっしょに はじめてね"].waitForExistence(timeout: 15), "最初の画面が出ない")
    tap(app.buttons["onboardingSkip"], "あとで設定する（プロフィール）")
    tap(app.buttons["onboardingSkip"], "あとで設定する（判定）")
    tap(app.buttons["onboardingNext"], "次へ（保護者用の画面）")
    tap(app.buttons["onboardingStart"], "はじめる")
    // 呼び名なしでも、キャラクター選びからあいさつまで行ける。
    tap(app.buttons["onboardingCharacter-ton"], "キャラクター")
    XCTAssertTrue(app.staticTexts["こんにちは！"].waitForExistence(timeout: 10), "あいさつが出ない")
  }
}
