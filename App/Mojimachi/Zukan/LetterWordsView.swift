import ContentModel
import SoundKit
import SwiftUI

/// もじから さがす（D35・D45・D181）。書けた字の字のカードから開き、その字で始まることばを絵カードで見せる。
/// 「ん」「を」は、始まることばがない理由を声で話す。ことばがまだ無い字は、キャラクターがやさしく待つ（エラーは出さない。D117）。
struct LetterWordsView: View {
  var char: Character
  /// ことばを書く画面へ。
  var onWord: (String) -> Void

  private struct Word: Identifiable {
    var text: String
    var id: String { text }
  }

  private var words: [Word] {
    // 絵のあることばだけ（カードに絵を出すため）。
    let candidates = WordCatalog.all.map(\.text).filter { WordArt.uiImage(for: $0) != nil }
    return WordSearch.words(startingWith: char, among: candidates).map(Word.init)
  }

  private var rule: WordSearch.Rule? { WordSearch.rule(for: char) }

  var body: some View {
    let words = words
    GeometryReader { proxy in
      let layout = cardLayout(count: words.count, width: proxy.size.width, maxSize: 280)
      ScrollView {
        VStack(spacing: 24) {
          if rule == nil { Heading(text: "「\(String(char))」から はじまる ことば") }
          if words.isEmpty {
            emptyState
          } else {
            CardGrid(items: words, columns: layout.columns, size: layout.size) { word in
              PictureCard(
                asset: WordArt.assetName(for: word.text), title: word.text,
                color: Theme.yellow.opacity(0.35), size: layout.size, font: .learning(40)
              ) { onWord(word.text) }
            }
          }
        }
        .frame(maxWidth: .infinity, minHeight: proxy.size.height - 36)
        .padding(.vertical, 12)
        .padding(.bottom, 24)
      }
    }
    .overlay(alignment: .top) { CaptionBubble().padding(.top, 12) }
    .accessibilityIdentifier("letterWords")
    .onAppear {
      switch rule {
      case .n: VoicePlayer.shared.speak(.noWordsN)
      case .wo: VoicePlayer.shared.speak(.noWordsWo)
      case nil: break
      }
    }
  }

  /// ことばが無いとき: キャラクターと、ひとこと。
  private var emptyState: some View {
    VStack(spacing: 24) {
      MainCharacterArt(character: ProgressStore.shared.mainCharacter, size: 280, pose: .wave)
      Text(message)
        .font(.ui(34, bold: true))
        .foregroundStyle(Theme.ink)
        .multilineTextAlignment(.center)
        .padding(24)
        .background(.white, in: .rect(cornerRadius: Theme.Radius.card))
        .softShadow()
        .accessibilityIdentifier("letterWordsEmpty")
    }
    .padding(.horizontal, 48)
    .padding(.top, 24)
  }

  private var message: String {
    switch rule {
    case .n: VoiceLine.noWordsN.text
    case .wo: VoiceLine.noWordsWo.text
    case nil: "この もじの ことばは\nもうすこし まっててね"
    }
  }
}
