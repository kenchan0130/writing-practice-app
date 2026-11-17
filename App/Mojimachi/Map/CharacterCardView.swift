import ContentModel
import SwiftUI

/// 字のカード（D101）。「かく」の大きなボタンと、その字のことばカード。
struct CharacterCardView: View {
  var char: Character
  var onWrite: () -> Void
  var onWord: (String) -> Void

  private var words: [PlaceholderArt.Item] {
    WordCatalog.words(containing: char).compactMap { entry in
      PlaceholderArt.words.first { $0.entry.text == entry.text }
    }
  }

  var body: some View {
    VStack(spacing: 32) {
      Text(String(char))
        .font(.learning(220))
        .foregroundStyle(Theme.ink)
        .frame(maxWidth: .infinity)
        .frame(height: 280)
        .background(Theme.paper, in: .rect(cornerRadius: Theme.Radius.paper))
        .overlay(
          RoundedRectangle(cornerRadius: Theme.Radius.paper).stroke(
            Theme.accent.opacity(0.7), lineWidth: 4)
        )
        .softShadow()
        .padding(.horizontal, 48)
      Button(action: onWrite) {
        Label("かく", systemImage: "pencil.line")
          .font(.ui(56, bold: true))
          .foregroundStyle(.white)
          .frame(maxWidth: 480, minHeight: 140)
          .background(Theme.accent.gradient, in: .rect(cornerRadius: 70))
          .softShadow()
      }
      .buttonStyle(.plain)
      if !words.isEmpty {
        Text("この もじの ことば").font(.ui(28, bold: true)).foregroundStyle(Theme.inkSoft)
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 20) {
            ForEach(words, id: \.entry.text) { item in
              WordCard(item: item) { onWord(item.entry.text) }
            }
          }
          .padding(.horizontal, 32)
        }
        .scrollClipDisabled()
        .frame(height: 200)
      }
      Spacer(minLength: 0)
    }
    .padding(.top, 8)
  }
}

private struct WordCard: View {
  var item: PlaceholderArt.Item
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 8) {
        Image(systemName: item.symbol)
          .font(.system(size: 64))
          .foregroundStyle(Color(item.color))
          .frame(height: 80)
        Text(item.entry.text).font(.learning(30)).foregroundStyle(Theme.ink)
      }
      .frame(minWidth: 160, minHeight: 180)
      .padding(.horizontal, 12)
      .background(Color(item.color).opacity(0.12), in: .rect(cornerRadius: Theme.Radius.card))
      .softShadow()
    }
    .buttonStyle(.plain)
  }
}
