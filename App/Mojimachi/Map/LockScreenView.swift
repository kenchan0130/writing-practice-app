import EntitlementKit
import SoundKit
import SwiftUI

extension Script {
  /// 保護者用の画面のお知らせに出す名前（ふつうの日本語。D157・D160）。
  var wishTitle: String {
    switch self {
    case .hiragana: "ひらがな"
    case .katakana: "カタカナ"
    case .abc: "アルファベットと数字"
    }
  }
}

/// 鍵の画面（§5.3・D3・D80・D160）。鍵のかかった字・ことばを子どもが触ったときに出す。
/// 「おとなのひとに おねがいする」は、押した気持ちを記録するだけ。購入画面は開かない。
/// 価格・「かう」ボタン・エラーは出さない（D3・D117）。
struct LockScreenView: View {
  /// 鍵のかかっているもの（購入できる単位）。
  var script: Script
  /// 元の画面へ戻る。
  var onClose: () -> Void
  /// おねがいを記録する（既定は本物の記録。試験で差し替える）。
  var onWish: (Script) -> Void = { ProgressStore.shared.makeWish(item: $0.rawValue) }

  /// おねがいを押したあと、「おねがい できたよ」を見せてから戻るまでの秒数。
  static let thanksSeconds = 1.8

  static let title = "この もじは まだ ねむっているよ"
  static let voiceLine = VoiceLine.locked.text
  static let thanks = VoiceLine.lockThanks.text

  @State private var activity = WritingActivity()
  @State private var asked = false
  @State private var closeTask: Task<Void, Never>?
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        BackButton(activity: activity) { close() }
        Spacer()
      }
      .padding(.horizontal, 32)
      .padding(.top, 12)
      Spacer(minLength: 0)
      VStack(spacing: 36) {
        Text(asked ? Self.thanks : Self.title)
          .font(.ui(48, bold: true))
          .foregroundStyle(Theme.ink)
          .multilineTextAlignment(.center)
          .accessibilityIdentifier("lockTitle")
        sleepingCharacter
        if asked {
          Image(systemName: "heart.fill")
            .font(.system(size: 72))
            .foregroundStyle(Theme.pink)
            .frame(minHeight: 140)
            .symbolEffect(.bounce, options: .nonRepeating, value: asked)
            .accessibilityHidden(true)
        } else {
          askButton
        }
      }
      .padding(.horizontal, 48)
      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .childBackground()
    .overlay(alignment: .top) { CaptionBubble().padding(.top, 12) }
    .accessibilityElement(children: .contain)
    .onAppear {
      SoundPlayer.shared.play(.locked)
      VoicePlayer.shared.speak(.locked)
    }
    .onDisappear { closeTask?.cancel() }
  }

  /// ねむっているキャラクター（絵ができるまでの仮。D134）。ホームのキャラクターと同じ丸に、zzz を添える。
  private var sleepingCharacter: some View {
    Image(systemName: "pawprint.fill")
      .font(.system(size: 120))
      .foregroundStyle(.white.opacity(0.9))
      .frame(width: 240, height: 240)
      .background(Theme.pink.opacity(0.55).gradient, in: .circle)
      .overlay(alignment: .topTrailing) {
        Image(systemName: "zzz")
          .font(.system(size: 64, weight: .bold))
          .foregroundStyle(Theme.blue)
          .offset(x: 36, y: -12)
          .symbolEffect(.pulse, isActive: !reduceMotion)
      }
      .softShadow()
      .accessibilityLabel("ねむっている キャラクター")
  }

  private var askButton: some View {
    Button(action: ask) {
      Label("おとなのひとに おねがいする", systemImage: "hands.sparkles.fill")
        .font(.ui(40, bold: true))
        .foregroundStyle(.white)
        .padding(.horizontal, 40)
        .frame(minWidth: 104, minHeight: 140)
        .background(Theme.accent.gradient, in: .rect(cornerRadius: 70))
        .softShadow()
    }
    .buttonStyle(.plain)
    .accessibilityIdentifier("lockAsk")
  }

  private func ask() {
    guard !asked else { return }
    asked = true
    onWish(script)
    VoicePlayer.shared.speak(.lockThanks)
    SoundPlayer.shared.play(.sparkle)
    closeTask = Task {
      try? await Task.sleep(for: .seconds(Self.thanksSeconds))
      guard !Task.isCancelled else { return }
      close()
    }
  }

  private func close() {
    closeTask?.cancel()
    onClose()
  }
}
