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

  // MARK: - 2. ことば（まちの地図 → テーマ → ことばのカード → 書く。D166）

  @MainActor func testWordMapFlow() {
    tap(button("ことば"), "ホームの ことば")
    // 絵のあることばがある場所だけが出る。
    XCTAssertTrue(button("えき").waitForExistence(timeout: 10), "まちの地図が出ない")
    XCTAssertTrue(button("まきば").exists)
    XCTAssertTrue(button("もり").exists)
    XCTAssertFalse(button("うみ").exists, "ことばのない場所が出ている")
    // おうち → テーマが3つ。
    tap(button("おうち"), "おうち")
    XCTAssertTrue(button("ふく").waitForExistence(timeout: 10), "テーマが出ない")
    XCTAssertTrue(button("おしゃれ こもの").exists)
    tap(button("いえで かう いきもの"), "いえで かう いきもの")
    XCTAssertTrue(button("ねこ").waitForExistence(timeout: 10), "ことばのカードが出ない")
    tap(button("いぬ"), "いぬのカード")
    let header = app.descendants(matching: .any)["wordHeader"].firstMatch
    XCTAssertTrue(header.waitForExistence(timeout: 10), "書く画面が出ない")
    XCTAssertEqual(header.label, "いぬ")
    // 選べるのは、このテーマのことばだけ。
    XCTAssertTrue(button("ねこ").exists)
    XCTAssertFalse(button("くま").exists, "別のテーマのことばが出ている")
    // 「←」で、ことばのカード → テーマ → まちの地図 → ホーム。
    tap(button("もどる"), "書く画面の ←")
    XCTAssertTrue(button("ねこ").waitForExistence(timeout: 10), "ことばのカードへ戻らない")
    tap(button("もどる"), "ことばのカードの ←")
    XCTAssertTrue(button("おしゃれ こもの").waitForExistence(timeout: 10), "テーマへ戻らない")
    tap(button("もどる"), "テーマの ←")
    XCTAssertTrue(button("えき").waitForExistence(timeout: 10), "まちの地図へ戻らない")
    tap(button("もどる"), "まちの地図の ←")
    XCTAssertTrue(button("もじ").waitForExistence(timeout: 10), "ホームへ戻らない")
  }

  /// テーマが1つだけの場所は、テーマを飛ばして、すぐことばのカードを出す（D67）。
  @MainActor func testSingleThemePlaceSkipsThemes() {
    tap(button("ことば"), "ホームの ことば")
    tap(button("えき"), "えき")
    XCTAssertTrue(button("そり").waitForExistence(timeout: 10), "ことばのカードが出ない")
    XCTAssertTrue(button("しんかんせん").exists)
    tap(button("そり"), "そりのカード")
    XCTAssertTrue(
      app.descendants(matching: .any)["wordHeader"].firstMatch.waitForExistence(timeout: 10),
      "書く画面が出ない")
    tap(button("もどる"), "書く画面の ←")
    XCTAssertTrue(button("そり").waitForExistence(timeout: 10))
    // テーマの画面を通らず、まちの地図へ戻る。
    tap(button("もどる"), "ことばのカードの ←")
    XCTAssertTrue(button("まきば").waitForExistence(timeout: 10), "まちの地図へ戻らない")
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
    let question = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'かける'")).firstMatch
    XCTAssertTrue(question.waitForExistence(timeout: 10))
    let answer = try! XCTUnwrap(Self.product(of: question.label), question.label)
    for digit in String(answer) { app.buttons[String(digit)].tap() }
    app.buttons["OK"].tap()
    let notice = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'カタカナをやりたがっています'"))
      .firstMatch
    XCTAssertTrue(notice.waitForExistence(timeout: 10), "おねがいのお知らせが出ない")
    XCTAssertFalse(notice.label.contains("回"), "回数を出してはいけない")
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
