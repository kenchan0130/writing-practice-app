import SwiftUI

/// 字幕の吹き出し（§3.9）。声を読んでいるあいだ、画面の上に出す。
struct CaptionBubble: View {
  /// 「←」の段（ContentView）に出すときは true。そこに出すときは、画面の中の（上の）吹き出しは出さない。
  var inHeader = false
  @Environment(\.captionInHeader) private var captionInHeader

  var body: some View {
    let voice = VoicePlayer.shared
    ZStack {
      if let text = voice.caption, inHeader || !captionInHeader {
        Text(text)
          .font(.learning(40))
          .padding(.horizontal, 28)
          .padding(.vertical, 14)
          .background(.white, in: .rect(cornerRadius: 32))
          .overlay(RoundedRectangle(cornerRadius: 32).stroke(Theme.accent, lineWidth: 4))
          .softShadow()
          .transition(.scale.combined(with: .opacity))
      }
    }
    .animation(.easeOut(duration: 0.25), value: voice.caption)
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }
}

private struct CaptionInHeaderKey: EnvironmentKey {
  static let defaultValue = false
}

extension EnvironmentValues {
  /// 声の字幕を、画面の上ではなく「←」の段に出しているか。字の行などに重ならないようにする。
  var captionInHeader: Bool {
    get { self[CaptionInHeaderKey.self] }
    set { self[CaptionInHeaderKey.self] = newValue }
  }
}
