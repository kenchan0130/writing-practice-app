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
  /// こうえんの物を使って遊ぶキャラクター（D173）。
  private let character: MainCharacter
  var onFinished: (() -> Void)?

  /// - Parameter lines: 子どもが書いた線（このシーンの座標。左上が原点）。`colors` は線ごとの書いたときの色（D88）。
  init(
    size: CGSize, lines: [[CGPoint]], colors: [UIColor], objectImage: UIImage, kind: WordKind,
    word: String, character: MainCharacter = .ton
  ) {
    self.character = character
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
    case .plaything: play(object)
    case .bodyAction: show(object)
    case .furniture: furnish(object)
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

  /// こうえんの物の型: 芝生のこうえんで、物が その物らしく使われ、主人公が よろこんで そばで はずむ（D173）。
  private func play(_ object: SKNode) {
    guard let sprite = object as? SKSpriteNode else { return }
    let reduce = UIAccessibility.isReduceMotionEnabled
    let h = size.height
    let w = size.width
    // 背景: 芝生の丘・小道・花・さく。絵と粒より奥。
    let park = SKNode()
    park.zPosition = -50
    park.alpha = 0
    // 空: 全体をおおう（下の書く場所の枠が すけて見えないように）。
    let sky = SKShapeNode(rect: CGRect(origin: .zero, size: size))
    sky.fillColor = UIColor(red: 0.8, green: 0.92, blue: 1, alpha: 1)
    sky.strokeColor = .clear
    sky.zPosition = -1
    park.addChild(sky)
    let far = SKShapeNode(ellipseOf: CGSize(width: w * 1.5, height: h * 0.8))
    far.fillColor = UIColor(red: 0.74, green: 0.89, blue: 0.72, alpha: 1)
    far.strokeColor = .clear
    far.position = CGPoint(x: w * 0.3, y: -h * 0.02)
    park.addChild(far)
    let lawn = SKShapeNode(ellipseOf: CGSize(width: w * 1.6, height: h * 0.74))
    lawn.fillColor = UIColor(red: 0.6, green: 0.85, blue: 0.42, alpha: 1)
    lawn.strokeColor = .clear
    lawn.position = CGPoint(x: w * 0.55, y: -h * 0.16)
    lawn.zPosition = 1
    park.addChild(lawn)
    let walk = SKShapeNode(ellipseOf: CGSize(width: w * 1.3, height: h * 0.2))
    walk.fillColor = UIColor(red: 0.89, green: 0.8, blue: 0.64, alpha: 1)
    walk.strokeColor = .clear
    walk.position = CGPoint(x: w * 0.5, y: h * 0.04)
    walk.zPosition = 2
    park.addChild(walk)
    let flowerColors = [
      UIColor(red: 1, green: 0.62, blue: 0.7, alpha: 1), UIColor(red: 1, green: 0.88, blue: 0.4, alpha: 1),
      UIColor.white,
    ]
    for index in 0..<9 {
      let flower = SKShapeNode(circleOfRadius: 7)
      flower.fillColor = flowerColors[index % 3]
      flower.strokeColor = UIColor(red: 0.29, green: 0.204, blue: 0.157, alpha: 1)
      flower.lineWidth = 2.5
      flower.position = CGPoint(
        x: w * (0.08 + CGFloat((index * 37) % 84) / 100), y: h * (0.2 + CGFloat((index * 29) % 18) / 100))
      flower.zPosition = 3
      park.addChild(flower)
    }
    addChild(park)
    park.run(.fadeIn(withDuration: reduce ? 0.3 : 0.6))
    // 物: 足もとを支点にして、すこし左へ。
    let side = sprite.size.height
    let feet = sprite.position.y - side / 2 + side * 0.05
    sprite.anchorPoint = CGPoint(x: 0.5, y: 0.05)
    sprite.position = CGPoint(x: w / 2 - side * 0.2, y: feet)
    sprite.zPosition = 10
    PlayMotion.start(sprite, word: word, phase: 0, reduceMotion: reduce)
    // 主人公: 物の右がわで、よろこんで はずむ。
    if let image = WordArt.image(asset: character.assetName(.happy), size: 320) {
      let hero = SKSpriteNode(texture: SKTexture(image: image))
      hero.size = CGSize(width: side * 0.5, height: side * 0.5)
      hero.anchorPoint = CGPoint(x: 0.5, y: 0.04)
      hero.position = CGPoint(x: sprite.position.x + side * 0.52, y: feet - h * 0.02)
      hero.xScale = -1
      hero.zPosition = 11
      hero.alpha = 0
      addChild(hero)
      hero.run(.sequence([.wait(forDuration: 0.2), .fadeIn(withDuration: 0.2)]))
      if !reduce {
        let up = SKAction.moveBy(x: 0, y: h * 0.07, duration: 0.2)
        up.timingMode = .easeOut
        let down = SKAction.moveBy(x: 0, y: -h * 0.07, duration: 0.22)
        down.timingMode = .easeIn
        hero.run(
          .sequence([
            .wait(forDuration: 0.4), .repeatForever(.sequence([up, down, up, down, .wait(forDuration: 0.8)])),
          ]))
        PlayMotion.react(sprite)
      }
    }
    run(.wait(forDuration: 3.4)) { [weak self] in self?.onFinished?() }
  }

  /// 体のことばの型: あたたかい部屋で、体の絵が すみに小さく出て、主人公が その動きを見せる（D175）。
  /// 部屋は全体をおおうので、下の書く場所の枠が すけない。動きは、間をあけて くりかえす。
  private func show(_ object: SKNode) {
    guard let sprite = object as? SKSpriteNode, let motion = BodyAction.motion(for: word) else {
      run(.wait(forDuration: 2)) { [weak self] in self?.onFinished?() }
      return
    }
    let reduce = UIAccessibility.isReduceMotionEnabled
    let w = size.width
    let h = size.height
    let unit = min(w, h)
    addRoomBackground(reduceMotion: reduce)
    // 体の絵: 左がわに、小さく。ふわふわ ういている。
    let artSide = sprite.size.height * 0.62
    let shrink = SKAction.group([
      .move(to: CGPoint(x: w * 0.27, y: h * 0.56), duration: reduce ? 0.3 : 0.6),
      .scale(to: artSide / max(sprite.size.height, 1), duration: reduce ? 0.3 : 0.6),
    ])
    shrink.timingMode = .easeInEaseOut
    sprite.zPosition = 10
    if reduce {
      sprite.run(shrink)
    } else {
      let bob = SKAction.sequence([
        .moveBy(x: 0, y: 8, duration: 1.1), .moveBy(x: 0, y: -8, duration: 1.1),
      ])
      bob.timingMode = .easeInEaseOut
      sprite.run(.sequence([shrink, .repeatForever(bob)]))
    }
    // 主人公: 右がわの ラグの上に立つ。
    guard let poses = BodyMotionFX.poses(for: character) else {
      run(.wait(forDuration: 2)) { [weak self] in self?.onFinished?() }
      return
    }
    let hero = SKSpriteNode(texture: poses.normal)
    let heroSide = unit * 0.62
    hero.size = CGSize(width: heroSide, height: heroSide)
    hero.anchorPoint = CGPoint(x: 0.5, y: 0.04)
    hero.position = CGPoint(x: w * 0.68, y: h * 0.15)
    hero.zPosition = 11
    hero.alpha = 0
    addChild(hero)
    hero.run(.sequence([.wait(forDuration: 0.5), .fadeIn(withDuration: 0.25)]))
    // はじめの動きのあと、すこし間をあけて くりかえす（動きを減らすときは1回だけ）。
    let seconds = BodyMotionFX.duration(of: motion, reduceMotion: reduce)
    let once = SKAction.run {
      BodyMotionFX.play(motion, hero: hero, poses: poses, reduceMotion: reduce)
    }
    let again = SKAction.sequence([once, .wait(forDuration: seconds + 1.0)])
    run(.sequence([.wait(forDuration: 0.9), reduce ? once : .repeatForever(again)]), withKey: "bodyMotion")
    run(.wait(forDuration: 3.4)) { [weak self] in self?.onFinished?() }
  }

  /// いえの物の型: あたたかい部屋で、物が ラグの よこに置かれ、主人公が それを使う（D185）。
  /// 動きは、いえの なか（`HouseScene`）と同じ `HouseMotion`。間をあけて くりかえす。
  private func furnish(_ object: SKNode) {
    guard let sprite = object as? SKSpriteNode, let use = HouseLayout.use(for: word),
      let poses = HouseMotion.poses(for: character)
    else {
      run(.wait(forDuration: 2)) { [weak self] in self?.onFinished?() }
      return
    }
    let reduce = UIAccessibility.isReduceMotionEnabled
    let w = size.width
    let h = size.height
    let unit = min(w, h)
    addRoomBackground(reduceMotion: reduce)
    // 物: 左がわへ。床の物は床に、棚・壁の物は すこし高いところに。
    let content = WordArt.contentFrame(word: word)
    let spot = HouseLayout.spot(for: word)
    let side = sprite.size.height * (spot == .floor ? 0.8 : 0.6)
    let target: CGPoint
    switch spot {
    case .floor:
      sprite.anchorPoint = CGPoint(x: content.midX, y: 1 - content.maxY)
      sprite.position = CGPoint(
        x: sprite.position.x + (content.midX - 0.5) * sprite.size.width,
        y: sprite.position.y + (0.5 - content.maxY) * sprite.size.height)
      target = CGPoint(x: w * 0.3, y: h * 0.16)
    case .shelf, .wall:
      target = CGPoint(x: w * 0.3, y: h * 0.58)
    }
    let settle = SKAction.group([
      .move(to: target, duration: reduce ? 0.3 : 0.6),
      .scale(to: side / max(sprite.size.height, 1), duration: reduce ? 0.3 : 0.6),
    ])
    settle.timingMode = .easeInEaseOut
    sprite.zPosition = 10
    sprite.run(settle)
    if spot == .shelf {
      // 棚の板（物の下）。
      let board = SKShapeNode(
        rect: CGRect(x: w * 0.12, y: target.y - side * content.height / 2 - unit * 0.03, width: w * 0.36, height: unit * 0.03),
        cornerRadius: unit * 0.01)
      board.fillColor = UIColor(red: 0.95, green: 0.71, blue: 0.42, alpha: 1)
      board.strokeColor = UIColor(red: 0.29, green: 0.204, blue: 0.157, alpha: 1)
      board.lineWidth = 3
      board.zPosition = 9
      board.alpha = 0
      addChild(board)
      board.run(.sequence([.wait(forDuration: 0.3), .fadeIn(withDuration: 0.3)]))
    }
    // 主人公: 右がわの ラグの上に立つ。
    let hero = SKSpriteNode(texture: poses.normal)
    let heroSide = unit * 0.5
    hero.size = CGSize(width: heroSide, height: heroSide)
    hero.anchorPoint = CGPoint(x: 0.5, y: 0.04)
    hero.position = CGPoint(x: w * 0.68, y: h * 0.12)
    hero.xScale = -1
    hero.zPosition = 11
    hero.alpha = 0
    addChild(hero)
    hero.run(.sequence([.wait(forDuration: 0.5), .fadeIn(withDuration: 0.25)]))
    if reduce {
      hero.run(.sequence([.wait(forDuration: 0.8), .setTexture(poses.happy, resize: false)]))
    } else {
      // 物が 置かれてから使う。大きさを決めてからでないと、飾りの場所が ずれる。
      let once = SKAction.run { [weak sprite, weak hero] in
        guard let sprite, let hero else { return }
        HouseMotion.play(use, hero: hero, thing: sprite, poses: poses, content: content)
      }
      let again = SKAction.sequence([once, .wait(forDuration: HouseMotion.duration(of: use) + 1.0)])
      run(.sequence([.wait(forDuration: 1.0), .repeatForever(again)]), withKey: "houseMotion")
    }
    run(.wait(forDuration: 3.4)) { [weak self] in self?.onFinished?() }
  }

  /// 体のことばの変身の背景（D175）: あたたかい部屋のかべ・ゆか・まるいラグ。全体をおおう。絵と粒より奥。
  private func addRoomBackground(reduceMotion: Bool) {
    let w = size.width
    let h = size.height
    let room = SKNode()
    room.zPosition = -50
    room.alpha = 0
    let wall = SKSpriteNode(texture: SKTexture(image: roomGradient()))
    wall.size = size
    wall.position = CGPoint(x: w / 2, y: h / 2)
    wall.zPosition = -1
    room.addChild(wall)
    let floorTop = h * 0.3
    let floor = SKShapeNode(rect: CGRect(x: 0, y: 0, width: w, height: floorTop))
    floor.fillColor = UIColor(red: 0.96, green: 0.8, blue: 0.58, alpha: 1)
    floor.strokeColor = .clear
    room.addChild(floor)
    let trim = SKShapeNode(rect: CGRect(x: 0, y: floorTop, width: w, height: 8))
    trim.fillColor = UIColor(red: 0.88, green: 0.66, blue: 0.44, alpha: 1)
    trim.strokeColor = .clear
    trim.zPosition = 0.2
    room.addChild(trim)
    let rug = SKShapeNode(ellipseOf: CGSize(width: w * 0.5, height: h * 0.2))
    rug.fillColor = UIColor(red: 1, green: 0.78, blue: 0.82, alpha: 1)
    rug.strokeColor = UIColor(red: 1, green: 0.92, blue: 0.94, alpha: 1)
    rug.lineWidth = 8
    rug.position = CGPoint(x: w * 0.68, y: h * 0.14)
    rug.zPosition = 0.5
    room.addChild(rug)
    let hearts = ["♡", "★", "♡"]
    for (index, text) in hearts.enumerated() {
      let mark = SKLabelNode(text: text)
      mark.fontName = "AvenirNext-Bold"
      mark.fontSize = unitFont
      mark.fontColor = UIColor(red: 1, green: 0.85, blue: 0.7, alpha: 1)
      mark.position = CGPoint(
        x: w * (0.1 + 0.34 * CGFloat(index)), y: h * (0.88 - 0.05 * CGFloat(index % 2)))
      mark.zPosition = 0.3
      room.addChild(mark)
    }
    addChild(room)
    room.run(.fadeIn(withDuration: reduceMotion ? 0.2 : 0.4))
  }

  private var unitFont: CGFloat { min(size.width, size.height) * 0.07 }

  private func roomGradient() -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 8, height: 256))
    return renderer.image { context in
      let colors = [
        UIColor(red: 1, green: 0.88, blue: 0.8, alpha: 1).cgColor,
        UIColor(red: 1, green: 0.96, blue: 0.88, alpha: 1).cgColor,
      ]
      guard
        let gradient = CGGradient(
          colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0, 1])
      else { return }
      context.cgContext.drawLinearGradient(
        gradient, start: .zero, end: CGPoint(x: 0, y: 256), options: [])
    }
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

  /// 景色になる物の型: 花・草・木はそよかぜでゆれる。くだもの・やさい・たてもの などは ぽんと出て、ひとはずみして止まる（D168）。
  private func settle(_ object: SKNode) {
    guard let sprite = object as? SKSpriteNode else { return }
    let reduce = UIAccessibility.isReduceMotionEnabled
    // 足もとを支点にする。
    let base = sprite.position.y - sprite.size.height / 2
    sprite.anchorPoint = CGPoint(x: 0.5, y: 0)
    sprite.position = CGPoint(x: sprite.position.x, y: base)
    addSceneryBackground(groundY: base, side: sprite.size.height, reduceMotion: reduce)
    // しんごう・ふみきりは、あかりが かわる（D174）。大きさが縮む前（scale 1）に付ける。
    LampMotion.attach(to: sprite, word: word, reduceMotion: reduce)
    if WordArt.sways(word) {
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

  /// 景色の変身の背景（D174）。空のグラデーション・丘・草。全体をおおうので、下の書く場所の枠が すけない。
  /// `groundY` は物の足もと。草は、足もとが少し草に入る高さにする。絵と粒より奥。
  private func addSceneryBackground(groundY: CGFloat, side: CGFloat, reduceMotion: Bool) {
    let w = size.width
    let background = SKNode()
    background.zPosition = -50
    background.alpha = 0
    let sky = SKSpriteNode(texture: SKTexture(image: skyGradient()))
    sky.size = size
    sky.position = CGPoint(x: w / 2, y: size.height / 2)
    sky.zPosition = -1
    background.addChild(sky)
    let horizon = groundY + side * 0.1
    let far = SKShapeNode(ellipseOf: CGSize(width: w * 1.5, height: (horizon + side * 0.5) * 2))
    far.fillColor = UIColor(red: 0.74, green: 0.89, blue: 0.72, alpha: 1)
    far.strokeColor = .clear
    far.position = CGPoint(x: w * 0.3, y: 0)
    background.addChild(far)
    let near = SKShapeNode(ellipseOf: CGSize(width: w * 1.3, height: (horizon + side * 0.25) * 2))
    near.fillColor = UIColor(red: 0.62, green: 0.83, blue: 0.58, alpha: 1)
    near.strokeColor = .clear
    near.position = CGPoint(x: w * 0.8, y: 0)
    near.zPosition = 0.5
    background.addChild(near)
    let lawn = SKShapeNode(ellipseOf: CGSize(width: w * 1.9, height: horizon * 2))
    lawn.fillColor = UIColor(red: 0.62, green: 0.82, blue: 0.46, alpha: 1)
    lawn.strokeColor = .clear
    lawn.position = CGPoint(x: w / 2, y: 0)
    lawn.zPosition = 1
    background.addChild(lawn)
    addChild(background)
    background.run(.fadeIn(withDuration: reduceMotion ? 0.3 : 0.6))
  }

  private func skyGradient() -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 8, height: 256))
    return renderer.image { context in
      let colors = [
        UIColor(red: 0.74, green: 0.9, blue: 1, alpha: 1).cgColor,
        UIColor(red: 0.96, green: 0.96, blue: 0.9, alpha: 1).cgColor,
      ]
      guard
        let gradient = CGGradient(
          colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0, 1])
      else { return }
      context.cgContext.drawLinearGradient(
        gradient, start: .zero, end: CGPoint(x: 0, y: 256), options: [])
    }
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
