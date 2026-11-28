import ContentModel
import PracticeKit
import SpriteKit
import UIKit

/// キャラクターのいえ（いえの なか）の場面（§3.4・D74・D82・D185）。
/// あたたかい部屋に、棚（4つ）・床（2つ）・壁（2つ）の決まった置き場所があり、書いた いえの物が そこに出る。
/// 主人公は部屋の中にいて、ときどき物のところへ行って使う。物を つつくと はずんで、名前を言う。
/// 置き場所の計算は `HouseLayout`、どれを出すかは `ToyBoxBoard`（入りきらない物は おもちゃばこ）。
final class HouseScene: SKScene {
  /// 出している物ひとつ。
  struct Thing: Equatable {
    let object: PlacedObject
    let spot: HouseSpot
    let slot: Int
  }

  private var things: [Thing] = []
  private var mainCharacter: MainCharacter = .ton
  private var thingNodes: [UUID: SKSpriteNode] = [:]
  private var heroNode: SKSpriteNode?

  private static let outline = UIColor(red: 0.29, green: 0.204, blue: 0.157, alpha: 1)  // #4a3428
  private var reduceMotion: Bool { UIAccessibility.isReduceMotionEnabled }
  /// 物の大きさの元（縦長でも横長でも、部屋に収まる）。
  private var unit: CGFloat { min(size.height, size.width * 1.15) }
  private var objectSize: CGFloat { unit * 0.2 }

  override init(size: CGSize = CGSize(width: 800, height: 900)) {
    super.init(size: size)
    scaleMode = .resizeFill
    backgroundColor = UIColor(red: 1, green: 0.93, blue: 0.84, alpha: 1)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func didChangeSize(_ oldSize: CGSize) { rebuild() }

  /// 出す物を知らせる。変わったら、部屋を作り直す。
  func show(_ board: ToyBoxBoard) {
    let spots: [(ShelfGroup, HouseSpot)] = [
      (.houseShelf, .shelf), (.houseFloor, .floor), (.houseWall, .wall),
    ]
    let next = spots.flatMap { group, spot in
      board.shown(group).map { Thing(object: $0.object, spot: spot, slot: $0.slot) }
    }
    guard next != things || heroNode == nil else { return }
    things = next
    rebuild()
  }

  func setCharacter(_ character: MainCharacter) {
    guard character != mainCharacter else { return }
    mainCharacter = character
    rebuild()
  }

  // MARK: 部屋

  private func rebuild() {
    guard size.width > 0, size.height > 0 else { return }
    removeAllChildren()
    removeAllActions()
    thingNodes = [:]
    heroNode = nil
    addRoom()
    var placed: [(thing: Thing, node: SKSpriteNode, slot: HouseSlot)] = []
    for thing in things {
      let slots = HouseLayout.slots(thing.spot)
      guard slots.indices.contains(thing.slot) else { continue }
      let slot = slots[thing.slot]
      let node = makeThing(thing, slot: slot)
      addChild(node)
      thingNodes[thing.object.id] = node
      placed.append((thing, node, slot))
    }
    addHero(placed)
  }

  private func shape(_ node: SKShapeNode, fill: UIColor, line: CGFloat = 3, z: CGFloat) -> SKShapeNode {
    node.fillColor = fill
    node.strokeColor = line > 0 ? Self.outline : .clear
    node.lineWidth = line
    node.zPosition = z
    return node
  }

  /// かべ・まど・ゆか・ラグ・たな。奥から順に描く。
  private func addRoom() {
    let w = size.width
    let h = size.height
    let floorTop = h * CGFloat(HouseLayout.floorTop)
    // かべ: 上が こい、あたたかい色。
    let wall = SKSpriteNode(texture: SKTexture(image: Self.wallGradient()))
    wall.size = size
    wall.position = CGPoint(x: w / 2, y: h / 2)
    wall.zPosition = -20
    addChild(wall)
    // かべの もよう（うすい 水玉）。
    let dotColor = UIColor(red: 1, green: 0.84, blue: 0.72, alpha: 0.7)
    let step = max(unit * 0.16, 60)
    var row = 0
    var y = floorTop + step * 0.6
    while y < h {
      var x = step * (row % 2 == 0 ? 0.5 : 1.0)
      while x < w {
        let dot = SKShapeNode(circleOfRadius: unit * 0.012)
        dot.position = CGPoint(x: x, y: y)
        addChild(shape(dot, fill: dotColor, line: 0, z: -19))
        x += step
      }
      y += step * 0.8
      row += 1
    }
    // まど: 空と雲。
    let windowSize = CGSize(width: min(w * 0.24, unit * 0.3), height: unit * 0.17)
    let window = SKShapeNode(
      rectOf: windowSize, cornerRadius: unit * 0.02)
    window.position = CGPoint(x: w * 0.2, y: h * 0.86)
    addChild(shape(window, fill: UIColor(red: 0.75, green: 0.9, blue: 1, alpha: 1), line: 5, z: -18))
    let cloud = SKShapeNode(ellipseOf: CGSize(width: windowSize.width * 0.45, height: windowSize.height * 0.3))
    cloud.position = CGPoint(x: windowSize.width * 0.1, y: windowSize.height * 0.12)
    window.addChild(shape(cloud, fill: .white, line: 0, z: 0.1))
    let cloud2 = SKShapeNode(ellipseOf: CGSize(width: windowSize.width * 0.3, height: windowSize.height * 0.22))
    cloud2.position = CGPoint(x: -windowSize.width * 0.2, y: -windowSize.height * 0.15)
    window.addChild(shape(cloud2, fill: .white, line: 0, z: 0.1))
    let bar = SKShapeNode(rectOf: CGSize(width: 5, height: windowSize.height))
    window.addChild(shape(bar, fill: Self.outline, line: 0, z: 0.2))
    let sill = SKShapeNode(
      rectOf: CGSize(width: windowSize.width * 1.12, height: unit * 0.018), cornerRadius: unit * 0.008)
    sill.position = CGPoint(x: 0, y: -windowSize.height / 2 - unit * 0.006)
    window.addChild(shape(sill, fill: UIColor(red: 0.95, green: 0.71, blue: 0.42, alpha: 1), z: 0.3))
    // ゆか: 木の板。
    let floor = SKShapeNode(rect: CGRect(x: -4, y: -4, width: w + 8, height: floorTop + 4))
    addChild(shape(floor, fill: UIColor(red: 0.96, green: 0.8, blue: 0.58, alpha: 1), line: 0, z: -15))
    let plank = UIColor(red: 0.9, green: 0.7, blue: 0.47, alpha: 1)
    for index in 1..<4 {
      let line = SKShapeNode(rect: CGRect(x: 0, y: floorTop * CGFloat(index) / 4, width: w, height: 3))
      addChild(shape(line, fill: plank, line: 0, z: -14))
    }
    let trim = SKShapeNode(rect: CGRect(x: -4, y: floorTop, width: w + 8, height: unit * 0.022))
    addChild(shape(trim, fill: UIColor(red: 0.95, green: 0.71, blue: 0.42, alpha: 1), z: -13))
    // ラグ: 主人公が ふだん立つところ。
    let rug = SKShapeNode(ellipseOf: CGSize(width: w * 0.42, height: h * 0.13))
    rug.position = CGPoint(x: w * CGFloat(HouseLayout.homeX), y: h * CGFloat(HouseLayout.homeY))
    addChild(shape(rug, fill: UIColor(red: 1, green: 0.78, blue: 0.82, alpha: 1), z: -12))
    let rugIn = SKShapeNode(ellipseOf: CGSize(width: w * 0.32, height: h * 0.09))
    rugIn.position = rug.position
    addChild(shape(rugIn, fill: UIColor(red: 1, green: 0.9, blue: 0.92, alpha: 1), line: 0, z: -11.5))
    // たな: 板と、板を ささえる 金具。
    let x0 = w * CGFloat(HouseLayout.shelfMinX)
    let x1 = w * CGFloat(HouseLayout.shelfMaxX)
    let shelfY = h * CGFloat(HouseLayout.shelfY)
    let thick = unit * 0.024
    for x in [x0 + (x1 - x0) * 0.12, x1 - (x1 - x0) * 0.12] {
      let path = CGMutablePath()
      path.move(to: CGPoint(x: x - thick * 0.6, y: shelfY - thick))
      path.addLine(to: CGPoint(x: x + thick * 0.6, y: shelfY - thick))
      path.addLine(to: CGPoint(x: x - thick * 0.6, y: shelfY - thick * 3.2))
      path.closeSubpath()
      addChild(shape(SKShapeNode(path: path), fill: UIColor(red: 0.79, green: 0.5, blue: 0.24, alpha: 1), z: -10))
    }
    let board = SKShapeNode(
      rect: CGRect(x: x0, y: shelfY - thick, width: x1 - x0, height: thick), cornerRadius: thick * 0.3)
    addChild(shape(board, fill: UIColor(red: 0.95, green: 0.71, blue: 0.42, alpha: 1), z: -9))
  }

  private static func wallGradient() -> UIImage {
    UIGraphicsImageRenderer(size: CGSize(width: 8, height: 256)).image { context in
      let colors = [
        UIColor(red: 1, green: 0.89, blue: 0.8, alpha: 1).cgColor,
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

  // MARK: 物

  /// 物を置き場所に置く。棚・床の物は、絵の中身の下のはしを 置き場所の高さに合わせる。壁の物は 真ん中。
  private func makeThing(_ thing: Thing, slot: HouseSlot) -> SKSpriteNode {
    let word = thing.object.baseWord
    let node = SKSpriteNode(texture: SKTexture(image: WordArt.image(word: word, size: 320)))
    node.name = thing.object.id.uuidString
    let side = objectSize * CGFloat(slot.scale)
    node.size = CGSize(width: side, height: side)
    let content = WordArt.contentFrame(word: word)
    switch thing.spot {
    case .shelf, .floor:
      node.anchorPoint = CGPoint(x: content.midX, y: 1 - content.maxY)
    case .wall:
      node.anchorPoint = CGPoint(x: content.midX, y: 1 - content.midY)
    }
    node.position = CGPoint(x: size.width * CGFloat(slot.x), y: size.height * CGFloat(slot.y))
    // 床の物は、手前（下）ほど前に描く。棚と壁の物は、床の物と主人公より奥。
    node.zPosition = thing.spot == .floor ? 10 - CGFloat(slot.y) * 10 : 1
    return node
  }

  /// 物を つつくと、はずんで、名前を言う（§3.4）。
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let point = touches.first?.location(in: self) else { return }
    for node in nodes(at: point) {
      guard let sprite = node as? SKSpriteNode, let id = sprite.name.flatMap(UUID.init(uuidString:)),
        let thing = things.first(where: { $0.object.id == id })
      else { continue }
      if !reduceMotion { HouseMotion.bounce(sprite) }
      VoicePlayer.shared.speak(thing.object.baseWord)
      return
    }
  }

  // MARK: 主人公

  private var home: CGPoint {
    CGPoint(x: size.width * CGFloat(HouseLayout.homeX), y: size.height * CGFloat(HouseLayout.homeY))
  }

  /// 主人公は ラグの上にいて、数秒ごとに 物のところへ はねていって使う。
  private func addHero(_ placed: [(thing: Thing, node: SKSpriteNode, slot: HouseSlot)]) {
    guard let poses = HouseMotion.poses(for: mainCharacter) else { return }
    let h = size.height
    let w = size.width
    let hero = SKSpriteNode(texture: poses.normal)
    let heroSide = objectSize * 0.7
    hero.size = CGSize(width: heroSide, height: heroSide)
    hero.anchorPoint = CGPoint(x: 0.5, y: 0.04)
    hero.name = "hero"
    hero.position = home
    hero.zPosition = 10 - (home.y / h) * 10 + 0.5
    addChild(hero)
    heroNode = hero
    guard !reduceMotion, !placed.isEmpty else { return }

    func travel(to point: CGPoint, from start: CGPoint, z: CGFloat? = nil) -> [SKAction] {
      let distance = hypot(point.x - start.x, point.y - start.y)
      guard distance > 1 else { return [] }
      let duration = max(0.5, Double(distance) / 420)
      let arc = SKAction.sequence([
        .moveBy(x: 0, y: h * 0.07, duration: duration / 2),
        .moveBy(x: 0, y: -h * 0.07, duration: duration / 2),
      ])
      let move = SKAction.move(to: point, duration: duration)
      move.timingMode = .easeInEaseOut
      let depth = z ?? (10 - (point.y / h) * 10 + 0.5)
      return [
        .scaleX(to: point.x < start.x ? -1 : 1, duration: 0.1),
        .run { [weak hero] in hero?.zPosition = max(hero?.zPosition ?? 0, depth) },
        .group([move, arc]),
        .run { [weak hero] in hero?.zPosition = depth },
      ]
    }

    var script: [SKAction] = [.wait(forDuration: 1.2)]
    var current = home
    // 新しい物から順に回る（置き場所の番号ではなく、手に入れた時間の順）。
    for item in placed.sorted(by: { $0.thing.object.date > $1.thing.object.date }) {
      guard let use = HouseLayout.use(for: item.thing.object.baseWord) else { continue }
      let node = item.node
      let content = WordArt.contentFrame(word: item.thing.object.baseWord)
      let thingX = node.position.x
      // 立つ場所: 床の物は、部屋の真ん中の側の となり。棚・壁の物は、その下の床（床の物の間）。
      let beside: CGPoint
      if item.thing.spot == .floor {
        let towardCentre: CGFloat = thingX < w / 2 ? 1 : -1
        beside = CGPoint(
          x: thingX + towardCentre * (node.size.width * content.width * 0.5 + heroSide * 0.42),
          y: node.position.y - h * 0.03)
      } else {
        beside = CGPoint(x: min(max(thingX, w * 0.38), w * 0.62), y: h * 0.2)
      }
      script += travel(to: beside, from: current)
      current = beside
      script.append(.scaleX(to: thingX < beside.x ? -1 : 1, duration: 0.1))
      var after: [SKAction] = []
      switch use {
      case .sit:
        // いすの 座るところへ とびのる。
        let seat = HouseMotion.point(in: node, x: 0.508, yFromTop: 0.523)
        let target = CGPoint(x: seat.x, y: seat.y - heroSide * 0.1)
        script += travel(to: target, from: current, z: node.zPosition + 0.5)
        script.append(.scaleX(to: 1, duration: 0.1))
        after = travel(to: beside, from: target)
      case .sleep:
        // ふとんの上へ。目を とじて、すこし ねむる。
        let bed = HouseMotion.point(in: node, x: 0.6, yFromTop: 0.6)
        script += travel(to: bed, from: current, z: node.zPosition + 0.5)
        script.append(.rotate(toAngle: thingX < w / 2 ? -0.12 : 0.12, duration: 0.2))
        after = [.rotate(toAngle: 0, duration: 0.15)] + travel(to: beside, from: bed)
      default: break
      }
      script.append(
        .run { [weak hero, weak node] in
          guard let hero, let node else { return }
          HouseMotion.play(use, hero: hero, thing: node, poses: poses, content: content)
        })
      script.append(.wait(forDuration: HouseMotion.duration(of: use) + 0.2))
      script += after
      // ラグに もどって、ひとやすみ。
      script += travel(to: home, from: current)
      current = home
      script.append(.scaleX(to: 1, duration: 0.1))
      script.append(.wait(forDuration: 2.4))
    }
    guard script.count > 1 else { return }
    hero.run(.repeatForever(.sequence(script)), withKey: "script")
  }
}
