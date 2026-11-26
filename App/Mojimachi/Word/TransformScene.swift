import ContentModel
import PracticeKit
import SpriteKit
import UIKit

/// 変身の演出（D43・D55・D110 の試作）。子どもの線が粒になって浮き上がり、物の形に集まって物になり、走りだす。
/// 絵は仮（SF Symbols）。動きの型は3つ: 乗り物＝走る、四つ足の動物＝歩いてはねる、服＝ハンガーで揺れる（D53・D110）。
final class TransformScene: SKScene {
  private let lines: [[CGPoint]]
  private let objectImage: UIImage
  private let colors: [UIColor]
  private let kind: WordKind
  private let word: String
  var onFinished: (() -> Void)?

  /// - Parameter lines: 子どもが書いた線（このシーンの座標。左上が原点）。`colors` は線ごとの書いたときの色（D88）。
  init(
    size: CGSize, lines: [[CGPoint]], colors: [UIColor], objectImage: UIImage, kind: WordKind,
    word: String
  ) {
    self.kind = kind
    self.word = word
    self.lines = lines
    self.objectImage = objectImage
    self.colors = colors
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
    let targets = WordArt.targetPoints(in: objectImage, count: 300).map {
      sceneTop(
        CGPoint(
          x: objectOrigin.x + $0.x * objectSide / objectImage.size.width,
          y: objectOrigin.y + $0.y * objectSide / objectImage.size.height))
    }
    SoundPlayer.shared.play(.gather)
    let sources = sampledInk(count: max(targets.count, 1))
    let texture = dotTexture()
    for (i, source) in sources.enumerated() {
      let dot = SKSpriteNode(texture: texture)
      dot.color = source.color
      dot.colorBlendFactor = 1
      dot.setScale(0.6)
      dot.position = sceneTop(source.point)
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
          // 物ができたら「ぽよっ」。そのあと、ことばの音（鳴き声・乗り物・服）。
          SoundPlayer.shared.play(.appear)
        },
        .wait(forDuration: 0.4),
        .run { [weak self] in
          guard let self else { return }
          SoundPlayer.shared.play(.word(self.word))
          self.move(object)
        },
      ]))
  }

  private func move(_ object: SKNode) {
    switch kind {
    case .vehicle: drive(object)
    case .animal: walk(object)
    case .clothes: sway(object)
    case .flyer: fly(object)
    case .scenery: settle(object)
    case .swimmer: swim(object)
    case .sky: rise(object)
    }
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

  /// 四つ足の動物の型: ぴょんぴょんはずんで歩き、たちどまって、向きを変えて戻る。
  private func walk(_ object: SKNode) {
    if WordCatalog.crawls(word) {
      crawl(object)
      return
    }
    let hop = SKAction.group([
      .sequence([.moveBy(x: 0, y: 26, duration: 0.14), .moveBy(x: 0, y: -26, duration: 0.14)]),
      .sequence([.rotate(toAngle: 0.08, duration: 0.14), .rotate(toAngle: -0.05, duration: 0.14)]),
    ])
    let step = size.width * 0.12
    func trot(_ direction: CGFloat) -> SKAction {
      .group([
        .repeat(hop, count: 3),
        .moveBy(x: direction * step, y: 0, duration: 0.84),
      ])
    }
    let stop = SKAction.group([.rotate(toAngle: 0, duration: 0.1), .wait(forDuration: 0.5)])
    // 向きは、左右を反転して変える（スケールの符号）。
    let turn = SKAction.sequence([.scaleX(to: -1, duration: 0.12)])
    let turnBack = SKAction.sequence([.scaleX(to: 1, duration: 0.12)])
    object.run(
      .sequence([trot(1), stop, trot(1), stop, turn, trot(-1), stop, turnBack, trot(-1)])
    ) { [weak self] in
      object.zRotation = 0
      self?.onFinished?()
    }
  }

  /// はう物（かたつむり・てんとうむし・かぶとむし）: はずまず、ゆらゆら ゆっくり進む（D169）。
  private func crawl(_ object: SKNode) {
    let sway = SKAction.sequence([
      .rotate(toAngle: 0.04, duration: 0.4), .rotate(toAngle: -0.04, duration: 0.4),
    ])
    let step = size.width * 0.05
    func go(_ direction: CGFloat) -> SKAction {
      .group([.repeat(sway, count: 2), .moveBy(x: direction * step, y: 0, duration: 1.6)])
    }
    let stop = SKAction.group([.rotate(toAngle: 0, duration: 0.1), .wait(forDuration: 0.4)])
    let turn = SKAction.sequence([.scaleX(to: -1, duration: 0.12)])
    let turnBack = SKAction.sequence([.scaleX(to: 1, duration: 0.12)])
    object.run(.sequence([go(1), stop, go(1), stop, turn, go(-1), stop, turnBack, go(-1)])) {
      [weak self] in
      object.zRotation = 0
      self?.onFinished?()
    }
  }

  /// 服の型: ハンガーにかかって、ゆらゆら揺れる（クローゼットの試作。D53）。
  private func sway(_ object: SKNode) {
    guard let sprite = object as? SKSpriteNode else { return }
    // 上の端を支点にして吊るす。
    let top = sprite.position.y + sprite.size.height * 0.42
    sprite.anchorPoint = CGPoint(x: 0.5, y: 0.92)
    sprite.position = CGPoint(x: sprite.position.x, y: top)
    let rail = SKShapeNode(
      rect: CGRect(x: size.width * 0.15, y: top + 28, width: size.width * 0.7, height: 6),
      cornerRadius: 3)
    rail.fillColor = UIColor(red: 0.55, green: 0.38, blue: 0.22, alpha: 1)
    rail.strokeColor = .clear
    rail.alpha = 0
    addChild(rail)
    let hook = SKShapeNode(rect: CGRect(x: -2, y: 0, width: 4, height: 30))
    hook.fillColor = UIColor.gray
    hook.strokeColor = .clear
    hook.position = CGPoint(x: sprite.position.x, y: top)
    hook.alpha = 0
    addChild(hook)
    rail.run(.fadeIn(withDuration: 0.2))
    hook.run(.fadeIn(withDuration: 0.2))
    let swing = SKAction.sequence([
      .rotate(toAngle: 0.22, duration: 0.5), .rotate(toAngle: -0.22, duration: 1.0),
      .rotate(toAngle: 0.12, duration: 0.8), .rotate(toAngle: -0.06, duration: 0.7),
      .rotate(toAngle: 0, duration: 0.5),
    ])
    // 揺れは続けるが、ボタンは3秒ほどで出す。
    sprite.run(.repeatForever(swing))
    run(.wait(forDuration: 3)) { [weak self] in self?.onFinished?() }
  }

  /// 空を飛ぶ物の型: はばたき（またはすべり）ながら上へ飛んでいき、また横から すーっと戻ってきて、ふわふわ浮かぶ（D168）。
  private func fly(_ object: SKNode) {
    let home = object.position
    let style = WordArt.flyerStyle(word)
    let reduce = UIAccessibility.isReduceMotionEnabled
    if reduce {
      let bob = SKAction.sequence([
        .moveBy(x: 0, y: 6, duration: 1.2), .moveBy(x: 0, y: -6, duration: 1.2),
      ])
      object.run(.repeatForever(bob))
      run(.wait(forDuration: 2)) { [weak self] in self?.onFinished?() }
      return
    }
    let flap: SKAction
    switch style {
    case .bird:
      flap = .repeatForever(
        .sequence([
          .group([.scaleY(to: 0.86, duration: 0.14), .rotate(toAngle: 0.1, duration: 0.14)]),
          .group([.scaleY(to: 1.0, duration: 0.14), .rotate(toAngle: -0.1, duration: 0.14)]),
        ]))
    case .plane:
      flap = .rotate(toAngle: 0.18, duration: 0.4)
    case .balloon:
      flap = .repeatForever(
        .sequence([.rotate(toAngle: 0.05, duration: 0.8), .rotate(toAngle: -0.05, duration: 0.8)]))
    }
    object.run(flap, withKey: "flap")
    let away = CGPoint(x: size.width * 1.2, y: size.height * 1.15)
    let out = SKAction.group([
      .move(to: away, duration: style == .balloon ? 2.0 : 1.2), .scale(to: 0.5, duration: 1.2),
    ])
    out.timingMode = .easeIn
    let back = SKAction.group([
      .move(to: home, duration: style == .balloon ? 2.0 : 1.4), .scale(to: 1, duration: 1.4),
    ])
    back.timingMode = .easeOut
    let hover = SKAction.sequence([
      .moveBy(x: 0, y: 14, duration: 0.9), .moveBy(x: 0, y: -14, duration: 0.9),
    ])
    object.run(
      .sequence([
        .wait(forDuration: 0.2), out,
        .move(to: CGPoint(x: -size.width * 0.2, y: size.height * 0.8), duration: 0),
        back, .repeatForever(hover),
      ]), withKey: "fly")
    run(.wait(forDuration: 3.4)) { [weak self] in self?.onFinished?() }
  }

  /// 空を変える物の型: 背景の空が、そのことばの空に変わり、絵が空へふわっと浮かびあがる（D172）。
  private func rise(_ object: SKNode) {
    let reduce = UIAccessibility.isReduceMotionEnabled
    let effect = SkyWeather.effect(for: word) ?? .cloudy
    let layers = SkyFX.make(effect, size: size, reduceMotion: reduce, showsMain: false)
    // 絵と粒より奥。空は ゆっくり うつりかわる。
    layers.back.position = CGPoint(x: size.width / 2, y: size.height / 2)
    layers.back.zPosition = -50
    layers.back.alpha = 0
    addChild(layers.back)
    layers.back.run(.fadeIn(withDuration: reduce ? 0.8 : 1.0))
    object.zPosition = 10
    // 絵が少し上へ昇って、小さくなって、空にういている。
    let rise = SKAction.group([
      .moveBy(x: 0, y: size.height * 0.08, duration: reduce ? 0.6 : 1.1),
      .scale(to: 0.85, duration: reduce ? 0.6 : 1.1),
    ])
    rise.timingMode = .easeOut
    if reduce {
      object.run(rise)
    } else {
      let bob = SKAction.sequence([
        .moveBy(x: 0, y: 10, duration: 1.0), .moveBy(x: 0, y: -10, duration: 1.0),
      ])
      bob.timingMode = .easeInEaseOut
      object.run(.sequence([rise, .repeatForever(bob)]))
    }
    run(.wait(forDuration: 3.4)) { [weak self] in self?.onFinished?() }
  }

  /// 水の生きものの型: 水のなみの上で、その子らしく泳ぐ・ういている（D170）。
  private func swim(_ object: SKNode) {
    guard let sprite = object as? SKSpriteNode else { return }
    let reduce = UIAccessibility.isReduceMotionEnabled
    let style = WordArt.swimStyle(word)
    // 足もとに、うすい水の まるいなみ。
    let pool = SKShapeNode(
      ellipseOf: CGSize(width: sprite.size.width * 1.3, height: sprite.size.height * 0.28))
    pool.fillColor = UIColor(red: 0.45, green: 0.77, blue: 0.95, alpha: 0.55)
    pool.strokeColor = UIColor(white: 1, alpha: 0.8)
    pool.lineWidth = 4
    pool.position = CGPoint(x: sprite.position.x, y: sprite.position.y - sprite.size.height * 0.42)
    pool.zPosition = sprite.zPosition - 1
    pool.alpha = 0
    addChild(pool)
    pool.run(.fadeIn(withDuration: 0.25))
    if !reduce {
      pool.run(
        .repeatForever(
          .sequence([.scaleX(to: 1.08, duration: 1.0), .scaleX(to: 0.94, duration: 1.0)])))
    }
    let h = size.height
    let step = size.width * 0.1
    func bob(_ amplitude: CGFloat, _ period: Double) -> SKAction {
      let up = SKAction.moveBy(x: 0, y: amplitude, duration: period / 2)
      up.timingMode = .easeInEaseOut
      return .repeatForever(.sequence([up, up.reversed()]))
    }
    func sail(_ speed: Double) -> SKAction {
      .sequence([
        .moveBy(x: step, y: 0, duration: speed), .scaleX(to: -1, duration: 0.15),
        .moveBy(x: -step * 2, y: 0, duration: speed * 2), .scaleX(to: 1, duration: 0.15),
        .moveBy(x: step, y: 0, duration: speed),
      ])
    }
    if reduce {
      sprite.run(bob(h * 0.01, 2.4))
    } else {
      switch style {
      case .fish, .dolphin, .whale, .turtle, .tadpole:
        sprite.run(bob(h * (style == .dolphin ? 0.04 : 0.02), style == .whale ? 2.6 : 1.4))
        sprite.run(sail(style == .whale || style == .turtle ? 1.4 : 0.9))
        let wag = SKAction.sequence([
          .rotate(toAngle: style == .dolphin ? 0.25 : 0.08, duration: 0.4),
          .rotate(toAngle: style == .dolphin ? -0.25 : -0.08, duration: 0.4),
        ])
        sprite.run(.repeatForever(wag))
      case .jelly:
        sprite.run(bob(h * 0.05, 2.2))
        sprite.run(
          .repeatForever(
            .sequence([
              .group([.scaleY(to: 0.86, duration: 0.5), .scaleX(to: 1.08, duration: 0.5)]),
              .group([.scaleY(to: 1.06, duration: 0.7), .scaleX(to: 0.96, duration: 0.7)]),
            ])))
      case .bob:
        sprite.run(bob(h * 0.035, 1.8))
        sprite.run(
          .repeatForever(
            .sequence([
              .group([.scaleY(to: 0.92, duration: 0.9), .scaleX(to: 1.05, duration: 0.9)]),
              .group([.scaleY(to: 1.0, duration: 0.9), .scaleX(to: 1.0, duration: 0.9)]),
            ])))
      case .crab:
        let scuttle = SKAction.repeat(
          .sequence([.moveBy(x: 0, y: 8, duration: 0.1), .moveBy(x: 0, y: -8, duration: 0.1)]),
          count: 12)
        sprite.run(
          .group([
            scuttle,
            .sequence([
              .moveBy(x: step, y: 0, duration: 1.2), .moveBy(x: -step * 2, y: 0, duration: 2.4),
              .moveBy(x: step, y: 0, duration: 1.2),
            ]),
          ]))
      case .star:
        sprite.run(
          .repeatForever(
            .sequence([
              .rotate(toAngle: 0.2, duration: 1.2), .rotate(toAngle: -0.2, duration: 2.4),
              .rotate(toAngle: 0, duration: 1.2),
            ])))
        sprite.run(bob(h * 0.012, 2.4))
      case .frog:
        let hop = SKAction.sequence([
          .moveBy(x: step * 0.3, y: h * 0.06, duration: 0.25),
          .moveBy(x: step * 0.3, y: -h * 0.06, duration: 0.25), .wait(forDuration: 0.5),
        ])
        sprite.run(
          .sequence([
            .repeat(hop, count: 3), .scaleX(to: -1, duration: 0.15),
            .repeat(
              .sequence([
                .moveBy(x: -step * 0.6, y: h * 0.06, duration: 0.25),
                .moveBy(x: -step * 0.6, y: -h * 0.06, duration: 0.25),
                .wait(forDuration: 0.5),
              ]), count: 3),
          ]))
      }
    }
    run(.wait(forDuration: 3.4)) { [weak self] in self?.onFinished?() }
  }

  /// 景色になる物の型: 花はそよかぜでゆれる。くだもの・やさいは ぽんと出て、ひとはずみして止まる（D168）。
  private func settle(_ object: SKNode) {
    guard let sprite = object as? SKSpriteNode else { return }
    let reduce = UIAccessibility.isReduceMotionEnabled
    // 足もとを支点にする。
    let base = sprite.position.y - sprite.size.height / 2
    sprite.anchorPoint = CGPoint(x: 0.5, y: 0)
    sprite.position = CGPoint(x: sprite.position.x, y: base)
    if WordArt.isFlower(word) {
      let sway = SKAction.sequence([
        .rotate(toAngle: reduce ? 0.02 : 0.07, duration: 1.0),
        .rotate(toAngle: reduce ? -0.02 : -0.07, duration: 2.0),
        .rotate(toAngle: 0, duration: 1.0),
      ])
      sway.timingMode = .easeInEaseOut
      if !reduce {
        sprite.setScale(0.6)
        sprite.run(.scale(to: 1, duration: 0.35))
      }
      sprite.run(.repeatForever(sway))
    } else if !reduce {
      sprite.setScale(0.5)
      let pop = SKAction.sequence([
        .scale(to: 1.2, duration: 0.2), .scale(to: 0.94, duration: 0.12),
        .scale(to: 1.0, duration: 0.1),
      ])
      let hop = SKAction.sequence([
        .moveBy(x: 0, y: 40, duration: 0.22), .moveBy(x: 0, y: -40, duration: 0.22),
        .moveBy(x: 0, y: 14, duration: 0.12), .moveBy(x: 0, y: -14, duration: 0.12),
      ])
      sprite.run(.group([pop, hop]))
    }
    run(.wait(forDuration: 2.5)) { [weak self] in self?.onFinished?() }
  }

  /// 子どもの線から、粒の出発点を同じ間かくで取る。
  private func sampledInk(count: Int) -> [(point: CGPoint, color: UIColor)] {
    let all = lines.enumerated().flatMap { index, line in
      line.map { (point: $0, color: colors.indices.contains(index) ? colors[index] : .black) }
    }
    guard !all.isEmpty else {
      return [(CGPoint(x: size.width / 2, y: size.height / 2), UIColor.black)]
    }
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
