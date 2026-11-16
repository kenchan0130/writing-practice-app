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
        $0.message = "ちがいます。あと \(remaining) 回 ためせます"
      }
    }
    await Self.type(store, "1")
    await store.send(.keyPressed("OK")) {
      $0.input = ""
      _ = $0.gate.answer(1, at: 1000)
      $0.message = "31 秒 まってから ためしてください"
    }
    #expect(!store.state.gate.isOpen(at: 1000))
    // ロック中は正しい答えでも通らない。
    await Self.type(store, "36")
    await store.send(.keyPressed("OK")) {
      $0.input = ""
      _ = $0.gate.answer(36, at: 1000)
      $0.message = "31 秒 まってから ためしてください"
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

  @Test("やめるで閉じる。けすで入力を消す")
  func cancelAndClear() async {
    let store = Self.store()
    await Self.type(store, "12")
    await store.send(.keyPressed("けす")) { $0.input = "" }
    await store.send(.cancelTapped) { $0.outcome = .cancelled }
    await store.send(.opened) { $0.outcome = nil }
  }
}
