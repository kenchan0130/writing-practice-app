import RecordKit
import SoundKit
import SwiftUI

/// おたのしみ ボックスの絵（箱と ふた。もとの SVG は `Content/Art/parts/otanoshimi-*.svg`）。
/// ふたは別の絵なので、あけるときに はずせる。
struct TreatBoxArt: View {
  var size: CGFloat
  /// ふたの ずれ（0 = しまっている、1 = あいている）。
  var open: CGFloat = 0
  /// ふたの かたむき（度。ゆらすとき）。
  var wobble: Double = 0
  /// ふたを出すか（「動きを減らす」で、あいたあとは出さない）。
  var showsLid = true

  var body: some View {
    ZStack {
      Image("part-otanoshimi-box").resizable().scaledToFit()
      if showsLid {
        Image("part-otanoshimi-lid").resizable().scaledToFit()
          // あくと、ふたは 右へ とんで、箱のよこに ころんと落ちる。
          .rotationEffect(.degrees(wobble + Double(open) * 52), anchor: .center)
          .offset(x: size * 0.6 * open, y: size * 0.2 * open)
      }
    }
    .frame(width: size, height: size)
    .accessibilityHidden(true)
  }
}

/// ホームの おたのしみ ボックス（§3.3・§3.5）。きょうの もくひょうに届いた日に、1回だけ あけられる。
/// 課金では あけられない。子どもの画面なので、数字・価格・エラーは出さない（D3・D117）。
struct TreatBoxButton: View {
  var state: TreatBoxState
  /// あけられるときに押した。
  var onOpen: () -> Void

  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var nudge = false

  var body: some View {
    Button {
      SoundPlayer.shared.play(state == .ready ? .tap : .locked)
      switch state {
      case .ready:
        onOpen()
      case .notYet:
        // 行き止まりにしない: あけ方を声で教える（D46）。
        VoicePlayer.shared.speak(.treatBoxNotYet)
        shake()
      case .opened:
        VoicePlayer.shared.speak(.stickerHint)
        shake()
      }
    } label: {
      TimelineView(.animation(paused: reduceMotion || state != .ready)) { timeline in
        let t = timeline.date.timeIntervalSinceReferenceDate
        // あけられるとき: ぴょんぴょん はねて、きらきらが出る。
        let hop = state == .ready && !reduceMotion ? abs(sin(t * 3.2)) * 10 : 0
        ZStack {
          if state == .ready {
            ForEach(0..<3, id: \.self) { index in
              let phase = reduceMotion ? 0.5 : (sin(t * 2.4 + Double(index) * 2.1) + 1) / 2
              Image(systemName: "sparkle")
                .font(.system(size: 22 + CGFloat(index) * 4, weight: .bold))
                .foregroundStyle(Theme.yellow)
                .opacity(0.35 + 0.65 * phase)
                .scaleEffect(0.7 + 0.5 * phase)
                .offset(x: [-52, 50, 40][index], y: [-30, -38, 30][index])
            }
          }
          TreatBoxArt(size: 92, open: state == .opened ? 1 : 0)
            .saturation(state == .notYet ? 0.25 : 1)
            .opacity(state == .ready ? 1 : 0.62)
            .offset(x: state == .opened ? -22 : 0, y: -hop)
        }
      }
      .rotationEffect(.degrees(nudge ? 7 : 0))
      .frame(width: 136, height: 108)
      .contentShape(.rect)
    }
    .buttonStyle(.plain)
    .accessibilityLabel("おたのしみ ボックス")
    .accessibilityValue(valueText)
    .accessibilityIdentifier("treatBox-\(state.rawValue)")
  }

  private var valueText: LocalizedStringKey {
    switch state {
    case .notYet: "まだ あけられない"
    case .ready: "あけられる"
    case .opened: "きょうは もう あけた"
    }
  }

  private func shake() {
    guard !reduceMotion else { return }
    withAnimation(.easeInOut(duration: 0.08).repeatCount(5, autoreverses: true)) { nudge = true }
    Task {
      try? await Task.sleep(for: .seconds(0.45))
      withAnimation(.easeOut(duration: 0.08)) { nudge = false }
    }
  }
}

/// おたのしみ ボックスを あける画面（§3.3）。箱を押すと、ゆれて ふたが とび、ステッカーが出てくる。
/// 短く（約2秒）、やさしく。「動きを減らす」なら、ゆらさず ふわっと出す。
struct TreatBoxOpeningView: View {
  /// 出たステッカーを まちに貼りに行く。
  var onTown: () -> Void
  var onClose: () -> Void

  private enum Stage { case closed, shaking, opened }

  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var stage: Stage = .closed
  @State private var sticker: OwnedSticker?
  @State private var wobble = 0.0
  @State private var lift: CGFloat = 0
  @State private var arrived = false
  @State private var showsButtons = false
  @State private var openedAt = Date()
  private let store = ProgressStore.shared

  var body: some View {
    ZStack {
      Color(red: 0.16, green: 0.11, blue: 0.2).opacity(0.86)
        .ignoresSafeArea()
        .contentShape(.rect)
        // あける前なら、後ろを押して やめられる（害がない）。
        .onTapGesture { if stage == .closed { onClose() } }
        .accessibilityHidden(true)
      VStack(spacing: 20) {
        Text("おたのしみ ボックス")
          .font(.ui(44, bold: true))
          .foregroundStyle(.white)
          .shadow(color: .black.opacity(0.3), radius: 6, y: 3)
          .accessibilityAddTraits(.isHeader)
        box
        footer.frame(height: 124)
      }
      .padding(32)
      if stage == .opened, !reduceMotion {
        TimelineView(.animation) { timeline in
          Confetti(time: timeline.date.timeIntervalSince(openedAt))
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
      }
    }
    .overlay(alignment: .top) { CaptionBubble().padding(.top, 24) }
    .accessibilityElement(children: .contain)
    .accessibilityAddTraits(.isModal)
    .accessibilityIdentifier("treatBoxOpening")
    .onAppear {
      VoicePlayer.shared.speak(.treatBoxOpen)
      #if DEBUG
        // 確かめ用: `-treatBox opened` で、あいたところから見せる。
        if UserDefaults.standard.string(forKey: "treatBox") == "opened" { open() }
      #endif
    }
  }

  /// 箱と、出てくるステッカー。箱は大きなボタン（押せる部分は 300pt 角）。
  private var box: some View {
    ZStack {
      // 光: ステッカーの後ろで ふわっと広がる。
      Circle()
        .fill(
          RadialGradient(
            colors: [Theme.yellow.opacity(0.9), Theme.yellow.opacity(0)], center: .center,
            startRadius: 10, endRadius: 210)
        )
        .frame(width: 420, height: 420)
        .scaleEffect(arrived ? 1 : 0.2)
        .opacity(arrived ? 1 : 0)
        .offset(y: -150)
      if let sticker {
        Image(StickerArt.assetName(sticker.sticker))
          .resizable().scaledToFit()
          .frame(width: 230, height: 230)
          .scaleEffect(arrived ? 1 : 0.25)
          .opacity(arrived ? 1 : 0)
          .offset(y: arrived || reduceMotion ? -150 : 30)
          .accessibilityLabel("ステッカー、\(StickerArt.name(sticker.sticker))")
          .accessibilityIdentifier("treatSticker")
      }
      Button {
        open()
      } label: {
        TreatBoxArt(
          size: 300, open: reduceMotion ? 0 : lift, wobble: wobble,
          showsLid: !(reduceMotion && stage == .opened)
        )
        .offset(y: 70)
        .contentShape(.rect)
      }
      .buttonStyle(.plain)
      // 無効にすると絵が うすくなるので、押せなくするだけにする。
      .allowsHitTesting(stage == .closed)
      .accessibilityLabel("おたのしみ ボックスを あける")
      .accessibilityIdentifier("treatBoxOpen")
    }
    .frame(width: 440, height: 470)
  }

  @ViewBuilder private var footer: some View {
    switch stage {
    case .closed:
      Text("おして あけよう")
        .font(.ui(36, bold: true))
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.3), radius: 6, y: 3)
    case .shaking:
      Color.clear
    case .opened:
      HStack(spacing: 24) {
        Button {
          onClose()
        } label: {
          Text("とじる")
        }
        .buttonStyle(PillButtonStyle(color: Theme.blue, minWidth: 180))
        .accessibilityIdentifier("treatBoxClose")
        Button {
          onTown()
        } label: {
          Label("まちに はる", systemImage: "house.fill")
        }
        .buttonStyle(PillButtonStyle(color: Theme.green, minWidth: 260))
        .accessibilityIdentifier("treatBoxToTown")
      }
      .opacity(showsButtons ? 1 : 0)
      .allowsHitTesting(showsButtons)
    }
  }

  /// あける。ここで初めて、ステッカーの行を足す（1日に1回だけ。`StickerBook.boxState`）。
  private func open() {
    guard stage == .closed else { return }
    guard let got = store.openTreatBox() else {
      // あけられなかった（もう あけた など）。エラーは出さず、そっと閉じる（D117）。
      onClose()
      return
    }
    sticker = got
    stage = .shaking
    SoundPlayer.shared.play(.gather)
    Task {
      if !reduceMotion {
        withAnimation(.easeInOut(duration: 0.07).repeatCount(7, autoreverses: true)) { wobble = 7 }
        try? await Task.sleep(for: .seconds(UITesting.seconds(0.55, uiTesting: 0.05)))
        wobble = 0
      }
      stage = .opened
      openedAt = Date()
      SoundPlayer.shared.play(.sparkle)
      if reduceMotion {
        withAnimation(.easeOut(duration: 0.3)) { arrived = true }
      } else {
        withAnimation(.spring(duration: 0.45, bounce: 0.3)) { lift = 1 }
        withAnimation(.spring(duration: 0.6, bounce: 0.45).delay(0.12)) { arrived = true }
      }
      VoicePlayer.shared.speak(.treatBoxGot)
      try? await Task.sleep(for: .seconds(UITesting.seconds(0.9, uiTesting: 0.05)))
      if !reduceMotion { SoundPlayer.shared.play(.confetti) }
      withAnimation(.easeOut(duration: 0.25)) { showsButtons = true }
    }
  }
}
