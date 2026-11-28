import Foundation
import Testing

@testable import RecordKit

@Suite("子の行が消えたときの判断")
struct ProfileVanishTests {
  private let a = UUID()
  private let b = UUID()

  @Test("直すときは、行が無ければ足さない")
  func updateNeverInserts() {
    #expect(ProfileWrite.update(canRead: true, rowExists: true) == .updated)
    #expect(ProfileWrite.update(canRead: true, rowExists: false) == .missing)
  }

  @Test("読めなかったときは、無かったとは言わない")
  func updateUnreadable() {
    #expect(ProfileWrite.update(canRead: false, rowExists: false) == .unreadable)
    #expect(ProfileWrite.update(canRead: false, rowExists: true) == .unreadable)
  }

  @Test("足すときは、行があれば二重にせず直す")
  func insertDoesNotDuplicate() {
    #expect(ProfileWrite.insert(rowExists: false) == .inserted)
    #expect(ProfileWrite.insert(rowExists: true) == .updated)
  }

  @Test("行が消えた子は、消えたと分かる")
  func vanished() {
    #expect(ProfileVanish.isVanished(profileID: a, placeholderID: nil, rowExists: false))
    #expect(!ProfileVanish.isVanished(profileID: a, placeholderID: nil, rowExists: true))
  }

  @Test("まだ保存していない最初の子は、消えたと言わない")
  func placeholderIsNeverVanished() {
    #expect(!ProfileVanish.isVanished(profileID: a, placeholderID: a, rowExists: false))
    #expect(ProfileVanish.isVanished(profileID: a, placeholderID: b, rowExists: false))
  }

  @Test("書いてよいかの決まり")
  func writeGate() {
    #expect(
      ProfileVanish.writeGate(switchPending: false, isPlaceholder: false, rowExists: true) == .write
    )
    #expect(
      ProfileVanish.writeGate(switchPending: false, isPlaceholder: true, rowExists: false) == .write
    )
    #expect(
      ProfileVanish.writeGate(switchPending: false, isPlaceholder: false, rowExists: false)
        == .drop)
    // 切り替えを待つあいだは、保存先に書かない。
    #expect(
      ProfileVanish.writeGate(switchPending: true, isPlaceholder: false, rowExists: true)
        == .memoryOnly)
    #expect(
      ProfileVanish.writeGate(switchPending: true, isPlaceholder: true, rowExists: false)
        == .memoryOnly)
  }

  @Test("読み直しで0人: 最初の子なら待つ、保存していた子なら消えた")
  func reloadAction() {
    #expect(
      ProfileVanish.reloadAction(placeholderID: a, currentID: a, loadedIDs: []) == .keepPlaceholder)
    #expect(
      ProfileVanish.reloadAction(placeholderID: nil, currentID: a, loadedIDs: []) == .vanished)
    #expect(ProfileVanish.reloadAction(placeholderID: b, currentID: a, loadedIDs: []) == .vanished)
  }

  @Test("1人でも読めたら、ふつうに読み直す")
  func reloadWithProfiles() {
    #expect(ProfileVanish.reloadAction(placeholderID: a, currentID: a, loadedIDs: [b]) == .adopt)
    #expect(ProfileVanish.reloadAction(placeholderID: a, currentID: a, loadedIDs: [a]) == .adopt)
    #expect(
      ProfileVanish.reloadAction(placeholderID: nil, currentID: a, loadedIDs: [a, b]) == .adopt)
  }

  @Test("いまの子だけ消えて、ほかの子が残っているとき")
  func currentGone() {
    #expect(
      ProfileVanish.reloadAction(placeholderID: nil, currentID: a, loadedIDs: [b]) == .currentGone)
    #expect(
      ProfileVanish.reloadAction(placeholderID: b, currentID: a, loadedIDs: [b]) == .currentGone)
  }

  @Test("書く画面にいるあいだは、切り替えを待つ")
  func timing() {
    #expect(ProfileVanish.switchTiming(isWriting: true) == .deferred)
    #expect(ProfileVanish.switchTiming(isWriting: false) == .now)
  }
}
