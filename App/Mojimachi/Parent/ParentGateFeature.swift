import ComposableArchitecture
import Foundation
import ParentGateKit

/// iPad の認証を求める部品（D64）。画面や端末に頼らないよう、差し替えられる形にする。
nonisolated struct DeviceAuthClient: Sendable {
  /// 「iPad のパスコードも求める」がオンか。
  var isRequired: @Sendable () -> Bool
  /// iPad の認証を求める。パスコードを設定していない iPad では通す。
  var confirm: @Sendable (_ reason: String) async -> Bool
}

nonisolated extension DeviceAuthClient: DependencyKey {
  static let liveValue = DeviceAuthClient(
    // Store は main で動くので、ここは main の上。
    isRequired: { MainActor.assumeIsolated { ProgressStore.shared.requiresDeviceAuth } },
    confirm: { await DeviceAuth.confirm(reason: $0) }
  )
  static let testValue = DeviceAuthClient(
    isRequired: unimplemented("DeviceAuthClient.isRequired", placeholder: false),
    confirm: unimplemented("DeviceAuthClient.confirm", placeholder: false)
  )
}

nonisolated extension DependencyValues {
  var deviceAuth: DeviceAuthClient {
    get { self[DeviceAuthClient.self] }
    set { self[DeviceAuthClient.self] = newValue }
  }
}

/// 保護者用の確認の流れ（D49・D64）。判定は `ParentGateKit` の `ParentGate` に任せる。
@Reducer
nonisolated struct ParentGateFeature {
  @ObservableState
  struct State: Equatable {
    var gate: ParentGate
    var input = ""
    var message: String?
    /// 画面を閉じてよい結果。画面がこれを見て閉じる。
    var outcome: Outcome?
    /// 保護者用の画面を開いたまま5分たって、確認が切れた（D49）。画面がこれを見て閉じる。
    var parentAreaExpired = false

    init(gate: ParentGate = Self.makeGate()) {
      self.gate = gate
    }

    static func makeGate() -> ParentGate {
      var validity = ParentGate.validSeconds
      #if DEBUG
        // UI テスト用: `-parentValiditySeconds 3` で有効な時間を縮める。
        let override = UserDefaults.standard.double(forKey: "parentValiditySeconds")
        if override > 0 { validity = override }
      #endif
      return ParentGate(random: { Double.random(in: 0..<1) }, validity: validity)
    }

    static func == (lhs: State, rhs: State) -> Bool {
      lhs.input == rhs.input && lhs.message == rhs.message && lhs.outcome == rhs.outcome
        && lhs.gate.question == rhs.gate.question && lhs.gate.mistakes == rhs.gate.mistakes
        && lhs.gate.lockedUntil == rhs.gate.lockedUntil
        && lhs.gate.lastActivity == rhs.gate.lastActivity
        && lhs.parentAreaExpired == rhs.parentAreaExpired
    }
  }

  enum Outcome: Equatable {
    case passed
    case cancelled
  }

  enum Action: Equatable {
    /// 画面が開いた。入力とメッセージを空にする。
    case opened
    /// キーパッドの 0〜9・「消す」・「OK」。
    case keyPressed(String)
    case cancelTapped
    case deviceAuthFinished(Bool)
    case passed
    /// 確認の有効を終える（保護者用の画面を閉じたとき）。
    case close
    /// 保護者用の画面が開いた。
    case parentAreaOpened
    /// 保護者用の画面で操作した（有効な時間を5分先へ延ばす。D49）。
    case touched
    /// 保護者用の画面を開いているあいだ、時々呼ぶ。切れていたら `parentAreaExpired` にする。
    case checkExpiry
  }

  @Dependency(\.date) var date
  @Dependency(\.deviceAuth) var deviceAuth

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .opened:
        state.input = ""
        state.message = nil
        state.outcome = nil
        return .none

      case .keyPressed(let key):
        switch key {
        case "消す":
          state.input = ""
        case "OK":
          return submit(&state)
        default:
          if state.input.count < 3 { state.input += key }
        }
        return .none

      case .cancelTapped:
        state.outcome = .cancelled
        return .none

      case .deviceAuthFinished(let ok):
        if ok {
          return .send(.passed)
        }
        state.message = String(localized: "iPad の確認ができませんでした")
        return .none

      case .passed:
        state.outcome = .passed
        return .none

      case .close:
        state.gate.close()
        return .none

      case .parentAreaOpened:
        state.parentAreaExpired = false
        #if DEBUG
          // 確かめ用の `-openParent` は確認を通らずに開くので、通ったことにする。
          let now = date.now.timeIntervalSince1970
          if UserDefaults.standard.string(forKey: "openParent") != nil,
            !state.gate.isOpen(at: now)
          {
            _ = state.gate.answer(state.gate.question.answer, at: now)
          }
        #endif
        return .none

      case .touched:
        state.gate.touch(at: date.now.timeIntervalSince1970)
        return .none

      case .checkExpiry:
        if !state.gate.isOpen(at: date.now.timeIntervalSince1970) {
          state.gate.close()
          state.parentAreaExpired = true
        }
        return .none
      }
    }
  }

  private func submit(_ state: inout State) -> Effect<Action> {
    guard let value = Int(state.input) else { return .none }
    state.input = ""
    let now = date.now.timeIntervalSince1970
    switch state.gate.answer(value, at: now) {
    case .passed:
      // 「iPad のパスコードも もとめる」（D64）。パスコードが設定されていなければ、かけ算だけで通す。
      if deviceAuth.isRequired() {
        return .run { [deviceAuth] send in
          await send(.deviceAuthFinished(await deviceAuth.confirm(String(localized: "保護者用の画面を開きます"))))
        }
      }
      return .send(.passed)
    case .wrong(let remaining):
      state.message = String(localized: "もう一度どうぞ。あと \(remaining) 回試せます")
    case .locked(let until):
      state.message = String(localized: "\(Int(until - now) + 1) 秒待ってから試してください")
    }
    return .none
  }
}
