import ContentModel
import EntitlementKit
import SwiftUI

/// 字のカード（D101）。「かく」の大きなボタンと、その字のことばカード。
struct CharacterCardView: View {
  var char: Character
  var onWrite: () -> Void
  var onWord: (String) -> Void
  /// 「ことばを さがす」（もじから さがす。D181）。
  var onSearch: () -> Void = {}
  /// 鍵のかかったことばを押した（鍵の画面へ。D93・D160）。
  var onLocked: (EntitlementKit.Script) -> Void = { _ in }

  /// その字を「書けた」か（なぞって かけた以上）。書けた字だけ、ことばを さがせる。
  private var canSearch: Bool {
    // 数字には、はじまることばがない（D199）。
    guard AbcTable.page(of: char) != .digits, let script = KanaTable.script(of: char),
      let id = KanaTable.characterID(char, script: script)
    else { return false }
    return ProgressStore.shared.log.canWrite(characterID: id)
  }

  /// その字を含むことば。アルファベットは英語のことば（大文字も小文字も同じ字として探す。D199）。
  /// 開いていることばを先に、鍵のことばは影絵で2枚まで（D93）。
  private var words: [(item: WordArt.Item, script: EntitlementKit.Script?)] {
    let texts: [String]
    if KanaTable.script(of: char) == .abc {
      let lower = Character(char.lowercased())
      texts = EnglishWords.all.map(\.text).filter { $0.contains(lower) }
    } else {
      texts = WordCatalog.words(containing: char).map(\.text)
    }
    let entitlements = PurchaseStore.shared.entitlements
    return WordSearch.arranged(
      texts.filter(WordArt.hasArt),
      isLocked: { WordAccess.lockedScript(of: $0, entitlements: entitlements) != nil }
    ).compactMap { result in
      WordArt.item(named: result.word).map {
        ($0, WordAccess.lockedScript(of: result.word, entitlements: entitlements))
      }
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
      HStack(spacing: 24) {
        Button(action: onWrite) {
          Label("かく", systemImage: "pencil.line")
            .font(.ui(56, bold: true))
            .foregroundStyle(.white)
            .frame(maxWidth: 480, minHeight: 140)
            .background(Theme.accent.gradient, in: .rect(cornerRadius: 70))
            .softShadow()
        }
        .buttonStyle(.plain)
        if canSearch {
          Button(action: onSearch) {
            Label("ことばを さがす", systemImage: "magnifyingglass")
              .font(.ui(34, bold: true))
              .foregroundStyle(.white)
              .padding(.horizontal, 28)
              .frame(minHeight: 140)
              .background(Theme.blue.gradient, in: .rect(cornerRadius: 70))
              .softShadow()
          }
          .buttonStyle(.plain)
          .accessibilityIdentifier("searchWords")
        }
      }
      .padding(.horizontal, 48)
      if !words.isEmpty {
        Text("この もじの ことば").font(.ui(28, bold: true)).foregroundStyle(Theme.inkSoft)
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 20) {
            ForEach(words, id: \.item.entry.text) { entry in
              WordCard(item: entry.item, locked: entry.script != nil) {
                if let script = entry.script { onLocked(script) } else { onWord(entry.item.entry.text) }
              }
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
  var item: WordArt.Item
  var locked = false
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 8) {
        Image(WordArt.assetName(item))
          .renderingMode(locked ? .template : .original)
          .resizable().scaledToFit()
          .foregroundStyle(Theme.ink.opacity(0.28))
          .frame(height: 96)
        if locked {
          Image(systemName: "lock.fill").font(.system(size: 28)).foregroundStyle(Theme.inkSoft)
            .frame(height: 38)
        } else {
          Text(item.entry.text).font(.learning(30)).foregroundStyle(Theme.ink)
        }
      }
      .frame(minWidth: 160, minHeight: 180)
      .padding(.horizontal, 12)
      .background(Color(item.color).opacity(0.12), in: .rect(cornerRadius: Theme.Radius.card))
      .softShadow()
    }
    .buttonStyle(.plain)
  }
}
