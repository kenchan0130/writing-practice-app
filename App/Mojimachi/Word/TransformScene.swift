import SpriteKit
import UIKit

/// 変身の演出（D43・D55・D110 の試作）。子どもの線が粒になって浮き上がり、物の形に集まって物になり、走りだす。
/// 絵は仮（SF Symbols）。動きの型は「乗り物＝走る」だけ。
final class TransformScene: SKScene {
  private let lines: [[CGPoint]]
  private let objectImage: UIImage
  private let inkColor: UIColor
  var onFinished: (() -> Void)?

  /// - Parameter lines: 子どもが書いた線（このシーンの座標。左上が原点）。
  init(size: CGSize, lines: [[CGPoint]], objectImage: UIImage, inkColor: UIColor) {
    self.lines = lines
    self.objectImage = objectImage
    self.inkColor = inkColor
    super.init(size: size)
    backgroundColor = .clear
    scaleMode = .resizeFill
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func didMove(to view: SKView) {
    view.allowsTransparency = true
    play()
  }

  private func play() {
    let objectSide = min(size.width, size.height) * 0.6
    let objectOrigin = CGPoint(x: (size.width - objectSide) / 2, y: (size.height - objectSide) / 2)
    let targets = PlaceholderArt.targetPoints(in: objectImage, count: 300).map {
      sceneTop(
        CGPoint(
          x: objectOrigin.x + $0.x * objectSide / objectImage.size.width,
          y: objectOrigin.y + $0.y * objectSide / objectImage.size.height))
    }
    let sources = sampledInk(count: max(targets.count, 1))
    let texture = dotTexture()
    for (i, source) in sources.enumerated() {
      let dot = SKSpriteNode(texture: texture)
      dot.color = inkColor
      dot.colorBlendFactor = 1
      dot.setScale(0.6)
      dot.position = sceneTop(source)
      addChild(dot)
      let target = targets.isEmpty ? dot.position : targets[i % targets.count]
      // 浮き上がって、くるくる回りながら物の形に集まる（D43）。
      let lift = SKAction.moveBy(x: 0, y: 20, duration: 0.25)
      lift.timingMode = .easeOut
      let wait = SKAction.wait(forDuration: Double(i % 30) * 0.012)
      let gather = SKAction.move(to: target, duration: 0.8)
      gather.timingMode = .easeInEaseOut
      let spin = SKAction.rotate(byAngle: .pi * 2, duration: 0.8)
      dot.run(.sequence([lift, wait, .group([gather, spin])]))
    }
    // 集まりきったら物にして、粒を消す。
    let object = SKSpriteNode(texture: SKTexture(image: objectImage))
    object.size = CGSize(width: objectSide, height: objectSide)
    object.position = CGPoint(x: size.width / 2, y: size.height / 2)
    object.alpha = 0
    addChild(object)
    run(
      .sequence([
        .wait(forDuration: 1.5),
        .run { [weak self] in
          guard let self else { return }
          for node in self.children where node !== object {
            node.run(.fadeOut(withDuration: 0.25))
          }
          object.run(.fadeIn(withDuration: 0.25))
        },
        .wait(forDuration: 0.4),
        .run { [weak self] in self?.drive(object) },
      ]))
  }

  /// 乗り物の型: はずみながら走る（D110 の型の試作）。
  private func drive(_ object: SKNode) {
    let bounce = SKAction.sequence([
      .moveBy(x: 0, y: 10, duration: 0.15), .moveBy(x: 0, y: -10, duration: 0.15),
    ])
    let run = SKAction.sequence([
      .moveBy(x: size.width * 0.25, y: 0, duration: 0.8),
      .moveBy(x: -size.width * 0.25, y: 0, duration: 0.8),
    ])
    object.run(.group([.repeat(bounce, count: 6), run])) { [weak self] in
      self?.onFinished?()
    }
  }

  /// 子どもの線から、粒の出発点を同じ間かくで取る。
  private func sampledInk(count: Int) -> [CGPoint] {
    let all = lines.flatMap { $0 }
    guard !all.isEmpty else { return [CGPoint(x: size.width / 2, y: size.height / 2)] }
    let stride = max(Double(all.count) / Double(count), 1)
    return (0..<min(count, all.count)).map { all[Int(Double($0) * stride) % all.count] }
  }

  /// 左上が原点の座標を、SpriteKit の座標（左下が原点）にする。
  private func sceneTop(_ p: CGPoint) -> CGPoint { CGPoint(x: p.x, y: size.height - p.y) }

  private func dotTexture() -> SKTexture {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 16, height: 16))
    let image = renderer.image { context in
      UIColor.white.setFill()
      context.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: 16, height: 16))
    }
    return SKTexture(image: image)
  }
}
