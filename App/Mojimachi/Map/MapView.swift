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
    }
  }

  var title: String {
    switch self {
    case .hiragana: "ひらがな"
    case .katakana: "カタカナ"
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
}

/// 文字の地図（D101・D125・D146）。壁の50音表と同じく、あ行を右に置いて字を並べ、押すと字のカードへ。
struct MapView: View {
  @Binding var selection: MapSelection
  var onSelect: (Character) -> Void
  @State private var showsLockedHelp = false
  private let store = ProgressStore.shared
  private let purchases = PurchaseStore.shared

  var body: some View {
    GeometryReader { proxy in
      let decision = MapLayout.decide(width: proxy.size.width)
      VStack(spacing: 20) {
        scriptSwitch
        pageSwitch
        if selection.page == .basic && decision.split {
          halfSwitch
        }
        Spacer(minLength: 0)
        grid(decision: decision)
        Spacer(minLength: 0)
        legend
      }
      .padding(.horizontal, MapLayout.edge)
      .padding(.bottom, 24)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .alert("おとなのひとに おねがいしてね", isPresented: $showsLockedHelp) {
      Button("わかった") {}
    }
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

  private var pageSwitch: some View {
    HStack(spacing: 16) {
      MapSwitchButton(title: "あいうえお", selected: selection.page == .basic, small: true) {
        selection.page = .basic
      }
      MapSwitchButton(title: "にごる・ちいさい", selected: selection.page == .extra, small: true) {
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
  private func grid(decision: MapLayout.Decision) -> some View {
    switch selection.page {
    case .basic:
      let halves = KanaTable.halves(selection.script)
      if decision.split {
        gridView(halves[min(selection.half, 1)], cell: decision.cell)
      } else {
        gridView(KanaTable.main(selection.script), cell: decision.cell)
      }
    case .extra:
      VStack(spacing: 24) {
        gridView(KanaTable.dakuon(selection.script), cell: decision.cell)
        gridView(
          KanaTable.small(selection.script), cell: decision.cell,
          wraps: decision.split || KanaTable.small(selection.script).columnCount > 9)
      }
    }
  }

  private func gridView(_ grid: KanaGrid, cell: Double, wraps: Bool = false) -> some View {
    let columns = grid.columnCount
    let rows = wraps ? grid.wrappedRightToLeft(perRow: 6).cells : grid.cells
    return VStack(spacing: MapLayout.gap) {
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
    }
    .frame(minWidth: Double(columns) * cell)
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
      showsLockedHelp = true
    } else {
      onSelect(char)
    }
  }

  private var legend: some View {
    HStack(spacing: 20) {
      ForEach([MapState.notYet, .practicing, .traced, .wroteAlone], id: \.self) { state in
        HStack(spacing: 8) {
          RoundedRectangle(cornerRadius: 6).fill(state.fill).frame(width: 28, height: 28)
          Text(state.label).font(.system(size: 20, weight: .bold)).foregroundStyle(.secondary)
        }
      }
    }
  }
}

extension MapState {
  var fill: Color {
    switch self {
    case .notYet: Color.gray.opacity(0.18)
    case .practicing: Color.orange.opacity(0.35)
    case .traced: Color.green.opacity(0.4)
    case .wroteAlone: Color.yellow.opacity(0.75)
    }
  }

  var label: String {
    switch self {
    case .notYet: "まだ"
    case .practicing: "れんしゅうちゅう"
    case .traced: "なぞって かけた"
    case .wroteAlone: "ひとりで かけた"
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
        .font(.system(size: size * (isSmallKana ? 0.36 : 0.5), weight: .bold))
        .foregroundStyle(locked ? Color.secondary : Color.primary)
        .frame(
          width: size - 8, height: size - 8, alignment: isSmallKana ? .bottomLeading : .center
        )
        .padding(
          isSmallKana ? EdgeInsets(top: 0, leading: 10, bottom: 8, trailing: 0) : EdgeInsets()
        )
        .background(state.fill, in: .rect(cornerRadius: 14))
        .overlay(alignment: .topTrailing) { badge }
        .frame(width: size, height: size)
        .contentShape(.rect)
    }
    .buttonStyle(.plain)
    .accessibilityLabel(String(char))
  }

  @ViewBuilder
  private var badge: some View {
    if locked {
      Image(systemName: "lock.fill")
        .font(.system(size: size * 0.22))
        .foregroundStyle(.secondary)
        .padding(6)
    } else if state == .wroteAlone {
      // スタンプ（何も見ないで書けた字。§3.8）。
      Image(systemName: "star.circle.fill")
        .font(.system(size: size * 0.3))
        .foregroundStyle(.orange, .white)
        .offset(x: 4, y: -4)
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
        .font(.system(size: small ? 28 : 36, weight: .bold))
        .foregroundStyle(selected ? Color.white : Color.primary)
        .padding(.horizontal, 28)
        .frame(minWidth: 104, minHeight: 104)
        .background(
          selected ? Color.orange : Color.gray.opacity(0.15), in: .rect(cornerRadius: 28))
    }
    .buttonStyle(.plain)
    .accessibilityAddTraits(selected ? .isSelected : [])
  }
}
