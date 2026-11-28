import ContentModel
import EntitlementKit
import PracticeKit
import SwiftUI

/// ことばの入口の3つの画面（まちの地図 → テーマ → ことばのカード。D53・D67・D101・D166）。
/// 出す場所・テーマ・ことばは、絵のあることばから決まる（`WordArt.index`）。

// MARK: - 見た目

/// 場所のカードの色。
enum PlaceStyle {
  static func color(_ id: String) -> Color {
    switch id {
    case "eki": Color(red: 0.80, green: 0.91, blue: 0.99)
    case "michi": Color(red: 0.89, green: 0.87, blue: 0.84)
    case "sora": Color(red: 0.76, green: 0.90, blue: 0.99)
    case "dobutsuen": Color(red: 1.0, green: 0.93, blue: 0.67)
    case "makiba": Color(red: 0.99, green: 0.84, blue: 0.78)
    case "mori": Color(red: 0.80, green: 0.93, blue: 0.74)
    case "ie": Color(red: 1.0, green: 0.87, blue: 0.70)
    case "umi": Color(red: 0.70, green: 0.88, blue: 0.97)
    case "kawa": Color(red: 0.78, green: 0.94, blue: 0.88)
    case "omise": Color(red: 1.0, green: 0.84, blue: 0.86)
    case "koen": Color(red: 0.90, green: 0.95, blue: 0.70)
    case "uchu": Color(red: 0.69, green: 0.70, blue: 0.93)
    default: Color(red: 1.0, green: 0.80, blue: 0.86)
    }
  }
}

/// 押すと少しへこむ、大きなカードのボタン。
struct CardButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.96 : 1)
      .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
      .onChange(of: configuration.isPressed) { _, pressed in
        if pressed { SoundPlayer.shared.play(.tap) }
      }
  }
}

/// 絵と短い名前の大きなカード。
struct PictureCard: View {
  var asset: String
  var title: String
  var color: Color
  var size: CGFloat
  var font: Font
  /// 鍵のかかったことば（影絵と鍵の印。押すと「おねがい」。D93・D160）。
  var locked = false
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 8) {
        Image(asset)
          .renderingMode(locked ? .template : .original)
          .resizable().scaledToFit()
          .foregroundStyle(Theme.ink.opacity(0.28))
          .padding(.horizontal, 10)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .accessibilityHidden(true)
        Group {
          if locked {
            Image(systemName: "lock.fill").font(.system(size: 30, weight: .bold))
              .foregroundStyle(Theme.inkSoft)
          } else {
            Text(title)
              .font(font)
              .foregroundStyle(Theme.ink)
              .lineLimit(2)
              .minimumScaleFactor(0.6)
              .multilineTextAlignment(.center)
          }
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 52)
        .background(.white.opacity(0.9), in: .capsule)
        .padding(.horizontal, 12)
        .padding(.bottom, 14)
      }
      .padding(.top, 14)
      .frame(width: size, height: size * 0.92)
      .background(color, in: .rect(cornerRadius: Theme.Radius.card))
      .overlay {
        RoundedRectangle(cornerRadius: Theme.Radius.card).stroke(.white.opacity(0.8), lineWidth: 5)
      }
      .softShadow()
    }
    .buttonStyle(CardButtonStyle())
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(locked ? String(localized: "ねむっている ことば") : title)
    .accessibilityAddTraits(.isButton)
  }
}

/// 列の数と1枚の大きさを、画面の幅と枚数から決める。
func cardLayout(count: Int, width: CGFloat, maxSize: CGFloat) -> (columns: Int, size: CGFloat) {
  let spacing: CGFloat = 28
  let usable = width - 64
  let wide = width > 1000
  let columns: Int
  switch count {
  case ...1: columns = 1
  case 2: columns = 2
  case 3: columns = wide ? 3 : 2
  case 4: columns = wide ? 4 : 2
  default: columns = wide ? 4 : 3
  }
  let size = min(maxSize, (usable - spacing * CGFloat(columns - 1)) / CGFloat(columns))
  return (columns, max(size, 170))
}

struct CardGrid<Item: Identifiable, Content: View>: View {
  var items: [Item]
  var columns: Int
  var size: CGFloat
  @ViewBuilder var content: (Item) -> Content

  var body: some View {
    LazyVGrid(
      columns: Array(repeating: GridItem(.fixed(size), spacing: 28), count: columns),
      spacing: 28
    ) {
      ForEach(items) { content($0) }
    }
  }
}

struct Heading: View {
  var text: String
  var body: some View {
    Text(text)
      .font(.ui(40, bold: true))
      .foregroundStyle(Theme.ink)
      .multilineTextAlignment(.center)
      .padding(.top, 4)
      .accessibilityAddTraits(.isHeader)
  }
}

// MARK: - まちの地図

/// 場所を選ぶ（まちの地図）。絵のあることばがある場所だけを出す。
struct PlacesView: View {
  var onSelect: (Place) -> Void
  /// 下の帯の「しりとり」（D35・D166）。
  var onShiritori: () -> Void = {}
  /// 下の帯の「ずかん」（D181）。
  var onZukan: () -> Void = {}

  var body: some View {
    let places = WordArt.index.places
    GeometryReader { proxy in
      let layout = cardLayout(count: places.count, width: proxy.size.width, maxSize: 380)
      ScrollView {
        VStack(spacing: 24) {
          Heading(text: String(localized: "どこに いく？"))
          CardGrid(items: places, columns: layout.columns, size: layout.size) { place in
            PictureCard(
              asset: "place-\(place.id)", title: place.name, color: PlaceStyle.color(place.id),
              size: layout.size, font: .ui(34, bold: true)
            ) { onSelect(place) }
          }
        }
        .frame(maxWidth: .infinity, minHeight: proxy.size.height - 36)
        .padding(.vertical, 12)
        .padding(.bottom, 24)
      }
    }
    .safeAreaInset(edge: .bottom) { WordMapBand(onShiritori: onShiritori, onZukan: onZukan) }
  }
}

/// まちの地図の下の固定の帯（D35・D166・D181）。ことばに出会う遊びの入口（しりとり・ずかん）を並べる。
private struct WordMapBand: View {
  var onShiritori: () -> Void
  var onZukan: () -> Void

  var body: some View {
    HStack(spacing: 24) {
      BandButton(
        title: String(localized: "しりとり"), character: ProgressStore.shared.mainCharacter, color: Theme.pink,
        action: onShiritori)
      BandButton(title: String(localized: "ずかん"), systemImage: "book.fill", color: Theme.green, action: onZukan)
    }
    .padding(.horizontal, 32)
    .padding(.vertical, 12)
    .frame(maxWidth: .infinity)
    .background(.white.opacity(0.7))
  }
}

/// 帯の大きなボタン（高さ 104pt をこえる。D101）。
private struct BandButton: View {
  var title: String
  var character: MainCharacter?
  var systemImage: String?
  var color: Color
  var action: () -> Void

  init(
    title: String, character: MainCharacter? = nil, systemImage: String? = nil, color: Color,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.character = character
    self.systemImage = systemImage
    self.color = color
    self.action = action
  }

  var body: some View {
    Button {
      SoundPlayer.shared.play(.tap)
      action()
    } label: {
      HStack(spacing: 16) {
        if let character {
          MainCharacterArt(character: character, size: 80, pose: .wave)
        } else if let systemImage {
          Image(systemName: systemImage).font(.system(size: 56, weight: .bold))
        }
        Text(title).font(.ui(38, bold: true))
      }
      .foregroundStyle(.white)
      .padding(.horizontal, 36)
      .frame(maxWidth: 420, minHeight: 112)
      .frame(maxWidth: .infinity)
      .background(color.gradient, in: .rect(cornerRadius: Theme.Radius.button))
      .softShadow()
    }
    .buttonStyle(.plain)
    .accessibilityLabel(title)
  }
}

// MARK: - テーマ

/// テーマを選ぶ。絵は、そのテーマのことばの1つ。キャラクターのいえは2列（いえの なか・クローゼット。D67）。
struct ThemesView: View {
  var place: Place
  var onSelect: (WordTheme) -> Void

  var body: some View {
    let themes = WordArt.index.themes(in: place)
    GeometryReader { proxy in
      let layout = cardLayout(count: themes.count, width: proxy.size.width, maxSize: 320)
      ScrollView {
        VStack(spacing: 24) {
          Heading(text: place.name)
          if themes.contains(where: { $0.row != nil }) {
            // 広い画面では、2列を横に並べて、スクロールしなくても見えるようにする。
            let wide = proxy.size.width > 1000
            let rows = HouseRow.allCases.filter { row in themes.contains { $0.row == row } }
            let groupWidth =
              wide ? proxy.size.width / CGFloat(max(rows.count, 1)) : proxy.size.width
            let group = ForEach(rows, id: \.self) { row in
              let inRow = themes.filter { $0.row == row }
              VStack(spacing: 16) {
                Text(row.name).font(.ui(30, bold: true)).foregroundStyle(Theme.inkSoft)
                grid(inRow, layout: cardLayout(count: inRow.count, width: groupWidth, maxSize: 320))
              }
              .frame(maxWidth: .infinity, alignment: .top)
            }
            if wide {
              HStack(alignment: .top, spacing: 0) { group }
            } else {
              VStack(spacing: 24) { group }
            }
          } else {
            grid(themes, layout: layout)
          }
        }
        .frame(maxWidth: .infinity, minHeight: proxy.size.height - 36)
        .padding(.vertical, 12)
        .padding(.bottom, 24)
      }
    }
  }

  private func grid(_ themes: [WordTheme], layout: (columns: Int, size: CGFloat))
    -> some View
  {
    CardGrid(items: themes, columns: layout.columns, size: layout.size) { theme in
      PictureCard(
        asset: WordArt.index.representative(of: theme).map { WordArt.assetName(for: $0) } ?? "",
        title: theme.name, color: PlaceStyle.color(place.id), size: layout.size,
        font: .ui(25, bold: true)
      ) { onSelect(theme) }
    }
  }
}

// MARK: - ことばのカード

/// ことばを選ぶ。押すと、そのことばを書く画面へ（D101）。
/// 英語のことばがあるテーマには、「ABC」の旗を出す（D67・D92）。押すと、同じ絵の英語のことばに切り替わる。
/// 鍵のかかったことば（カタカナのことば・英語のことば）は影絵に鍵の印で、押すと「おねがい」（D93・D160）。
struct WordCardsView: View {
  var theme: WordTheme
  /// 英語のことばを出しているか（書く画面から戻っても残す）。
  @Binding var english: Bool
  var onSelect: (String) -> Void
  /// 鍵のかかったことばを押した（鍵の画面へ）。
  var onLocked: (EntitlementKit.Script) -> Void = { _ in }
  private let purchases = PurchaseStore.shared

  private struct Word: Identifiable {
    var text: String
    var id: String { text }
  }

  var body: some View {
    let index = WordArt.index
    let hasEnglish = !index.englishWords(in: theme).isEmpty
    let showsEnglish = english && hasEnglish
    let texts = showsEnglish ? index.englishWords(in: theme) : index.words(in: theme)
    let words = texts.map(Word.init)
    let entitlements = purchases.entitlements
    GeometryReader { proxy in
      let layout = cardLayout(count: words.count, width: proxy.size.width, maxSize: 280)
      ScrollView {
        VStack(spacing: 24) {
          ZStack {
            Heading(text: theme.name)
            if hasEnglish {
              HStack {
                Spacer()
                LanguageFlag(english: showsEnglish) { english.toggle() }
              }
            }
          }
          CardGrid(items: words, columns: layout.columns, size: layout.size) { word in
            let lock = WordAccess.lockedScript(of: word.text, entitlements: entitlements)
            PictureCard(
              asset: WordArt.assetName(for: word.text), title: word.text,
              color: PlaceStyle.color(theme.placeID), size: layout.size, font: .learning(40),
              locked: lock != nil
            ) {
              if let lock { onLocked(lock) } else { onSelect(word.text) }
            }
            .accessibilityIdentifier("wordCard-\(word.text)")
          }
        }
        .frame(maxWidth: .infinity, minHeight: proxy.size.height - 36)
        .padding(.vertical, 12)
        .padding(.bottom, 24)
        .padding(.horizontal, 24)
      }
    }
  }
}

/// 「ABC」の旗（D67）。だれでも押せる。英語のことばを出しているときは、日本語に戻す旗になる。
private struct LanguageFlag: View {
  var english: Bool
  var action: () -> Void

  var body: some View {
    Button {
      SoundPlayer.shared.play(.tap)
      action()
    } label: {
      HStack(spacing: 10) {
        Image(systemName: "flag.fill").font(.system(size: 32, weight: .bold))
        Text(english ? "あいう" : "ABC").font(.ui(34, bold: true))
      }
      .foregroundStyle(.white)
      .padding(.horizontal, 28)
      .frame(minWidth: 148, minHeight: 104)
      .background(Theme.blue.gradient, in: .rect(cornerRadius: Theme.Radius.button))
      .softShadow()
    }
    .buttonStyle(.plain)
    .accessibilityLabel(english ? String(localized: "にほんごの ことば") : String(localized: "えいごの ことば"))
    .accessibilityIdentifier("languageFlag")
  }
}
