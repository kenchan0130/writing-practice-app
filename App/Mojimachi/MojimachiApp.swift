import SwiftUI

@main
struct MojimachiApp: App {
  init() {
    // できるだけ早く。DSN が空のビルドと DEBUG では何もしない（D183）。
    CrashReporting.start()
    UITesting.configure()
    SoundPlayer.shared.preload()
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
