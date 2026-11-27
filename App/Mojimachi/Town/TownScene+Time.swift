import PracticeKit
import SpriteKit
import UIKit

/// 時間帯の景色（§3.4・§3.5）。端末の時刻に合わせて、朝・昼・夕方・夜で 空と明るさが変わる。
/// 夜は、星・月・あかりのついた窓。主人公は眠そうにする。演出であって、使えなくする仕組みではない（D17）。
/// 空のことばの空（D172）が出ているあいだは、そちらが勝つ（`setPhaseLighting`）。
extension TownScene {
  private static func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> UIColor {
    UIColor(red: r, green: g, blue: b, alpha: a)
  }

  /// 空の色（上から下へ）と、その位置。地平線は 上から 6割ほどのところ。
  private static func skyColors(_ phase: DayPhase) -> (colors: [UIColor], locations: [CGFloat]) {
    switch phase {
    case .morning:
      ([rgb(0.56, 0.80, 0.99), rgb(0.99, 0.90, 0.84), rgb(1, 0.82, 0.62)], [0, 0.38, 0.64])
    case .day:
      ([rgb(1, 0.96, 0.86), rgb(0.78, 0.91, 1), rgb(0.50, 0.78, 1)], [0, 0.4, 1])
    case .evening:
      (
        [rgb(0.38, 0.36, 0.66), rgb(0.95, 0.55, 0.52), rgb(1, 0.78, 0.40)], [0, 0.36, 0.62]
      )
    case .night:
      ([rgb(0.04, 0.07, 0.24), rgb(0.12, 0.13, 0.38), rgb(0.27, 0.24, 0.54)], [0, 0.34, 0.64])
    }
  }

  @MainActor private static var skyTextures: [DayPhase: SKTexture] = [:]

  private static func skyTexture(_ phase: DayPhase) -> SKTexture {
    if let cached = skyTextures[phase] { return cached }
    let spec = skyColors(phase)
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 4, height: 256))
    let image = renderer.image { context in
      let gradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: spec.colors.map(\.cgColor) as CFArray,
        locations: spec.locations)!
      context.cgContext.drawLinearGradient(
        gradient, start: .zero, end: CGPoint(x: 0, y: 256),
        options: [.drawsAfterEndLocation])
    }
    let texture = SKTexture(image: image)
    skyTextures[phase] = texture
    return texture
  }

  /// 雲の色（時間帯で少し変わる）。
  var cloudColor: UIColor {
    switch phase {
    // 朝・夕方・夜は、丸どうしの重なりが見えないよう、すきとおらない色にする。
    case .morning: Self.rgb(1, 0.97, 0.93)
    case .day: UIColor(white: 1, alpha: 0.95)
    case .evening: Self.rgb(1, 0.84, 0.80)
    case .night: Self.rgb(0.21, 0.23, 0.47)
    }
  }

  /// 空と、太陽（夜は 月と星）。カメラについていき、動かない。原点は画面の真ん中。
  func addPhaseSky() {
    let sky = SKSpriteNode(texture: Self.skyTexture(phase))
    sky.size = size
    sky.zPosition = -100
    cameraNode.addChild(sky)
    let w = size.width
    let h = size.height
    switch phase {
    case .morning:
      // 丘の上に のぼってきた、やわらかい朝の太陽。
      addSun(
        at: CGPoint(x: -w * 0.30, y: h * 0.12), radius: h * 0.055,
        color: Self.rgb(1, 0.90, 0.62), glow: Self.rgb(1, 0.86, 0.66))
    case .day:
      addSun(
        at: CGPoint(x: w * 0.36, y: h * 0.30), radius: h * 0.05,
        color: Self.rgb(1, 0.92, 0.55), glow: Self.rgb(1, 0.92, 0.55))
    case .evening:
      // 丘の向こうへ しずむ、大きな夕日。
      addSun(
        at: CGPoint(x: w * 0.27, y: h * 0.06), radius: h * 0.085,
        color: Self.rgb(1, 0.56, 0.30), glow: Self.rgb(1, 0.70, 0.40))
    case .night:
      addStars()
      addMoon(at: CGPoint(x: w * 0.30, y: h * 0.31), radius: h * 0.06)
    }
  }

  private func addSun(at point: CGPoint, radius: CGFloat, color: UIColor, glow: UIColor) {
    let sun = SKNode()
    sun.position = point
    sun.zPosition = -90
    for (scale, alpha) in [(2.0, 0.22), (1.5, 0.38)] as [(CGFloat, CGFloat)] {
      let disc = SKShapeNode(circleOfRadius: radius * scale)
      disc.fillColor = glow.withAlphaComponent(alpha)
      disc.strokeColor = .clear
      sun.addChild(disc)
    }
    let disc = SKShapeNode(circleOfRadius: radius)
    disc.fillColor = color
    disc.strokeColor = .clear
    sun.addChild(disc)
    cameraNode.addChild(sun)
  }

  private func addMoon(at point: CGPoint, radius: CGFloat) {
    let moon = SKNode()
    moon.position = point
    moon.zPosition = -90
    for (scale, alpha) in [(2.1, 0.10), (1.5, 0.18)] as [(CGFloat, CGFloat)] {
      let halo = SKShapeNode(circleOfRadius: radius * scale)
      halo.fillColor = Self.rgb(1, 0.96, 0.75, alpha)
      halo.strokeColor = .clear
      moon.addChild(halo)
    }
    let disc = SKShapeNode(circleOfRadius: radius)
    disc.fillColor = Self.rgb(1, 0.95, 0.70)
    disc.strokeColor = .clear
    moon.addChild(disc)
    for (dx, dy, r) in [(-0.3, 0.25, 0.2), (0.32, -0.1, 0.15), (-0.05, -0.42, 0.11)]
      as [(CGFloat, CGFloat, CGFloat)]
    {
      let crater = SKShapeNode(circleOfRadius: radius * r)
      crater.fillColor = Self.rgb(0.96, 0.86, 0.55)
      crater.strokeColor = .clear
      crater.position = CGPoint(x: radius * dx, y: radius * dy)
      moon.addChild(crater)
    }
    cameraNode.addChild(moon)
  }

  /// 星（決まった並び）。3つに1つは、ゆっくり またたく（動きを減らすときは止める）。
  private func addStars() {
    let w = size.width
    let h = size.height
    var rng = SeededGenerator(seed: 2026)
    let steady = SKNode()
    steady.zPosition = -95
    cameraNode.addChild(steady)
    for index in 0..<42 {
      let x = CGFloat.random(in: -0.49...0.49, using: &rng) * w
      let y = CGFloat.random(in: 0.02...0.48, using: &rng) * h
      let radius = CGFloat.random(in: 1.6...3.6, using: &rng)
      let star = SKShapeNode(circleOfRadius: radius)
      star.fillColor = index % 5 == 0 ? Self.rgb(1, 0.93, 0.70) : .white
      star.strokeColor = .clear
      star.position = CGPoint(x: x, y: y)
      star.alpha = 0.85
      if index % 3 == 0, !reduceMotion {
        star.zPosition = -95
        let time = 1.2 + Double(index % 4) * 0.4
        star.run(
          .sequence([
            .wait(forDuration: Double(index % 7) * 0.3),
            .repeatForever(
              .sequence([
                .fadeAlpha(to: 0.25, duration: time), .fadeAlpha(to: 0.95, duration: time),
              ])),
          ]))
        cameraNode.addChild(star)
      } else {
        steady.addChild(star)
      }
    }
  }

  /// まち全体にかける うすい色（朝は あたたかく、夕方は だいだい、夜は こん色）。物の手前、空のことばの色（100）の下。
  func addPhaseTint() {
    let color: UIColor
    let alpha: CGFloat
    switch phase {
    case .morning: (color, alpha) = (Self.rgb(1, 0.82, 0.55), 0.07)
    case .day: return
    case .evening: (color, alpha) = (Self.rgb(1, 0.48, 0.22), 0.17)
    case .night: (color, alpha) = (Self.rgb(0.05, 0.08, 0.32), 0.34)
    }
    let tint = SKSpriteNode(color: color, size: CGSize(width: size.width + 4, height: size.height + 4))
    tint.alpha = alpha
    tint.zPosition = 99
    tint.name = "phaseTint"
    tint.userData = ["alpha": alpha]
    cameraNode.addChild(tint)
    phaseTint = tint
  }

  /// ぼんやりした光の絵（真ん中が明るく、まわりへ消える）。
  @MainActor private static var glowTexture: SKTexture = {
    let side: CGFloat = 96
    let image = UIGraphicsImageRenderer(size: CGSize(width: side, height: side)).image { context in
      let colors = [rgb(1, 0.86, 0.42, 0.75), rgb(1, 0.80, 0.35, 0.28), rgb(1, 0.78, 0.3, 0)]
        .map(\.cgColor) as CFArray
      let gradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.4, 1])!
      let center = CGPoint(x: side / 2, y: side / 2)
      context.cgContext.drawRadialGradient(
        gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: side / 2,
        options: [])
    }
    return SKTexture(image: image)
  }()

  /// 夜の窓: あたたかい色の あかりと、まわりへ もれる光。
  /// 光は、夜の うすい色（99）より手前に、足し算で重ねる（暗い色をかけた上からでも明るく見える）。
  /// 前を通る物にも光が当たって見える。
  func lightWindow(_ window: SKShapeNode, side: CGFloat, in world: SKNode) {
    window.fillColor = Self.rgb(1, 0.93, 0.50)
    let glow = SKSpriteNode(texture: Self.glowTexture)
    glow.size = CGSize(width: side * 4.2, height: side * 4.2)
    glow.position = CGPoint(x: window.position.x + side / 2, y: window.position.y + side / 2)
    glow.blendMode = .add
    glow.zPosition = 99.5
    world.addChild(glow)
    nightLights.append(glow)
    if !reduceMotion, nightLights.count % 2 == 0 {
      // ときどき、ほんの少し ゆらめく。
      let flicker = SKAction.sequence([
        .scale(to: 1.08, duration: 1.6), .scale(to: 0.96, duration: 1.9),
      ])
      flicker.timingMode = .easeInEaseOut
      glow.run(.repeatForever(flicker))
    }
  }

  /// 空のことばの空が出ているあいだは、時間帯の色と あかりを消す（D172）。終わったら もどす。
  func setPhaseLighting(shown: Bool, duration: TimeInterval) {
    if let tint = phaseTint {
      let alpha = shown ? (tint.userData?["alpha"] as? CGFloat ?? 0) : 0
      tint.removeAction(forKey: "phase")
      tint.run(.fadeAlpha(to: alpha, duration: max(duration, 0.01)), withKey: "phase")
    }
    for light in nightLights {
      light.removeAction(forKey: "phase")
      light.run(.fadeAlpha(to: shown ? 1 : 0, duration: max(duration, 0.01)), withKey: "phase")
    }
  }

  /// まちを開いているあいだに時間帯が変わったら、作り直す（30秒ごとに見る）。
  func watchPhase() {
    removeAction(forKey: "watchPhase")
    run(
      .repeatForever(
        .sequence([
          .wait(forDuration: 30),
          .run { [weak self] in
            guard let self, TownClock.phase() != self.phase else { return }
            self.refreshForPhase()
          },
        ])), withKey: "watchPhase")
  }

  // MARK: 夜の主人公

  /// うとうと: ゆっくり前に かたむいて、もどる。
  static func doze(seconds: Double) -> SKAction {
    let nod = SKAction.sequence([
      .rotate(toAngle: -0.07, duration: 1.0), .rotate(toAngle: 0.02, duration: 1.1),
    ])
    nod.timingMode = .easeInEaseOut
    return .sequence([
      .repeat(nod, count: max(Int(seconds / 2.1), 1)), .rotate(toAngle: 0, duration: 0.2),
    ])
  }

  /// 夜、こうえんに主人公がいないときは、まちの左がわで うとうとする（ときどき目をあける）。
  func addDozer(to world: SKNode, objectSize: CGFloat) {
    guard phase.isSleepy, !hasPlayer,
      let sleepImage = WordArt.image(asset: mainCharacter.assetName(.sleep), size: 320),
      let normalImage = WordArt.image(asset: mainCharacter.assetName(.normal), size: 320)
    else { return }
    let sleep = SKTexture(image: sleepImage)
    let normal = SKTexture(image: normalImage)
    let hero = SKSpriteNode(texture: sleep)
    hero.size = CGSize(width: objectSize * 0.95, height: objectSize * 0.95)
    hero.anchorPoint = CGPoint(x: 0.5, y: 0.04)
    hero.position = CGPoint(x: landMinX + size.width * 0.12, y: size.height * 0.30)
    hero.zPosition = 20 - 0.30 * 20 + 0.5
    hero.name = "dozer"
    world.addChild(hero)
    dozerNode = hero
    guard !reduceMotion else { return }
    hero.run(
      .repeatForever(
        .sequence([
          Self.doze(seconds: 6.3),
          .run { [weak hero] in hero?.texture = normal },
          .wait(forDuration: 2.2),
          .run { [weak hero] in hero?.texture = sleep },
        ])))
    // ねいきの「z」が、ふわっと のぼる。
    let spawn = SKAction.run { [weak hero] in
      guard let hero, hero.texture === sleep else { return }
      let z = SKLabelNode(text: "z")
      z.fontName = "ZenMaruGothic-Bold"
      z.fontSize = objectSize * 0.16
      z.fontColor = UIColor(white: 1, alpha: 0.9)
      z.position = CGPoint(x: hero.size.width * 0.28, y: hero.size.height * 0.78)
      z.zPosition = 1
      hero.addChild(z)
      z.run(
        .sequence([
          .group([
            .moveBy(x: hero.size.width * 0.16, y: hero.size.height * 0.34, duration: 1.8),
            .scale(to: 1.5, duration: 1.8),
            .sequence([.wait(forDuration: 1.0), .fadeOut(withDuration: 0.8)]),
          ]),
          .removeFromParent(),
        ]))
    }
    hero.run(.repeatForever(.sequence([.wait(forDuration: 1.3), spawn])), withKey: "zzz")
  }
}
