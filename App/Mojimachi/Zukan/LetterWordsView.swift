import ContentModel
import EntitlementKit
import SoundKit
import SwiftUI

/// もじから さがす（D35・D45・D181）。書けた字の字のカードから開き、その字で始まることばを絵カードで見せる。
/// 「ん」「を」は、始まることばがない理由を声で話す。ことばがまだ無い字は、キャラクターがやさしく待つ（エラーは出さない。D117）。
struct LetterWordsView: View {
  var char: Character
  /// ことばを書く画面へ。
  var onWord: (String) -> Void
  /// 鍵のかかったことばを押した（鍵の画面へ。D93・D160）。
  var onLocked: (EntitlementKit.Script) -> Void = { _ in }

  private struct Word: Identifiable {
    var text: String
    var locked: EntitlementKit.Script?
    var id: String { text }
  }

  /// 字で始まることば（D93・D199）。
  /// - ひらがなの字: ひらがなのことば。
  /// - カタカナの字: 同じ音のひらがなのことばと、カタカナのことば。
  /// - アルファベットの字: 英語のことば（大文字も小文字も同じ字）。
  /// 開いていることばを先に、鍵のことばは影絵で2枚まで。
  private var words: [Word] {
    let script = KanaTable.script(of: char)
    let source: [String] =
      script == .abc
      ? EnglishWords.all.map(\.text)
      : WordCatalog.all.map(\.text).filter { text in
        script == .katakana || WordText.script(of: text) != .katakana
      }
    // 絵のあることばだけ（カードに絵を出すため）。
    let candidates = source.filter { WordArt.uiImage(for: $0) != nil }
    let entitlements = PurchaseStore.shared.entitlements
    return WordSearch.results(
      startingWith: char, among: candidates,
      isLocked: { WordAccess.lockedScript(of: $0, entitlements: entitlements) != nil }
    ).map { Word(text: $0.word, locked: $0.isLocked ? WordAccess.script(of: $0.word) : nil) }
  }

  private var rule: WordSearch.Rule? { WordSearch.rule(for: char) }

  var body: some View {
    let words = words
    GeometryReader { proxy in
      let layout = cardLayout(count: words.count, width: proxy.size.width, maxSize: 280)
      ScrollView {
        VStack(spacing: 24) {
          if rule == nil { Heading(text: String(localized: "「\(String(char))」から はじまる ことば")) }
          if words.isEmpty {
            emptyState
          } else {
            CardGrid(items: words, columns: layout.columns, size: layout.size) { word in
              PictureCard(
                asset: WordArt.assetName(for: word.text), title: word.text,
                color: Theme.yellow.opacity(0.35), size: layout.size, font: .learning(40),
                locked: word.locked != nil
              ) {
                if let script = word.locked { onLocked(script) } else { onWord(word.text) }
              }
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
