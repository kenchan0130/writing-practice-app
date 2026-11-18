import PracticeKit
import SwiftUI

/// 主人公3人の仮の絵（SF Symbol）。本物は D134 の Rive で作る。
extension MainCharacter {
  var symbol: String {
    switch self {
    case .ton: "pawprint.fill"
    case .run: "hare.fill"
    case .hira: "cloud.fill"
    }
  }

  var color: Color {
    switch self {
    case .ton: Theme.pink
    case .run: Theme.blue
    case .hira: Theme.accent
    }
  }
}

/// 丸い顔の中にキャラクターの絵を入れた形。
struct MainCharacterArt: View {
  var character: MainCharacter
  var size: CGFloat

  var body: some View {
    Image(systemName: character.symbol)
      .font(.system(size: size * 0.5))
      .foregroundStyle(.white)
      .frame(width: size, height: size)
      .background(character.color.gradient, in: .circle)
      .softShadow()
      .accessibilityHidden(true)
  }
}
