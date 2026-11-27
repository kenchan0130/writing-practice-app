import ContentModel
import EntitlementKit
import RecordKit
import SwiftUI

extension KanaScript {
  /// 権利の決まり（EntitlementKit）での文字の種類。
  var entitlementScript: Script {
    switch self {
    case .hiragana: .hiragana
    case .katakana: .katakana
    case .abc: .abc
    }
  }

  /// 育ちの名前（「ひらがなの たね」。D151）に使う、日本語のままの名前。
  var japaneseTitle: String {
    switch self {
    case .hiragana: "ひらがな"
    case .katakana: "カタカナ"
    case .abc: "ABC"
    }
  }

  var title: String {
    switch self {
    case .hiragana: String(localized: "ひらがな")
    case .katakana: String(localized: "カタカナ")
    case .abc: "ABC"
    }
  }
}

extension AbcTable.Page {
  /// 地図のページのつまみの名前（D180）。
  var title: String {
    switch self {
    case .upper: String(localized: "おおもじ")
    case .lower: String(localized: "こもじ")
    case .digits: String(localized: "すうじ")
    }
  }
}

/// 文字の地図で選んでいるページ。字のカードから戻っても残す。
struct MapSelection: Equatable {
  enum Page: String { case basic, extra }
  var script: KanaScript = .hiragana
  var page: Page = .basic
  /// 狭いときの「あ行〜な行」(0)・「は行〜わ行」(1)。
  var half = 0
  /// ABC のページ（おおもじ・こもじ・すうじ。D180）。
  var abcPage = AbcTable.Page.upper

  init(script: KanaScript = .hiragana) {
    self.script = script
  }

  /// その字があるページを開く。
  init(showing char: Character) {
    script = KanaTable.script(of: char) ?? .hiragana
    if let page = AbcTable.page(of: char) { abcPage = page }
  }
}

/// 文字の地図（D101・D125・D146）。壁の50音表と同じく、あ行を右に置いて字を並べ、押すと字のカードへ。
struct MapView: View {
  @Binding var selection: MapSelection
  var onSelect: (Character) -> Void
  /// 鍵のかかった字を押した（鍵の画面へ。D160）。
  var onLocked: (Script) -> Void = { _ in }
  private let store = ProgressStore.shared
  private let purchases = PurchaseStore.shared

  var body: some View {
    GeometryReader { proxy in
      // ABC は1段7字（D180）。段の左右に、はなばたけの印の分の空きを取る。
      let landscape = proxy.size.width > proxy.size.height
      let decision =
        selection.script == .abc
        ? MapLayout.decide(
          width: proxy.size.width - 2 * (28 + MapLayout.gap), columns: AbcTable.lettersPerRow)
        : MapLayout.decide(width: proxy.size.width)
      VStack(spacing: 16) {
        // 横に余裕があるときは、字の種類とページのつまみを1行に並べて、表の場所を広げる。
        ViewThatFits(in: .horizontal) {
          HStack(spacing: 48) {
            scriptSwitch
            pageSwitch
          }
          VStack(spacing: 16) {
            scriptSwitch
            pageSwitch
          }
        }
        // 横向きは高さが足りないので、育ちの名前と凡例を1行に並べる（縦向きは凡例を表の下に出す）。
        if landscape {
          HStack(spacing: 32) {
            GrowthBadge(summary: ScriptGrowthSummary(script: selection.script, log: store.log))
            legend
          }
        } else {
          GrowthBadge(summary: ScriptGrowthSummary(script: selection.script, log: store.log))
        }
        if selection.script != .abc && selection.page == .basic && decision.split {
          halfSwitch
        }
        // 残りの高さに表と凡例を入れる。入りきらないときは、自然に縦に送れる。
        GeometryReader { area in
          let cell = fittedCell(
            decision: decision, height: area.size.height, legendBelow: !landscape)
          ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
              Spacer(minLength: 0)
              grid(decision: decision, cell: cell)
              Spacer(minLength: 0)
              if !landscape { legend }
            }
            .frame(maxWidth: .infinity, minHeight: area.size.height)
          }
          .scrollBounceBehavior(.basedOnSize)
        }
      }
      .padding(.horizontal, MapLayout.edge)
      .padding(.bottom, 24)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }

  /// 凡例の高さ（絵 36pt）と、表の上下の余白（16pt が3つ）、ゆとり。
  private static let legendHeight = 36.0 + 48 + 12

  /// 残りの高さに表が収まる字の大きさ。幅から決めた大きさより大きくはしない。収まらないとき（1.5cm 角より小さくなるとき）は 1.5cm 角のまま、縦に送る（D125）。
  private func fittedCell(decision: MapLayout.Decision, height: Double, legendBelow: Bool) -> Double
  {
    let gap = MapLayout.gap
    var rows = 0.0
    var extra = legendBelow ? Self.legendHeight : 2 * 16.0 + 12
    if selection.script == .abc {
      rows = Double(AbcTable.grid(selection.abcPage).cells.count)
    } else {
      switch selection.page {
      case .basic:
        let grid =
          decision.split
          ? KanaTable.halves(selection.script)[min(selection.half, 1)]
          : KanaTable.main(selection.script)
        rows = Double(grid.cells.count)
        extra += 28 + gap
      case .extra:
        let small = KanaTable.small(selection.script)
        let wraps = decision.split || small.columnCount > 9
        rows = Double(KanaTable.dakuon(selection.script).cells.count) + (wraps ? 2 : 1)
        extra += 28 + gap + 24 + 4
      }
    }
    let byHeight = (height - extra - gap * (rows - 1)) / rows
    return max(MapLayout.minCell, min(decision.cell, byHeight))
  }

  // MARK: - つまみ（2cm 角以上。D101）

  private var scriptSwitch: some View {
    HStack(spacing: 16) {
      ForEach(KanaScript.allCases, id: \.self) { script in
        MapSwitchButton(title: script.title, selected: selection.script == script) {
          selection = MapSelection(script: script)
        }
      }
    }
  }

  @ViewBuilder
  private var pageSwitch: some View {
    if selection.script == .abc { abcPageSwitch } else { kanaPageSwitch }
  }

  /// ABC のページ（おおもじ・こもじ・すうじ。D180）。
  private var abcPageSwitch: some View {
    HStack(spacing: 16) {
      ForEach(AbcTable.Page.allCases, id: \.self) { page in
        MapSwitchButton(title: page.title, selected: selection.abcPage == page, small: true) {
          selection.abcPage = page
        }
      }
    }
  }

  private var kanaPageSwitch: some View {
    HStack(spacing: 16) {
      MapSwitchButton(title: "あいうえお", selected: selection.page == .basic, small: true) {
        selection.page = .basic
      }
      MapSwitchButton(title: String(localized: "にごる・ちいさい"), selected: selection.page == .extra, small: true) {
        selection.page = .extra
      }
    }
  }

  private var halfSwitch: some View {
    HStack(spacing: 16) {
      MapSwitchButton(title: "あ〜な", selected: selection.half == 0, small: true) {
        selection.half = 0
      }
      MapSwitchButton(title: "は〜わ", selected: selection.half == 1, small: true) {
        selection.half = 1
      }
    }
  }

  // MARK: - 表

  @ViewBuilder
  private func grid(decision: MapLayout.Decision, cell: Double) -> some View {
    if selection.script == .abc {
      abcGridView(AbcTable.grid(selection.abcPage), cell: cell)
    } else {
      kanaGrid(decision: decision, cell: cell)
    }
  }

  /// アルファベットと数字の表（D180）。左から右に読む。段の右に、はなばたけの印を出す。
  private func abcGridView(_ grid: KanaGrid, cell: Double) -> some View {
    VStack(spacing: MapLayout.gap) {
      ForEach(Array(grid.cells.enumerated()), id: \.offset) { _, row in
        HStack(spacing: MapLayout.gap) {
          ForEach(Array(row.enumerated()), id: \.offset) { _, char in
            if let char {
              MapCell(
                char: char, size: cell, state: state(of: char), locked: isLocked(char)
              ) { tapped(char) }
            } else {
              Color.clear.frame(width: cell, height: cell)
            }
          }
          ZStack {
            if isGarden(row.compactMap { $0 }) { GardenMarker(size: 28) }
          }
          .frame(width: 28, height: cell)
        }
        // 印の分だけ左にも空きを取り、表をまん中に置く。
        .padding(.leading, 28 + MapLayout.gap)
      }
    }
  }

  @ViewBuilder
  private func kanaGrid(decision: MapLayout.Decision, cell: Double) -> some View {
    switch selection.page {
    case .basic:
      let halves = KanaTable.halves(selection.script)
      if decision.split {
        gridView(halves[min(selection.half, 1)], cell: cell)
      } else {
        gridView(KanaTable.main(selection.script), cell: cell)
      }
    case .extra:
      VStack(spacing: 24) {
        gridView(KanaTable.dakuon(selection.script), cell: cell)
        gridView(
          KanaTable.small(selection.script), cell: cell,
          wraps: decision.split || KanaTable.small(selection.script).columnCount > 9)
      }
    }
  }

  private func gridView(_ grid: KanaGrid, cell: Double, wraps: Bool = false) -> some View {
    let columns = grid.columnCount
    let rows = wraps ? grid.wrappedRightToLeft(perRow: 6).cells : grid.cells
    return VStack(spacing: MapLayout.gap) {
      // 1段だけの表（小さい字）は全体で1つの行。それ以外は列が行。
      if grid.rowCount > 1 { gardenMarkers(grid, cell: cell) }
      ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
        HStack(spacing: MapLayout.gap) {
          ForEach(Array(row.enumerated()), id: \.offset) { _, char in
            if let char {
              MapCell(
                char: char, size: cell, state: state(of: char), locked: isLocked(char)
              ) { tapped(char) }
            } else {
              Color.clear.frame(width: cell, height: cell)
            }
          }
        }
      }
      if grid.rowCount == 1, isGarden(grid.characters) {
        GardenMarker().padding(.top, 4)
      }
    }
    .frame(minWidth: Double(columns) * cell)
  }

  /// 列（あ行・か行 …）の上に、行の字がすべて「はな」になった印を出す（はなばたけ。D151）。
  private func gardenMarkers(_ grid: KanaGrid, cell: Double) -> some View {
    HStack(spacing: MapLayout.gap) {
      ForEach(0..<grid.columnCount, id: \.self) { column in
        let chars = grid.cells.compactMap { $0[column] }
        ZStack {
          if isGarden(chars) { GardenMarker(size: 28) }
        }
        .frame(width: cell, height: 28)
      }
    }
  }

  private func isGarden(_ chars: [Character]) -> Bool {
    RowGrowth.isGarden(chars.map(state(of:)))
  }

  private func state(of char: Character) -> MapState {
    guard let id = KanaTable.characterID(char, script: selection.script) else { return .notYet }
    return store.log.mapState(of: id)
  }

  /// 鍵がかかっているか。おためしの字は開いている（D90・D94）。
  private func isLocked(_ char: Character) -> Bool {
    !purchases.entitlements.canWrite(char, in: selection.script.entitlementScript)
  }

  private func tapped(_ char: Character) {
    if isLocked(char) {
      onLocked(selection.script.entitlementScript)
    } else {
      onSelect(char)
    }
  }

  /// 凡例（たね・め・つぼみ・はな。D151）。形の絵も付けて、色だけで区別しない（D36）。
  private var legend: some View {
    HStack(spacing: 20) {
      ForEach(GrowthStage.allCases, id: \.self) { stage in
        HStack(spacing: 8) {
          RoundedRectangle(cornerRadius: 8).fill(stage.fill).frame(width: 36, height: 36)
            .overlay { GrowthIcon(stage: stage, size: 22) }
          Text(stage.name).font(.ui(22, bold: true)).foregroundStyle(Theme.inkSoft)
        }
      }
      HStack(spacing: 6) {
        GardenMarker(size: 28)
        Text("はなばたけ").font(.ui(22, bold: true)).foregroundStyle(Theme.inkSoft)
      }
    }
  }
}

/// 字1つ。押せる大きさは `size`（1.5cm 角以上。D125）。見た目は少し内側に描いて間を広く見せる。
private struct MapCell: View {
  var char: Character
  var size: Double
  var state: MapState
  var locked: Bool
  var action: () -> Void

  private static let smallKana: Set<Character> = Set("ぁぃぅぇぉっゃゅょゎァィゥェォッャュョヮヵヶ")
  private var isSmallKana: Bool { Self.smallKana.contains(char) }

  var body: some View {
    Button(action: action) {
      // 小さい字（ゃ・っ など）は、字を小さくして左下に寄せ、ふつうの字と見分けられるようにする。
      Text(String(char))
        .font(.learning(size * (isSmallKana ? 0.36 : 0.5)))
        .foregroundStyle(locked ? Theme.inkSoft : Theme.ink)
        .frame(
          width: size - 8, height: size - 8, alignment: isSmallKana ? .bottomLeading : .center
        )
        .padding(
          isSmallKana ? EdgeInsets(top: 0, leading: 10, bottom: 8, trailing: 0) : EdgeInsets()
        )
        .background(state.fill, in: .rect(cornerRadius: Theme.Radius.cell))
        .overlay(alignment: .topTrailing) { badge }
        .frame(width: size, height: size)
        .contentShape(.rect)
    }
    .buttonStyle(.plain)
    .accessibilityLabel(String(char))
    .accessibilityValue(locked ? "" : state.label)
  }

  @ViewBuilder
  private var badge: some View {
    if locked {
      Image(systemName: "lock.fill")
        .font(.system(size: size * 0.22))
        .foregroundStyle(Theme.inkSoft)
        .padding(6)
    } else {
      // 育ちの小さな絵（たね・め・つぼみ・はな。D151）。
      GrowthIcon(stage: state.growth, size: size * 0.26).padding(6)
    }
  }
}

/// ページの切り替えのつまみ（高さ 104pt。D101）。
private struct MapSwitchButton: View {
  var title: String
  var selected: Bool
  var small = false
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.ui(small ? 28 : 36, bold: true))
        .foregroundStyle(selected ? Color.white : Theme.ink)
        .padding(.horizontal, 28)
        .frame(minWidth: 104, minHeight: 104)
        .background(
          selected ? Theme.accent : Color.white.opacity(0.8), in: .rect(cornerRadius: 28)
        )
        .softShadow()
    }
    .buttonStyle(.plain)
    .accessibilityAddTraits(selected ? .isSelected : [])
  }
}
