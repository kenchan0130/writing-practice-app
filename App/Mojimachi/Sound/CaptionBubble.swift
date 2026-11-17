import SwiftUI

/// 字幕の吹き出し（§3.9）。声を読んでいるあいだ、画面の上に出す。
struct CaptionBubble: View {
  var body: some View {
    let voice = VoicePlayer.shared
    ZStack {
      if let text = voice.caption {
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
