import SwiftUI

@main
struct MojimachiApp: App {
  init() {
    SoundPlayer.shared.preload()
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
