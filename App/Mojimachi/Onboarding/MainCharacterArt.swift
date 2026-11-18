import PracticeKit
import SwiftUI

/// 主人公3人の絵（描いたイラスト。D164）。もとの SVG は `Content/Art/characters/`。
/// いまは動かない1枚の絵。動かす絵は D134 の Rive で、同じ SVG から作る。
enum CharacterPose: String, CaseIterable, Sendable {
  case normal, wave, happy, sleep
}

extension MainCharacter {
  /// アセットの名前（`Assets.xcassets` の `char-<キャラクター>-<ポーズ>`）。
  func assetName(_ pose: CharacterPose = .normal) -> String {
    "char-\(rawValue)-\(pose.rawValue)"
  }

  /// キャラクターの色（飾りや背景に使う）。
  var color: Color {
    switch self {
    case .ton: Color(red: 0.94, green: 0.48, blue: 0.29)  // #f07a4a
    case .run: Color(red: 0.35, green: 0.70, blue: 0.92)  // #58b2ea
    case .hira: Color(red: 0.49, green: 0.76, blue: 0.42)  // #7cc36a
    }
  }
}

/// キャラクターの絵。`size` 四方に、縦横の比を保って入れる。ベクターのままなので、どの大きさでもくっきり出る。
struct MainCharacterArt: View {
  var character: MainCharacter
  var size: CGFloat
  var pose: CharacterPose = .normal

  var body: some View {
    Image(character.assetName(pose))
      .resizable()
      .scaledToFit()
      .frame(width: size, height: size)
      .softShadow()
      .accessibilityHidden(true)
  }
}
