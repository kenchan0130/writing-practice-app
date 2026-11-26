import PracticeKit
import SpriteKit
import UIKit

/// 体のことばを書いたときに、主人公が見せる動き（D175）。
/// 変身のあと（`TransformScene`）と、まちが開いたとき（`TownScene`）で同じ動きを使う。
/// 主人公の絵（`SKSpriteNode`）は、足もとが原点（anchorPoint の y が低い）。
/// 音符・あわなどの小さな飾りは、主人公と同じ親ノードに足して、終わったら自分で消える。
/// 「動きを減らす」がオンなら、そのことばのポーズで、ふわっと見せるだけ。
@MainActor
enum BodyMotionFX {
  /// 主人公の顔のちがい（絵は `Scripts/art/chars.py`）。
  struct Poses {
    let normal: SKTexture
    let wave: SKTexture
    let happy: SKTexture
    let blink: SKTexture
  }

  static func poses(for character: MainCharacter) -> Poses? {
    func texture(_ pose: CharacterPose) -> SKTexture? {
      WordArt.image(asset: character.assetName(pose), size: 320).map { SKTexture(image: $0) }
    }
    guard let normal = texture(.normal), let wave = texture(.wave), let happy = texture(.happy),
      let blink = texture(.blink)
    else { return nil }
    return Poses(normal: normal, wave: wave, happy: happy, blink: blink)
  }

  private static let noteColors = [
    UIColor(red: 0.93, green: 0.42, blue: 0.5, alpha: 1),
    UIColor(red: 0.42, green: 0.45, blue: 0.9, alpha: 1),
    UIColor(red: 0.96, green: 0.65, blue: 0.2, alpha: 1),
  ]

  /// 動きの長さ（秒）。`play` の中身と合わせてある。
  static func duration(of motion: BodyMotion, reduceMotion: Bool) -> TimeInterval {
    if reduceMotion { return 1.0 }
    switch motion {
    case .wave: return 0.15 + 0.56 * 3 + 0.15
    case .jump: return 2 * 0.69 + 0.08
    case .look: return 0.34 * 2 + 0.1 + 1.9 + 0.34
    case .listen: return 0.1 + 0.4 + 1.0 + 0.5 + 0.8 + 0.15
    case .sing: return 0.36 * 5 + 0.12 + 0.3
    case .nod: return 0.1 + 0.42 * 3 + 0.15 + 0.4
    case .belly: return 0.2 + 0.44 * 3 + 0.15 + 0.5
    case .puff: return 2 * 1.54
    }
  }

  /// 動きを1回見せる。見せている長さ（秒）を返す。終わると、元の向き・大きさ・ポーズにもどる。
  @discardableResult
  static func play(
    _ motion: BodyMotion, hero: SKSpriteNode, poses: Poses, reduceMotion reduce: Bool
  ) -> TimeInterval {
    let side = hero.size.height
    let baseX = hero.xScale
    let baseY = hero.yScale
    func pose(_ texture: SKTexture) -> SKAction { .setTexture(texture, resize: false) }
    func eased(_ action: SKAction) -> SKAction {
      action.timingMode = .easeInEaseOut
      return action
    }
    func squash(_ x: CGFloat, _ y: CGFloat, _ duration: TimeInterval) -> SKAction {
      eased(
        .group([
          .scaleX(to: baseX * x, duration: duration), .scaleY(to: baseY * y, duration: duration),
        ]))
    }
    let rest = SKAction.group([
      .rotate(toAngle: 0, duration: 0.15), .scaleX(to: baseX, duration: 0.15),
      .scaleY(to: baseY, duration: 0.15),
    ])
    let normal = pose(poses.normal)

    if reduce {
      // 止まった絵: そのことばのポーズ（まばたき・口のあき・手を振る形）を、すこしのあいだ見せる。
      let held: SKTexture =
        switch motion {
        case .wave: poses.wave
        case .jump, .sing, .nod: poses.happy
        case .look, .belly, .puff: poses.blink
        case .listen: poses.normal
        }
      hero.removeAllActions()
      hero.alpha = 0.6
      hero.run(
        .sequence([
          pose(held), .fadeIn(withDuration: 0.4), .wait(forDuration: 0.6), normal,
        ]))
      return duration(of: motion, reduceMotion: true)
    }

    switch motion {
    case .wave:
      // 手を振る形のまま、左右にゆれる。
      let rock = SKAction.sequence([
        eased(.rotate(toAngle: 0.1, duration: 0.28)), eased(.rotate(toAngle: -0.1, duration: 0.28)),
      ])
      hero.run(
        .sequence([
          pose(poses.wave), .repeat(rock, count: 3), rest, normal,
        ]))
      return duration(of: motion, reduceMotion: false)
    case .jump:
      // しゃがんで、ぴょん。2回。
      func hop() -> SKAction {
        let up = SKAction.moveBy(x: 0, y: side * 0.5, duration: 0.26)
        up.timingMode = .easeOut
        let down = SKAction.moveBy(x: 0, y: -side * 0.5, duration: 0.24)
        down.timingMode = .easeIn
        return .sequence([
          squash(1.1, 0.86, 0.1),
          .group([pose(poses.happy), squash(0.94, 1.1, 0.12), up]),
          down, squash(1.12, 0.86, 0.07), squash(1, 1, 0.1),
        ])
      }
      hero.run(.sequence([hop(), .wait(forDuration: 0.08), hop(), normal]))
      return duration(of: motion, reduceMotion: false)
    case .look:
      // まばたきをして、きょろきょろ見て、もう一度まばたき。
      func blink() -> SKAction {
        .sequence([pose(poses.blink), .wait(forDuration: 0.16), normal, .wait(forDuration: 0.18)])
      }
      let glance = side * 0.1
      let around = SKAction.sequence([
        .group([.moveBy(x: -glance, y: 0, duration: 0.35), .scaleX(to: -baseX, duration: 0.12)]),
        .wait(forDuration: 0.35),
        .group([.moveBy(x: glance * 2, y: 0, duration: 0.5), .scaleX(to: baseX, duration: 0.12)]),
        .wait(forDuration: 0.35),
        .group([.moveBy(x: -glance, y: 0, duration: 0.35), .scaleX(to: baseX, duration: 0.05)]),
      ])
      hero.run(.sequence([blink(), .wait(forDuration: 0.1), blink(), around, blink(), normal]))
      return duration(of: motion, reduceMotion: false)
    case .listen:
      // 首をかしげて、聞く。まわりに ♪。目をとじて、気もちよさそうに。
      let lean = SKAction.sequence([
        eased(.rotate(toAngle: 0.16, duration: 0.4)), .wait(forDuration: 1.0),
        eased(.rotate(toAngle: -0.16, duration: 0.5)), .wait(forDuration: 0.8), rest,
      ])
      hero.run(
        .sequence([
          .wait(forDuration: 0.1), .group([lean, .sequence([.wait(forDuration: 0.5), pose(poses.blink)])]),
          normal,
        ]))
      for index in 0..<4 {
        let left = index % 2 == 0
        floatNote(
          index.isMultiple(of: 2) ? "♪" : "♫", near: hero,
          at: CGPoint(x: (left ? -0.6 : 0.6) * side, y: side * (0.55 + 0.1 * CGFloat(index % 3))),
          delay: 0.2 + 0.55 * Double(index), size: side * 0.2, color: noteColors[index % 3],
          drift: (left ? -1 : 1) * side * 0.1)
      }
      return duration(of: motion, reduceMotion: false)
    case .sing:
      // 口を大きくあけて「あー」。リズムにのって はずみ、♪ がのぼる。
      func beat() -> SKAction {
        let up = SKAction.moveBy(x: 0, y: side * 0.1, duration: 0.17)
        up.timingMode = .easeOut
        let down = SKAction.moveBy(x: 0, y: -side * 0.1, duration: 0.19)
        down.timingMode = .easeIn
        return .sequence([.group([squash(0.96, 1.06, 0.17), up]), .group([squash(1.06, 0.94, 0.19), down])])
      }
      hero.run(
        .sequence([
          pose(poses.happy), .repeat(beat(), count: 5), squash(1, 1, 0.12), .wait(forDuration: 0.3), normal,
        ]))
      for index in 0..<5 {
        floatNote(
          index.isMultiple(of: 2) ? "♪" : "♫", near: hero,
          at: CGPoint(x: side * (0.15 * CGFloat(index % 3) - 0.1), y: side * 0.95),
          delay: 0.1 + 0.36 * Double(index), size: side * 0.24, color: noteColors[index % 3],
          drift: side * (index.isMultiple(of: 2) ? 0.2 : -0.1))
      }
      return duration(of: motion, reduceMotion: false)
    case .nod:
      // うなずく。ぺこ、ぺこ、ぺこ。
      let bow = SKAction.sequence([
        .group([eased(.rotate(toAngle: -0.12, duration: 0.2)), squash(1.04, 0.92, 0.2)]),
        .group([eased(.rotate(toAngle: 0.02, duration: 0.22)), squash(1, 1.02, 0.22)]),
      ])
      hero.run(
        .sequence([
          .wait(forDuration: 0.1), .repeat(bow, count: 3), pose(poses.happy), rest, .wait(forDuration: 0.4),
          normal,
        ]))
      return duration(of: motion, reduceMotion: false)
    case .belly:
      // おなかが「ぐう」。ぷるぷる ゆれる。
      let jelly = SKAction.sequence([
        squash(1.13, 0.9, 0.22), squash(0.94, 1.06, 0.22),
      ])
      hero.run(
        .sequence([
          .wait(forDuration: 0.2), pose(poses.blink), .repeat(jelly, count: 3), squash(1, 1, 0.15),
          pose(poses.happy), .wait(forDuration: 0.5), normal,
        ]))
      floatBubble("ぐう", near: hero, at: CGPoint(x: side * 0.55, y: side * 0.5), delay: 0.2, size: side * 0.16)
      floatBubble("ぐう", near: hero, at: CGPoint(x: -side * 0.55, y: side * 0.62), delay: 1.1, size: side * 0.16)
      return duration(of: motion, reduceMotion: false)
    case .puff:
      // ほっぺを ぷーっと ふくらませて、ぷしゅっ。
      func puff() -> SKAction {
        .sequence([
          pose(poses.blink), squash(1.18, 0.92, 0.35), .wait(forDuration: 0.5),
          .group([pose(poses.happy), squash(0.94, 1.08, 0.08)]),
          .moveBy(x: 0, y: side * 0.08, duration: 0.12), .moveBy(x: 0, y: -side * 0.08, duration: 0.12),
          squash(1, 1, 0.12), .wait(forDuration: 0.25),
        ])
      }
      hero.run(.sequence([puff(), puff(), normal]))
      return duration(of: motion, reduceMotion: false)
    }
  }

  /// 小さな音符が ふわっとのぼって、消える。
  private static func floatNote(
    _ text: String, near hero: SKSpriteNode, at offset: CGPoint, delay: TimeInterval, size: CGFloat,
    color: UIColor, drift: CGFloat
  ) {
    guard let parent = hero.parent else { return }
    let label = SKLabelNode(text: text)
    label.fontName = "AvenirNext-Bold"
    label.fontSize = size
    label.fontColor = color
    label.verticalAlignmentMode = .center
    label.alpha = 0
    label.zPosition = hero.zPosition + 1
    label.position = CGPoint(x: hero.position.x + offset.x, y: hero.position.y + offset.y)
    parent.addChild(label)
    label.run(
      .sequence([
        .wait(forDuration: delay),
        .group([
          .sequence([
            .fadeIn(withDuration: 0.2), .wait(forDuration: 0.8), .fadeOut(withDuration: 0.4),
          ]),
          .moveBy(x: drift, y: hero.size.height * 0.28, duration: 1.4),
          .sequence([.rotate(toAngle: 0.15, duration: 0.5), .rotate(toAngle: -0.15, duration: 0.9)]),
        ]),
        .removeFromParent(),
      ]))
  }

  /// 「ぐう」と書いた、小さな白いふきだし。ぽんと出て、のぼって、消える。
  private static func floatBubble(
    _ text: String, near hero: SKSpriteNode, at offset: CGPoint, delay: TimeInterval, size: CGFloat
  ) {
    guard let parent = hero.parent else { return }
    let bubble = SKNode()
    bubble.alpha = 0
    bubble.zPosition = hero.zPosition + 1
    bubble.position = CGPoint(x: hero.position.x + offset.x, y: hero.position.y + offset.y)
    let label = SKLabelNode(text: text)
    label.fontName = "HiraginoSans-W6"
    label.fontSize = size
    label.fontColor = UIColor(red: 0.29, green: 0.204, blue: 0.157, alpha: 1)
    label.verticalAlignmentMode = .center
    label.zPosition = 1
    let width = size * CGFloat(text.count) * 1.1 + size * 0.9
    let back = SKShapeNode(
      rect: CGRect(x: -width / 2, y: -size * 0.8, width: width, height: size * 1.6),
      cornerRadius: size * 0.8)
    back.fillColor = .white
    back.strokeColor = UIColor(red: 0.29, green: 0.204, blue: 0.157, alpha: 1)
    back.lineWidth = 3
    bubble.addChild(back)
    bubble.addChild(label)
    bubble.setScale(0.5)
    parent.addChild(bubble)
    bubble.run(
      .sequence([
        .wait(forDuration: delay),
        .group([
          .sequence([.fadeIn(withDuration: 0.15), .wait(forDuration: 0.9), .fadeOut(withDuration: 0.4)]),
          .scale(to: 1, duration: 0.2),
          .moveBy(x: 0, y: hero.size.height * 0.15, duration: 1.4),
        ]),
        .removeFromParent(),
      ]))
  }
}
