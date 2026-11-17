import ContentModel
import RecordKit
import SwiftUI

/// 書く場所の横のパネル（D154）。字の前後の矢印「＜ あ ＞」、その行の字の小さな表、キャラクターとひとこと。
/// 横向きでは縦に並べて書く手と反対の側に、縦向きでは書く場所の上に横に並べる。
struct WritingPanel: View {
  var model: WritingModel
  var vertical: Bool
  /// 鍵のかかった字を押したとき（やさしく知らせる。D3・D150）。
  var onLockedTap: () -> Void

  private let store = ProgressStore.shared

  /// 表の字の押せる大きさ（1.5cm 角以上。D125）。
  private static let cell: CGFloat = 80

  var body: some View {
    Group {
      if vertical {
        ScrollView(.vertical, showsIndicators: false) {
          VStack(spacing: 16) {
            arrows
            rowTable(columns: 3)
            WritingHelper(model: model, vertical: true)
          }
          .padding(.vertical, 4)
        }
        .frame(width: 340)
        // 角のペンたて（利き手の反対側。同じ側）と重ならないように、下をあける。
        .padding(.bottom, 112)
      } else {
        // 縦向き: 1段に並べて、書く場所を広く残す。字が多い行は横に送る。
        HStack(spacing: 16) {
          arrows
          ScrollView(.horizontal, showsIndicators: false) {
            rowTable(columns: 9)
          }
        }
      }
    }
    .padding(12)
    .background(Color.white.opacity(0.6), in: .rect(cornerRadius: Theme.Radius.card))
  }

  // MARK: - 矢印

  /// 「＜ あ ＞」。押せる部分は 104pt 角。
  private var arrows: some View {
    HStack(spacing: 4) {
      arrowButton("chevron.left", label: "まえの もじ") { model.previousCharacter() }
      Text(String(model.currentChar ?? " "))
        .font(.learning(64))
        .foregroundStyle(Theme.ink)
        .frame(minWidth: 72)
        .accessibilityIdentifier("panelChar")
      arrowButton("chevron.right", label: "つぎの もじ") { model.nextCharacter() }
    }
    .opacity(model.hasNeighbors ? 1 : 0.4)
    .disabled(!model.hasNeighbors)
  }

  private func arrowButton(_ symbol: String, label: String, action: @escaping () -> Void)
    -> some View
  {
    Button(action: action) {
      Image(systemName: symbol)
        .font(.system(size: 34, weight: .bold))
        .foregroundStyle(.white)
        .frame(width: 104, height: 104)
        .background(Theme.accent, in: .rect(cornerRadius: Theme.Radius.cell + 8))
        .softShadow()
    }
    .buttonStyle(.plain)
    .accessibilityLabel(label)
  }

  // MARK: - 行の表

  @ViewBuilder
  private func rowTable(columns: Int) -> some View {
    if let row = model.currentRow {
      let count = vertical ? columns : min(row.characters.count, columns)
      LazyVGrid(
        columns: Array(repeating: GridItem(.fixed(Self.cell), spacing: 8), count: count),
        spacing: 8
      ) {
        ForEach(row.characters, id: \.self) { char in
          RowCell(
            char: char, state: state(of: char), locked: model.isLocked(char),
            current: char == model.currentChar, size: Self.cell
          ) {
            if model.isLocked(char) { onLockedTap() } else { model.jump(to: char) }
          }
        }
      }
    }
  }

  private func state(of char: Character) -> MapState {
    guard let id = KanaTable.characterID(char, script: model.script) else { return .notYet }
    return store.log.mapState(of: id)
  }
}

/// 行の表の字1つ。
private struct RowCell: View {
  var char: Character
  var state: MapState
  var locked: Bool
  var current: Bool
  var size: CGFloat
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(String(char))
        .font(.learning(42))
        .foregroundStyle(locked ? Theme.inkSoft : Theme.ink)
        .frame(width: size, height: size)
        .background(state.fill, in: .rect(cornerRadius: Theme.Radius.cell))
        .overlay {
          if current {
            RoundedRectangle(cornerRadius: Theme.Radius.cell).stroke(Theme.accent, lineWidth: 5)
          }
        }
        .overlay(alignment: .topTrailing) {
          if locked {
            Image(systemName: "lock.fill").font(.system(size: 16)).foregroundStyle(Theme.inkSoft)
              .padding(6)
          } else {
            GrowthIcon(stage: state.growth, size: 20).padding(5)
          }
        }
        .contentShape(.rect)
    }
    .buttonStyle(.plain)
    .accessibilityLabel(String(char))
  }
}

/// キャラクター（絵はまだ仮。D134）とひとこと（D150）。
struct WritingHelper: View {
  var model: WritingModel
  var vertical: Bool

  var body: some View {
    Group {
      if vertical {
        VStack(spacing: 8) {
          mascot
          bubble
        }
      } else {
        HStack(spacing: 10) {
          mascot
          bubble
        }
      }
    }
    .accessibilityElement(children: .combine)
  }

  private var mascot: some View {
    Image(systemName: model.finishedRating != nil ? "party.popper.fill" : "pawprint.fill")
      .font(.system(size: vertical ? 44 : 30))
      .foregroundStyle(.white)
      .frame(width: vertical ? 84 : 56, height: vertical ? 84 : 56)
      .background(Theme.pink.gradient, in: .circle)
      .softShadow()
  }

  private var bubble: some View {
    Text(model.guidance)
      .font(.ui(vertical ? 22 : 24, bold: true))
      .foregroundStyle(Theme.ink)
      .multilineTextAlignment(.center)
      .padding(.horizontal, 14)
      .padding(.vertical, 8)
      .background(.white, in: .rect(cornerRadius: 20))
      .softShadow()
  }
}
