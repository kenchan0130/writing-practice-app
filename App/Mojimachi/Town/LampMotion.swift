import SpriteKit
import UIKit

/// しんごう・ふみきりの あかり（D174）。絵の上に、あかりの丸を重ねて、色を変える。
/// 絵（`Scripts/art/words.py`）は、しんごうは青、ふみきりは両方赤で止まっている。
/// 「動きを減らす」がオンなら重ねず、絵のまま止める。
enum LampMotion {
  /// 絵の中のあかり。x・y・r は絵の大きさに対する割合（y は上から）。r は、ふちを除いた丸の半径。
  struct Lamp {
    let x: CGFloat
    let y: CGFloat
    let r: CGFloat
  }

  private enum Pattern {
    /// しんごう: 青（長く）→ 黄（短く）→ 赤。3つのあかり。
    case signal
    /// ふみきり: 2つの赤が かわるがわる光る。
    case crossing
  }

  private static func lamps(_ word: String) -> (lamps: [Lamp], pattern: Pattern)? {
    switch word {
    case "しんごう":
      let r: CGFloat = 32.7 / 512
      return (
        [
          Lamp(x: 152 / 512, y: 104.8 / 512, r: r), Lamp(x: 256 / 512, y: 104.8 / 512, r: r),
          Lamp(x: 360 / 512, y: 104.8 / 512, r: r),
        ], .signal
      )
    case "ふみきり":
      let r: CGFloat = 14.9 / 512
      return (
        [Lamp(x: 100.4 / 512, y: 208.1 / 512, r: r), Lamp(x: 151.1 / 512, y: 208.1 / 512, r: r)],
        .crossing
      )
    default: return nil
    }
  }

  private static func color(_ hex: UInt32) -> UIColor {
    UIColor(
      red: CGFloat((hex >> 16) & 0xff) / 255, green: CGFloat((hex >> 8) & 0xff) / 255,
      blue: CGFloat(hex & 0xff) / 255, alpha: 1)
  }

  /// `sprite`（絵の四角いノード）に、あかりを付けて動かす。`sprite.size` が最後の大きさのときに呼ぶ。
  static func attach(to sprite: SKSpriteNode, word: String, reduceMotion: Bool) {
    guard !reduceMotion, let (lamps, pattern) = lamps(word) else { return }
    let side = sprite.size.width
    let nodes: [SKShapeNode] = lamps.map { lamp in
      let node = SKShapeNode(circleOfRadius: lamp.r * side)
      node.lineWidth = 0
      node.position = CGPoint(
        x: (lamp.x - sprite.anchorPoint.x) * side,
        y: ((1 - lamp.y) - sprite.anchorPoint.y) * side)
      node.zPosition = 1
      sprite.addChild(node)
      return node
    }
    func light(_ lit: Int?) {
      switch pattern {
      case .signal:
        let on = [color(0x58d36a), color(0xffd23a), color(0xff4a40)]
        let off = [color(0x2f6b3a), color(0x5e5320), color(0x6b2a28)]
        for (i, node) in nodes.enumerated() { node.fillColor = i == lit ? on[i] : off[i] }
      case .crossing:
        for (i, node) in nodes.enumerated() {
          node.fillColor = i == lit ? color(0xff3b30) : color(0x8c2a26)
        }
      }
    }
    switch pattern {
    case .signal:
      light(0)
      sprite.run(
        .repeatForever(
          .sequence([
            .wait(forDuration: 3.5), .run { light(1) }, .wait(forDuration: 1.0),
            .run { light(2) }, .wait(forDuration: 3.0), .run { light(0) },
          ])), withKey: "lamps")
    case .crossing:
      light(0)
      sprite.run(
        .repeatForever(
          .sequence([
            .wait(forDuration: 0.5), .run { light(1) }, .wait(forDuration: 0.5),
            .run { light(0) },
          ])), withKey: "lamps")
    }
  }
}
