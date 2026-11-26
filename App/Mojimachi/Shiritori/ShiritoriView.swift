import ComposableArchitecture
import ContentModel
import EntitlementKit
import PracticeKit
import SoundKit
import SwiftUI

/// しりとりの画面（D35・D45・D70。§3.10）。主人公が絵カードを出して「これ！」と言い、
/// 案内役がことばを読む（D57）。子どもは3枚の候補から選んで、ことばを書く。
struct ShiritoriView: View {
  let store: StoreOf<ShiritoriFeature>
  var character: MainCharacter
  var pool: ShiritoriPool
  /// 選んだことばを書く画面へ。
  var onWrite: (String) -> Void
  /// 鍵のかかった候補を押した（影絵。「おねがい」の画面を出す。D3・D160）。
  var onLocked: (Script) -> Void

  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  private var round: ShiritoriRound { store.round }

  var body: some View {
    GeometryReader { proxy in
      let wide = proxy.size.width > 900
      ScrollView {
        VStack(spacing: 28) {
          HStack(alignment: .center, spacing: 24) {
            MainCharacterArt(character: character, size: wide ? 240 : 190, pose: pose)
            speech
          }
          .frame(maxWidth: .infinity)
          if round.isOver {
            endPanel
          } else {
            turnPanel(width: proxy.size.width)
          }
          progress
        }
        .padding(.horizontal, 32)
        .padding(.top, 8)
        .padding(.bottom, 32)
        .frame(maxWidth: .infinity, minHeight: proxy.size.height)
      }
    }
    .overlay { if round.outcome == .characterGaveUp { WinConfetti() } }
    .onAppear { store.send(.appeared(pool)) }
    // 番が進むたびに、声を順に言う（取り消されたらそこで止まる）。
    .task(id: store.turn) { await speak() }
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier("shiritoriBoard")
  }

  // MARK: - 見た目

  private var pose: CharacterPose {
    switch round.outcome {
    case .characterGaveUp?: .happy
    case .finished?: .wave
    case nil: .normal
    }
  }

  /// 主人公の吹き出し。出したことばの絵カード、または おわりのひとこと。
  @ViewBuilder
  private var speech: some View {
    switch round.outcome {
    case .characterGaveUp?:
      bubble { Text(VoiceLine.shiritoriGiveUp.text).font(.ui(40, bold: true)) }
    case .finished?:
      bubble { Text(VoiceLine.shiritoriEnd.text).font(.ui(34, bold: true)) }
    case nil:
      if let word = round.characterWord {
        bubble {
          HStack(spacing: 16) {
            Image(WordArt.assetName(for: word)).resizable().scaledToFit()
              .frame(width: 120, height: 120)
              .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
              Text(VoiceLine.shiritoriKore.text).font(.ui(30, bold: true))
              Text(word).font(.learning(52))
            }
          }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(character.name)の ことば \(word)")
        .accessibilityIdentifier("shiritoriCharacterWord")
      }
    }
  }

  private func bubble<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
    content()
      .foregroundStyle(Theme.ink)
      .multilineTextAlignment(.leading)
      .padding(.horizontal, 28)
      .padding(.vertical, 20)
      .frame(minHeight: 104)
      .background(.white, in: .rect(cornerRadius: Theme.Radius.card))
      .overlay(RoundedRectangle(cornerRadius: Theme.Radius.card).stroke(Theme.accent, lineWidth: 4))
      .softShadow()
  }

  /// 子どもの番: 3枚の候補。
  private func turnPanel(width: CGFloat) -> some View {
    let cardWidth = min(250, (width - 64 - 40) / 3)
    return VStack(spacing: 20) {
      Text(VoiceLine.shiritoriYourTurn.text)
        .font(.ui(34, bold: true))
        .foregroundStyle(Theme.ink)
        .accessibilityAddTraits(.isHeader)
      HStack(spacing: 20) {
        ForEach(round.cards) { card in
          ShiritoriCard(word: card, width: cardWidth) { pick(card) }
        }
      }
      history
    }
  }

  /// 終わったあと: 「もういっかい」。
  private var endPanel: some View {
    VStack(spacing: 28) {
      if round.outcome == .characterGaveUp {
        HStack(spacing: 10) {
          ForEach(0..<3, id: \.self) { _ in
            Image(systemName: "star.fill").font(.system(size: 64)).foregroundStyle(Theme.yellow)
          }
        }
        .accessibilityHidden(true)
        Text(VoiceLine.shiritoriWin.text)
          .font(.ui(48, bold: true)).foregroundStyle(Theme.ink)
      }
      history
      Button {
        store.send(.newRound)
      } label: {
        Label("もういっかい", systemImage: "arrow.counterclockwise")
          .font(.ui(34, bold: true))
      }
      .buttonStyle(PillButtonStyle(color: Theme.accent, minWidth: 280))
      .accessibilityIdentifier("shiritoriAgain")
    }
  }

  /// ここまでのことば（絵と字を つないで並べる）。
  @ViewBuilder
  private var history: some View {
    if round.turns.count > 1 || round.isOver {
      let words = round.turns.map(\.word)
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) {
          ForEach(Array(round.turns.enumerated()), id: \.offset) { index, turn in
            if index > 0 {
              Image(systemName: "arrow.right").font(.system(size: 20, weight: .bold))
                .foregroundStyle(Theme.inkSoft)
            }
            VStack(spacing: 2) {
              Image(WordArt.assetName(for: turn.word)).resizable().scaledToFit()
                .frame(width: 56, height: 56)
              Text(turn.word).font(.learning(22)).foregroundStyle(Theme.ink)
            }
            .padding(8)
            .background(
              turn.speaker == .child ? Theme.yellow.opacity(0.35) : Color.white.opacity(0.7),
              in: .rect(cornerRadius: 16))
          }
        }
        .padding(.horizontal, 4)
      }
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(words.joined(separator: "、"))
      .accessibilityIdentifier("shiritoriHistory")
    }
  }

  /// 子どもが書いたことばの数を、星で（5つまで。数字は出さない。D70）。
  private var progress: some View {
    HStack(spacing: 8) {
      ForEach(0..<ShiritoriRound.childWordLimit, id: \.self) { index in
        Image(systemName: index < round.childWordCount ? "star.fill" : "star")
          .font(.system(size: 36))
          .foregroundStyle(index < round.childWordCount ? Theme.yellow : Color.gray.opacity(0.4))
      }
    }
    .accessibilityHidden(true)
  }

  // MARK: - 動き

  private func pick(_ card: ShiritoriWord) {
    if card.isLocked {
      onLocked(ShiritoriWords.script(of: card.text) ?? .katakana)
      return
    }
    store.send(.picked(card.text))
    onWrite(card.text)
  }

  /// 番ごとの声。主人公の決まったせりふと、案内役のことばの読み（D57）。
  private func speak() async {
    guard store.started else { return }
    var lines: [String] = []
    switch round.outcome {
    case .characterGaveUp?:
      lines = [VoiceLine.shiritoriGiveUp.text, VoiceLine.shiritoriWin.text]
    case .finished?:
      lines = [VoiceLine.shiritoriEnd.text]
    case nil:
      if round.turns.count == 1 { lines.append(VoiceLine.shiritoriStart.text) }
      if let word = round.characterWord {
        lines += [VoiceLine.shiritoriKore.text, word]
      }
      lines.append(VoiceLine.shiritoriYourTurn.text)
    }
    await VoicePlayer.shared.speak(sequence: lines)
  }
}

/// 候補の絵カード（押せる大きさは 104pt をこえる。D101）。鍵のかかったことばは影絵で、押すと「おねがい」（D3）。
private struct ShiritoriCard: View {
  var word: ShiritoriWord
  var width: CGFloat
  var action: () -> Void

  var body: some View {
    Button {
      SoundPlayer.shared.play(.tap)
      action()
    } label: {
      VStack(spacing: 8) {
        Image(WordArt.assetName(for: word.text)).resizable().scaledToFit()
          .padding(.horizontal, 10)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .opacity(word.isLocked ? 0 : 1)
          .overlay {
            if word.isLocked {
              Image(WordArt.assetName(for: word.text)).renderingMode(.template)
                .resizable().scaledToFit().foregroundStyle(.gray.opacity(0.35))
                .padding(.horizontal, 10)
                .overlay { Image(systemName: "lock.fill").font(.system(size: 44)).foregroundStyle(.white) }
            }
          }
          .accessibilityHidden(true)
        Text(word.isLocked ? "？" : word.text)
          .font(.learning(40))
          .foregroundStyle(Theme.ink)
          .lineLimit(1)
          .minimumScaleFactor(0.5)
          .padding(.horizontal, 14)
          .frame(minHeight: 60)
          .background(.white.opacity(0.9), in: .capsule)
          .padding(.horizontal, 10)
          .padding(.bottom, 14)
      }
      .padding(.top, 14)
      .frame(width: width, height: width * 1.05)
      .background(Theme.yellow.opacity(0.28), in: .rect(cornerRadius: Theme.Radius.card))
      .overlay {
        RoundedRectangle(cornerRadius: Theme.Radius.card).stroke(.white.opacity(0.8), lineWidth: 5)
      }
      .softShadow()
    }
    .buttonStyle(.plain)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(word.isLocked ? "ねむっている ことば" : word.text)
    .accessibilityAddTraits(.isButton)
    .accessibilityIdentifier("shiritoriCard")
  }
}

/// 子どもの勝ちの大きな演出（紙ふぶきを、何度かくりかえし降らせる。D70）。
private struct WinConfetti: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var started = Date()

  var body: some View {
    if !reduceMotion {
      TimelineView(.animation(paused: UITesting.isOn)) { timeline in
        let t = timeline.date.timeIntervalSince(started)
        // 1.6秒で降り終わる紙ふぶきを、3回くりかえす。
        if t < 5.4 {
          Confetti(time: t.truncatingRemainder(dividingBy: 1.8))
        }
      }
      .allowsHitTesting(false)
      .accessibilityHidden(true)
    }
  }
}
