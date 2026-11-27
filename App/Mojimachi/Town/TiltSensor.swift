import CoreMotion
import UIKit

/// iPad の傾き（§3.3）。まちの画面が見えているあいだだけ動かす。
/// センサーのない端末（Mac など）では何もしない（押して転がす。D133）。値は端末の外へ出さない。
@MainActor
final class TiltSensor {
  private let manager = CMMotionManager()

  func start() {
    guard manager.isDeviceMotionAvailable, !manager.isDeviceMotionActive else { return }
    manager.deviceMotionUpdateInterval = 1.0 / 30
    manager.startDeviceMotionUpdates()
  }

  func stop() {
    guard manager.isDeviceMotionActive else { return }
    manager.stopDeviceMotionUpdates()
  }

  /// 画面の横向きの傾き（-1〜1。画面の右がわが下がると正）。分からなければ 0。
  func tilt(orientation: UIInterfaceOrientation) -> Double {
    guard let gravity = manager.deviceMotion?.gravity else { return 0 }
    return Self.tilt(x: gravity.x, y: gravity.y, orientation: orientation)
  }

  /// 重力の向き（端末の座標。x = 端末の右、y = 端末の上）を、画面の横向きの傾きにする。
  nonisolated static func tilt(x: Double, y: Double, orientation: UIInterfaceOrientation) -> Double {
    switch orientation {
    case .portraitUpsideDown: -x
    // 端末の上が画面の左（ホームボタンが右）。画面の右 = 端末の下。
    case .landscapeRight: -y
    // 端末の上が画面の右。
    case .landscapeLeft: y
    default: x
    }
  }
}
