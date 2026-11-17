import CloudKit
import Foundation
import Testing

@testable import Mojimachi

/// iCloud のエラーの見分けと、「前に同期できた」の印（D159）。
@Suite("iCloud のエラーの見分け")
struct CloudErrorTests {
  private func zoneID() -> CKRecordZone.ID {
    CKRecordZone.ID(zoneName: RecordStore.cloudZoneName, ownerName: CKCurrentUserDefaultName)
  }

  @Test("一番上の zoneNotFound は、置き場所が消えた")
  func topLevelZoneNotFound() {
    #expect(RecordStore.syncEvent(forError: CKError(.zoneNotFound)) == .zoneDeleted)
  }

  @Test("userDeletedZone も、置き場所が消えた")
  func userDeletedZone() {
    #expect(RecordStore.syncEvent(forError: CKError(.userDeletedZone)) == .zoneDeleted)
  }

  @Test("partialFailure の中の zoneNotFound も、置き場所が消えた")
  func partialFailure() {
    let inner = CKError(.zoneNotFound)
    let error = CKError(
      .partialFailure, userInfo: [CKPartialErrorsByItemIDKey: [zoneID(): inner]])
    #expect(RecordStore.syncEvent(forError: error) == .zoneDeleted)
  }

  @Test("元のエラーの中の zoneNotFound も、置き場所が消えた")
  func underlying() {
    let error = NSError(
      domain: NSCocoaErrorDomain, code: 134_400,
      userInfo: [NSUnderlyingErrorKey: CKError(.zoneNotFound) as NSError])
    #expect(RecordStore.syncEvent(forError: error) == .zoneDeleted)
  }

  @Test("partialFailure でも、中が別のエラーなら消えたことにしない")
  func partialFailureOther() {
    let error = CKError(
      .partialFailure,
      userInfo: [CKPartialErrorsByItemIDKey: [zoneID(): CKError(.networkUnavailable)]])
    #expect(RecordStore.syncEvent(forError: error) == .failed(.other))
  }

  @Test("容量いっぱい")
  func quota() {
    #expect(RecordStore.syncEvent(forError: CKError(.quotaExceeded)) == .failed(.quotaExceeded))
  }

  @Test("サインインしていない")
  func notAuthenticated() {
    #expect(RecordStore.syncEvent(forError: CKError(.notAuthenticated)) == .failed(.notSignedIn))
  }

  @Test("そのほかのエラー")
  func other() {
    #expect(RecordStore.syncEvent(forError: CKError(.internalError)) == .failed(.other))
    #expect(RecordStore.syncEvent(forError: URLError(.notConnectedToInternet)) == .failed(.other))
  }
}

@Suite("前に同期できた印")
struct SyncedBeforeTests {
  private func makeDefaults() -> UserDefaults {
    let name = "SyncedBeforeTests-\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defaults.removePersistentDomain(forName: name)
    return defaults
  }

  @Test("起動の確認が要るのは、同期がオンで、前に同期できたときだけ")
  func needsCheck() {
    #expect(RecordStore.needsZoneCheckAtLaunch(syncOn: true, syncedBefore: true))
    #expect(!RecordStore.needsZoneCheckAtLaunch(syncOn: true, syncedBefore: false))
    #expect(!RecordStore.needsZoneCheckAtLaunch(syncOn: false, syncedBefore: true))
    #expect(!RecordStore.needsZoneCheckAtLaunch(syncOn: false, syncedBefore: false))
  }

  @Test("印を付けて、消せる")
  func setAndClear() {
    let defaults = makeDefaults()
    #expect(!RecordStore.hasSyncedBefore(defaults))
    RecordStore.setSyncedBefore(true, defaults)
    #expect(RecordStore.hasSyncedBefore(defaults))
    RecordStore.setSyncedBefore(false, defaults)
    #expect(!RecordStore.hasSyncedBefore(defaults))
  }

  @Test("同期をオフにすると、印が消える")
  func clearedWhenSyncTurnedOff() {
    let defaults = makeDefaults()
    RecordStore.setSyncedBefore(true, defaults)
    let progress = ProgressStore(records: RecordStore(url: nil), defaults: defaults)
    progress.syncsWithICloud = false
    #expect(!RecordStore.hasSyncedBefore(defaults))
  }
}
