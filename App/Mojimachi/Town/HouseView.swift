import PracticeKit
import SpriteKit
import SwiftUI

/// キャラクターのいえ（いえの なか。§3.1・§3.4・D185）。
/// 部屋に いえの物が並び、主人公が使う。下に、クローゼットと おもちゃばこの入口。
struct HouseView: View {
  var onCloset: () -> Void

  private let store = ProgressStore.shared
  @State private var scene = HouseScene()

  private var title: String {
    let name = store.currentProfile?.name.trimmingCharacters(in: .whitespaces) ?? ""
    return name.isEmpty ? "わたしの いえ" : "\(name)の いえ"
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(title)
        .font(.learning(40))
        .foregroundStyle(Theme.ink)
        .accessibilityIdentifier("houseTitle")
      GeometryReader { proxy in
        SpriteView(scene: scene)
          .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.paper))
          .softShadow()
          .onAppear {
            scene.size = proxy.size
            #if DEBUG
              debugSeedTown(store)
            #endif
            scene.setCharacter(store.mainCharacter)
            scene.show(store.board)
            #if DEBUG
              // 確かめ用: `-toyBox YES` で、おもちゃばこを開いておく。
              if UserDefaults.standard.bool(forKey: "toyBox") {
                ToyBoxPresenter.show(groups: ShelfGroup.house)
              }
            #endif
          }
          .onChange(of: store.placed) { scene.show(store.board) }
          .onChange(of: store.moves) { scene.show(store.board) }
          .onChange(of: store.mainCharacter) { _, character in scene.setCharacter(character) }
          .accessibilityLabel("いえの なか")
          .overlay(alignment: .bottomLeading) {
            ChildToolButton(title: "クローゼット", systemImage: "hanger", color: Theme.blue) {
              onCloset()
            }
            .accessibilityIdentifier("closetButton")
            .padding(12)
          }
          .overlay(alignment: .bottomTrailing) {
            ToyBoxButton { ToyBoxPresenter.show(groups: ShelfGroup.house) }
              .padding(12)
          }
      }
    }
    .padding(32)
  }
}
