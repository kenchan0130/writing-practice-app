import XCTest

/// 子どもと保護者の押す流れを、シミュレータで実際に押して確かめる。
final class FlowUITests: XCTestCase {
  private var app: XCUIApplication!

  @MainActor override func setUp() async throws {
    continueAfterFailure = false
    app = XCUIApplication()
    app.launchArguments = [
      "-inMemoryStore", "YES", "-localOnlyStore", "YES", "-penColor", "blue", "-fakePurchases",
      "none", "-skipOnboarding", "YES",
    ]
    app.launch()
  }

  // MARK: - 部品

  @MainActor private func tap(_ element: XCUIElement, _ name: String) {
    XCTAssertTrue(element.waitForExistence(timeout: 10), "\(name) が見つからない")
    element.tap()
  }

  @MainActor private func button(_ label: String) -> XCUIElement { app.buttons[label].firstMatch }

  @MainActor private func openMap() {
    tap(button("もじ"), "ホームの もじ")
    XCTAssertTrue(button("あ").waitForExistence(timeout: 10), "文字の地図が出ない")
  }

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

  // MARK: - 2. ことば

  @MainActor func testWordPicker() {
    tap(button("ことば"), "ホームの ことば")
    let header = app.descendants(matching: .any)["wordHeader"].firstMatch
    XCTAssertTrue(header.waitForExistence(timeout: 10), "ことば画面が出ない")
    let dog = button("いぬ")
    tap(dog, "ことばの いぬ")
    let shown = NSPredicate(format: "label == %@", "いぬ")
    expectation(for: shown, evaluatedWith: header)
    waitForExpectations(timeout: 10)
  }

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
    // 標準のアラートではなく、独自のポップなダイアログ（D155）。ボタンは識別子で探す。
    let message = app.staticTexts["おとなのひとに おねがいしてね"]
    XCTAssertTrue(message.waitForExistence(timeout: 10), "鍵の案内が出ない")
    let ok = app.buttons["popDialogButton"]
    XCTAssertTrue(ok.exists, "ダイアログのボタンが出ない")
    ok.tap()
    let gone = NSPredicate(format: "exists == false")
    expectation(for: gone, evaluatedWith: message)
    waitForExpectations(timeout: 10)
    tap(button("ニ"), "おためしの ニ")
    XCTAssertTrue(button("かく").waitForExistence(timeout: 10), "ニのカードが出ない")
  }

  // MARK: - 5. 保護者用の確認

  @MainActor private func openGate() {
    let gear = app.descendants(matching: .any)["保護者用の画面"].firstMatch
    XCTAssertTrue(gear.waitForExistence(timeout: 10), "歯車が見つからない")
    gear.press(forDuration: 2.5)
    XCTAssertTrue(app.staticTexts["保護者の方へ"].waitForExistence(timeout: 10), "確認の画面が出ない")
  }

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
    let question = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'かける'")).firstMatch
    XCTAssertTrue(question.waitForExistence(timeout: 10))
    let answer = try! XCTUnwrap(Self.product(of: question.label), question.label)
    for digit in String(answer) { app.buttons[String(digit)].tap() }
    app.buttons["OK"].tap()
    XCTAssertTrue(
      app.navigationBars["保護者用の画面"].waitForExistence(timeout: 10), "保護者用の画面が開かない")
  }

  /// 「十四かける六の答えを …」から積を出す（十二〜十九、三〜九）。
  @MainActor private static func product(of text: String) -> Int? {
    let parts = text.components(separatedBy: "かける")
    guard parts.count == 2, let left = kanji(parts[0]),
      let right = kanji(String(parts[1].prefix(while: { $0 != "の" })))
    else {
      return nil
    }
    return left * right
  }

  @MainActor private static func kanji(_ text: String) -> Int? {
    let digits: [Character: Int] = [
      "一": 1, "二": 2, "三": 3, "四": 4, "五": 5, "六": 6, "七": 7, "八": 8, "九": 9,
    ]
    if text.first == "十" {
      return 10 + (text.dropFirst().first.flatMap { digits[$0] } ?? 0)
    }
    return text.count == 1 ? digits[text.first!] : nil
  }
}
