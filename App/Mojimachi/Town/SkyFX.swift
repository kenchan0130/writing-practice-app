import PracticeKit
import SpriteKit
import UIKit

/// 空が変わる見せ方（D172）。まちの空と、変身のあとの背景で同じものを使う。
/// 原点は画面の真ん中。`back` は空と、空に出る物すべて（子の zPosition は 0〜10）、`front` は まち全体にかける うすい色。
/// ノードは数十個で、毎フレームの計算はしない（雨・雪だけ SKEmitterNode 1つ）。「動きを減らす」なら動かさない。
@MainActor
enum SkyFX {
  struct Layers {
    let back: SKNode
    let front: SKNode?
  }

  private static let outline = UIColor(red: 0.29, green: 0.204, blue: 0.157, alpha: 1)  // #4a3428
  private static var textures: [String: SKTexture] = [:]

  /// - Parameter showsMain: 太陽・月・虹の大きな絵を出すか。変身のあとの背景では、絵そのものが主役なので出さない。
  static func make(
    _ effect: SkyEffect, size: CGSize, reduceMotion: Bool, showsMain: Bool = true
  ) -> Layers {
    let ctx = Context(size: size, reduce: reduceMotion)
    let back = SKNode()
    var front: SKNode?
    func sky(_ top: UIColor, _ bottom: UIColor, key: String) {
      let node = SKSpriteNode(texture: gradient(top, bottom, key: key), size: size)
      node.zPosition = 0
      back.addChild(node)
    }
    func tint(_ color: UIColor, alpha: CGFloat) {
      let node = SKSpriteNode(color: color, size: size)
      node.alpha = alpha
      front = node
    }
    switch effect {
    case .cloudy:
      sky(rgb(0.62, 0.82, 0.98), rgb(0.93, 0.96, 1), key: "cloudy")
      ctx.drifting(in: back, count: 6, color: .white, speed: 34, scale: 1.5...2.6)
    case .rain:
      sky(rgb(0.52, 0.58, 0.68), rgb(0.78, 0.82, 0.88), key: "rain")
      ctx.drifting(in: back, count: 4, color: rgb(0.7, 0.75, 0.82), speed: 14, scale: 2.0...2.8)
      ctx.rain(in: back, birth: 110)
      tint(rgb(0.2, 0.25, 0.35), alpha: 0.08)
    case .snow:
      sky(rgb(0.76, 0.83, 0.92), rgb(0.93, 0.96, 0.99), key: "snow")
      ctx.drifting(in: back, count: 3, color: rgb(0.95, 0.97, 1), speed: 10, scale: 1.8...2.4)
      ctx.snow(in: back)
    case .thunder:
      sky(rgb(0.36, 0.40, 0.50), rgb(0.62, 0.66, 0.74), key: "thunder")
      ctx.drifting(in: back, count: 4, color: rgb(0.48, 0.52, 0.6), speed: 12, scale: 2.2...3.0)
      ctx.rain(in: back, birth: 45)
      ctx.lightning(in: back)
      tint(rgb(0.15, 0.17, 0.25), alpha: 0.12)
    case .rainbow:
      sky(rgb(0.55, 0.8, 1), rgb(0.95, 0.97, 1), key: "rainbow")
      ctx.drifting(in: back, count: 3, color: .white, speed: 8, scale: 1.2...1.8)
      if showsMain { ctx.rainbow(in: back) }
    case .wind:
      sky(rgb(0.6, 0.82, 1), rgb(0.92, 0.97, 1), key: "wind")
      ctx.drifting(in: back, count: 6, color: .white, speed: 230, scale: 1.2...2.0)
      ctx.windLines(in: back)
      ctx.leaves(in: back)
    case .sun:
      sky(rgb(0.4, 0.72, 1), rgb(1, 0.95, 0.8), key: "sun")
      ctx.drifting(in: back, count: 2, color: .white, speed: 8, scale: 1.1...1.5)
      if showsMain { ctx.sun(in: back) }
    case .stars, .moon, .ufo:
      sky(rgb(0.04, 0.07, 0.24), rgb(0.30, 0.26, 0.56), key: "night")
      ctx.stars(in: back, shooting: effect == .stars)
      if effect == .moon, showsMain { ctx.moon(in: back) }
      if effect == .ufo { ctx.ufo(in: back) }
      tint(rgb(0.08, 0.10, 0.3), alpha: 0.22)
    }
    return Layers(back: back, front: front)
  }

  // MARK: 小さな道具

  private static func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
    UIColor(red: r, green: g, blue: b, alpha: 1)
  }

  private static func gradient(_ top: UIColor, _ bottom: UIColor, key: String) -> SKTexture {
    if let cached = textures[key] { return cached }
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 4, height: 256))
    let image = renderer.image { context in
      let colors = [top, bottom].map(\.cgColor) as CFArray
      let gradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1])!
      context.cgContext.drawLinearGradient(
        gradient, start: .zero, end: CGPoint(x: 0, y: 256), options: [])
    }
    let texture = SKTexture(image: image)
    textures[key] = texture
    return texture
  }

  private static func texture(_ key: String, size: CGSize, _ draw: (CGContext) -> Void) -> SKTexture {
    if let cached = textures[key] { return cached }
    let image = UIGraphicsImageRenderer(size: size).image { draw($0.cgContext) }
    let texture = SKTexture(image: image)
    textures[key] = texture
    return texture
  }

  /// いつも同じ並びになる、かんたんな乱数（絵が毎回ちがうと確かめにくいので）。
  private struct Lcg {
    var state: UInt64
    mutating func next() -> CGFloat {
      state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
      return CGFloat((state >> 33) & 0xFFFF) / 65535
    }
  }

  @MainActor
  private struct Context {
    let size: CGSize
    let reduce: Bool
    var w: CGFloat { size.width }
    var h: CGFloat { size.height }
    var unit: CGFloat { min(size.height, size.width * 0.75) }

    // MARK: 雲

    func cloud(color: UIColor) -> SKNode {
      let cloud = SKNode()
      let puffs: [(CGFloat, CGFloat, CGFloat)] = [(-38, -6, 30), (0, 6, 40), (42, -4, 32), (8, -14, 34)]
      for (dx, dy, r) in puffs {
        let puff = SKShapeNode(circleOfRadius: r)
        puff.fillColor = color
        puff.strokeColor = .clear
        puff.position = CGPoint(x: dx, y: dy)
        cloud.addChild(puff)
      }
      return cloud
    }

    /// 横へ流れる雲。`speed` は 1 秒に進む長さ。「動きを減らす」なら止める。
    func drifting(
      in node: SKNode, count: Int, color: UIColor, speed: CGFloat, scale: ClosedRange<CGFloat>
    ) {
      var rng = Lcg(state: 7)
      let left = -w / 2 - 200
      let right = w / 2 + 200
      for i in 0..<count {
        let cloud = cloud(color: color)
        let s = (scale.lowerBound + (scale.upperBound - scale.lowerBound) * rng.next()) * unit / 1000
        cloud.setScale(s)
        let x = left + (right - left) * (CGFloat(i) + rng.next() * 0.6) / CGFloat(count)
        let y = h * (0.12 + 0.34 * ((CGFloat(i) * 0.37).truncatingRemainder(dividingBy: 1)))
        cloud.position = CGPoint(x: x, y: y)
        cloud.zPosition = 1
        node.addChild(cloud)
        guard !reduce else { continue }
        let first = Double((right - x) / speed)
        cloud.run(
          .sequence([
            .moveTo(x: right, duration: first),
            .repeatForever(
              .sequence([
                .moveTo(x: left, duration: 0),
                .moveTo(x: right, duration: Double((right - left) / speed)),
              ])),
          ]))
      }
    }

    // MARK: 雨・雪

    func rain(in node: SKNode, birth: CGFloat) {
      let streak = SkyFX.texture("streak", size: CGSize(width: 4, height: 30)) { c in
        UIColor.white.setFill()
        UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 4, height: 30), cornerRadius: 2).fill()
      }
      let color = SkyFX.rgb(0.55, 0.74, 0.98)
      if reduce {
        // 止まった雨（1つのノード）。
        var rng = Lcg(state: 11)
        let path = CGMutablePath()
        for _ in 0..<Int(birth * 0.4) {
          let x = (rng.next() - 0.5) * w
          let y = (rng.next() - 0.45) * h
          path.move(to: CGPoint(x: x, y: y))
          path.addLine(to: CGPoint(x: x - 3, y: y - 26))
        }
        let rain = SKShapeNode(path: path)
        rain.strokeColor = color
        rain.alpha = 0.5
        rain.lineWidth = 3
        rain.lineCap = .round
        rain.zPosition = 5
        node.addChild(rain)
        return
      }
      let emitter = SKEmitterNode()
      emitter.particleTexture = streak
      emitter.particleBirthRate = birth
      emitter.particleLifetime = 1.5
      emitter.particlePositionRange = CGVector(dx: w * 1.2, dy: 0)
      emitter.position = CGPoint(x: 0, y: h / 2 + 30)
      emitter.emissionAngle = -.pi / 2 - 0.12
      emitter.particleSpeed = 520
      emitter.particleSpeedRange = 120
      emitter.particleRotation = -0.12
      emitter.particleAlpha = 0.55
      emitter.particleAlphaRange = 0.2
      emitter.particleScale = 0.8
      emitter.particleScaleRange = 0.3
      emitter.particleColor = color
      emitter.particleColorBlendFactor = 1
      emitter.zPosition = 5
      emitter.advanceSimulationTime(1.5)
      node.addChild(emitter)
    }

    func snow(in node: SKNode) {
      let dot = SkyFX.texture("snowdot", size: CGSize(width: 32, height: 32)) { c in
        let colors = [UIColor.white.cgColor, UIColor.white.withAlphaComponent(0).cgColor] as CFArray
        let gradient = CGGradient(
          colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0.55, 1])!
        c.drawRadialGradient(
          gradient, startCenter: CGPoint(x: 16, y: 16), startRadius: 0,
          endCenter: CGPoint(x: 16, y: 16), endRadius: 16, options: [])
      }
      if reduce {
        var rng = Lcg(state: 13)
        for _ in 0..<45 {
          let flake = SKSpriteNode(texture: dot)
          flake.setScale(0.25 + rng.next() * 0.3)
          flake.position = CGPoint(x: (rng.next() - 0.5) * w, y: (rng.next() - 0.45) * h)
          flake.zPosition = 5
          node.addChild(flake)
        }
        return
      }
      let emitter = SKEmitterNode()
      emitter.particleTexture = dot
      emitter.particleBirthRate = 24
      emitter.particleLifetime = 9
      emitter.particlePositionRange = CGVector(dx: w * 1.1, dy: 0)
      emitter.position = CGPoint(x: 0, y: h / 2 + 20)
      emitter.emissionAngle = -.pi / 2
      emitter.emissionAngleRange = 0.5
      emitter.particleSpeed = 55
      emitter.particleSpeedRange = 25
      emitter.particleAlpha = 0.95
      emitter.particleScale = 0.3
      emitter.particleScaleRange = 0.2
      emitter.zPosition = 5
      emitter.advanceSimulationTime(8)
      node.addChild(emitter)
    }

    // MARK: かみなり

    func lightning(in node: SKNode) {
      let u = unit
      let path = UIBezierPath()
      let pts: [(CGFloat, CGFloat)] = [(14, 60), (-24, -2), (0, -2), (-20, -64), (34, 6), (10, 6), (30, 60)]
      for (i, p) in pts.enumerated() {
        let point = CGPoint(x: p.0, y: p.1)
        if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
      }
      path.close()
      let bolt = SKShapeNode(path: path.cgPath)
      bolt.fillColor = SkyFX.rgb(1, 0.85, 0.3)
      bolt.strokeColor = SkyFX.outline
      bolt.lineWidth = 4
      bolt.lineJoin = .round
      bolt.setScale(u / 380)
      bolt.position = CGPoint(x: -w * 0.18, y: h * 0.16)
      bolt.zPosition = 6
      node.addChild(bolt)
      guard !reduce else { return }
      bolt.alpha = 0
      let flash = SKSpriteNode(color: .white, size: size)
      flash.alpha = 0
      flash.zPosition = 7
      node.addChild(flash)
      let once = SKAction.group([
        .sequence([.fadeAlpha(to: 0.28, duration: 0.08), .fadeOut(withDuration: 0.5)]).onNode(flash),
        .sequence([.fadeIn(withDuration: 0.1), .wait(forDuration: 0.5), .fadeOut(withDuration: 0.3)])
          .onNode(bolt),
      ])
      node.run(.sequence([.wait(forDuration: 1.2), .repeatForever(.sequence([once, .wait(forDuration: 3.8)]))]))
    }

    // MARK: にじ

    func rainbow(in node: SKNode) {
      let outer = min(w * 0.36, h * 0.5)
      let band = outer * 0.075
      let colors = [
        SkyFX.rgb(1, 0.42, 0.42), SkyFX.rgb(1, 0.66, 0.34), SkyFX.rgb(1, 0.87, 0.4),
        SkyFX.rgb(0.5, 0.8, 0.45), SkyFX.rgb(0.4, 0.78, 0.9), SkyFX.rgb(0.4, 0.6, 0.92),
        SkyFX.rgb(0.66, 0.5, 0.88),
      ]
      let center = CGPoint(x: 0, y: -h * 0.04)
      let arcs = SKNode()
      arcs.position = center
      arcs.zPosition = 2
      for (i, color) in colors.enumerated() {
        let r = outer - band * (CGFloat(i) + 0.5)
        let path = UIBezierPath(arcCenter: .zero, radius: r, startAngle: 0, endAngle: .pi, clockwise: true)
        let arc = SKShapeNode(path: path.cgPath)
        arc.strokeColor = color
        arc.lineWidth = band + 1
        arc.lineCap = .butt
        arcs.addChild(arc)
      }
      arcs.alpha = 0.92
      node.addChild(arcs)
      if !reduce {
        arcs.run(
          .repeatForever(.sequence([.fadeAlpha(to: 0.78, duration: 2.5), .fadeAlpha(to: 0.95, duration: 2.5)])))
      }
      // 両はしの雲。
      for s in [-1, 1] as [CGFloat] {
        let cloud = cloud(color: .white)
        cloud.setScale(unit / 700 * 1.7)
        cloud.position = CGPoint(x: center.x + s * (outer - band * 3.5), y: center.y + 10)
        cloud.zPosition = 3
        node.addChild(cloud)
      }
    }

    // MARK: かぜ

    func windLines(in node: SKNode) {
      let path = UIBezierPath()
      path.move(to: .zero)
      path.addCurve(to: CGPoint(x: 240, y: 0), controlPoint1: CGPoint(x: 80, y: -22), controlPoint2: CGPoint(x: 160, y: 22))
      path.addCurve(to: CGPoint(x: 276, y: -52), controlPoint1: CGPoint(x: 290, y: -12), controlPoint2: CGPoint(x: 310, y: -42))
      path.addCurve(to: CGPoint(x: 262, y: -34), controlPoint1: CGPoint(x: 252, y: -66), controlPoint2: CGPoint(x: 240, y: -40))
      let left = -w / 2 - 320
      let right = w / 2 + 40
      for i in 0..<3 {
        let line = SKShapeNode(path: path.cgPath)
        line.strokeColor = UIColor(white: 1, alpha: 0.9)
        line.lineWidth = 6
        line.lineCap = .round
        line.setScale(unit / 500 * (1 + CGFloat(i) * 0.15))
        let y = h * (0.1 + 0.14 * CGFloat(i))
        line.zPosition = 4
        node.addChild(line)
        if reduce {
          line.position = CGPoint(x: -w * 0.2 + CGFloat(i) * w * 0.25, y: y)
          continue
        }
        line.position = CGPoint(x: left + CGFloat(i) * w * 0.3, y: y)
        let time = 3.2 + Double(i) * 0.7
        line.run(
          .sequence([
            .wait(forDuration: Double(i) * 0.5),
            .repeatForever(
              .sequence([
                .moveTo(x: left, duration: 0), .moveTo(x: right, duration: time),
              ])),
          ]))
      }
    }

    func leaves(in node: SKNode) {
      guard !reduce else { return }
      var rng = Lcg(state: 5)
      for i in 0..<8 {
        let leaf = SKShapeNode(ellipseOf: CGSize(width: 22, height: 11))
        leaf.fillColor = i % 3 == 0 ? SkyFX.rgb(0.95, 0.7, 0.3) : SkyFX.rgb(0.5, 0.78, 0.4)
        leaf.strokeColor = .clear
        leaf.zPosition = 5
        let y = h * (-0.05 + 0.5 * rng.next())
        let left = -w / 2 - 40
        let right = w / 2 + 40
        leaf.position = CGPoint(x: left - rng.next() * w * 0.5, y: y)
        node.addChild(leaf)
        let time = 3.5 + Double(rng.next()) * 2.5
        leaf.run(
          .sequence([
            .wait(forDuration: Double(i) * 0.4),
            .repeatForever(
              .sequence([.moveTo(x: left, duration: 0), .moveTo(x: right, duration: time)])),
          ]))
        leaf.run(
          .repeatForever(
            .sequence([.moveBy(x: 0, y: 36, duration: 0.7), .moveBy(x: 0, y: -36, duration: 0.7)])))
        leaf.run(.repeatForever(.rotate(byAngle: .pi * 2, duration: 1.3)))
      }
    }

    // MARK: 顔のついた大きなもの

    func face(on node: SKNode, radius r: CGFloat, sleepy: Bool = false) {
      for s in [-1, 1] as [CGFloat] {
        let x = s * r * 0.36
        if sleepy {
          let eye = UIBezierPath()
          eye.move(to: CGPoint(x: x - r * 0.12, y: r * 0.06))
          eye.addQuadCurve(to: CGPoint(x: x + r * 0.12, y: r * 0.06), controlPoint: CGPoint(x: x, y: -r * 0.12))
          let shape = SKShapeNode(path: eye.cgPath)
          shape.strokeColor = SkyFX.outline
          shape.lineWidth = max(r * 0.05, 3)
          shape.lineCap = .round
          shape.zPosition = 3
          node.addChild(shape)
        } else {
          let eye = SKShapeNode(ellipseOf: CGSize(width: r * 0.13, height: r * 0.17))
          eye.fillColor = SkyFX.outline
          eye.strokeColor = .clear
          eye.position = CGPoint(x: x, y: r * 0.08)
          eye.zPosition = 3
          node.addChild(eye)
          let shine = SKShapeNode(circleOfRadius: r * 0.03)
          shine.fillColor = .white
          shine.strokeColor = .clear
          shine.position = CGPoint(x: x + r * 0.03, y: r * 0.13)
          shine.zPosition = 4
          node.addChild(shine)
        }
        let cheek = SKShapeNode(ellipseOf: CGSize(width: r * 0.2, height: r * 0.12))
        cheek.fillColor = UIColor(red: 1, green: 0.6, blue: 0.66, alpha: 0.7)
        cheek.strokeColor = .clear
        cheek.position = CGPoint(x: s * r * 0.62, y: -r * 0.14)
        cheek.zPosition = 3
        node.addChild(cheek)
      }
      let smile = UIBezierPath()
      smile.move(to: CGPoint(x: -r * 0.14, y: -r * 0.2))
      smile.addQuadCurve(to: CGPoint(x: r * 0.14, y: -r * 0.2), controlPoint: CGPoint(x: 0, y: -r * 0.4))
      let mouth = SKShapeNode(path: smile.cgPath)
      mouth.strokeColor = SkyFX.outline
      mouth.lineWidth = max(r * 0.05, 3)
      mouth.lineCap = .round
      mouth.zPosition = 3
      node.addChild(mouth)
    }

    func disc(radius r: CGFloat, fill: UIColor, line: CGFloat = 4) -> SKShapeNode {
      let disc = SKShapeNode(circleOfRadius: r)
      disc.fillColor = fill
      disc.strokeColor = line > 0 ? SkyFX.outline : .clear
      disc.lineWidth = line
      return disc
    }

    func sun(in node: SKNode) {
      let r = unit * 0.14
      let sun = SKNode()
      sun.position = CGPoint(x: w * 0.18, y: h * 0.24)
      sun.zPosition = 3
      let glow = disc(radius: r * 1.9, fill: UIColor(red: 1, green: 1, blue: 0.85, alpha: 0.3), line: 0)
      glow.zPosition = 0
      sun.addChild(glow)
      let path = UIBezierPath()
      for i in 0..<12 {
        let a = CGFloat(i) * .pi / 6
        let ux = cos(a), uy = sin(a)
        let px = -uy, py = ux
        let base = r * 1.0, tip = r * 1.6, half = r * 0.2
        path.move(to: CGPoint(x: ux * base + px * half, y: uy * base + py * half))
        path.addLine(to: CGPoint(x: ux * tip, y: uy * tip))
        path.addLine(to: CGPoint(x: ux * base - px * half, y: uy * base - py * half))
        path.close()
      }
      let rays = SKShapeNode(path: path.cgPath)
      rays.fillColor = SkyFX.rgb(1, 0.72, 0.28)
      rays.strokeColor = SkyFX.outline
      rays.lineWidth = 4
      rays.lineJoin = .round
      rays.zPosition = 1
      sun.addChild(rays)
      if !reduce { rays.run(.repeatForever(.rotate(byAngle: -.pi * 2, duration: 30))) }
      let body = disc(radius: r, fill: SkyFX.rgb(1, 0.86, 0.3))
      body.zPosition = 2
      sun.addChild(body)
      face(on: sun, radius: r)
      node.addChild(sun)
    }

    // MARK: 夜

    func stars(in node: SKNode, shooting: Bool) {
      let star = SkyFX.texture("sparkle", size: CGSize(width: 40, height: 40)) { c in
        UIColor.white.setFill()
        let path = UIBezierPath()
        let m = CGPoint(x: 20, y: 20)
        for i in 0..<8 {
          let a = CGFloat(i) * .pi / 4 - .pi / 2
          let r: CGFloat = i % 2 == 0 ? 19 : 5
          let p = CGPoint(x: m.x + cos(a) * r, y: m.y + sin(a) * r)
          if i == 0 { path.move(to: p) } else { path.addLine(to: p) }
        }
        path.close()
        path.fill()
      }
      var rng = Lcg(state: 3)
      for i in 0..<34 {
        let s = SKSpriteNode(texture: star)
        s.color = i % 4 == 0 ? SkyFX.rgb(1, 0.92, 0.6) : .white
        s.colorBlendFactor = 1
        s.setScale((0.25 + rng.next() * 0.45) * unit / 700)
        s.position = CGPoint(x: (rng.next() - 0.5) * w, y: h * (-0.08 + 0.58 * rng.next()))
        s.zPosition = 1
        s.alpha = 0.85
        node.addChild(s)
        if !reduce {
          let t = 0.8 + Double(rng.next()) * 1.4
          s.run(
            .sequence([
              .wait(forDuration: Double(rng.next()) * 2),
              .repeatForever(.sequence([.fadeAlpha(to: 0.3, duration: t), .fadeAlpha(to: 1, duration: t)])),
            ]))
        }
      }
      guard shooting, !reduce else { return }
      let comet = SKSpriteNode(texture: star)
      comet.setScale(unit / 700 * 0.9)
      comet.alpha = 0
      comet.zPosition = 2
      node.addChild(comet)
      let start = CGPoint(x: w * 0.4, y: h * 0.4)
      comet.run(
        .repeatForever(
          .sequence([
            .wait(forDuration: 3),
            .move(to: start, duration: 0),
            .group([
              .moveBy(x: -w * 0.5, y: -h * 0.22, duration: 1.1),
              .sequence([.fadeIn(withDuration: 0.15), .wait(forDuration: 0.6), .fadeOut(withDuration: 0.35)]),
            ]),
            .wait(forDuration: 4),
          ])))
    }

    func moon(in node: SKNode) {
      let r = unit * 0.15
      let moon = SKNode()
      moon.position = CGPoint(x: w * 0.2, y: h * 0.25)
      moon.zPosition = 3
      for (scale, alpha) in [(2.0, 0.1), (1.5, 0.18)] as [(CGFloat, CGFloat)] {
        let glow = disc(radius: r * scale, fill: UIColor(red: 1, green: 0.95, blue: 0.7, alpha: alpha), line: 0)
        glow.zPosition = 0
        moon.addChild(glow)
      }
      let body = disc(radius: r, fill: SkyFX.rgb(1, 0.94, 0.68))
      body.zPosition = 1
      moon.addChild(body)
      for (dx, dy, k) in [(-0.55, -0.4, 0.16), (0.5, 0.5, 0.11), (0.6, -0.5, 0.09)] as [(CGFloat, CGFloat, CGFloat)] {
        let crater = disc(radius: r * k, fill: SkyFX.rgb(0.96, 0.84, 0.5), line: 0)
        crater.position = CGPoint(x: r * dx, y: r * dy)
        crater.zPosition = 2
        moon.addChild(crater)
      }
      face(on: moon, radius: r, sleepy: true)
      node.addChild(moon)
      if !reduce {
        let up = SKAction.moveBy(x: 0, y: h * 0.012, duration: 2.5)
        up.timingMode = .easeInEaseOut
        moon.run(.repeatForever(.sequence([up, up.reversed()])))
      }
    }

    func ufo(in node: SKNode) {
      let u = unit
      let ufo = SKNode()
      ufo.zPosition = 3
      // 中の うちゅうじん。
      let alien = disc(radius: u * 0.034, fill: SkyFX.rgb(0.58, 0.85, 0.44), line: 3)
      alien.position = CGPoint(x: 0, y: u * 0.05)
      alien.zPosition = 1
      ufo.addChild(alien)
      for s in [-1, 1] as [CGFloat] {
        let eye = SKShapeNode(ellipseOf: CGSize(width: u * 0.016, height: u * 0.022))
        eye.fillColor = SkyFX.outline
        eye.strokeColor = .clear
        eye.position = CGPoint(x: s * u * 0.014, y: 0.01 * u)
        alien.addChild(eye)
        let feeler = SKShapeNode(rect: CGRect(x: -1.5, y: 0, width: 3, height: u * 0.03))
        feeler.fillColor = SkyFX.outline
        feeler.strokeColor = .clear
        feeler.position = CGPoint(x: s * u * 0.018, y: u * 0.03)
        feeler.zRotation = -s * 0.4
        alien.addChild(feeler)
      }
      let dome = disc(radius: u * 0.055, fill: UIColor(red: 0.75, green: 0.92, blue: 1, alpha: 0.55), line: 3)
      dome.position = CGPoint(x: 0, y: u * 0.045)
      dome.zPosition = 2
      ufo.addChild(dome)
      let saucer = SKShapeNode(ellipseOf: CGSize(width: u * 0.3, height: u * 0.085))
      saucer.fillColor = SkyFX.rgb(0.8, 0.84, 0.92)
      saucer.strokeColor = SkyFX.outline
      saucer.lineWidth = 4
      saucer.zPosition = 3
      ufo.addChild(saucer)
      let colors = [SkyFX.rgb(1, 0.45, 0.45), SkyFX.rgb(1, 0.85, 0.3), SkyFX.rgb(0.4, 0.8, 1)]
      for (i, color) in colors.enumerated() {
        let light = disc(radius: u * 0.011, fill: color, line: 0)
        light.position = CGPoint(x: (CGFloat(i) - 1) * u * 0.08, y: -u * 0.004 - (i == 1 ? u * 0.006 : 0))
        light.zPosition = 4
        ufo.addChild(light)
        if !reduce {
          light.run(
            .sequence([
              .wait(forDuration: Double(i) * 0.2),
              .repeatForever(.sequence([.fadeAlpha(to: 0.3, duration: 0.5), .fadeAlpha(to: 1, duration: 0.5)])),
            ]))
        }
      }
      node.addChild(ufo)
      let y = h * 0.24
      if reduce {
        ufo.position = CGPoint(x: w * 0.2, y: y)
        return
      }
      let left = -w * 0.6, right = w * 0.6
      ufo.position = CGPoint(x: left, y: y)
      ufo.run(
        .repeatForever(
          .sequence([
            .moveTo(x: right, duration: 15), .scaleX(to: -1, duration: 0.3),
            .moveTo(x: left, duration: 15), .scaleX(to: 1, duration: 0.3),
          ])))
      let up = SKAction.moveBy(x: 0, y: h * 0.03, duration: 1.4)
      up.timingMode = .easeInEaseOut
      ufo.run(.repeatForever(.sequence([up, up.reversed()])))
    }
  }
}

extension SKAction {
  /// このアクションを、ほかのノードで動かす（グループの中で、ノードごとに動きを分けるため）。
  fileprivate func onNode(_ node: SKNode) -> SKAction {
    .run { [self] in node.run(self) }
  }
}
