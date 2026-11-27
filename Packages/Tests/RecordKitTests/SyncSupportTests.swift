import Foundation
import Testing

@testable import RecordKit

@Suite("同期まわりの計算（D194）")
struct SyncSupportTests {
  @Test("自分の保存だけなら、読み直さない")
  func ownTransactionsIgnored() {
    #expect(!HistoryAuthor.hasRemote(authors: []))
    #expect(!HistoryAuthor.hasRemote(authors: [HistoryAuthor.app, HistoryAuthor.app]))
    #expect(
      !HistoryAuthor.hasRemote(authors: [HistoryAuthor.app, "NSCloudKitMirroringDelegate.export"]))
  }

  @Test("iCloud から届いた変更が混じっていれば、読み直す")
  func remoteDetected() {
    #expect(
      HistoryAuthor.hasRemote(authors: [HistoryAuthor.app, "NSCloudKitMirroringDelegate.import"]))
    #expect(HistoryAuthor.hasRemote(authors: [nil]))
  }

  @Test("読み直しの依頼は1つにまとまる")
  func coalesces() {
    var coalescer = ReloadCoalescer()
    let first = coalescer.request()
    let second = coalescer.request()
    let third = coalescer.request()
    #expect(first)
    #expect(!second)
    #expect(!third)
    let fired = coalescer.fire()
    let firedAgain = coalescer.fire()
    #expect(fired)
    #expect(!firedAgain)
    let next = coalescer.request()
    #expect(next)
  }

  @Test("アカウントが同じなら何もしない")
  func sameAccount() {
    #expect(ICloudAccountWatch.evaluate(previous: "a", current: "a", accountKnown: true) == .none)
  }

  @Test("別のアカウントになったら changed")
  func changedAccount() {
    #expect(
      ICloudAccountWatch.evaluate(previous: "a", current: "b", accountKnown: true) == .changed)
  }

  @Test("サインアウトしたら signedOut")
  func signedOut() {
    #expect(
      ICloudAccountWatch.evaluate(previous: "a", current: nil, accountKnown: true) == .signedOut)
  }

  @Test("前の印がない、または確かめられないときは何もしない")
  func unknown() {
    #expect(ICloudAccountWatch.evaluate(previous: nil, current: "b", accountKnown: true) == .none)
    #expect(ICloudAccountWatch.evaluate(previous: "a", current: nil, accountKnown: false) == .none)
  }

  @Test("前は子がいたのに、いま0人なら、データが消えたかもしれない")
  func lostData() {
    #expect(ICloudAccountWatch.lostLocalData(hadProfilesBefore: true, loadedProfileCount: 0))
    #expect(!ICloudAccountWatch.lostLocalData(hadProfilesBefore: false, loadedProfileCount: 0))
    #expect(!ICloudAccountWatch.lostLocalData(hadProfilesBefore: true, loadedProfileCount: 1))
  }

  @Test("届いた本物の子が、仮の子と入れ替わる")
  func adoptsRemote() {
    let placeholder = UUID()
    let real = Profile(name: "ゆうと", face: "cat.fill")
    let result = ProfileAdoption.resolve(
      placeholder: placeholder, current: placeholder, loaded: [real], preferred: nil)
    #expect(result.currentID == real.id)
    #expect(result.dropPlaceholder)
  }

  @Test("覚えている子がいれば、その子を使う")
  func adoptsPreferred() {
    let placeholder = UUID()
    let a = Profile(name: "あ", face: "x")
    let b = Profile(name: "い", face: "x")
    let result = ProfileAdoption.resolve(
      placeholder: placeholder, current: placeholder, loaded: [a, b], preferred: b.id)
    #expect(result.currentID == b.id)
  }

  @Test("まだ何も届いていなければ、仮の子のまま")
  func keepsPlaceholderWhenEmpty() {
    let placeholder = UUID()
    let result = ProfileAdoption.resolve(
      placeholder: placeholder, current: placeholder, loaded: [], preferred: nil)
    #expect(result.currentID == placeholder)
    #expect(!result.dropPlaceholder)
  }

  @Test("仮の子でなければ、いまの子を変えない")
  func noPlaceholder() {
    let a = Profile(name: "あ", face: "x")
    let b = Profile(name: "い", face: "x")
    let result = ProfileAdoption.resolve(
      placeholder: nil, current: b.id, loaded: [a, b], preferred: nil)
    #expect(result.currentID == b.id)
    #expect(!result.dropPlaceholder)
  }

  @Test("線を読んでいなくても、hasStrokes があればアルバムに出る")
  func albumUsesHasStrokes() {
    let record = CharacterRecord(
      date: Date(), characterID: "hira.3042", stage: .jibunde, passed: true, hasStrokes: true)
    var log = LearningLog()
    log.append(record)
    #expect(record.strokes == nil)
    #expect(log.album.map(\.characterID) == ["hira.3042"])
  }

  @Test("線がなければ、アルバムに出ない")
  func albumSkipsWithoutStrokes() {
    var log = LearningLog()
    log.append(
      CharacterRecord(date: Date(), characterID: "hira.3042", stage: .jibunde, passed: true))
    #expect(log.album.isEmpty)
  }

  @Test("いまの子が消えていたら、最初の子にする")
  func currentGone() {
    let a = Profile(name: "あ", face: "x")
    let result = ProfileAdoption.resolve(
      placeholder: nil, current: UUID(), loaded: [a], preferred: nil)
    #expect(result.currentID == a.id)
  }
}
