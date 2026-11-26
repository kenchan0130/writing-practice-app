import SwiftUI

@main
struct MojimachiApp: App {
  init() {
    UITesting.configure()
    SoundPlayer.shared.preload()
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
