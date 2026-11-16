import LocalAuthentication

/// iPad の認証（Face ID・Touch ID・パスコード。D64）。
enum DeviceAuth {
  /// iPad にパスコードが設定されているか。
  static var isAvailable: Bool {
    LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
  }

  /// iPad の認証を求める。パスコードを設定していない iPad では通す（D64）。
  static func confirm(reason: String) async -> Bool {
    let context = LAContext()
    guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) else { return true }
    return (try? await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason))
      ?? false
  }

  /// 「iPad のパスコードも求める」がオンのときだけ、iPad の認証を求める。
  @MainActor
  static func confirmIfRequired() async -> Bool {
    guard ProgressStore.shared.requiresDeviceAuth else { return true }
    return await confirm(reason: "取り返しのつかない操作をします")
  }
}
