import PracticeKit
import SpriteKit
import UIKit

/// いえの物を、主人公が使うときの動き（D185）。いえの なか（`HouseScene`）と、変身のあと（`TransformScene`）で同じ動きを使う。
/// 物の絵（`SKSpriteNode`）と主人公の絵は、同じ親ノードの中にあること。
/// 飾り（ゆげ・あわ・きらきら・Z）は、その親に足して、終わったら自分で消える。
@MainActor
enum HouseMotion {
  private static let outline = UIColor(red: 0.29, green: 0.204, blue: 0.157, alpha: 1)

  /// 主人公の顔のちがい。
  struct Poses {
    let normal: SKTexture
    let wave: SKTexture
    let happy: SKTexture
    let sleep: SKTexture
  }

  static func poses(for character: MainCharacter) -> Poses? {
    func texture(_ pose: CharacterPose) -> SKTexture? {
      WordArt.image(asset: character.assetName(pose), size: 320).map { SKTexture(image: $0) }
    }
    guard let normal = texture(.normal), let wave = texture(.wave), let happy = texture(.happy),
      let sleep = texture(.sleep)
    else { return nil }
    return Poses(normal: normal, wave: wave, happy: happy, sleep: sleep)
  }

  /// 使う動きの長さ（秒）。
  static func duration(of use: HouseUse) -> TimeInterval {
    switch use {
    case .sleep: 3.6
    case .sit: 3.0
    default: 2.4
    }
  }

  /// 絵の中の場所（左上が 0,0、右下が 1,1）を、物の親ノードの座標にする。
  static func point(in node: SKSpriteNode, x: CGFloat, yFromTop: CGFloat) -> CGPoint {
    CGPoint(
      x: node.position.x + (x - node.anchorPoint.x) * node.size.width,
      y: node.position.y + ((1 - yFromTop) - node.anchorPoint.y) * node.size.height)
  }

  /// 物が つつかれた・使われたときの、ひとはずみ。
  static func bounce(_ node: SKSpriteNode) {
    guard node.action(forKey: "bounce") == nil else { return }
    let h = node.size.height
    let up = SKAction.moveBy(x: 0, y: h * 0.07, duration: 0.12)
    up.timingMode = .easeOut
    let down = SKAction.moveBy(x: 0, y: -h * 0.07, duration: 0.14)
    down.timingMode = .easeIn
    node.run(.sequence([up, down, up, down]), withKey: "bounce")
  }

  /// 主人公が、その場で物を使う。`hero` は使う場所に もう立っていること。
  /// `thingFrame` は、絵の中身（すきまを除いた四角。左上が原点の割合）。
  static func play(
    _ use: HouseUse, hero: SKSpriteNode, thing: SKSpriteNode, poses: Poses,
    content: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
  ) {
    guard let parent = thing.parent else { return }
    let top = point(in: thing, x: content.midX, yFromTop: content.minY)
    let side = thing.size.height
    let seconds = duration(of: use)
    func pose(_ texture: SKTexture) -> SKAction { .setTexture(texture, resize: false) }
    func hop(_ height: CGFloat = 0.12) -> SKAction {
      let up = SKAction.moveBy(x: 0, y: hero.size.height * height, duration: 0.16)
      up.timingMode = .easeOut
      let down = SKAction.moveBy(x: 0, y: -hero.size.height * height, duration: 0.18)
      down.timingMode = .easeIn
      return .sequence([up, down])
    }
    func nod() -> SKAction {
      .sequence([.scaleY(to: 0.93, duration: 0.14), .scaleY(to: 1, duration: 0.14)])
    }
    let z = max(hero.zPosition, thing.zPosition) + 1
    switch use {
    case .eat:
      // もぐもぐ: よろこんで、こくこく うなずく。物は はずむ。
      bounce(thing)
      hero.run(
        .sequence([
          pose(poses.happy), nod(), nod(), .wait(forDuration: 0.2), nod(), nod(),
          .wait(forDuration: seconds - 1.6), pose(poses.normal),
        ]), withKey: "use")
      for index in 0..<2 {
        floatMark(
          "♪", color: UIColor(red: 1, green: 0.55, blue: 0.4, alpha: 1), from: top,
          dx: CGFloat(index * 2 - 1) * side * 0.25, rise: side * 0.5, size: side * 0.28,
          delay: Double(index) * 0.5, z: z, in: parent)
      }
    case .cook:
      // ゆげが のぼる。ふたが かたかた。
      thing.run(
        .sequence([
          .rotate(toAngle: 0.04, duration: 0.1), .rotate(toAngle: -0.04, duration: 0.2),
          .rotate(toAngle: 0.04, duration: 0.2), .rotate(toAngle: 0, duration: 0.1),
        ]), withKey: "wobble")
      for index in 0..<3 {
        floatPuff(
          from: CGPoint(x: top.x + CGFloat(index - 1) * side * 0.14, y: top.y),
          radius: side * 0.09, rise: side * 0.55, delay: Double(index) * 0.35, stroke: false, z: z,
          in: parent)
      }
      hero.run(
        .sequence([pose(poses.happy), hop(), .wait(forDuration: seconds - 0.8), pose(poses.normal)]),
        withKey: "use")
    case .sit, .sleep:
      // すわる・ねむる は、場所を変えるので `HouseScene` が動かす。ここでは顔と飾りだけ。
      if use == .sleep {
        hero.run(
          .sequence([pose(poses.sleep), .wait(forDuration: seconds), pose(poses.normal)]),
          withKey: "use")
        for index in 0..<3 {
          floatMark(
            "Z", color: UIColor(red: 0.45, green: 0.55, blue: 0.9, alpha: 1),
            from: CGPoint(x: hero.position.x + hero.size.width * 0.3, y: hero.position.y + hero.size.height * 0.75),
            dx: side * 0.1 * CGFloat(index), rise: side * 0.4, size: side * (0.14 + 0.04 * CGFloat(index)),
            delay: 0.5 + Double(index) * 0.7, z: z, in: parent)
        }
      } else {
        hero.run(
          .sequence([pose(poses.happy), .wait(forDuration: seconds), pose(poses.normal)]),
          withKey: "use")
      }
    case .study:
      // つくえに むかって、こくこく。ほしが ひとつ のぼる。
      hero.run(
        .sequence([
          nod(), nod(), .wait(forDuration: 0.3), pose(poses.happy), hop(0.08),
          .wait(forDuration: seconds - 1.6), pose(poses.normal),
        ]), withKey: "use")
      floatMark(
        "★", color: UIColor(red: 1, green: 0.8, blue: 0.25, alpha: 1), from: top, dx: 0,
        rise: side * 0.35, size: side * 0.22, delay: 0.6, z: z, in: parent)
    case .look:
      // とけいが ちくたく ゆれる。主人公は見上げて、よろこぶ。
      let tick = SKAction.sequence([
        .rotate(toAngle: 0.1, duration: 0.2), .rotate(toAngle: -0.1, duration: 0.4),
        .rotate(toAngle: 0, duration: 0.2),
      ])
      tick.timingMode = .easeInEaseOut
      thing.run(.repeat(tick, count: 2), withKey: "wobble")
      hero.run(
        .sequence([
          .wait(forDuration: 0.6), pose(poses.happy), hop(), .wait(forDuration: seconds - 1.4),
          pose(poses.normal),
        ]), withKey: "use")
    case .tidy:
      // ひきだしを あけたように、ぽんと ふくらんで もどる。
      thing.run(
        .sequence([
          .scaleY(to: 0.95, duration: 0.12), .scaleY(to: 1.04, duration: 0.14),
          .scaleY(to: 1, duration: 0.12),
        ]), withKey: "wobble")
      hero.run(
        .sequence([pose(poses.happy), hop(), hop(), .wait(forDuration: seconds - 1.2), pose(poses.normal)]),
        withKey: "use")
    case .wash:
      // あわが のぼる。
      bounce(thing)
      for index in 0..<4 {
        floatPuff(
          from: CGPoint(x: top.x + CGFloat(index % 2 * 2 - 1) * side * 0.16, y: top.y - side * 0.1),
          radius: side * (0.06 + 0.02 * CGFloat(index % 3)), rise: side * 0.6,
          delay: Double(index) * 0.3, stroke: true, z: z, in: parent)
      }
      hero.run(
        .sequence([pose(poses.happy), hop(), .wait(forDuration: seconds - 0.8), pose(poses.normal)]),
        withKey: "use")
    case .groom:
      // しゃかしゃか: 物が 左右に ゆれて、主人公の頭の上で きらきら。
      let shake = SKAction.sequence([
        .moveBy(x: side * 0.06, y: 0, duration: 0.08), .moveBy(x: -side * 0.12, y: 0, duration: 0.16),
        .moveBy(x: side * 0.06, y: 0, duration: 0.08),
      ])
      thing.run(.repeat(shake, count: 3), withKey: "wobble")
      hero.run(
        .sequence([.wait(forDuration: 0.9), pose(poses.happy), hop(), .wait(forDuration: seconds - 1.7), pose(poses.normal)]),
        withKey: "use")
      for index in 0..<3 {
        floatMark(
          "✦", color: UIColor(red: 1, green: 0.82, blue: 0.3, alpha: 1),
          from: CGPoint(x: hero.position.x, y: hero.position.y + hero.size.height * 0.85),
          dx: CGFloat(index - 1) * hero.size.width * 0.3, rise: hero.size.height * 0.12,
          size: side * 0.2, delay: 0.9 + Double(index) * 0.15, z: z, in: parent)
      }
    case .mirror:
      // かがみに てを ふる。かがみが きらっと ひかる。
      let glint = SKShapeNode(ellipseOf: CGSize(width: side * 0.5, height: side * 0.62))
      glint.fillColor = .white
      glint.strokeColor = .clear
      glint.alpha = 0
      glint.position = point(in: thing, x: content.midX, yFromTop: content.midY)
      glint.zPosition = thing.zPosition + 0.5
      parent.addChild(glint)
      glint.run(
        .sequence([
          .wait(forDuration: 0.4), .fadeAlpha(to: 0.55, duration: 0.2), .fadeOut(withDuration: 0.5),
          .removeFromParent(),
        ]))
      hero.run(
        .sequence([pose(poses.wave), hop(0.06), .wait(forDuration: seconds - 0.6), pose(poses.normal)]),
        withKey: "use")
    }
  }

  private static func floatMark(
    _ text: String, color: UIColor, from point: CGPoint, dx: CGFloat, rise: CGFloat, size: CGFloat,
    delay: TimeInterval, z: CGFloat, in parent: SKNode
  ) {
    let mark = SKLabelNode(text: text)
    mark.fontName = "AvenirNext-Heavy"
    mark.fontSize = max(size, 12)
    mark.fontColor = color
    mark.verticalAlignmentMode = .center
    mark.position = CGPoint(x: point.x + dx * 0.4, y: point.y)
    mark.alpha = 0
    mark.zPosition = z
    parent.addChild(mark)
    mark.run(
      .sequence([
        .wait(forDuration: delay),
        .group([
          .sequence([.fadeIn(withDuration: 0.2), .wait(forDuration: 0.7), .fadeOut(withDuration: 0.4)]),
          .moveBy(x: dx * 0.6, y: rise, duration: 1.3),
        ]),
        .removeFromParent(),
      ]))
  }

  /// ゆげ（線なしの白い丸）・あわ（線のある丸）が のぼって消える。
  private static func floatPuff(
    from point: CGPoint, radius: CGFloat, rise: CGFloat, delay: TimeInterval, stroke: Bool,
    z: CGFloat, in parent: SKNode
  ) {
    let puff = SKShapeNode(circleOfRadius: max(radius, 3))
    puff.fillColor = stroke ? UIColor(red: 0.85, green: 0.95, blue: 1, alpha: 0.85) : .white
    puff.strokeColor = stroke ? outline : .clear
    puff.lineWidth = stroke ? 2 : 0
    puff.position = point
    puff.alpha = 0
    puff.zPosition = z
    parent.addChild(puff)
    puff.run(
      .sequence([
        .wait(forDuration: delay),
        .group([
          .sequence([.fadeAlpha(to: 0.9, duration: 0.2), .wait(forDuration: 0.6), .fadeOut(withDuration: 0.5)]),
          .moveBy(x: radius * 0.6, y: rise, duration: 1.3),
          .scale(to: 1.4, duration: 1.3),
        ]),
        .removeFromParent(),
      ]))
  }
}
