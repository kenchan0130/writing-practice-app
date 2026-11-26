import ContentModel
import PracticeKit
import SpriteKit
import UIKit

/// まちの場面（SpriteKit）。D165: 画面の1.5〜3枚分の横長のまちを、指1本のドラッグで見て回る。
/// 乗り物は道、動物は草の上、飛ぶ物は空を、物ごとの持ち場の中で動きまわる（持ち場の計算は `TownLayout`）。
/// 景色（花・くだもの・やさい）は、丘の手前の草に立つ（D168）。
/// 服は横木にかかる（クローゼット。D53）。
final class TownScene: SKScene {
  /// まち（乗り物と動物）か、クローゼット（服）か。
  enum Layer { case town, closet }
  let layer: Layer
  private var shown: Set<UUID> = []
  /// 横木にかけた服の数（かけ場所の番号に使う）。
  private var shownClothes = 0

  /// まちに出している物（古い順。上限は `TownLayout.maxRoaming`）。
  private var townObjects: [PlacedObject] = []
  /// まちに出している景色（古い順。上限は `TownLayout.maxScenery`）。
  private var sceneryObjects: [PlacedObject] = []
  private var worldWidth: CGFloat = 0
  private let cameraNode = SKCameraNode()
  private var panStartX: CGFloat = 0

  private static let outline = UIColor(red: 0.29, green: 0.204, blue: 0.157, alpha: 1)  // #4a3428
  /// 物や飾りの大きさの元（縦長の画面でも大きくなりすぎない）。
  private var unit: CGFloat { min(size.height, size.width * 0.75) }
  private var reduceMotion: Bool { UIAccessibility.isReduceMotionEnabled }

  init(layer: Layer = .town) {
    self.layer = layer
    super.init(size: CGSize(width: 1000, height: 700))
    scaleMode = .resizeFill
    backgroundColor =
      layer == .closet
      ? UIColor(red: 1, green: 0.93, blue: 0.84, alpha: 1)
      : UIColor(red: 0.78, green: 0.9, blue: 1, alpha: 1)
    if layer == .town {
      addChild(cameraNode)
      camera = cameraNode
    }
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func didMove(to view: SKView) {
    guard layer == .town else { return }
    // 指1本のドラッグだけ（ピンチ・複数の指・長押しは使わない。D101）。
    let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    pan.minimumNumberOfTouches = 1
    pan.maximumNumberOfTouches = 1
    view.addGestureRecognizer(pan)
  }

  override func didChangeSize(_ oldSize: CGSize) {
    guard layer == .town else { return }
    rebuildTown()
  }

  /// 置いた物の一覧に合わせて、足したり消したりする（子どもを切り替えたときなど）。
  func show(_ all: [PlacedObject]) {
    if layer == .town {
      let roaming = TownLayout.shown(all.filter { $0.kind != .clothes && $0.kind != .scenery })
      let scenery = TownLayout.shownScenery(all.filter { $0.kind == .scenery })
      guard roaming.map(\.id) != townObjects.map(\.id) || scenery.map(\.id) != sceneryObjects.map(\.id)
      else { return }
      townObjects = roaming
      sceneryObjects = scenery
      rebuildTown()
      return
    }
    showCloset(all)
  }

  // MARK: まち

  @objc private func handlePan(_ pan: UIPanGestureRecognizer) {
    guard let view = pan.view else { return }
    switch pan.state {
    case .began:
      cameraNode.removeAllActions()
      panStartX = cameraNode.position.x
    case .changed:
      cameraNode.position.x = clampedCameraX(panStartX - pan.translation(in: view).x)
    case .ended, .cancelled:
      let target = clampedCameraX(cameraNode.position.x - pan.velocity(in: view).x * 0.25)
      let glide = SKAction.moveTo(x: target, duration: reduceMotion ? 0.01 : 0.5)
      glide.timingMode = .easeOut
      cameraNode.run(glide)
    default: break
    }
  }

  private func clampedCameraX(_ x: CGFloat) -> CGFloat {
    let half = size.width / 2
    return min(max(x, half), max(worldWidth - half, half))
  }

  /// 背景（空・太陽）はカメラについていき、動かない。地面・飾り・物はまちの中に置く。
  private func rebuildTown() {
    guard size.width > 0, size.height > 0 else { return }
    childNode(withName: "world")?.removeFromParent()
    cameraNode.removeAllChildren()
    let h = size.height
    let objectSize = unit * 0.23
    let plan = TownLayout.make(
      roles: townObjects.map { Self.role(of: $0.kind) }, scenery: sceneryObjects.count,
      screenWidth: Double(size.width), objectWidth: Double(objectSize))
    worldWidth = CGFloat(plan.worldWidth)
    #if DEBUG
      // 確かめ用: `-townScroll 0.5` で、まちの途中（0〜1）から見る。
      if UserDefaults.standard.object(forKey: "townScroll") != nil {
        let scroll = UserDefaults.standard.double(forKey: "townScroll")
        cameraNode.position.x = size.width / 2 + CGFloat(scroll) * (worldWidth - size.width)
      }
    #endif
    cameraNode.position = CGPoint(x: clampedCameraX(cameraNode.position.x), y: h / 2)

    addSky()
    let world = SKNode()
    world.name = "world"
    addChild(world)
    addScenery(to: world)
    for (object, place) in zip(sceneryObjects, plan.scenery) {
      world.addChild(makeScenery(object, place: place, objectSize: objectSize))
    }
    for (object, slot) in zip(townObjects, plan.slots) {
      world.addChild(makeObject(object, slot: slot, objectSize: objectSize))
    }
  }

  private static func role(of kind: WordKind) -> TownRole {
    switch kind {
    case .vehicle: .vehicle
    case .flyer: .flyer
    case .animal, .clothes, .scenery: .animal
    }
  }

  private func addSky() {
    let sky = SKSpriteNode(texture: Self.skyTexture)
    sky.size = size
    sky.zPosition = -100
    cameraNode.addChild(sky)
    let sun = SKNode()
    sun.position = CGPoint(x: size.width * 0.36, y: size.height * 0.30)
    sun.zPosition = -90
    for (radius, alpha) in [(0.10, 0.25), (0.075, 0.4), (0.05, 1.0)] as [(CGFloat, CGFloat)] {
      let disc = SKShapeNode(circleOfRadius: size.height * radius)
      disc.fillColor = UIColor(red: 1, green: 0.92, blue: 0.55, alpha: alpha)
      disc.strokeColor = .clear
      sun.addChild(disc)
    }
    cameraNode.addChild(sun)
  }

  private static let skyTexture: SKTexture = {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 4, height: 256))
    let image = renderer.image { context in
      let colors =
        [
          UIColor(red: 1, green: 0.96, blue: 0.86, alpha: 1),
          UIColor(red: 0.78, green: 0.91, blue: 1, alpha: 1),
          UIColor(red: 0.50, green: 0.78, blue: 1, alpha: 1),
        ].map(\.cgColor) as CFArray
      let gradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.4, 1])!
      context.cgContext.drawLinearGradient(
        gradient, start: .zero, end: CGPoint(x: 0, y: 256), options: [])
    }
    return SKTexture(image: image)
  }()

  private func shape(
    _ node: SKShapeNode, fill: UIColor, line: CGFloat = 0, z: CGFloat
  ) -> SKShapeNode {
    node.fillColor = fill
    node.strokeColor = line > 0 ? Self.outline : .clear
    node.lineWidth = line
    node.lineJoin = .round
    node.zPosition = z
    return node
  }

  /// 丘・地面・道・木・家・雲。ノードは数十個で、毎フレームの計算はしない。
  private func addScenery(to world: SKNode) {
    let h = size.height
    let width = worldWidth
    let horizon = h * 0.36

    // 奥の丘（2段）。
    var x: CGFloat = 0
    var i = 0
    while x < width + 400 {
      let far = shape(
        SKShapeNode(ellipseOf: CGSize(width: 760, height: h * 0.34)),
        fill: UIColor(red: 0.74, green: 0.89, blue: 0.72, alpha: 1), z: -80)
      far.position = CGPoint(x: x, y: horizon - h * 0.02 + CGFloat(i % 2) * h * 0.02)
      world.addChild(far)
      let near = shape(
        SKShapeNode(ellipseOf: CGSize(width: 560, height: h * 0.24)),
        fill: UIColor(red: 0.62, green: 0.83, blue: 0.58, alpha: 1), z: -70)
      near.position = CGPoint(x: x + 330, y: horizon - h * 0.03)
      world.addChild(near)
      x += 640
      i += 1
    }

    // 草と道。
    world.addChild(
      shape(
        SKShapeNode(rect: CGRect(x: 0, y: 0, width: width, height: horizon)),
        fill: UIColor(red: 0.62, green: 0.82, blue: 0.46, alpha: 1), z: -50))
    world.addChild(
      shape(
        SKShapeNode(rect: CGRect(x: 0, y: horizon - h * 0.012, width: width, height: h * 0.012)),
        fill: UIColor(red: 0.52, green: 0.75, blue: 0.38, alpha: 1), z: -49))
    world.addChild(
      shape(
        SKShapeNode(rect: CGRect(x: -20, y: h * 0.02, width: width + 40, height: h * 0.17)),
        fill: UIColor(red: 0.83, green: 0.76, blue: 0.68, alpha: 1), z: -45))
    // 道の真ん中の点線（1つのノード）。
    let center = CGMutablePath()
    center.move(to: CGPoint(x: 0, y: h * 0.105))
    center.addLine(to: CGPoint(x: width, y: h * 0.105))
    let dashes = center.copy(dashingWithPhase: 0, lengths: [34, 26])
    let dashLine = SKShapeNode(path: dashes)
    dashLine.strokeColor = UIColor(white: 1, alpha: 0.9)
    dashLine.lineWidth = 7
    dashLine.lineCap = .round
    dashLine.zPosition = -44
    world.addChild(dashLine)

    // 木と家（草の向こう側。物の動く範囲より奥）。
    var index = 0
    var decorationX: CGFloat = 140
    while decorationX < width {
      if index % 3 == 1 {
        addHouse(world, x: decorationX, base: horizon + h * 0.015, index: index)
        decorationX += 380
      } else {
        addTree(world, x: decorationX, base: horizon + h * 0.01, index: index)
        decorationX += 300 + CGFloat(index % 2) * 70
      }
      index += 1
    }

    // 雲（ゆっくり左右にゆれる）。
    var cloudX: CGFloat = 200
    var cloudIndex = 0
    while cloudX < width {
      let cloud = makeCloud(scale: 0.8 + CGFloat(cloudIndex % 3) * 0.25)
      cloud.position = CGPoint(x: cloudX, y: h * (0.76 + CGFloat((cloudIndex * 5) % 3) * 0.07))
      cloud.zPosition = -85
      if !reduceMotion {
        let time = 7 + Double(cloudIndex % 3)
        cloud.run(
          .repeatForever(
            .sequence([.moveBy(x: 50, y: 0, duration: time), .moveBy(x: -50, y: 0, duration: time)])
          ))
      }
      world.addChild(cloud)
      cloudX += 520 + CGFloat((cloudIndex * 7) % 3) * 90
      cloudIndex += 1
    }
  }

  private func makeCloud(scale: CGFloat) -> SKNode {
    let cloud = SKNode()
    let puffs: [(CGFloat, CGFloat, CGFloat)] = [
      (-38, -6, 30), (0, 6, 40), (42, -4, 32), (8, -14, 34),
    ]
    for (dx, dy, r) in puffs {
      let puff = SKShapeNode(circleOfRadius: r)
      puff.fillColor = UIColor(white: 1, alpha: 0.95)
      puff.strokeColor = .clear
      puff.position = CGPoint(x: dx, y: dy)
      cloud.addChild(puff)
    }
    cloud.setScale(scale)
    return cloud
  }

  private func addTree(_ world: SKNode, x: CGFloat, base: CGFloat, index: Int) {
    let s = 0.9 + CGFloat(index % 3) * 0.15
    let r = unit * 0.075 * s
    let trunkHeight = unit * 0.07 * s
    let trunk = shape(
      SKShapeNode(
        rect: CGRect(x: -9 * s, y: 0, width: 18 * s, height: trunkHeight), cornerRadius: 4),
      fill: UIColor(red: 0.74, green: 0.52, blue: 0.34, alpha: 1), line: 4, z: -40)
    trunk.position = CGPoint(x: x, y: base)
    world.addChild(trunk)
    let greens = [
      UIColor(red: 0.45, green: 0.78, blue: 0.40, alpha: 1),
      UIColor(red: 0.38, green: 0.72, blue: 0.50, alpha: 1),
    ]
    let crown = shape(SKShapeNode(circleOfRadius: r), fill: greens[index % 2], line: 4, z: -39)
    crown.position = CGPoint(x: x, y: base + trunkHeight + r * 0.6)
    world.addChild(crown)
    let shine = shape(
      SKShapeNode(circleOfRadius: r * 0.16), fill: UIColor(white: 1, alpha: 0.6), z: -38)
    shine.position = CGPoint(x: x - r * 0.4, y: crown.position.y + r * 0.4)
    world.addChild(shine)
  }

  private func addHouse(_ world: SKNode, x: CGFloat, base: CGFloat, index: Int) {
    let h = unit
    let w = h * 0.22
    let bodyHeight = h * 0.12
    let bodies = [
      UIColor(red: 1, green: 0.93, blue: 0.78, alpha: 1),
      UIColor(red: 1, green: 0.85, blue: 0.85, alpha: 1),
    ]
    let roofs = [
      UIColor(red: 0.93, green: 0.45, blue: 0.40, alpha: 1),
      UIColor(red: 0.45, green: 0.62, blue: 0.90, alpha: 1),
    ]
    let k = (index / 3) % 2
    let body = shape(
      SKShapeNode(rect: CGRect(x: -w / 2, y: 0, width: w, height: bodyHeight), cornerRadius: 8),
      fill: bodies[k], line: 4, z: -40)
    body.position = CGPoint(x: x, y: base)
    world.addChild(body)
    let roofPath = CGMutablePath()
    roofPath.move(to: CGPoint(x: -w / 2 - 12, y: bodyHeight - 2))
    roofPath.addLine(to: CGPoint(x: 0, y: bodyHeight + h * 0.09))
    roofPath.addLine(to: CGPoint(x: w / 2 + 12, y: bodyHeight - 2))
    roofPath.closeSubpath()
    let roof = shape(SKShapeNode(path: roofPath), fill: roofs[k], line: 4, z: -39)
    roof.position = CGPoint(x: x, y: base)
    world.addChild(roof)
    let door = shape(
      SKShapeNode(
        rect: CGRect(x: -w * 0.1, y: 0, width: w * 0.2, height: bodyHeight * 0.55),
        cornerRadius: 6),
      fill: UIColor(red: 0.74, green: 0.52, blue: 0.34, alpha: 1), line: 3, z: -38)
    door.position = CGPoint(x: x - w * 0.12, y: base)
    world.addChild(door)
    let window = shape(
      SKShapeNode(rect: CGRect(x: 0, y: 0, width: w * 0.2, height: w * 0.2), cornerRadius: 6),
      fill: UIColor(red: 0.8, green: 0.93, blue: 1, alpha: 1), line: 3, z: -38)
    window.position = CGPoint(x: x + w * 0.14, y: base + bodyHeight * 0.4)
    world.addChild(window)
  }

  /// 物ひとつ。持ち場の中で動きまわる。足もとの高さ（奥行き）で大きさと手前・奥が決まる。
  private func makeObject(_ object: PlacedObject, slot: TownSlot, objectSize: CGFloat)
    -> SKSpriteNode
  {
    // 絵は、保存した名前ではなく、ことばから決める（前に置いた物も新しい絵になる）。
    let image = WordArt.image(word: object.word, size: 320)
    let node = SKSpriteNode(texture: SKTexture(image: image))
    node.name = object.id.uuidString
    let side = objectSize * CGFloat(slot.scale)
    node.size = CGSize(width: side, height: side)
    node.anchorPoint = slot.role == .flyer ? CGPoint(x: 0.5, y: 0.5) : CGPoint(x: 0.5, y: 0.08)
    node.position = CGPoint(x: slot.startX, y: size.height * CGFloat(slot.yFraction))
    // 空の物は、雲（-85）と太陽より手前、丘より手前。地面の物は、足もとが低いほど手前。
    node.zPosition = slot.role == .flyer ? 30 - CGFloat(slot.lane) : 20 - CGFloat(slot.yFraction) * 20
    let range = CGFloat(slot.minX)...CGFloat(slot.maxX)
    switch slot.role {
    case .vehicle: driveVehicle(node, range: range, index: slot.index)
    case .animal: trotAnimal(node, range: range, index: slot.index)
    case .flyer: glide(node, word: object.word, range: range, index: slot.index)
    }
    return node
  }

  /// 景色になる物ひとつ。丘の手前の草に立つ。動物より奥（zPosition が小さい）に描く（D168）。
  private func makeScenery(_ object: PlacedObject, place: SceneryPlace, objectSize: CGFloat)
    -> SKSpriteNode
  {
    let image = WordArt.image(word: object.word, size: 320)
    let node = SKSpriteNode(texture: SKTexture(image: image))
    node.name = object.id.uuidString
    let side = objectSize * CGFloat(place.scale)
    node.size = CGSize(width: side, height: side)
    node.anchorPoint = CGPoint(x: 0.5, y: 0.05)
    node.position = CGPoint(x: place.x, y: size.height * CGFloat(place.yFraction))
    // 動物の最も奥の段（z=13.6）より奥。手前の列ほど手前。
    node.zPosition = 2 + CGFloat(1 - place.row) * 2
    if WordArt.isFlower(object.word) {
      // 花: ほんのすこし、根もとからゆれる（動きを減らすときは止める）。
      guard !reduceMotion else { return node }
      let angle: CGFloat = 0.04
      let sway = SKAction.sequence([
        .rotate(toAngle: angle, duration: 1.8), .rotate(toAngle: -angle, duration: 3.6),
        .rotate(toAngle: 0, duration: 1.8),
      ])
      sway.timingMode = .easeInEaseOut
      node.run(
        .sequence([
          .wait(forDuration: Double(place.index % 5) * 0.5), .repeatForever(sway),
        ]))
    } else if !reduceMotion {
      // くだもの・やさい: 出てくるときにひとはずみして、止まる。
      let target = node.size
      node.size = CGSize(width: target.width * 0.5, height: target.height * 0.5)
      node.run(
        .sequence([
          .wait(forDuration: Double(place.index % 6) * 0.12),
          .group([
            .resize(toWidth: target.width, height: target.height, duration: 0.3),
            .sequence([.moveBy(x: 0, y: 22, duration: 0.15), .moveBy(x: 0, y: -22, duration: 0.15)]),
          ]),
        ]))
    }
    return node
  }

  /// 空を飛ぶ物: 空の段をゆったり行き来して、ふわふわ上下する。鳥ははばたき、ききゅうはゆっくり上がり下がりする（D168）。
  private func glide(_ node: SKSpriteNode, word: String, range: ClosedRange<CGFloat>, index: Int) {
    let style = WordArt.flyerStyle(word)
    let speed: CGFloat
    switch style {
    case .plane: speed = reduceMotion ? 30 : 110
    case .bird: speed = reduceMotion ? 25 : 70
    case .balloon: speed = reduceMotion ? 12 : 28
    }
    let time = Double(max(range.upperBound - range.lowerBound, 1) / speed)
    let first = Double(max(range.upperBound - node.position.x, 1) / speed)
    let face = abs(node.xScale)
    node.run(
      .sequence([
        .moveTo(x: range.upperBound, duration: first),
        .repeatForever(
          .sequence([
            .scaleX(to: -face, duration: 0.2), .moveTo(x: range.lowerBound, duration: time),
            .scaleX(to: face, duration: 0.2), .moveTo(x: range.upperBound, duration: time),
          ])),
      ]))
    let baseY = node.position.y
    let bobHeight: CGFloat
    switch style {
    case .balloon: bobHeight = size.height * 0.035
    case .bird: bobHeight = size.height * 0.02
    case .plane: bobHeight = size.height * 0.008
    }
    let period = style == .balloon ? 3.5 : (style == .bird ? 1.6 : 2.4)
    if !reduceMotion {
      let bob = SKAction.sequence([
        .moveTo(y: baseY + bobHeight, duration: period / 2),
        .moveTo(y: baseY - bobHeight, duration: period / 2),
      ])
      bob.timingMode = .easeInEaseOut
      node.run(
        .sequence([
          .wait(forDuration: Double(index % 4) * 0.4), .repeatForever(bob),
        ]))
    }
    if style == .bird, !reduceMotion {
      // はばたき: すこし縦につぶれて、すこし かたむく。
      let flap = SKAction.sequence([
        .group([.scaleY(to: 0.9, duration: 0.18), .rotate(toAngle: 0.08, duration: 0.18)]),
        .group([.scaleY(to: 1, duration: 0.18), .rotate(toAngle: -0.08, duration: 0.18)]),
      ])
      node.run(.repeatForever(flap))
    }
  }

  /// 乗り物: 道をはずみながら行ったり来たりする。
  private func driveVehicle(_ node: SKSpriteNode, range: ClosedRange<CGFloat>, index: Int) {
    let speed: CGFloat = reduceMotion ? 40 : 75 + CGFloat(index % 3) * 15
    let time = Double(max(range.upperBound - range.lowerBound, 1) / speed)
    let first = Double(max(range.upperBound - node.position.x, 1) / speed)
    let face = abs(node.xScale)
    node.run(
      .sequence([
        .moveTo(x: range.upperBound, duration: first),
        .repeatForever(
          .sequence([
            .scaleX(to: -face, duration: 0.12), .moveTo(x: range.lowerBound, duration: time),
            .scaleX(to: face, duration: 0.12), .moveTo(x: range.upperBound, duration: time),
          ])),
      ]))
    if !reduceMotion {
      let baseY = node.position.y
      node.run(
        .repeatForever(
          .sequence([.moveTo(y: baseY + 5, duration: 0.22), .moveTo(y: baseY, duration: 0.22)])))
    }
  }

  /// 四つ足の動物: 草の上をぴょんぴょん歩き、ときどきたちどまって、向きを変える。
  private func trotAnimal(_ node: SKSpriteNode, range: ClosedRange<CGFloat>, index: Int) {
    let speed: CGFloat = reduceMotion ? 35 : 60
    let hopHeight: CGFloat = reduceMotion ? 6 : 20
    let baseY = node.position.y
    let hop = SKAction.sequence([
      .moveTo(y: baseY + hopHeight, duration: 0.14), .moveTo(y: baseY, duration: 0.14),
    ])
    func trot(to x: CGFloat, from start: CGFloat) -> SKAction {
      let duration = Double(max(abs(x - start), 1) / speed)
      return .group([
        .repeat(hop, count: Int(duration / 0.28) + 1),
        .moveTo(x: x, duration: duration),
      ])
    }
    let pause = SKAction.wait(forDuration: 0.8 + Double(index % 3) * 0.4)
    let face = abs(node.xScale)
    node.run(
      .sequence([
        .wait(forDuration: Double(index % 4) * 0.3),
        trot(to: range.upperBound, from: node.position.x), pause,
        .repeatForever(
          .sequence([
            .scaleX(to: -face, duration: 0.12),
            trot(to: range.lowerBound, from: range.upperBound), pause,
            .scaleX(to: face, duration: 0.12),
            trot(to: range.upperBound, from: range.lowerBound), pause,
          ])),
      ]))
  }

  // MARK: クローゼット

  private func showCloset(_ all: [PlacedObject]) {
    let placed = all.filter { $0.kind == .clothes }
    let ids = Set(placed.map(\.id))
    for node in children
    where node.name.flatMap(UUID.init(uuidString:)).map({ !ids.contains($0) }) ?? false {
      node.removeFromParent()
    }
    shown = shown.intersection(ids)
    var clothesCount = 0
    for object in placed where !shown.contains(object.id) {
      shown.insert(object.id)
      let image = WordArt.image(word: object.word, size: 240)
      let node = SKSpriteNode(texture: SKTexture(image: image))
      node.name = object.id.uuidString
      node.size = CGSize(width: 160, height: 160)
      addChild(node)
      hangClothes(node, slot: clothesCount + shownClothes)
      clothesCount += 1
    }
    shownClothes += clothesCount
  }

  /// 服: 空の高いところの横木にハンガーでかかって、ゆらゆら揺れる（クローゼットの試作。D53）。
  private func hangClothes(_ node: SKSpriteNode, slot: Int) {
    let perRow = max(Int((size.width - 160) / 150), 1)
    let column = slot % perRow
    let row = slot / perRow
    let railY = size.height - 30 - CGFloat(row) * 190
    if row == 0, childNode(withName: "rail") == nil {
      let rail = SKShapeNode(
        rect: CGRect(x: 40, y: railY, width: size.width - 80, height: 6), cornerRadius: 3)
      rail.fillColor = UIColor(red: 0.55, green: 0.38, blue: 0.22, alpha: 1)
      rail.strokeColor = .clear
      rail.name = "rail"
      rail.zPosition = 1
      addChild(rail)
    }
    node.size = CGSize(width: 120, height: 120)
    node.anchorPoint = CGPoint(x: 0.5, y: 0.92)
    node.position = CGPoint(x: 100 + CGFloat(column) * 150, y: railY - 18)
    node.zPosition = 2
    let hook = SKShapeNode(rect: CGRect(x: -2, y: 0, width: 4, height: 18))
    hook.fillColor = .gray
    hook.strokeColor = .clear
    hook.position = .zero
    node.addChild(hook)
    let amplitude = 0.12 + 0.03 * CGFloat(slot % 3)
    let swing = SKAction.sequence([
      .rotate(toAngle: amplitude, duration: 0.9), .rotate(toAngle: -amplitude, duration: 1.8),
      .rotate(toAngle: 0, duration: 0.9),
    ])
    swing.timingMode = .easeInEaseOut
    node.run(
      .sequence([
        .wait(forDuration: Double(slot % 5) * 0.4),
        .repeatForever(swing),
      ]))
  }
}
