import ContentModel
import EntitlementKit
import RecordKit
import SwiftUI

/// ずかん（D35・D74・D82・D181）。集めたことばをテーマごとに見返す。
/// 書いたことばは絵と★（書いた回数。多くても3）。絵を押すと、ひとことの説明を声で読む。
/// まだ書いていないことばは影絵。押すと「かいて みよう」と言い、大きなボタンで書く画面へ行ける。
/// 鍵つきのことばは影絵に鍵。押すと鍵の画面（D3・D160）。子どもの画面なので、エラー・価格は出さない。
struct ZukanView: View {
  /// ことばを書く画面へ。
  var onWrite: (String) -> Void
  /// 鍵つきのことばを押した（鍵の画面へ）。
  var onLocked: (Script) -> Void = { _ in }

  private let store = ProgressStore.shared
  private let purchases = PurchaseStore.shared
  @State private var selected: String?

  var body: some View {
    let counts = store.log.wordWriteCounts
    let sections = Zukan.sections(
      index: WordArt.index, writtenCounts: counts, isLocked: isLocked)
    ScrollView {
      VStack(spacing: 28) {
        Heading(text: "ずかん")
        ForEach(sections) { section in
          sectionView(section)
        }
      }
      .padding(.horizontal, 32)
      .padding(.vertical, 12)
      .padding(.bottom, 24)
    }
    .safeAreaInset(edge: .bottom) { detail(counts: counts) }
    .overlay(alignment: .top) { CaptionBubble().padding(.top, 12) }
    .accessibilityIdentifier("zukan")
  }

  // MARK: - テーマごとの絵

  private func sectionView(_ section: ZukanSection) -> some View {
    VStack(alignment: .leading, spacing: 14) {
      Text(section.theme.name)
        .font(.ui(30, bold: true))
        .foregroundStyle(Theme.ink)
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(
          PlaceStyle.color(section.theme.placeID), in: .capsule)
      LazyVGrid(
        columns: [GridItem(.adaptive(minimum: 190, maximum: 230), spacing: 20)], spacing: 20
      ) {
        ForEach(section.entries) { entry in
          ZukanCard(
            entry: entry, color: PlaceStyle.color(section.theme.placeID),
            selected: selected == entry.word
          ) { tapped(entry) }
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  // MARK: - 選んだことば

  @ViewBuilder
  private func detail(counts: [String: Int]) -> some View {
    if let word = selected {
      let state = Zukan.state(of: word, writtenCounts: counts, isLocked: isLocked)
      HStack(spacing: 24) {
        Image(WordArt.assetName(for: word))
          .renderingMode(state.isWritten ? .original : .template)
          .resizable().scaledToFit()
          .foregroundStyle(Theme.ink.opacity(0.3))
          .frame(width: 96, height: 96)
          .accessibilityHidden(true)
        switch state {
        case .written:
          VStack(alignment: .leading, spacing: 6) {
            Text(word).font(.learning(36)).foregroundStyle(Theme.ink)
            if let note = WordNotes.note(for: word) {
              Text(note).font(.learning(26)).foregroundStyle(Theme.inkSoft)
            }
          }
          Spacer(minLength: 0)
          Button("もういちど かく") { onWrite(word) }
            .buttonStyle(PillButtonStyle(color: Theme.blue, minWidth: 200))
            .accessibilityIdentifier("zukanWriteAgain")
        case .unwritten:
          Text("かいて みよう").font(.ui(34, bold: true)).foregroundStyle(Theme.ink)
          Spacer(minLength: 0)
          Button("このことばを かく") { onWrite(word) }
            .buttonStyle(PillButtonStyle(color: Theme.accent, minWidth: 260))
            .accessibilityIdentifier("zukanWrite")
        case .locked:
          EmptyView()
        }
      }
      .padding(20)
      .frame(maxWidth: .infinity)
      .background(.white, in: .rect(cornerRadius: Theme.Radius.card))
      .softShadow()
      .padding(.horizontal, 32)
      .padding(.bottom, 12)
      .transition(.move(edge: .bottom).combined(with: .opacity))
    }
  }

  // MARK: - 押したとき

  private func tapped(_ entry: ZukanEntry) {
    withAnimation(.easeOut(duration: 0.2)) { selected = entry.word }
    switch entry.state {
    case .written:
      if let note = WordNotes.note(for: entry.word) {
        VoicePlayer.shared.speak(note)
      } else {
        VoicePlayer.shared.speak(entry.word)
      }
    case .unwritten:
      VoicePlayer.shared.speak(.zukanHint)
    case .locked:
      selected = nil
      if let script = Self.script(of: entry.word) { onLocked(script) }
    }
  }

  /// ことばを書くのに鍵がかかっているか（字のどれかが書けないとき）。
  private func isLocked(_ word: String) -> Bool {
    word.contains { char in
      guard let script = KanaTable.script(of: char) else { return false }
      return !purchases.entitlements.canWrite(char, in: script.entitlementScript)
    }
  }

  private static func script(of word: String) -> Script? {
    word.compactMap { KanaTable.script(of: $0)?.entitlementScript }.first
  }
}

/// ずかんのカード1枚。書いたことばは絵と★、まだは影絵。押せる大きさは 190pt 角ほど（104pt 以上。D101）。
private struct ZukanCard: View {
  var entry: ZukanEntry
  var color: Color
  var selected: Bool
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 8) {
        art
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .padding(.horizontal, 12)
        footer
          .frame(height: 44)
      }
      .padding(.top, 14)
      .padding(.bottom, 10)
      .frame(height: 220)
      .background(
        entry.state.isWritten ? color : color.opacity(0.45),
        in: .rect(cornerRadius: Theme.Radius.card)
      )
      .overlay {
        RoundedRectangle(cornerRadius: Theme.Radius.card)
          .stroke(selected ? Theme.accent : .white.opacity(0.8), lineWidth: selected ? 7 : 5)
      }
      .softShadow()
    }
    .buttonStyle(.plain)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(label)
    .accessibilityIdentifier("zukan-\(entry.word)")
    .accessibilityAddTraits(.isButton)
  }

  private var label: String {
    switch entry.state {
    case .written(let stars): "\(entry.word)、ほし \(stars)"
    case .unwritten: "まだ かいていない ことば"
    case .locked: "ねむっている ことば"
    }
  }

  /// 書いたことばはもとの絵、まだは1色の影絵（絵の形だけを塗りつぶす。絵づくりの「sil」と同じ）。
  private var art: some View {
    Image(WordArt.assetName(for: entry.word))
      .renderingMode(entry.state.isWritten ? .original : .template)
      .resizable().scaledToFit()
      .foregroundStyle(Theme.ink.opacity(0.28))
      .accessibilityHidden(true)
  }

  @ViewBuilder
  private var footer: some View {
    switch entry.state {
    case .written(let stars):
      HStack(spacing: 4) {
        ForEach(1...Zukan.maxStars, id: \.self) { index in
          Image(systemName: index <= stars ? "star.fill" : "star")
            .font(.system(size: 30))
            .foregroundStyle(index <= stars ? Theme.yellow : Color.gray.opacity(0.4))
        }
      }
      .padding(.horizontal, 14)
      .frame(maxHeight: .infinity)
      .background(.white.opacity(0.9), in: .capsule)
    case .unwritten:
      Text("？").font(.ui(30, bold: true)).foregroundStyle(Theme.inkSoft)
    case .locked:
      Image(systemName: "lock.fill").font(.system(size: 28)).foregroundStyle(Theme.inkSoft)
    }
  }
}
