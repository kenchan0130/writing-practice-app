import XCTest

/// UI テストの共通の土台。`-uiTesting YES` で動きと待ち時間を縮めて起動する（D171）。
class MojimachiUITestCase: XCTestCase {
  var app: XCUIApplication!
  /// 起動の引数に足すもの（テストごとに変える）。
  var extraLaunchArguments: [String] { [] }

  @MainActor override func setUp() async throws {
    continueAfterFailure = false
    app = XCUIApplication()
    app.launchArguments = [
      "-inMemoryStore", "YES", "-localOnlyStore", "YES", "-penColor", "blue", "-fakePurchases",
      "none", "-skipOnboarding", "YES", "-uiTesting", "YES",
    ] + extraLaunchArguments
    app.launch()
  }

  @MainActor func tap(_ element: XCUIElement, _ name: String) {
    XCTAssertTrue(element.waitForExistence(timeout: 10), "\(name) が見つからない")
    element.tap()
  }

  @MainActor func button(_ label: String) -> XCUIElement { app.buttons[label].firstMatch }

  @MainActor func openMap() {
    tap(button("もじ"), "ホームの もじ")
    XCTAssertTrue(button("あ").waitForExistence(timeout: 10), "文字の地図が出ない")
  }

  @MainActor func openGate() {
    let gear = app.descendants(matching: .any)["保護者用の画面"].firstMatch
    XCTAssertTrue(gear.waitForExistence(timeout: 10), "歯車が見つからない")
    gear.press(forDuration: 2.5)
    XCTAssertTrue(app.staticTexts["保護者の方へ"].waitForExistence(timeout: 10), "確認の画面が出ない")
  }

  /// 親の確認の問いに答えて、OK を押す。
  @MainActor func answerGate() {
    let question = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'かける'")).firstMatch
    XCTAssertTrue(question.waitForExistence(timeout: 10))
    let answer = try! XCTUnwrap(Self.product(of: question.label), question.label)
    for digit in String(answer) { app.buttons[String(digit)].tap() }
    app.buttons["OK"].tap()
  }

  /// 「十四かける六の答えを …」から積を出す（十二〜十九、三〜九）。
  @MainActor static func product(of text: String) -> Int? {
    let parts = text.components(separatedBy: "かける")
    guard parts.count == 2, let left = kanji(parts[0]),
      let right = kanji(String(parts[1].prefix(while: { $0 != "の" })))
    else {
      return nil
    }
    return left * right
  }

  @MainActor static func kanji(_ text: String) -> Int? {
    let digits: [Character: Int] = [
      "一": 1, "二": 2, "三": 3, "四": 4, "五": 5, "六": 6, "七": 7, "八": 8, "九": 9,
    ]
    if text.first == "十" {
      return 10 + (text.dropFirst().first.flatMap { digits[$0] } ?? 0)
    }
    return text.count == 1 ? digits[text.first!] : nil
  }
}
