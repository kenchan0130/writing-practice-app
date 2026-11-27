import SwiftUI
import UIKit

/// 日付が変わったときに、画面を読み直させる（D194）。
/// アプリを開いたまま夜中をまたいでも、きょうの もくひょう・スタンプ・おたのしみ ボックスが
/// 昨日のまま残らないようにする。アプリに戻ったとき、日付が変わったとき、時計が大きく変わったときに
/// `token` を増やす（画面の側は、増えたら読み直す）。
struct DayRefresh: ViewModifier {
  @Binding var token: Int
  @Environment(\.scenePhase) private var scenePhase

  func body(content: Content) -> some View {
    content
      .onChange(of: scenePhase) { _, phase in
        if phase == .active { token += 1 }
      }
      .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
        token += 1
      }
      .onReceive(
        NotificationCenter.default.publisher(
          for: UIApplication.significantTimeChangeNotification)
      ) { _ in
        token += 1
      }
  }
}
