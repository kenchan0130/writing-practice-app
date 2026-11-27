import ContentModel
import PracticeKit
import SoundKit
import SwiftUI

/// はじめての流れの後半: 子どもの体験（D23。約3分）。
/// キャラクターを選ぶ → あいさつ → 最初の1字（みる → なぞる）→ なにが すき？ → 2文字のことば → まち → ホーム。
/// 操作の説明はしない。ことばは短いひらがなで（D26・D150）、呼び名は声で読まない（D28）。
struct OnboardingChildView: View {
  /// ホームへ移る。
  var onFinish: () -> Void

  private enum Step {
    case character
    case greeting
    case letter
    case theme
    case word
    case town
  }

  private let store = ProgressStore.shared
  @State private var step = Step.character
  @State private var activity = WritingActivity()
  @State private var kind: WordKind = .vehicle
  @State private var word = ""

  /// 最初の1字は、呼び名の最初の字（なければ「あ」。D46）。
  private let letter = Onboarding.firstLetter(
    nickname: ProgressStore.shared.currentProfile?.name ?? "")

  var body: some View {
    VStack(spacing: 0) {
      if step != .town {
        HStack {
          // 「←」で抜けられる（この起動のあいだは出さない。D101）。
          BackButton(activity: activity) {
            store.leaveChildOnboarding()
            onFinish()
          }
          Spacer()
        }
        .padding(.horizontal, 32)
        .padding(.top, 12)
      }
      content
    }
  }

  @ViewBuilder
  private var content: some View {
    switch step {
    case .character:
      characterStep.overlay(alignment: .top) { CaptionBubble().padding(.top, 12) }
    case .greeting:
      greetingStep.overlay(alignment: .top) { CaptionBubble().padding(.top, 12) }
    case .letter:
      WritingCanvasView(activity: activity, start: letter) {
        withAnimation { step = .theme }
      }
    case .theme:
      themeStep.overlay(alignment: .top) { CaptionBubble().padding(.top, 12) }
    case .word:
      WordWritingView(activity: activity, start: word, locksWord: true) { _ in
        withAnimation { step = .town }
      }
      .id(word)
    case .town:
      townStep.overlay(alignment: .top) { CaptionBubble().padding(.top, 12) }
    }
  }

  // MARK: - 1 キャラクターを選ぶ

  private var characterStep: some View {
    VStack(spacing: 40) {
      Spacer()
      Text("だれと いっしょに かく？")
        .font(.ui(48, bold: true))
        .foregroundStyle(Theme.ink)
      HStack(spacing: 32) {
        ForEach(MainCharacter.allCases, id: \.self) { character in
          Button {
            store.mainCharacter = character
            SoundPlayer.shared.play(.tap)
            withAnimation { step = .greeting }
          } label: {
            VStack(spacing: 16) {
              MainCharacterArt(character: character, size: 180)
              Text(character.name).font(.ui(36, bold: true)).foregroundStyle(Theme.ink)
            }
            .padding(24)
            .frame(minWidth: 220, minHeight: 280)
            .background(.white.opacity(0.85), in: .rect(cornerRadius: Theme.Radius.card))
            .softShadow()
          }
          .buttonStyle(.plain)
          .accessibilityLabel(character.name)
          .accessibilityIdentifier("onboardingCharacter-\(character.rawValue)")
        }
      }
      Spacer()
    }
    .padding(.horizontal, 32)
    .task { VoicePlayer.shared.speak(.onboardingWho) }
  }

  // MARK: - 2 あいさつ

  private var greetingStep: some View {
    GreetingStep(
      character: store.mainCharacter, nickname: store.currentProfile?.displayName ?? ""
    ) {
      withAnimation { step = .letter }
    }
  }

  // MARK: - 4 なにが すき？

  private var themeStep: some View {
    VStack(spacing: 40) {
      Spacer()
      HStack(spacing: 24) {
        MainCharacterArt(character: store.mainCharacter, size: 120)
        Text("なにが すき？")
          .font(.ui(56, bold: true))
          .foregroundStyle(Theme.ink)
      }
      HStack(spacing: 32) {
        ForEach(Onboarding.themes, id: \.self) { theme in
          Button {
            SoundPlayer.shared.play(.tap)
            kind = theme
            word = Onboarding.starterWord(for: theme)
            withAnimation { step = .word }
          } label: {
            VStack(spacing: 16) {
              Image(systemName: Self.symbol(theme))
                .font(.system(size: 88))
                .foregroundStyle(Self.color(theme))
                .frame(height: 110)
              Text(Self.title(theme)).font(.ui(36, bold: true)).foregroundStyle(Theme.ink)
            }
            .padding(24)
            .frame(minWidth: 220, minHeight: 240)
            .background(.white.opacity(0.85), in: .rect(cornerRadius: Theme.Radius.card))
            .softShadow()
          }
          .buttonStyle(.plain)
          .accessibilityLabel(Self.title(theme))
          .accessibilityIdentifier("onboardingTheme-\(theme.rawValue)")
        }
      }
      Spacer()
    }
    .padding(.horizontal, 32)
    .task { VoicePlayer.shared.speak(.onboardingLike) }
  }

  private static func title(_ kind: WordKind) -> String {
    switch kind {
    case .vehicle: "のりもの"
    case .animal: "どうぶつ"
    case .clothes: "ふく"
    case .flyer: "そら"
    case .scenery: "はな"
    case .swimmer: "うみ"
    case .sky: "そら"
    case .plaything: "こうえん"
    case .bodyAction: "からだ"
    case .furniture: "おうち"
    case .seasonal: "きせつ"
    }
  }

  private static func symbol(_ kind: WordKind) -> String {
    switch kind {
    case .vehicle: "car.side.fill"
    case .animal: "pawprint.fill"
    case .clothes: "tshirt.fill"
    case .flyer: "bird.fill"
    case .scenery: "leaf.fill"
    case .swimmer: "fish.fill"
    case .sky: "cloud.sun.fill"
    case .plaything: "figure.play"
    case .bodyAction: "hand.wave.fill"
    case .furniture: "chair.fill"
    case .seasonal: "flag.fill"
    }
  }

  private static func color(_ kind: WordKind) -> Color {
    switch kind {
    case .vehicle: Color(red: 0.85, green: 0.3, blue: 0.25)
    case .animal: Color(red: 0.62, green: 0.4, blue: 0.2)
    case .clothes: Color(red: 0.25, green: 0.45, blue: 0.85)
    case .flyer: Color(red: 0.3, green: 0.62, blue: 0.9)
    case .scenery: Color(red: 0.4, green: 0.7, blue: 0.32)
    case .swimmer: Color(red: 0.2, green: 0.6, blue: 0.85)
    case .sky: Color(red: 0.35, green: 0.55, blue: 0.9)
    case .plaything: Color(red: 0.95, green: 0.6, blue: 0.25)
    case .bodyAction: Color(red: 0.93, green: 0.45, blue: 0.5)
    case .furniture: Color(red: 0.8, green: 0.55, blue: 0.3)
    case .seasonal: Color(red: 0.9, green: 0.42, blue: 0.5)
    }
  }

  // MARK: - 6 まち

  private var townStep: some View {
    ZStack(alignment: .bottom) {
      TownView(layer: kind == .clothes ? .closet : .town)
      HStack(alignment: .bottom, spacing: 24) {
        MainCharacterArt(character: store.mainCharacter, size: 120)
        Spacer()
        Button {
          onFinish()
        } label: {
          Label("おうちへ", systemImage: "house.fill")
        }
        .buttonStyle(PillButtonStyle(color: Theme.green, minWidth: 240))
        .accessibilityIdentifier("onboardingHome")
      }
      .padding(.horizontal, 48)
      .padding(.bottom, 48)
    }
    .task { VoicePlayer.shared.speak(.onboardingDone) }
  }
}

/// キャラクターが手を振ってあいさつする。画面には呼び名を出す（声では読まない。D28）。
private struct GreetingStep: View {
  var character: MainCharacter
  var nickname: String
  var onNext: () -> Void

  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var waving = false

  var body: some View {
    VStack(spacing: 32) {
      Spacer()
      Text(nickname.isEmpty ? "こんにちは！" : "\(nickname)、こんにちは！")
        .font(.ui(52, bold: true))
        .foregroundStyle(Theme.ink)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)
        .padding(.vertical, 24)
        .background(.white, in: .rect(cornerRadius: Theme.Radius.card))
        .overlay(alignment: .bottom) {
          Image(systemName: "arrowtriangle.down.fill")
            .foregroundStyle(.white)
            .offset(y: 16)
        }
        .softShadow()
        .accessibilityIdentifier("onboardingGreeting")
      HStack(spacing: 8) {
        MainCharacterArt(character: character, size: 280, pose: .wave)
        Image(systemName: "hand.wave.fill")
          .font(.system(size: 88))
          .foregroundStyle(Theme.yellow)
          .rotationEffect(.degrees(waving ? 18 : -18), anchor: .bottom)
          .accessibilityHidden(true)
      }
      Button(action: onNext) {
        Label("いこう！", systemImage: "arrow.right.circle.fill")
      }
      .buttonStyle(PillButtonStyle(color: Theme.accent, minWidth: 240))
      .accessibilityIdentifier("onboardingGo")
      Spacer()
    }
    .padding(.horizontal, 32)
    .task {
      VoicePlayer.shared.speak(.onboardingHello)
      guard !reduceMotion else { return }
      withAnimation(.easeInOut(duration: 0.45).repeatForever(autoreverses: true)) {
        waving = true
      }
    }
  }
}
