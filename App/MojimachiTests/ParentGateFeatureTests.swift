import ComposableArchitecture
import Foundation
import ParentGateKit
import Testing

@testable import Mojimachi

/// 保護者用の確認の流れを TestStore で確かめる（D105）。
@Suite("保護者用の確認の流れ")
@MainActor
struct ParentGateFeatureTests {
  /// いつも 12 × 3 = 36 の問題が出る確認。
  private static func store(deviceAuthRequired: Bool = false, authResult: Bool = true)
    -> TestStore<ParentGateFeature.State, ParentGateFeature.Action>
  {
    TestStore(initialState: ParentGateFeature.State(gate: ParentGate(random: { 0 }))) {
      ParentGateFeature()
    } withDependencies: {
      $0.date = .constant(Date(timeIntervalSince1970: 1000))
      $0.deviceAuth = DeviceAuthClient(
        isRequired: { deviceAuthRequired },
        confirm: { _ in authResult }
      )
    }
  }

  private static func type(
    _ store: TestStore<ParentGateFeature.State, ParentGateFeature.Action>, _ text: String
  )
    async
  {
    for key in text.map(String.init) {
      await store.send(.keyPressed(key)) { $0.input += key }
    }
  }

  @Test("正しい答えで通る")
  func correctAnswerPasses() async {
    let store = Self.store()
    #expect(store.state.gate.question.answer == 36)
    await Self.type(store, "36")
    await store.send(.keyPressed("OK")) {
      $0.input = ""
      _ = $0.gate.answer(36, at: 1000)
    }
    await store.receive(.passed) { $0.outcome = .passed }
    #expect(store.state.gate.isOpen(at: 1000))
  }

  @Test("3回まちがえると待つ")
  func threeWrongAnswersLock() async {
    let store = Self.store()
    for remaining in [2, 1] {
      await Self.type(store, "1")
      await store.send(.keyPressed("OK")) {
        $0.input = ""
        _ = $0.gate.answer(1, at: 1000)
        $0.message = "もう一度どうぞ。あと \(remaining) 回試せます"
      }
    }
    await Self.type(store, "1")
    await store.send(.keyPressed("OK")) {
      $0.input = ""
      _ = $0.gate.answer(1, at: 1000)
      $0.message = "31 秒待ってから試してください"
    }
    #expect(!store.state.gate.isOpen(at: 1000))
    // ロック中は正しい答えでも通らない。
    await Self.type(store, "36")
    await store.send(.keyPressed("OK")) {
      $0.input = ""
      _ = $0.gate.answer(36, at: 1000)
      $0.message = "31 秒待ってから試してください"
    }
    #expect(store.state.outcome == nil)
  }

  @Test("iPad の確認を求めるときは、確認が通ってから通る")
  func deviceAuthRequired() async {
    let store = Self.store(deviceAuthRequired: true, authResult: true)
    await Self.type(store, "36")
    await store.send(.keyPressed("OK")) {
      $0.input = ""
      _ = $0.gate.answer(36, at: 1000)
    }
    await store.receive(.deviceAuthFinished(true))
    await store.receive(.passed) { $0.outcome = .passed }
  }

  @Test("iPad の確認が通らなければ、通さない")
  func deviceAuthDenied() async {
    let store = Self.store(deviceAuthRequired: true, authResult: false)
    await Self.type(store, "36")
    await store.send(.keyPressed("OK")) {
      $0.input = ""
      _ = $0.gate.answer(36, at: 1000)
    }
    await store.receive(.deviceAuthFinished(false)) {
      $0.message = "iPad の確認ができませんでした"
    }
  }

  @Test("やめるで閉じる。「消す」で入力を消す")
  func cancelAndClear() async {
    let store = Self.store()
    await Self.type(store, "12")
    await store.send(.keyPressed("消す")) { $0.input = "" }
    await store.send(.cancelTapped) { $0.outcome = .cancelled }
    await store.send(.opened) { $0.outcome = nil }
  }

  /// 時計を手で進められる確認。通った時刻は 1000 秒。
  private static func clockStore(_ now: LockIsolated<Double>) -> TestStore<
    ParentGateFeature.State, ParentGateFeature.Action
  > {
    var gate = ParentGate(random: { 0 })
    _ = gate.answer(36, at: 1000)
    return TestStore(initialState: ParentGateFeature.State(gate: gate)) {
      ParentGateFeature()
    } withDependencies: {
      $0.date = DateGenerator { Date(timeIntervalSince1970: now.value) }
    }
  }

  @Test("保護者用の画面は、5分操作がなければ切れる（D49）")
  func expiresAfterFiveMinutes() async {
    let now = LockIsolated(1000.0)
    let store = Self.clockStore(now)
    now.setValue(1000 + 299)
    await store.send(.checkExpiry)
    #expect(!store.state.parentAreaExpired)
    now.setValue(1000 + 300)
    await store.send(.checkExpiry) {
      $0.gate.close()
      $0.parentAreaExpired = true
    }
    #expect(!store.state.gate.isOpen(at: 1000 + 300))
    // 開き直すと、切れた印は消える。
    await store.send(.parentAreaOpened) { $0.parentAreaExpired = false }
  }

  @Test("操作すると、切れるまでの時間が5分先へ延びる")
  func touchExtends() async {
    let now = LockIsolated(1000.0)
    let store = Self.clockStore(now)
    now.setValue(1000 + 250)
    await store.send(.touched) { $0.gate.touch(at: 1250) }
    now.setValue(1250 + 299)
    await store.send(.checkExpiry)
    #expect(!store.state.parentAreaExpired)
    now.setValue(1250 + 300)
    await store.send(.checkExpiry) {
      $0.gate.close()
      $0.parentAreaExpired = true
    }
  }

  @Test("切れたあとの操作では、延びない")
  func touchAfterExpiryDoesNothing() async {
    let now = LockIsolated(1000.0)
    let store = Self.clockStore(now)
    now.setValue(1000 + 400)
    await store.send(.touched)
    #expect(!store.state.gate.isOpen(at: 1400))
  }
}
