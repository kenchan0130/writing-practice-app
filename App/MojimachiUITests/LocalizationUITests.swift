import XCTest

/// 英語の端末で起動したとき、保護者用の画面は英語になり、子どもが学ぶ字・ことばは日本語のままか確かめる（D186）。
final class LocalizationUITests: MojimachiUITestCase {
  override var extraLaunchArguments: [String] {
    ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
  }

  private static let numbers: [String: Int] = [
    "twelve": 12, "thirteen": 13, "fourteen": 14, "fifteen": 15, "sixteen": 16,
    "seventeen": 17, "eighteen": 18, "nineteen": 19,
    "three": 3, "four": 4, "five": 5, "six": 6, "seven": 7, "eight": 8, "nine": 9,
  ]

  /// 「Enter fourteen times six」から積を出す。
  private static func englishProduct(of text: String) -> Int? {
    let words = text.lowercased().components(separatedBy: " ")
    guard words.count == 4, words[2] == "times", let left = numbers[words[1]],
      let right = numbers[words[3]]
    else { return nil }
    return left * right
  }

  @MainActor func testParentAreaIsEnglishAndLettersStayJapanese() {
    // ホームの大きなボタンは英語。
    XCTAssertTrue(button("Letters").waitForExistence(timeout: 15), "ホームのボタンが英語にならない")
    XCTAssertFalse(button("もじ").exists)

    // 字の地図の字は日本語のまま。
    tap(button("Letters"), "ホームの Letters")
    XCTAssertTrue(button("あ").waitForExistence(timeout: 10), "字が日本語のままでない")
    tap(button("Back"), "地図の ←")

    // 保護者用の確認は、英語の問いと英語の見出し。
    let gear = app.descendants(matching: .any)["Parent Area"].firstMatch
    XCTAssertTrue(gear.waitForExistence(timeout: 10), "歯車が見つからない")
    gear.press(forDuration: 2.5)
    XCTAssertTrue(app.staticTexts["For parents"].waitForExistence(timeout: 10), "確認の見出しが英語でない")
    let question = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Enter '"))
      .firstMatch
    XCTAssertTrue(question.waitForExistence(timeout: 10), "問いが英語でない")
    let answer = try! XCTUnwrap(Self.englishProduct(of: question.label), question.label)
    for digit in String(answer) { app.buttons[String(digit)].tap() }
    app.buttons["OK"].tap()

    // 保護者用の画面の項目が英語。
    XCTAssertTrue(app.navigationBars["Parent Area"].waitForExistence(timeout: 10), "保護者用の画面が英語でない")
    for title in ["Learning Record", "Children", "Purchases", "Sound & Display", "Support"] {
      XCTAssertTrue(app.buttons[title].firstMatch.exists, "\(title) が英語で出ない")
    }
    XCTAssertFalse(app.buttons["学習記録"].exists)

    // 購入の画面も英語。
    tap(app.buttons["Purchases"].firstMatch, "Purchases")
    XCTAssertTrue(app.buttons["Restore purchases"].waitForExistence(timeout: 10), "購入の画面が英語でない")
  }
}
