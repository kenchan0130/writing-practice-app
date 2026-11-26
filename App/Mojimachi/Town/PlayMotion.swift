import SpriteKit
import UIKit

/// こうえんの物が「使われている」ときの小さな動き（D173）。
/// まち（`TownScene`）と、変身のあと（`TransformScene`）で同じ動きを使う。
/// 物の絵（`SKSpriteNode`）の足もとが原点（anchorPoint の y が低い）として動く。
/// 子ノードは、ぶらんこの座るところ・すべりだいのボールと、音符だけ。
@MainActor
enum PlayMotion {
  private static let outline = UIColor(red: 0.29, green: 0.204, blue: 0.157, alpha: 1)

  /// ぶらんこで ゆれる ひもの付け根（絵に対する割合。`Scripts/art/words.py` が出す値）。
  private static let swingPivot = (x: 0.5, yFromTop: 0.1611)
  /// すべりだいの すべる面の曲線（絵に対する割合。上が原点。`Scripts/art/words.py` が出す値）。
  private static let slideCurve: [(x: Double, y: Double)] = [
    (0.3639, 0.3096), (0.5576, 0.3678), (0.6971, 0.6196), (0.8134, 0.763),
  ]
  private static let slideEnd = (x: 0.88, y: 0.763)

  /// 絵の中の位置（左上が原点・0〜1）を、ノードの中の座標にする。
  private static func local(_ node: SKSpriteNode, _ x: Double, _ yFromTop: Double) -> CGPoint {
    CGPoint(
      x: (CGFloat(x) - node.anchorPoint.x) * node.size.width,
      y: (1 - CGFloat(yFromTop) - node.anchorPoint.y) * node.size.height)
  }

  /// その物らしい動きを、ずっと続ける。`phase` は、物ごとに動きをずらす秒数。
  /// 「動きを減らす」がオンなら、止まるか、ごくゆっくり。
  static func start(_ node: SKSpriteNode, word: String, phase: Double, reduceMotion reduce: Bool) {
    let style = WordArt.playStyle(word)
    let h = node.size.height
    func loop(_ actions: [SKAction], key: String = "play") {
      node.run(
        .sequence([.wait(forDuration: phase), .repeatForever(.sequence(actions))]), withKey: key)
    }
    func eased(_ action: SKAction) -> SKAction {
      action.timingMode = .easeInEaseOut
      return action
    }
    switch style {
    case .swing:
      installSwing(node, reduceMotion: reduce, phase: phase)
    case .slide:
      installSlide(node, reduceMotion: reduce, phase: phase)
    case .top:
      // 回る: 左右に すこしかたむき、横にふくらんだり細くなったりして、回って見える。
      guard !reduce else { return }
      loop([
        eased(.group([.rotate(toAngle: 0.1, duration: 0.5), .scaleX(to: 0.82, duration: 0.5)])),
        eased(.group([.rotate(toAngle: -0.1, duration: 0.5), .scaleX(to: 1.0, duration: 0.5)])),
        eased(.group([.rotate(toAngle: 0.1, duration: 0.5), .scaleX(to: 0.82, duration: 0.5)])),
        eased(.group([.rotate(toAngle: 0, duration: 0.5), .scaleX(to: 1.0, duration: 0.5)])),
      ])
    case .kendama:
      // 玉が ぽんと はねあがる。
      guard !reduce else { return }
      loop([
        .wait(forDuration: 1.0),
        eased(.group([.moveBy(x: 0, y: h * 0.12, duration: 0.28), .rotate(toAngle: 0.08, duration: 0.28)])),
        eased(.group([.moveBy(x: 0, y: -h * 0.12, duration: 0.28), .rotate(toAngle: 0, duration: 0.28)])),
        .scaleY(to: 0.94, duration: 0.07), .scaleY(to: 1, duration: 0.1),
      ])
    case .balloon:
      let amount = reduce ? 0.008 : 0.03
      loop([
        eased(.group([.moveBy(x: 0, y: h * amount, duration: reduce ? 3 : 1.6),
          .rotate(toAngle: reduce ? 0.01 : 0.05, duration: reduce ? 3 : 1.6)])),
        eased(.group([.moveBy(x: 0, y: -h * amount, duration: reduce ? 3 : 1.6),
          .rotate(toAngle: reduce ? -0.01 : -0.05, duration: reduce ? 3 : 1.6)])),
      ])
    case .doll:
      guard !reduce else { return }
      loop([
        eased(.rotate(toAngle: 0.07, duration: 0.6)), eased(.rotate(toAngle: -0.07, duration: 1.2)),
        eased(.rotate(toAngle: 0, duration: 0.6)),
      ])
    case .blocks:
      // ときどき、ぐらっとして、もどる。
      guard !reduce else { return }
      loop([
        .wait(forDuration: 2.2),
        .rotate(toAngle: 0.05, duration: 0.12), .rotate(toAngle: -0.05, duration: 0.2),
        .rotate(toAngle: 0.025, duration: 0.15), .rotate(toAngle: 0, duration: 0.12),
      ])
    case .drum, .xylophone:
      guard !reduce else { return }
      let gap = style == .drum ? 0.5 : 0.9
      loop([
        .wait(forDuration: gap),
        .group([.scaleY(to: 0.92, duration: 0.07), .scaleX(to: 1.04, duration: 0.07)]),
        .group([.scaleY(to: 1.0, duration: 0.12), .scaleX(to: 1.0, duration: 0.12)]),
        .wait(forDuration: gap * 0.6),
        .group([.scaleY(to: 0.94, duration: 0.07), .scaleX(to: 1.03, duration: 0.07)]),
        .group([.scaleY(to: 1.0, duration: 0.12), .scaleX(to: 1.0, duration: 0.12)]),
      ])
      addNotes(to: node, phase: phase)
    case .flute:
      guard !reduce else { return }
      loop([
        eased(.rotate(toAngle: 0.1, duration: 0.7)), eased(.rotate(toAngle: -0.06, duration: 0.9)),
        eased(.rotate(toAngle: 0, duration: 0.5)),
      ])
      addNotes(to: node, phase: phase)
    case .bell:
      guard !reduce else { return }
      let shake: [SKAction] = [0.12, -0.12, 0.09, -0.09, 0.05, 0].map {
        .rotate(toAngle: $0, duration: 0.09)
      }
      loop([.wait(forDuration: 1.4)] + shake)
      addNotes(to: node, phase: phase)
    case .rope:
      // 縄が回るたびに ぴょんと とぶ。
      guard !reduce else { return }
      loop([
        .scaleY(to: 0.9, duration: 0.12),
        eased(.group([.moveBy(x: 0, y: h * 0.1, duration: 0.2), .scaleY(to: 1.04, duration: 0.2)])),
        eased(.group([.moveBy(x: 0, y: -h * 0.1, duration: 0.2), .scaleY(to: 1, duration: 0.2)])),
        .wait(forDuration: 0.25),
      ])
    case .bar:
      let angle: CGFloat = reduce ? 0.003 : 0.012
      loop([
        eased(.rotate(toAngle: angle, duration: reduce ? 4 : 1.8)),
        eased(.rotate(toAngle: -angle, duration: reduce ? 4 : 1.8)),
      ])
    case .box:
      // だれかが とびこえたみたいに、ぐっとへこんで、もどる。
      guard !reduce else { return }
      loop([
        .wait(forDuration: 2.6),
        .scaleY(to: 0.93, duration: 0.1),
        eased(.scaleY(to: 1.03, duration: 0.14)), .scaleY(to: 1.0, duration: 0.1),
      ])
    case .sandbox:
      // 砂ほりで すこしゆれる。
      guard !reduce else { return }
      loop([
        .wait(forDuration: 2.0),
        .rotate(toAngle: 0.012, duration: 0.14), .rotate(toAngle: -0.012, duration: 0.2),
        .rotate(toAngle: 0, duration: 0.14),
      ])
    }
  }

  /// キャラクターが使ったときの、物の ひとはずみ（くりかえす動きに足し算するので、相対の動きだけ）。
  static func react(_ node: SKSpriteNode) {
    let h = node.size.height
    let up = SKAction.moveBy(x: 0, y: h * 0.05, duration: 0.12)
    up.timingMode = .easeOut
    let down = SKAction.moveBy(x: 0, y: -h * 0.05, duration: 0.14)
    down.timingMode = .easeIn
    node.run(.sequence([up, down, up, down]), withKey: "react")
  }

  // MARK: ぶらんこ

  /// ぶらんこ: 絵を「わく」だけにして、座るところ（ひも付き）を ゆらす。
  private static func installSwing(_ node: SKSpriteNode, reduceMotion reduce: Bool, phase: Double) {
    guard
      let frame = UIImage(named: "part-burango-frame"), let seat = UIImage(named: "part-burango-seat")
    else { return }
    node.texture = SKTexture(image: rasterized(frame, side: 320))
    let part = SKSpriteNode(texture: SKTexture(image: rasterized(seat, side: 320)))
    part.size = node.size
    part.anchorPoint = CGPoint(x: swingPivot.x, y: 1 - swingPivot.yFromTop)
    part.position = local(node, swingPivot.x, swingPivot.yFromTop)
    part.zPosition = 0.1
    part.name = "seat"
    node.addChild(part)
    let angle: CGFloat = reduce ? 0.03 : 0.2
    let swing = SKAction.sequence([
      .rotate(toAngle: angle, duration: reduce ? 3 : 1.2), .rotate(toAngle: -angle, duration: reduce ? 6 : 2.4),
      .rotate(toAngle: 0, duration: reduce ? 3 : 1.2),
    ])
    swing.timingMode = .easeInEaseOut
    part.run(.sequence([.wait(forDuration: phase), .repeatForever(swing)]))
  }

  // MARK: すべりだい

  /// すべりだい: ボールが ときどき すべりおりる（すべる面の曲線にそって）。
  private static func installSlide(_ node: SKSpriteNode, reduceMotion reduce: Bool, phase: Double) {
    let radius = node.size.width * 0.045
    let ball = SKShapeNode(circleOfRadius: radius)
    ball.fillColor = UIColor(red: 0.9, green: 0.33, blue: 0.29, alpha: 1)
    ball.strokeColor = outline
    ball.lineWidth = 3
    ball.zPosition = 0.2
    let lift = CGPoint(x: 0, y: radius * 1.1)
    func p(_ point: (x: Double, y: Double)) -> CGPoint {
      let q = local(node, point.x, point.y)
      return CGPoint(x: q.x + lift.x, y: q.y + lift.y)
    }
    let c = slideCurve.map(p)
    let path = CGMutablePath()
    path.move(to: c[0])
    path.addCurve(to: c[3], control1: c[1], control2: c[2])
    path.addLine(to: p(slideEnd))
    ball.position = c[0]
    node.addChild(ball)
    if reduce {
      // 止まった絵: ボールは すべる面の おわりに ある。
      ball.position = p(slideEnd)
      return
    }
    ball.alpha = 0
    let roll = SKAction.follow(path, asOffset: false, orientToPath: false, duration: 1.5)
    roll.timingMode = .easeIn
    ball.run(
      .sequence([
        .wait(forDuration: phase),
        .repeatForever(
          .sequence([
            .wait(forDuration: 2.0), .move(to: c[0], duration: 0), .fadeIn(withDuration: 0.1),
            .group([roll, .rotate(byAngle: -.pi * 4, duration: 1.5)]),
            .fadeOut(withDuration: 0.3),
          ])),
      ]))
  }

  // MARK: 音符

  /// 楽器から、音符が ふわっと のぼって 消える。1つの物に1つのノード。
  private static func addNotes(to node: SKSpriteNode, phase: Double) {
    let note = SKLabelNode(text: phase.truncatingRemainder(dividingBy: 2) < 1 ? "♪" : "♫")
    note.fontName = "AvenirNext-Bold"
    note.fontSize = node.size.width * 0.2
    note.fontColor = UIColor(red: 0.93, green: 0.42, blue: 0.5, alpha: 1)
    note.verticalAlignmentMode = .center
    note.zPosition = 0.3
    note.alpha = 0
    let top = local(node, 0.5, 0.15)
    let dx = node.size.width * (phase.truncatingRemainder(dividingBy: 2) < 1 ? 0.28 : -0.28)
    let rise = SKAction.group([
      .sequence([.fadeIn(withDuration: 0.25), .wait(forDuration: 0.9), .fadeOut(withDuration: 0.5)]),
      .moveBy(x: dx * 0.5, y: node.size.height * 0.22, duration: 1.65),
    ])
    note.run(
      .sequence([
        .wait(forDuration: phase),
        .repeatForever(
          .sequence([
            .run { note.position = CGPoint(x: top.x + dx * 0.4, y: top.y) }, rise,
            .wait(forDuration: 1.2),
          ])),
      ]))
    node.addChild(note)
  }

  /// SVG の絵を、決まった大きさの画像にする（`WordArt.image` と同じやり方）。
  private static func rasterized(_ art: UIImage, side: CGFloat) -> UIImage {
    UIGraphicsImageRenderer(size: CGSize(width: side, height: side)).image { _ in
      let s = art.size
      let scale = min(side / max(s.width, 1), side / max(s.height, 1))
      let width = s.width * scale
      let height = s.height * scale
      art.draw(in: CGRect(x: (side - width) / 2, y: (side - height) / 2, width: width, height: height))
    }
  }
}
