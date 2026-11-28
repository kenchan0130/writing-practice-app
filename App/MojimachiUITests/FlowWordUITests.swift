import XCTest

/// ことば（まちの地図 → テーマ → カード → 書く）を押して確かめる。
final class FlowWordUITests: MojimachiUITestCase {
  // MARK: - 2. ことば（まちの地図 → テーマ → ことばのカード → 書く。D166）

  @MainActor func testWordMapFlow() {
    tap(button("ことば"), "ホームの ことば")
    // 絵のあることばがある場所だけが出る。
    XCTAssertTrue(button("えき").waitForExistence(timeout: 10), "まちの地図が出ない")
    XCTAssertTrue(button("まきば").exists)
    XCTAssertTrue(button("もり").exists)
    // うみ・かわは、水の生きもの（D170）のことばがあるので出る。
    XCTAssertTrue(button("うみ").exists)
    XCTAssertTrue(button("かわ").exists)
    // こうえんは、こうえんの物（D173）のことばがあるので出る。
    XCTAssertTrue(button("こうえん").exists)
    // おうち → テーマが8つ（へんしん D178、いえの なかの 3つ D185）。
    tap(button("おうち"), "おうち")
    XCTAssertTrue(button("ふく").waitForExistence(timeout: 10), "テーマが出ない")
    XCTAssertTrue(button("おしゃれ こもの").exists)
    // いえの なかのテーマ（D185）。おうちは 2列で 8つ。
    XCTAssertTrue(button("だいどころ").exists, "だいどころ が出ない")
    XCTAssertTrue(button("いえの もの").exists, "いえの もの が出ない")
    XCTAssertTrue(button("おふろ・みじたく").exists, "おふろ・みじたく が出ない")
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
    // えきは たてもの（D174）、うみは さかな・かい（D201）が足されてテーマが増えたので、テーマが1つの うちゅう（D172）で確かめる。
    tap(button("うちゅう"), "うちゅう")
    XCTAssertTrue(button("たいよう").waitForExistence(timeout: 10), "ことばのカードが出ない")
    XCTAssertTrue(button("うちゅうじん").exists)
    tap(button("たいよう"), "たいようのカード")
    XCTAssertTrue(
      app.descendants(matching: .any)["wordHeader"].firstMatch.waitForExistence(timeout: 10),
      "書く画面が出ない")
    tap(button("もどる"), "書く画面の ←")
    XCTAssertTrue(button("たいよう").waitForExistence(timeout: 10))
    // テーマの画面を通らず、まちの地図へ戻る。
    tap(button("もどる"), "ことばのカードの ←")
    XCTAssertTrue(button("まきば").waitForExistence(timeout: 10), "まちの地図へ戻らない")
  }

  /// 英語のことばがあるテーマの「ABC」の旗（D67・D92・D199）。持っていなければ、cat だけが開いていて、ほかは鍵。
  @MainActor func testEnglishFlagShowsTrialWordAndLocks() {
    tap(button("ことば"), "ホームの ことば")
    tap(button("おうち"), "おうち")
    tap(button("いえで かう いきもの"), "いえで かう いきもの")
    XCTAssertTrue(button("ねこ").waitForExistence(timeout: 10), "ことばのカードが出ない")
    let flag = app.buttons["languageFlag"].firstMatch
    XCTAssertTrue(flag.exists, "ABC の旗が出ない")
    tap(flag, "ABC の旗")
    // おためしの cat は開いている。dog は影絵に鍵（名前は出さない）。
    XCTAssertTrue(button("cat").waitForExistence(timeout: 10), "cat のカードが出ない")
    XCTAssertFalse(button("ねこ").exists, "日本語のカードが残っている")
    let dog = app.buttons["wordCard-dog"].firstMatch
    XCTAssertTrue(dog.exists, "鍵の dog のカードが出ない")
    XCTAssertEqual(dog.label, "ねむっている ことば")
    tap(dog, "鍵の dog")
    XCTAssertTrue(app.staticTexts["lockTitle"].waitForExistence(timeout: 10), "鍵の画面が出ない")
    tap(button("もどる"), "鍵の画面の ←")
    // cat を書く。選べることばは、開いているものだけ（cat）。
    tap(button("cat"), "cat のカード")
    let header = app.descendants(matching: .any)["wordHeader"].firstMatch
    XCTAssertTrue(header.waitForExistence(timeout: 10), "書く画面が出ない")
    XCTAssertEqual(header.label, "cat")
    XCTAssertFalse(button("dog").exists, "鍵のことばが選べる")
    tap(button("もどる"), "書く画面の ←")
    // 英語のままで戻る。旗でもとの日本語へ。
    XCTAssertTrue(button("cat").waitForExistence(timeout: 10), "英語のカードへ戻らない")
    tap(flag, "あいうの旗")
    XCTAssertTrue(button("ねこ").waitForExistence(timeout: 10), "日本語へ戻らない")
  }

  /// 英語のことばがないテーマには、「ABC」の旗を出さない（D67・D92）。
  @MainActor func testNoEnglishFlagWithoutEnglishWords() {
    tap(button("ことば"), "ホームの ことば")
    tap(button("おうち"), "おうち")
    tap(button("ふく"), "ふく")
    XCTAssertTrue(button("ゆかた").waitForExistence(timeout: 10), "ことばのカードが出ない")
    XCTAssertFalse(app.buttons["languageFlag"].exists, "英語のことばがないのに、旗が出ている")
  }
}
