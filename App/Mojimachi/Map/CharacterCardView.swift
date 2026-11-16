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
        .font(.system(size: 220, weight: .bold))
        .frame(maxWidth: .infinity)
        .frame(height: 260)
      Button(action: onWrite) {
        Label("かく", systemImage: "pencil.line")
          .font(.system(size: 56, weight: .bold))
          .foregroundStyle(.white)
          .frame(maxWidth: 480, minHeight: 140)
          .background(Color.orange.gradient, in: .rect(cornerRadius: 40))
      }
      .buttonStyle(.plain)
      if !words.isEmpty {
        Text("この もじの ことば").font(.system(size: 28, weight: .bold)).foregroundStyle(.secondary)
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
        Text(item.entry.text).font(.system(size: 30, weight: .bold)).foregroundStyle(.primary)
      }
      .frame(minWidth: 160, minHeight: 180)
      .padding(.horizontal, 12)
      .background(Color(item.color).opacity(0.12), in: .rect(cornerRadius: 28))
    }
    .buttonStyle(.plain)
  }
}
