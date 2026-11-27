import ContentModel
import Testing

@testable import PracticeKit

@Suite("はじめての流れの決まり")
struct OnboardingTests {
  private func situation(
    adultDone: Bool = false, waiting: Bool = false, profiles: Int = 1, named: Bool = false,
    practiced: Bool = false, childDone: Bool = false
  ) -> Onboarding.Situation {
    Onboarding.Situation(
      adultDone: adultDone, waitingForFirstImport: waiting, profileCount: profiles,
      currentHasName: named, currentHasPractice: practiced, currentChildDone: childDone)
  }

  @Test("最初の起動は、おとなの前半から（D23）")
  func firstLaunchStartsWithAdult() {
    #expect(Onboarding.stage(for: situation()) == .adult)
  }

  @Test("iCloud の取り込みを待っているあいだは出さない（D63）")
  func waitingShowsNothing() {
    #expect(Onboarding.stage(for: situation(waiting: true)) == nil)
  }

  @Test("前半を終えたら、子どもの後半から")
  func afterAdultComesChild() {
    #expect(Onboarding.stage(for: situation(adultDone: true)) == .child)
  }

  @Test("後半を終えたら出さない（くり返さない）")
  func doneShowsNothing() {
    #expect(Onboarding.stage(for: situation(adultDone: true, childDone: true)) == nil)
  }

  @Test("何も練習していない子を選んだら、後半から（新しく足した子・記録だけリセットした子）")
  func profileWithoutPracticeStartsChild() {
    #expect(
      Onboarding.stage(for: situation(adultDone: true, profiles: 3, named: true)) == .child)
  }

  @Test("練習したことがある子には出さない")
  func practicedShowsNothing() {
    #expect(Onboarding.stage(for: situation(adultDone: true, practiced: true)) == nil)
  }

  @Test("すでに使っている iPad（子が複数・呼び名あり・記録あり）には、前半を出さない")
  func existingInstallSkipsAdult() {
    #expect(Onboarding.stage(for: situation(profiles: 2)) == .child)
    #expect(Onboarding.stage(for: situation(named: true)) == .child)
    #expect(Onboarding.stage(for: situation(practiced: true)) == nil)
  }

  @Test("最初の1字は呼び名の最初の字")
  func firstLetterFromNickname() {
    #expect(Onboarding.firstLetter(nickname: "ゆうと") == "ゆ")
    #expect(Onboarding.firstLetter(nickname: "  そら") == "そ")
    #expect(Onboarding.firstLetter(nickname: "がく") == "が")
  }

  @Test("カタカナは同じ音のひらがなにする")
  func katakanaBecomesHiragana() {
    #expect(Onboarding.firstLetter(nickname: "ソラ") == "そ")
    #expect(Onboarding.firstLetter(nickname: "ガク") == "が")
  }

  @Test("濁点が別の文字で入っていても、1つの字として扱う")
  func decomposedDakuten() {
    #expect(Onboarding.firstLetter(nickname: "か\u{3099}く") == "が")
  }

  @Test("呼び名がないとき、書けない字のときは「あ」")
  func fallbackToA() {
    #expect(Onboarding.firstLetter(nickname: "") == "あ")
    #expect(Onboarding.firstLetter(nickname: "   ") == "あ")
    #expect(Onboarding.firstLetter(nickname: "太郎") == "あ")
    #expect(Onboarding.firstLetter(nickname: "Taro") == "あ")
    #expect(Onboarding.firstLetter(nickname: "ゃま") == "あ")
    #expect(Onboarding.firstLetter(nickname: "ー") == "あ")
  }

  @Test("最初のことばは、テーマのことばで、ひらがな2文字（D78）")
  func starterWords() {
    #expect(Onboarding.themes == [.vehicle, .animal, .clothes])
    for kind in Onboarding.themes {
      let word = Onboarding.starterWord(for: kind)
      #expect(word.count == 2)
      #expect(WordCatalog.entry(for: word)?.kind == kind)
    }
  }

  @Test("最初の1字は、みる → なぞる だけで終わる（D46）")
  func nazoruOnlyFinishesAfterTracing() throws {
    let data = try PracticeFlowTests.character("ゆ")
    var flow = PracticeFlow(character: data, preset: .hajimete, nazoruOnly: true)
    #expect(flow.step == .miru)
    #expect(flow.handle(.animationFinished) == [.stepChanged(.nazoru)])
    let lines = PracticeFlowTests.model(data)
    var effects: [PracticeEffect] = []
    for line in lines { effects = flow.handle(.strokeEnded(line)) }
    #expect(effects == [.keepStroke, .finished(rating: .maru, rescued: false)])
    #expect(flow.finished)
    #expect(flow.step == .nazoru)
  }

  @Test("最初の1字も、3回続けて合わなければ行き止まりにせず先へ進む（D46・D191）")
  func nazoruOnlyHasNoDeadEnd() throws {
    let data = try PracticeFlowTests.character("あ")
    var flow = PracticeFlow(character: data, preset: .hajimete, nazoruOnly: true)
    _ = flow.handle(.animationFinished)
    _ = flow.handle(.strokeEnded(PracticeFlowTests.scribble))
    _ = flow.handle(.strokeEnded(PracticeFlowTests.scribble))
    let effects = flow.handle(.strokeEnded(PracticeFlowTests.scribble))
    #expect(effects.last == .finished(rating: .maru, rescued: true))
  }

  @Test("キャラクターは3人（D39）")
  func threeCharacters() {
    #expect(MainCharacter.allCases.map(\.name) == ["とん", "るん", "ひら"])
  }
}
