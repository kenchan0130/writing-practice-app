import SwiftUI

/// UI テスト用の起動の引数 `-uiTesting YES`（DEBUG のときだけ）。
/// 動きを止め、テストが待つ長い待ち時間を縮める。確かめる中身は変えない（D171）。
enum UITesting {
  static let isOn: Bool = {
    #if DEBUG
      UserDefaults.standard.bool(forKey: "uiTesting")
    #else
      false
    #endif
  }()

  static func configure() {
    #if DEBUG
      if isOn { UIView.setAnimationsEnabled(false) }
    #endif
  }

  /// 本番はそのまま、UI テストでは短くした待ち時間。
  static func seconds(_ normal: Double, uiTesting short: Double) -> Double {
    isOn ? short : normal
  }
}
