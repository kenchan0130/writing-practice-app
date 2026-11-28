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
  /// 水べの生きもの（古い順。上限は `TownLayout.maxSwimmers`。D170）。
  private var swimObjects: [PlacedObject] = []
  /// こうえんの物（置き場所の番号の順。上限は `TownLayout.maxPlaythings`）と、置き場所の番号（D173・D185）。
  private var playObjects: [(object: PlacedObject, ordinal: Int)] = []
  /// 季節の飾り（置き場所の番号の順。上限は `FestiveLayout.capacity`）と、置き場所の番号（§3.4）。
  private var festiveObjects: [(object: PlacedObject, ordinal: Int)] = []
  /// こうえんで遊ぶキャラクター（「なにが すき？」の前に選んだ主人公。D164）。
  private(set) var mainCharacter: MainCharacter = .ton
  /// 空のことばを書いた記録と、いま出している空（D172）。
  private var skyRecords: [SkyRecord] = []
  private var skyStart: Date?
  private var shownSky: SkyForecast?
  private var skyNodes: [SKNode] = []
  /// 体のことばを書いた記録と、動きを見せた時刻（D175）。こうえんの主人公（いれば）と、その動きの前に流れていた動き。
  private var bodyRecords: [BodyRecord] = []
  /// すうじ あそび: かごに入れて見せる りんごの数（D199）。物ではないので、おもちゃばこや置き場所には入らない。
  private var appleCount = 0
  private var bodyPlayedAt: Date?
  /// 動きの途中でまちを作り直したら（大きさが決まった直後など）、はじめから見せなおす。
  private var bodyInProgress = false
  private var playerNode: SKSpriteNode?
  private var playerScript: SKAction?
  private(set) var worldWidth: CGFloat = 0
  /// 陸のまちの左はし（こうえんがあると、その右）。ステッカーの位置は、ここから数える。
  private(set) var landMinX: CGFloat = 0
  private(set) var landWidth: CGFloat = 0
  let cameraNode = SKCameraNode()
  private var panStartX: CGFloat = 0
  /// 子どもが まちを動かしたか。動かすまでは、まちの左はしから見せる（大きさが決まる前の位置を残さない）。
  private var hasPanned = false

  // 時間帯の景色（§3.4。`TownScene+Time.swift`）。
  /// いまの時間帯。まちを作り直すときに、端末の時刻から決める。
  var phase: DayPhase = .day
  /// まち全体にかける、時間帯の うすい色。空のことばの空が出ているあいだは消す（D172）。
  var phaseTint: SKNode?
  /// 夜だけの あかり（窓の光）。空のことばの空が出ているあいだは消す。
  var nightLights: [SKNode] = []
  /// 夜、まちで うとうとする主人公（こうえんに主人公がいないとき）。
  var dozerNode: SKSpriteNode?

  // ステッカー（§3.3・D54。`TownScene+Stickers.swift`）。
  var townStickers: [TownSticker] = []
  /// ステッカーを貼る・はがす あいだ。押すと はがれる。
  var stickerMode = false
  /// ステッカーを押して はがした。
  var onStickerPeel: ((UUID) -> Void)?

  // 傾けると転がる（§3.3・D133。`TownScene+Rolling.swift`）。
  var rollers: [Roller] = []
  /// いまの傾き（-1〜1。右に傾けると正）。センサーがなければ nil。
  var tiltProvider: (() -> Double)?
  var lastUpdateTime: TimeInterval?

  static let outline = UIColor(red: 0.29, green: 0.204, blue: 0.157, alpha: 1)  // #4a3428
  /// 物や飾りの大きさの元（縦長の画面でも大きくなりすぎない）。
  var unit: CGFloat { min(size.height, size.width * 0.75) }
  var reduceMotion: Bool { UIAccessibility.isReduceMotionEnabled }

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
    panRecognizer = pan
    watchPhase()
  }

  /// 絵が画面から外れるとき、つけたドラッグの受け取りを外す（まちを開くたびに溜まらないように。D194）。
  override func willMove(from view: SKView) {
    if let pan = panRecognizer {
      view.removeGestureRecognizer(pan)
      panRecognizer = nil
    }
  }

  private var panRecognizer: UIPanGestureRecognizer?

  override func didChangeSize(_ oldSize: CGSize) {
    guard layer == .town else { return }
    rebuildTown()
  }

  /// ステッカーや 転がる物を押した（§3.3・D133）。まちを動かすドラッグは、別に受ける。
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard layer == .town, let point = touches.first?.location(in: self) else { return }
    if tapSticker(at: point) { return }
    _ = tapRoller(at: point)
  }

  override func update(_ currentTime: TimeInterval) {
    guard layer == .town else { return }
    stepRollers(currentTime)
  }

  /// 置いた物の一覧に合わせて、足したり消したりする（子どもを切り替えたときなど）。
  /// まちに出す物は、行から計算した並び（`ToyBoxBoard`）で決まる。入りきらない物は おもちゃばこ（D74・D82）。
  func show(_ all: [PlacedObject], board: ToyBoxBoard) {
    if layer == .town {
      let roaming = board.shown(.roaming).map(\.object)
      let scenery = board.shown(.scenery).map(\.object)
      let swimmers = board.shown(.swimmers).map(\.object)
      // こうえんの物は、8つの置き場所に入る。いっぱいなら、出してからいちばん長い物の場所に入る（D82）。
      let playing = board.shown(.park).map { (object: $0.object, ordinal: $0.slot) }
      let festive = board.shown(.festive).map { (object: $0.object, ordinal: $0.slot) }
      guard
        roaming.map(\.id) != townObjects.map(\.id)
          || scenery.map(\.id) != sceneryObjects.map(\.id)
          || swimmers.map(\.id) != swimObjects.map(\.id)
          || playing.map(\.object.id) != playObjects.map(\.object.id)
          || playing.map(\.ordinal) != playObjects.map(\.ordinal)
          || festive.map(\.object.id) != festiveObjects.map(\.object.id)
          || festive.map(\.ordinal) != festiveObjects.map(\.ordinal)
      else { return }
      townObjects = roaming
      sceneryObjects = scenery
      swimObjects = swimmers
      playObjects = playing
      festiveObjects = festive
      rebuildTown()
      return
    }
    showCloset(all)
  }

  /// こうえんで遊ぶキャラクターを知らせる（D173）。かわったら、まちを作り直す。
  func setCharacter(_ character: MainCharacter) {
    guard character != mainCharacter else { return }
    mainCharacter = character
    guard layer == .town, !playObjects.isEmpty else { return }
    rebuildTown()
  }

  // MARK: まち

  @objc private func handlePan(_ pan: UIPanGestureRecognizer) {
    guard let view = pan.view else { return }
    switch pan.state {
    case .began:
      cameraNode.removeAllActions()
      hasPanned = true
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

  /// こうえんに、遊ぶ主人公がいるか。
  var hasPlayer: Bool { playerNode != nil }

  /// 時間帯が変わったので、まちを作り直す。
  func refreshForPhase() { rebuildTown() }

  /// 背景（空・太陽）はカメラについていき、動かない。地面・飾り・物はまちの中に置く。
  private func rebuildTown() {
    guard size.width > 0, size.height > 0 else { return }
    childNode(withName: "world")?.removeFromParent()
    cameraNode.removeAllChildren()
    skyNodes = []
    shownSky = nil
    playerNode = nil
    playerScript = nil
    phaseTint = nil
    nightLights = []
    dozerNode = nil
    rollers = []
    phase = TownClock.phase()
    if bodyInProgress {
      bodyPlayedAt = nil
      bodyInProgress = false
    }
    let h = size.height
    let objectSize = unit * 0.23
    let plan = TownLayout.make(
      roles: townObjects.map { Self.role(of: $0.kind) }, scenery: sceneryObjects.count,
      swimmers: swimObjects.count, playthings: playObjects.count, screenWidth: Double(size.width),
      objectWidth: Double(objectSize))
    worldWidth = CGFloat(plan.worldWidth)
    landMinX = CGFloat(plan.landMinX)
    landWidth = CGFloat(plan.landWidth)
    if !hasPanned { cameraNode.position.x = size.width / 2 }
    #if DEBUG
      // 確かめ用: `-townScroll 0.5` で、まちの途中（0〜1）から見る。
      if UserDefaults.standard.object(forKey: "townScroll") != nil {
        let scroll = UserDefaults.standard.double(forKey: "townScroll")
        cameraNode.position.x = size.width / 2 + CGFloat(scroll) * (worldWidth - size.width)
      }
    #endif
    cameraNode.position = CGPoint(x: clampedCameraX(cameraNode.position.x), y: h / 2)

    addPhaseSky()
    let world = SKNode()
    world.name = "world"
    addChild(world)
    // 大きな景色が立つはばには、背景の木と家を出さない（D174）。
    let landmarkSpans = zip(sceneryObjects, plan.scenery).compactMap { object, place in
      WordArt.landmarkFactor(object.baseWord).map {
        TownLayout.landmarkSpan(
          TownLayout.landmarkPlace(place, factor: $0), objectWidth: Double(objectSize))
      }
    }
    // 季節の飾り（§3.4）。立てる物のはばにも、背景の木と家を出さない。
    let festiveArea = FestiveLayout.area(
      landMinX: plan.landMinX, landWidth: plan.landWidth, screenWidth: Double(size.width))
    let festiveSpots: [(object: PlacedObject, spot: FestiveSpot)] = festiveObjects.compactMap {
      item in
      FestiveLayout.style(for: item.object.baseWord).map {
        (item.object, FestiveLayout.spot(index: item.ordinal, style: $0, in: festiveArea))
      }
    }
    let standSpans = festiveSpots.filter { $0.spot.style == .stand }.map {
      FestiveLayout.standSpan($0.spot, objectWidth: Double(objectSize))
    }
    addScenery(
      to: world, landWidth: CGFloat(plan.landWidth), originX: CGFloat(plan.landMinX),
      avoiding: landmarkSpans + standSpans)
    if !festiveSpots.isEmpty {
      addGarland(to: world, area: festiveArea)
      for (object, spot) in festiveSpots {
        addFestive(object, spot: spot, to: world, objectSize: objectSize)
      }
    }
    if let water = plan.water { addWater(to: world, water: water) }
    if let park = plan.park {
      addPark(to: world, park: park)
      addPlayEquipment(to: world, plan: plan, objectSize: objectSize)
    }
    for (object, slot) in zip(swimObjects, plan.swimSlots) {
      world.addChild(makeSwimmer(object, slot: slot, objectSize: objectSize))
    }
    for (object, place) in zip(sceneryObjects, plan.scenery) {
      world.addChild(makeScenery(object, place: place, objectSize: objectSize))
    }
    for (object, slot) in zip(townObjects, plan.slots) {
      world.addChild(makeObject(object, slot: slot, objectSize: objectSize))
    }
    addApples(to: world, objectSize: objectSize)
    addStickers(to: world)
    addPhaseTint()
    addDozer(to: world, objectSize: objectSize)
    applySky()
    applyBodyAction(objectSize: objectSize)
  }

  // MARK: すうじ あそび（D199）

  /// 最後に書いた数字の数だけ、りんごを かごに入れて見せる。0 なら かごも出さない。
  /// まちの左のほうの決まった所に置く。ほかの物を押し出さず、次の数字を書くまで同じ。
  func setApples(_ count: Int) {
    appleCount = count
    guard layer == .town, let world = childNode(withName: "world") else { return }
    world.childNode(withName: "apples")?.removeFromParent()
    addApples(to: world, objectSize: unit * 0.23)
  }

  private func addApples(to world: SKNode, objectSize: CGFloat) {
    guard layer == .town, appleCount > 0 else { return }
    let basket = SKNode()
    basket.name = "apples"
    basket.position = CGPoint(x: landMinX + objectSize * 1.1, y: size.height * 0.1)
    basket.zPosition = 21
    let width = objectSize * 1.5
    let body = shape(
      SKShapeNode(
        rect: CGRect(x: -width / 2, y: -objectSize * 0.25, width: width, height: objectSize * 0.4),
        cornerRadius: 10),
      fill: UIColor(red: 0.85, green: 0.6, blue: 0.3, alpha: 1), line: 4, z: 1)
    let apple = objectSize * 0.42
    let image = WordArt.image(word: NumberPlay.appleWord, size: 160)
    let texture = SKTexture(image: image)
    // 3つずつの山。下の段から うめる。
    for index in 0..<appleCount {
      let row = index / 3
      let column = index % 3
      let sprite = SKSpriteNode(texture: texture)
      sprite.size = CGSize(width: apple, height: apple)
      sprite.position = CGPoint(
        x: (CGFloat(column) - 1) * apple * 0.8 + (row % 2 == 1 ? apple * 0.2 : 0),
        y: objectSize * 0.15 + CGFloat(row) * apple * 0.55 + apple * 0.4)
      sprite.zPosition = 0.5
      basket.addChild(sprite)
    }
    basket.addChild(body)
    world.addChild(basket)
  }

  // MARK: 主人公が動いて見せる（D175）

  /// 体のことばを書いた記録を渡す。10分の間に書いたことばの動きを、まちが開いたとき1回だけ、主人公が見せる（`BodyAction`）。
  func setBody(_ records: [BodyRecord]) {
    bodyRecords = records
    guard layer == .town else { return }
    applyBodyAction(objectSize: unit * 0.23)
  }

  /// こうえんの主人公がいれば、その子が。いなければ、まちの左はしに主人公が出てきて、動きを見せて、帰る。
  private func applyBodyAction(objectSize: CGFloat) {
    guard layer == .town, size.width > 0, size.height > 0,
      let world = childNode(withName: "world"),
      let motion = BodyAction.pending(records: bodyRecords, now: Date(), playedAt: bodyPlayedAt),
      let poses = BodyMotionFX.poses(for: mainCharacter)
    else { return }
    bodyPlayedAt = Date()
    bodyInProgress = true
    let reduce = reduceMotion
    let seconds = BodyMotionFX.duration(of: motion, reduceMotion: reduce)
    if let player = playerNode {
      // こうえんの主人公: いつもの動きを止めて、その動きを見せてから、いつもの動きにもどる。
      let script = playerScript
      player.removeAllActions()
      player.texture = poses.normal
      player.run(
        .sequence([
          .wait(forDuration: 0.4),
          .run { BodyMotionFX.play(motion, hero: player, poses: poses, reduceMotion: reduce) },
          .wait(forDuration: seconds + 0.6),
          .run { [weak self] in
            self?.bodyInProgress = false
            if let script { player.run(script) }
          },
        ]))
      return
    }
    // まちの左はし（はじめに見えるところ）に、立って見せる。
    let hero = SKSpriteNode(texture: poses.normal)
    hero.size = CGSize(width: objectSize * 1.1, height: objectSize * 1.1)
    hero.anchorPoint = CGPoint(x: 0.5, y: 0.04)
    // 見えているはんいの左がわ（カメラの位置から決める）。
    let visibleLeft = cameraNode.position.x - size.width / 2
    hero.position = CGPoint(x: visibleLeft + size.width * 0.22, y: size.height * 0.17)
    hero.zPosition = 20 - 0.17 * 20 + 0.5
    hero.alpha = 0
    hero.setScale(0.6)
    world.addChild(hero)
    // 夜に うとうとしている主人公は、動きを見せるあいだ かくす（同じ子が2人に見えないように）。
    dozerNode?.run(.sequence([.fadeOut(withDuration: 0.2), .wait(forDuration: seconds + 2.2), .fadeIn(withDuration: 0.4)]))
    let enter = SKAction.group([
      .fadeIn(withDuration: 0.3),
      {
        let pop = SKAction.scale(to: 1, duration: reduce ? 0.01 : 0.3)
        pop.timingMode = .easeOut
        return pop
      }(),
    ])
    hero.run(
      .sequence([
        enter, .wait(forDuration: 0.3),
        .run { BodyMotionFX.play(motion, hero: hero, poses: poses, reduceMotion: reduce) },
        .wait(forDuration: seconds + 0.8), .fadeOut(withDuration: 0.5),
        .run { [weak self] in self?.bodyInProgress = false }, .removeFromParent(),
      ]))
  }

  // MARK: 空が変わる（D172）

  /// 空のことばを書いた記録を渡す。10分の間に書いたことばの空が、40秒だけ見える（`SkyWeather`）。
  func setSky(_ records: [SkyRecord]) {
    skyRecords = records
    guard layer == .town else { return }
    applySky()
  }

  private func applySky() {
    guard layer == .town, size.width > 0, size.height > 0 else { return }
    guard
      let forecast = SkyWeather.forecast(records: skyRecords, now: Date(), shownSince: skyStart)
    else {
      removeSky()
      return
    }
    // 同じ空がもう出ているなら、そのまま。
    if let shown = shownSky, shown.effect == forecast.effect, shown.since == forecast.since,
      !skyNodes.isEmpty
    {
      return
    }
    removeSky()
    skyStart = forecast.since
    shownSky = forecast
    let layers = SkyFX.make(forecast.effect, size: size, reduceMotion: reduceMotion)
    // 空・太陽・雲（z -100〜-85）をおおい、丘（-80）より奥に置く。うすい色は、物の手前（100）。
    layers.back.zPosition = -84
    var nodes: [SKNode] = [layers.back]
    cameraNode.addChild(layers.back)
    if let front = layers.front {
      front.zPosition = 100
      cameraNode.addChild(front)
      nodes.append(front)
    }
    skyNodes = nodes
    let fadeIn = min(2, forecast.remaining)
    let hold = max(forecast.remaining - fadeIn - SkyWeather.fade, 0)
    for node in nodes {
      let target = node.alpha
      node.alpha = 0
      node.run(
        .sequence([
          .fadeAlpha(to: target, duration: fadeIn), .wait(forDuration: hold),
          .fadeOut(withDuration: SkyWeather.fade), .removeFromParent(),
        ]))
    }
    // 空のことばの空が出ているあいだは、時間帯の色と あかりを消す（空のことばが勝つ。D172）。
    setPhaseLighting(shown: false, duration: fadeIn)
    layers.back.run(
      .sequence([
        .wait(forDuration: fadeIn + hold),
        .run { [weak self] in self?.setPhaseLighting(shown: true, duration: SkyWeather.fade) },
      ]))
  }

  private func removeSky() {
    let hadSky = !skyNodes.isEmpty
    for node in skyNodes { node.removeFromParent() }
    skyNodes = []
    shownSky = nil
    if hadSky { setPhaseLighting(shown: true, duration: 0.3) }
  }

  private static func role(of kind: WordKind) -> TownRole {
    switch kind {
    case .vehicle: .vehicle
    case .flyer: .flyer
    case .animal, .clothes, .scenery, .swimmer, .sky, .plaything, .bodyAction, .furniture,
      .seasonal:
      .animal
    }
  }

  func shape(
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
  private func addScenery(
    to world: SKNode, landWidth width: CGFloat, originX: CGFloat,
    avoiding landmarkSpans: [ClosedRange<Double>] = []
  ) {
    let h = size.height
    let horizon = h * 0.36

    // 奥の丘（2段）。
    var x: CGFloat = 0
    var i = 0
    while x < worldWidth + 400 {
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
        SKShapeNode(rect: CGRect(x: originX, y: 0, width: width, height: horizon)),
        fill: UIColor(red: 0.62, green: 0.82, blue: 0.46, alpha: 1), z: -50))
    world.addChild(
      shape(
        SKShapeNode(
          rect: CGRect(x: originX, y: horizon - h * 0.012, width: width, height: h * 0.012)),
        fill: UIColor(red: 0.52, green: 0.75, blue: 0.38, alpha: 1), z: -49))
    world.addChild(
      shape(
        SKShapeNode(
          rect: CGRect(x: originX - 20, y: h * 0.02, width: width + 40, height: h * 0.17)),
        fill: UIColor(red: 0.83, green: 0.76, blue: 0.68, alpha: 1), z: -45))
    // 道の真ん中の点線（1つのノード）。
    let center = CGMutablePath()
    center.move(to: CGPoint(x: originX, y: h * 0.105))
    center.addLine(to: CGPoint(x: originX + width, y: h * 0.105))
    let dashes = center.copy(dashingWithPhase: 0, lengths: [34, 26])
    let dashLine = SKShapeNode(path: dashes)
    dashLine.strokeColor = UIColor(white: 1, alpha: 0.9)
    dashLine.lineWidth = 7
    dashLine.lineCap = .round
    dashLine.zPosition = -44
    world.addChild(dashLine)

    // 木と家（草の向こう側。物の動く範囲より奥）。大きな景色のはばは あける。
    let spots = TownLayout.backdrop(
      TownLayout.backdropSpots(minX: Double(originX), width: Double(width), unit: Double(unit)),
      avoiding: landmarkSpans)
    for spot in spots {
      if spot.isHouse {
        addHouse(world, x: CGFloat(spot.x), base: horizon + h * 0.015, index: spot.index)
      } else {
        addTree(world, x: CGFloat(spot.x), base: horizon + h * 0.01, index: spot.index)
      }
    }

    // 雲（ゆっくり左右にゆれる）。水べの上にも出る。
    var cloudX: CGFloat = 200
    var cloudIndex = 0
    while cloudX < worldWidth {
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
      puff.fillColor = cloudColor
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
    if phase == .night { lightWindow(window, side: w * 0.2, in: world) }
  }

  /// 物ひとつ。持ち場の中で動きまわる。足もとの高さ（奥行き）で大きさと手前・奥が決まる。
  private func makeObject(_ object: PlacedObject, slot: TownSlot, objectSize: CGFloat)
    -> SKSpriteNode
  {
    // 絵は、保存した名前ではなく、ことばから決める（前に置いた物も新しい絵になる）。
    let image = WordArt.image(word: object.baseWord, size: 320)
    let node = SKSpriteNode(texture: SKTexture(image: image))
    node.name = object.id.uuidString
    let side = objectSize * CGFloat(slot.scale)
    node.size = CGSize(width: side, height: side)
    node.anchorPoint = slot.role == .flyer ? CGPoint(x: 0.5, y: 0.5) : CGPoint(x: 0.5, y: 0.08)
    node.position = CGPoint(x: slot.startX, y: size.height * CGFloat(slot.yFraction))
    // 空の物は、雲（-85）と太陽より手前、丘より手前。地面の物は、足もとが低いほど手前。
    node.zPosition =
      slot.role == .flyer ? 30 - CGFloat(slot.lane) : 20 - CGFloat(slot.yFraction) * 20
    let range = CGFloat(slot.minX)...CGFloat(slot.maxX)
    switch slot.role {
    case .vehicle: driveVehicle(node, range: range, index: slot.index)
    case .animal:
      if WordCatalog.crawls(object.baseWord) {
        crawlAnimal(node, range: range, index: slot.index)
      } else {
        trotAnimal(node, range: range, index: slot.index)
      }
    case .flyer: glide(node, word: object.baseWord, range: range, index: slot.index)
    }
    return node
  }

  /// 景色になる物ひとつ。丘の手前の草に立つ。動物より奥（zPosition が小さい）に描く（D168）。
  private func makeScenery(_ object: PlacedObject, place: SceneryPlace, objectSize: CGFloat)
    -> SKSpriteNode
  {
    // 大きな景色（やま・たき・たてもの）は、奥の列に立って大きくなり、ほかの景色より奥に描く（D174）。
    let landmarkFactor = WordArt.landmarkFactor(object.baseWord)
    let landmark = landmarkFactor != nil
    let place = landmarkFactor.map { TownLayout.landmarkPlace(place, factor: $0) } ?? place
    let image = WordArt.image(word: object.baseWord, size: 320)
    let node = SKSpriteNode(texture: SKTexture(image: image))
    node.name = object.id.uuidString
    let side = objectSize * CGFloat(place.scale) * CGFloat(WordArt.scenerySizeFactor(object.baseWord))
    node.size = CGSize(width: side, height: side)
    node.anchorPoint = CGPoint(x: 0.5, y: landmark ? 0 : 0.05)
    node.position = CGPoint(x: place.x, y: size.height * CGFloat(place.yFraction))
    // 動物の最も奥の段（z=13.6）より奥。手前の列ほど手前。大きな景色は、背景の木・家と同じ奥（丘の手前、草の向こう）。
    // 大きい物ほど奥。
    node.zPosition = landmark ? -60 - min(CGFloat(landmarkFactor ?? 0), 10) / 10 : 2 + CGFloat(1 - place.row) * 2
    if Rolling.isRollable(object.baseWord), !landmark {
      // 丸い くだもの・やさい・木の実: 傾けると転がる。押しても転がる（D133）。
      makeRoller(node, word: object.baseWord)
    }
    if WordArt.sways(object.baseWord) {
      // 花・草・木: ほんのすこし、根もとからゆれる（動きを減らすときは止める）。
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
      // くだもの・やさい・たてもの など: 出てくるときにひとはずみして、止まる。
      let target = node.size
      node.size = CGSize(width: target.width * 0.5, height: target.height * 0.5)
      node.run(
        .sequence([
          .wait(forDuration: Double(place.index % 6) * 0.12),
          .group([
            .resize(toWidth: target.width, height: target.height, duration: 0.3),
            .sequence([.moveBy(x: 0, y: 22, duration: 0.15), .moveBy(x: 0, y: -22, duration: 0.15)]
            ),
          ]),
          // しんごう・ふみきりは、出てきたあとに あかりが かわる（D174）。
          .run { LampMotion.attach(to: node, word: object.baseWord, reduceMotion: false) },
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
    if word == "ほたる", !reduceMotion {
      // ほたるは、おしりが ぽわっと光るように、すこし明るさが変わる。
      node.run(
        .repeatForever(
          .sequence([.fadeAlpha(to: 0.7, duration: 1.1), .fadeAlpha(to: 1, duration: 1.1)])))
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

  /// はう物（かたつむり・てんとうむし・かぶとむし。D169）: はずまず、ゆっくり進み、ときどき止まって向きを変える。
  private func crawlAnimal(_ node: SKSpriteNode, range: ClosedRange<CGFloat>, index: Int) {
    let speed: CGFloat = reduceMotion ? 8 : 18
    let sway = SKAction.sequence([
      .rotate(toAngle: 0.03, duration: 0.6), .rotate(toAngle: -0.03, duration: 0.6),
    ])
    func crawl(to x: CGFloat, from start: CGFloat) -> SKAction {
      let duration = Double(max(abs(x - start), 1) / speed)
      let move = SKAction.moveTo(x: x, duration: duration)
      guard !reduceMotion else { return move }
      return .group([.repeat(sway, count: Int(duration / 1.2) + 1), move])
    }
    let pause = SKAction.wait(forDuration: 1.5 + Double(index % 3) * 0.5)
    let face = abs(node.xScale)
    node.run(
      .sequence([
        .wait(forDuration: Double(index % 4) * 0.3),
        crawl(to: range.upperBound, from: node.position.x), pause,
        .repeatForever(
          .sequence([
            .scaleX(to: -face, duration: 0.2),
            crawl(to: range.lowerBound, from: range.upperBound), pause,
            .scaleX(to: face, duration: 0.2),
            crawl(to: range.upperBound, from: range.lowerBound), pause,
          ])),
      ]))
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

  // MARK: 水べ（D170）

  /// 右はしの水べ。砂浜・なみの線・ゆれるなみのきらめき。生きものがいるときだけ出る。
  private func addWater(to world: SKNode, water: WaterArea) {
    let h = size.height
    let horizon = h * 0.36
    let left = CGFloat(water.minX)
    let right = CGFloat(water.maxX)
    // 水: 地平線まで。上のふちはゆるいなみ。
    let body = CGMutablePath()
    body.move(to: CGPoint(x: left, y: 0))
    body.addLine(to: CGPoint(x: left, y: horizon))
    var x = left
    while x < right + 60 {
      body.addQuadCurve(
        to: CGPoint(x: x + 60, y: horizon),
        control: CGPoint(x: x + 30, y: horizon + (Int((x - left) / 60) % 2 == 0 ? 8 : -8)))
      x += 60
    }
    body.addLine(to: CGPoint(x: x, y: 0))
    body.closeSubpath()
    let sea = SKShapeNode(path: body)
    sea.fillColor = UIColor(red: 0.45, green: 0.77, blue: 0.95, alpha: 1)
    sea.strokeColor = .clear
    sea.zPosition = -46
    world.addChild(sea)
    // 手前ほど深い色（1つの帯）。
    let deep = SKShapeNode(rect: CGRect(x: left, y: 0, width: right - left + 60, height: h * 0.1))
    deep.fillColor = UIColor(red: 0.36, green: 0.68, blue: 0.9, alpha: 1)
    deep.strokeColor = .clear
    deep.zPosition = -45.5
    world.addChild(deep)
    // 水面のうすい線（なみの線）。
    let surface = CGMutablePath()
    surface.move(to: CGPoint(x: left, y: horizon - 7))
    x = left
    while x < right + 60 {
      surface.addQuadCurve(
        to: CGPoint(x: x + 60, y: horizon - 7),
        control: CGPoint(x: x + 30, y: horizon - 7 + (Int((x - left) / 60) % 2 == 0 ? 8 : -8)))
      x += 60
    }
    let surfaceLine = SKShapeNode(path: surface)
    surfaceLine.strokeColor = UIColor(white: 1, alpha: 0.75)
    surfaceLine.lineWidth = 5
    surfaceLine.lineCap = .round
    surfaceLine.zPosition = -45
    world.addChild(surfaceLine)
    // 砂浜: 左がまっすぐ（草の下）、右がなみ打ちぎわ。白い あわのふち。
    let sandEnd = CGFloat(water.swimMinX) - 36
    let sand = CGMutablePath()
    sand.move(to: CGPoint(x: left - 24, y: 0))
    sand.addLine(to: CGPoint(x: left - 24, y: horizon))
    sand.addLine(to: CGPoint(x: sandEnd, y: horizon))
    var y = horizon
    while y > 0 {
      let next = max(y - h * 0.09, 0)
      let bulge: CGFloat = Int(y / (h * 0.09)) % 2 == 0 ? 16 : -10
      sand.addQuadCurve(
        to: CGPoint(x: sandEnd, y: next), control: CGPoint(x: sandEnd + bulge, y: (y + next) / 2))
      y = next
    }
    sand.closeSubpath()
    let beach = SKShapeNode(path: sand)
    beach.fillColor = UIColor(red: 0.98, green: 0.91, blue: 0.7, alpha: 1)
    beach.strokeColor = .clear
    beach.zPosition = -43
    world.addChild(beach)
    // 打ちぎわの白い あわ（右のふちだけ）。
    let foam = CGMutablePath()
    foam.move(to: CGPoint(x: sandEnd, y: horizon))
    y = horizon
    while y > 0 {
      let next = max(y - h * 0.09, 0)
      let bulge: CGFloat = Int(y / (h * 0.09)) % 2 == 0 ? 16 : -10
      foam.addQuadCurve(
        to: CGPoint(x: sandEnd, y: next), control: CGPoint(x: sandEnd + bulge, y: (y + next) / 2))
      y = next
    }
    let foamLine = SKShapeNode(path: foam)
    foamLine.strokeColor = UIColor(white: 1, alpha: 0.85)
    foamLine.lineWidth = 6
    foamLine.lineCap = .round
    foamLine.zPosition = -42.5
    world.addChild(foamLine)
    // なみのきらめき: 小さな白いなみの線。ゆっくり横にゆれる。
    let glintCount = max(Int((right - left) / 150), 4)
    for index in 0..<glintCount {
      let glint = SKShapeNode(path: Self.glintPath(width: 38 + CGFloat(index % 3) * 10))
      glint.strokeColor = UIColor(white: 1, alpha: 0.7)
      glint.lineWidth = 4
      glint.lineCap = .round
      glint.position = CGPoint(
        x: left + 110 + CGFloat(index) * (right - left - 140) / CGFloat(glintCount),
        y: h * (0.05 + CGFloat((index * 5) % 6) * 0.05))
      glint.zPosition = -44
      if !reduceMotion {
        let drift = 14 + CGFloat(index % 3) * 6
        glint.run(
          .sequence([
            .wait(forDuration: Double(index % 4) * 0.5),
            .repeatForever(
              .sequence([
                .moveBy(x: drift, y: 0, duration: 2.4), .moveBy(x: -drift, y: 0, duration: 2.4),
              ])),
          ]))
      }
      world.addChild(glint)
    }
  }

  private static func glintPath(width: CGFloat) -> CGPath {
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 0, y: 0))
    path.addQuadCurve(to: CGPoint(x: width / 2, y: 0), control: CGPoint(x: width / 4, y: 9))
    path.addQuadCurve(to: CGPoint(x: width, y: 0), control: CGPoint(x: width * 0.75, y: -9))
    return path
  }

  /// 水の生きもの。水の中の持ち場だけを動く（D170）。
  private func makeSwimmer(_ object: PlacedObject, slot: SwimSlot, objectSize: CGFloat)
    -> SKSpriteNode
  {
    let image = WordArt.image(word: object.baseWord, size: 320)
    let node = SKSpriteNode(texture: SKTexture(image: image))
    node.name = object.id.uuidString
    let side = objectSize * CGFloat(slot.scale)
    node.size = CGSize(width: side, height: side)
    node.position = CGPoint(x: slot.startX, y: size.height * CGFloat(slot.yFraction))
    node.zPosition = 20 - CGFloat(slot.yFraction) * 20
    let range = CGFloat(slot.minX)...CGFloat(slot.maxX)
    let style = WordArt.swimStyle(object.baseWord)
    if style == .frog { addLilyPad(to: node) }
    swim(node, style: style, range: range, index: slot.index)
    return node
  }

  /// かえるが のる はっぱ（かえるといっしょに動く）。
  private func addLilyPad(to node: SKSpriteNode) {
    let pad = SKShapeNode(
      ellipseOf: CGSize(width: node.size.width * 0.95, height: node.size.height * 0.22))
    pad.fillColor = UIColor(red: 0.42, green: 0.75, blue: 0.4, alpha: 1)
    pad.strokeColor = Self.outline
    pad.lineWidth = 4
    pad.position = CGPoint(x: 0, y: -node.size.height * 0.4)
    pad.zPosition = -1
    node.addChild(pad)
  }

  /// 泳ぎ方（`WordArt.SwimStyle`）。横にゆく物は、はしで向きを変える。
  private func swim(
    _ node: SKSpriteNode, style: WordArt.SwimStyle, range: ClosedRange<CGFloat>, index: Int
  ) {
    let baseY = node.position.y
    let reduce = reduceMotion
    let speed: CGFloat
    switch style {
    case .fish: speed = reduce ? 20 : 55
    case .dolphin: speed = reduce ? 25 : 70
    case .whale: speed = reduce ? 8 : 22
    case .bob: speed = reduce ? 4 : 10
    case .jelly: speed = reduce ? 4 : 12
    case .crab: speed = reduce ? 15 : 45
    case .turtle: speed = reduce ? 6 : 18
    case .star: speed = reduce ? 2 : 5
    case .frog: speed = reduce ? 10 : 30
    case .tadpole: speed = reduce ? 15 : 50
    }
    let flips = style != .crab && style != .jelly && style != .bob
    let face = abs(node.xScale)
    func leg(to x: CGFloat, from start: CGFloat) -> SKAction {
      .moveTo(x: x, duration: Double(max(abs(x - start), 1) / speed))
    }
    let pause = SKAction.wait(forDuration: style == .crab ? 0.7 : 0.1)
    var turnLeft = SKAction.wait(forDuration: 0)
    var turnRight = SKAction.wait(forDuration: 0)
    if flips {
      turnLeft = .scaleX(to: -face, duration: 0.2)
      turnRight = .scaleX(to: face, duration: 0.2)
    }
    node.run(
      .sequence([
        .wait(forDuration: Double(index % 4) * 0.3),
        leg(to: range.upperBound, from: node.position.x), pause,
        .repeatForever(
          .sequence([
            turnLeft, leg(to: range.lowerBound, from: range.upperBound), pause,
            turnRight, leg(to: range.upperBound, from: range.lowerBound), pause,
          ])),
      ]))
    guard !reduce else { return }
    let phase = Double(index % 4) * 0.4
    func repeatBob(_ amplitude: CGFloat, _ period: Double) {
      let bob = SKAction.sequence([
        .moveTo(y: baseY + amplitude, duration: period / 2),
        .moveTo(y: baseY - amplitude, duration: period / 2),
      ])
      bob.timingMode = .easeInEaseOut
      node.run(.sequence([.wait(forDuration: phase), .repeatForever(bob)]), withKey: "bob")
    }
    let h = size.height
    switch style {
    case .fish:
      // 横にゆれながら、すこし上下に波うつ。
      repeatBob(h * 0.012, 1.4)
      let wag = SKAction.sequence([
        .rotate(toAngle: 0.07, duration: 0.35), .rotate(toAngle: -0.07, duration: 0.35),
      ])
      node.run(.repeatForever(wag))
    case .dolphin:
      repeatBob(h * 0.028, 1.8)
      let arc = SKAction.sequence([
        .rotate(toAngle: 0.22, duration: 0.9), .rotate(toAngle: -0.22, duration: 0.9),
      ])
      arc.timingMode = .easeInEaseOut
      node.run(.repeatForever(arc))
    case .whale:
      repeatBob(h * 0.012, 3.6)
      let breathe = SKAction.sequence([
        .scaleY(to: 0.95, duration: 1.8), .scaleY(to: 1.0, duration: 1.8),
      ])
      node.run(.repeatForever(breathe))
    case .bob:
      repeatBob(h * 0.022, 2.2)
      let squash = SKAction.sequence([
        .group([.scaleY(to: 0.93, duration: 1.1), .scaleX(to: face * 1.05, duration: 1.1)]),
        .group([.scaleY(to: 1.0, duration: 1.1), .scaleX(to: face, duration: 1.1)]),
      ])
      node.run(.repeatForever(squash))
    case .jelly:
      repeatBob(h * 0.04, 2.6)
      let pulse = SKAction.sequence([
        .group([.scaleY(to: 0.88, duration: 0.7), .scaleX(to: face * 1.08, duration: 0.7)]),
        .group([.scaleY(to: 1.06, duration: 0.9), .scaleX(to: face * 0.96, duration: 0.9)]),
      ])
      pulse.timingMode = .easeInEaseOut
      node.run(.repeatForever(pulse))
    case .crab:
      let scuttle = SKAction.sequence([
        .moveBy(x: 0, y: h * 0.008, duration: 0.12), .moveBy(x: 0, y: -h * 0.008, duration: 0.12),
      ])
      node.run(.repeatForever(scuttle))
    case .turtle:
      repeatBob(h * 0.014, 3.0)
      let paddle = SKAction.sequence([
        .rotate(toAngle: 0.06, duration: 0.9), .rotate(toAngle: -0.06, duration: 0.9),
      ])
      node.run(.repeatForever(paddle))
    case .star:
      repeatBob(h * 0.008, 3.2)
      let sway = SKAction.sequence([
        .rotate(toAngle: 0.14, duration: 1.6), .rotate(toAngle: -0.14, duration: 1.6),
      ])
      sway.timingMode = .easeInEaseOut
      node.run(.repeatForever(sway))
    case .frog:
      let hop = SKAction.sequence([
        .moveBy(x: 0, y: h * 0.03, duration: 0.2), .moveBy(x: 0, y: -h * 0.03, duration: 0.2),
        .wait(forDuration: 0.9),
      ])
      node.run(.repeatForever(hop))
    case .tadpole:
      let wiggle = SKAction.sequence([
        .rotate(toAngle: 0.18, duration: 0.15), .rotate(toAngle: -0.18, duration: 0.15),
      ])
      node.run(.repeatForever(wiggle))
      repeatBob(h * 0.01, 1.2)
    }
  }

  // MARK: こうえん（D173）

  /// 左はしのこうえん。明るい芝生・小道・さく・ベンチ・木・「こうえん」の看板。物があるときだけ出る。
  private func addPark(to world: SKNode, park: ParkArea) {
    let h = size.height
    let horizon = h * 0.36
    let left = CGFloat(park.minX)
    let right = CGFloat(park.maxX)
    let wood = UIColor(red: 0.95, green: 0.78, blue: 0.5, alpha: 1)
    // 芝生。まちの草より明るい。刈りあとの しまを うすく重ねる。
    world.addChild(
      shape(
        SKShapeNode(rect: CGRect(x: left - 40, y: 0, width: right - left + 40, height: horizon)),
        fill: UIColor(red: 0.6, green: 0.85, blue: 0.42, alpha: 1), z: -50))
    var x = left - 40
    var stripe = 0
    while x < right {
      if stripe % 2 == 0 {
        world.addChild(
          shape(
            SKShapeNode(rect: CGRect(x: x, y: 0, width: 130, height: horizon)),
            fill: UIColor(red: 0.67, green: 0.89, blue: 0.5, alpha: 0.55), z: -49.5))
      }
      x += 130
      stripe += 1
    }
    world.addChild(
      shape(
        SKShapeNode(
          rect: CGRect(x: left - 40, y: horizon - h * 0.012, width: right - left + 40, height: h * 0.012)),
        fill: UIColor(red: 0.5, green: 0.76, blue: 0.36, alpha: 1), z: -49))
    // 手前の小道（ゆるやかな なみ）。
    let path = CGMutablePath()
    path.move(to: CGPoint(x: left - 40, y: 0))
    path.addLine(to: CGPoint(x: left - 40, y: h * 0.05))
    x = left - 40
    var k = 0
    while x < right + 40 {
      path.addQuadCurve(
        to: CGPoint(x: x + 90, y: h * 0.05),
        control: CGPoint(x: x + 45, y: h * (k % 2 == 0 ? 0.062 : 0.038)))
      x += 90
      k += 1
    }
    path.addLine(to: CGPoint(x: x, y: 0))
    path.closeSubpath()
    world.addChild(shape(SKShapeNode(path: path), fill: UIColor(red: 0.89, green: 0.8, blue: 0.64, alpha: 1), z: -45))
    // 小道の石（小さなだ円）。
    x = left + 30
    k = 0
    while x < right {
      let pebble = shape(
        SKShapeNode(ellipseOf: CGSize(width: 18 + CGFloat(k % 3) * 6, height: 8)),
        fill: UIColor(red: 0.97, green: 0.93, blue: 0.84, alpha: 1), z: -44)
      pebble.position = CGPoint(x: x, y: h * (0.018 + CGFloat(k % 3) * 0.01))
      world.addChild(pebble)
      x += 120 + CGFloat(k % 2) * 40
      k += 1
    }
    // 花（小さな丸）。
    let flowers = [
      UIColor(red: 1, green: 0.62, blue: 0.7, alpha: 1), UIColor(red: 1, green: 0.88, blue: 0.4, alpha: 1),
      UIColor(white: 1, alpha: 1),
    ]
    for index in 0..<12 {
      let flower = shape(
        SKShapeNode(circleOfRadius: 6.5), fill: flowers[index % 3], line: 2.5, z: -48)
      flower.position = CGPoint(
        x: left + 60 + CGFloat((index * 97) % 100) / 100 * (right - left - 120),
        y: h * (0.075 + CGFloat((index * 53) % 100) / 100 * 0.26))
      world.addChild(flower)
    }
    // さく: 草のおくに、はしらを たてて、横木を2本わたす。
    let postHeight = h * 0.06
    let base = horizon - h * 0.002
    let posts = CGMutablePath()
    var postX = left + 20
    while postX < right - 10 {
      posts.addRoundedRect(
        in: CGRect(x: postX - 8, y: base, width: 16, height: postHeight), cornerWidth: 6, cornerHeight: 6)
      postX += 76
    }
    world.addChild(shape(SKShapeNode(path: posts), fill: wood, line: 4, z: -42))
    let rails = CGMutablePath()
    for fraction in [0.32, 0.7] as [CGFloat] {
      rails.addRoundedRect(
        in: CGRect(x: left - 20, y: base + postHeight * fraction - 5, width: right - left + 20, height: 10),
        cornerWidth: 5, cornerHeight: 5)
    }
    world.addChild(shape(SKShapeNode(path: rails), fill: wood, line: 3, z: -41.8))
    // 木。
    addTree(world, x: left + unit * 0.16, base: horizon + h * 0.01, index: 0)
    addTree(world, x: right - unit * 0.2, base: horizon + h * 0.01, index: 2)
    // ベンチ。
    let bench = SKNode()
    bench.position = CGPoint(x: left + (right - left) * 0.3, y: horizon + h * 0.004)
    bench.zPosition = -41
    let seatWidth = unit * 0.15
    let back = shape(
      SKShapeNode(rect: CGRect(x: -seatWidth / 2, y: unit * 0.045, width: seatWidth, height: unit * 0.03), cornerRadius: 5),
      fill: wood, line: 3.5, z: 0)
    let seat = shape(
      SKShapeNode(rect: CGRect(x: -seatWidth / 2 - 6, y: unit * 0.02, width: seatWidth + 12, height: unit * 0.025), cornerRadius: 5),
      fill: wood, line: 3.5, z: 0.1)
    bench.addChild(back)
    bench.addChild(seat)
    for side in [-1, 1] as [CGFloat] {
      let leg = shape(
        SKShapeNode(rect: CGRect(x: side * seatWidth * 0.4 - 5, y: -unit * 0.005, width: 10, height: unit * 0.03), cornerRadius: 3),
        fill: UIColor(red: 0.74, green: 0.52, blue: 0.34, alpha: 1), line: 3, z: -0.1)
      bench.addChild(leg)
    }
    world.addChild(bench)
    // 看板「こうえん」。さくの上に立つ。
    let signCenter = CGPoint(x: left + (right - left) * 0.62, y: h * 0.55)
    let boardSize = CGSize(width: unit * 0.36, height: unit * 0.1)
    for side in [-1, 1] as [CGFloat] {
      let post = shape(
        SKShapeNode(
          rect: CGRect(x: signCenter.x + side * boardSize.width * 0.36 - 7, y: horizon, width: 14, height: signCenter.y - horizon),
          cornerRadius: 5),
        fill: UIColor(red: 0.74, green: 0.52, blue: 0.34, alpha: 1), line: 4, z: -41.5)
      world.addChild(post)
    }
    let board = shape(
      SKShapeNode(rect: CGRect(origin: CGPoint(x: -boardSize.width / 2, y: -boardSize.height / 2), size: boardSize), cornerRadius: 16),
      fill: UIColor(red: 1, green: 0.93, blue: 0.7, alpha: 1), line: 5, z: -41)
    board.position = signCenter
    let label = SKLabelNode(text: "こうえん")
    label.fontName = "HiraMaruProN-W4"
    label.fontSize = unit * 0.06
    label.fontColor = Self.outline
    label.verticalAlignmentMode = .center
    label.horizontalAlignmentMode = .center
    label.zPosition = 0.1
    board.addChild(label)
    world.addChild(board)
  }

  /// こうえんの物と、遊ぶキャラクター。置き場所は、置いた順で8つを回る（`TownLayout.parkSlotIndex`）。
  private func addPlayEquipment(to world: SKNode, plan: TownLayout, objectSize: CGFloat) {
    let h = size.height
    var things: [(node: SKSpriteNode, slot: ParkSlot)] = []
    for (object, ordinal) in playObjects {
      let slot = plan.parkSlots[TownLayout.parkSlotIndex(ordinal: ordinal)]
      let image = WordArt.image(word: object.baseWord, size: 320)
      let node = SKSpriteNode(texture: SKTexture(image: image))
      node.name = object.id.uuidString
      let big: CGFloat =
        switch WordArt.playStyle(object.baseWord) {
        case .slide: 1.12
        case .sandbox: 1.05
        default: 1.0
        }
      let side = objectSize * CGFloat(slot.scale) * big
      node.size = CGSize(width: side, height: side)
      node.anchorPoint = CGPoint(x: 0.5, y: 0.05)
      node.position = CGPoint(x: slot.x, y: h * CGFloat(slot.yFraction))
      node.zPosition = 20 - CGFloat(slot.yFraction) * 20
      world.addChild(node)
      PlayMotion.start(
        node, word: object.baseWord, phase: Double(slot.index) * 0.37, reduceMotion: reduceMotion)
      things.append((node, slot))
    }
    guard let park = plan.park, !things.isEmpty else { return }
    addPlayer(to: world, things: things.reversed(), park: park, objectSize: objectSize)
  }

  /// こうえんで遊ぶキャラクター。いちばん新しい物のそばに立ち、数秒ごとに、ほかの物のところへ はねていって使う。
  private func addPlayer(
    to world: SKNode, things: [(node: SKSpriteNode, slot: ParkSlot)], park: ParkArea,
    objectSize: CGFloat
  ) {
    let h = size.height
    guard let normalImage = WordArt.image(asset: mainCharacter.assetName(.normal), size: 320),
      let happyImage = WordArt.image(asset: mainCharacter.assetName(.happy), size: 320)
    else { return }
    let normal = SKTexture(image: normalImage)
    let happy = SKTexture(image: happyImage)
    // 夜は、遊びのあいまに 目をとじて うとうとする（§3.5）。
    let sleep =
      phase.isSleepy
      ? WordArt.image(asset: mainCharacter.assetName(.sleep), size: 320).map(SKTexture.init(image:))
      : nil
    let player = SKSpriteNode(texture: sleep ?? normal)
    player.size = CGSize(width: objectSize * 0.85, height: objectSize * 0.85)
    player.anchorPoint = CGPoint(x: 0.5, y: 0.04)
    player.name = "player"
    struct Stop {
      let point: CGPoint
      let faceLeft: Bool
      let thing: SKSpriteNode
    }
    let stops: [Stop] = things.map { thing in
      let node = thing.node
      // 物の右がわに立つ。こうえんの右はしの物は、左がわ。
      let rightSide = node.position.x + node.size.width * 0.55 < CGFloat(park.maxX) - 20
      let dx = node.size.width * 0.55 * (rightSide ? 1 : -1)
      return Stop(
        point: CGPoint(x: node.position.x + dx, y: node.position.y - h * 0.035),
        faceLeft: rightSide, thing: node)
    }
    player.position = stops[0].point
    player.xScale = stops[0].faceLeft ? -1 : 1
    player.zPosition = 20 - (stops[0].point.y / h) * 20 + 0.5
    world.addChild(player)
    playerNode = player
    guard !reduceMotion else { return }
    func bounce() -> SKAction {
      let up = SKAction.moveBy(x: 0, y: h * 0.05, duration: 0.16)
      up.timingMode = .easeOut
      let down = SKAction.moveBy(x: 0, y: -h * 0.05, duration: 0.18)
      down.timingMode = .easeIn
      return .sequence([up, down])
    }
    var script: [SKAction] = []
    var current = stops[0].point
    for stop in stops {
      let distance = hypot(stop.point.x - current.x, stop.point.y - current.y)
      if distance > 1 {
        let duration = max(0.55, Double(distance) / 380)
        let arc = SKAction.sequence([
          .moveBy(x: 0, y: h * 0.1, duration: duration / 2), .moveBy(x: 0, y: -h * 0.1, duration: duration / 2),
        ])
        let travel = SKAction.move(to: stop.point, duration: duration)
        travel.timingMode = .easeInEaseOut
        // 行く向きを向いてから、はねていく。着いたら、物のほうを向く。
        let headingLeft = stop.point.x < current.x
        script.append(.scaleX(to: headingLeft ? -1 : 1, duration: 0.12))
        script.append(.group([travel, arc]))
        script.append(.scaleX(to: stop.faceLeft ? -1 : 1, duration: 0.12))
        script.append(
          .run { [weak player] in
            player?.zPosition = 20 - (stop.point.y / h) * 20 + 0.5
          })
      }
      current = stop.point
      let thing = stop.thing
      script.append(.run { [weak player] in player?.texture = happy })
      script.append(.run { [weak thing] in if let thing { PlayMotion.react(thing) } })
      script.append(bounce())
      script.append(bounce())
      script.append(.wait(forDuration: 1.6))
      script.append(.run { [weak player] in player?.texture = normal })
      if let sleep {
        script.append(.wait(forDuration: 1.0))
        script.append(.run { [weak player] in player?.texture = sleep })
        script.append(Self.doze(seconds: 4.2))
        script.append(.run { [weak player] in player?.texture = normal })
        script.append(.wait(forDuration: 0.6))
      } else {
        script.append(.wait(forDuration: 2.6))
      }
    }
    // 1つしか物がないときは、同じ場所で ときどき使う。最後に、はじめの物へ もどる。
    if stops.count > 1, let first = stops.first {
      let distance = hypot(first.point.x - current.x, first.point.y - current.y)
      let duration = max(0.55, Double(distance) / 380)
      let arc = SKAction.sequence([
        .moveBy(x: 0, y: h * 0.1, duration: duration / 2), .moveBy(x: 0, y: -h * 0.1, duration: duration / 2),
      ])
      let travel = SKAction.move(to: first.point, duration: duration)
      travel.timingMode = .easeInEaseOut
      script.append(.scaleX(to: first.point.x < current.x ? -1 : 1, duration: 0.12))
      script.append(.group([travel, arc]))
      script.append(.scaleX(to: first.faceLeft ? -1 : 1, duration: 0.12))
      script.append(
        .run { [weak player] in player?.zPosition = 20 - (first.point.y / h) * 20 + 0.5 })
    }
    let loop = SKAction.repeatForever(.sequence(script))
    playerScript = loop
    player.run(loop)
  }

  // MARK: 季節の飾り（§3.4）

  /// おまつりの はた: 柱を立てて、たるんだ ひもをわたし、色とりどりの三角の旗を下げる。
  /// 季節の飾りが 1つでも出ているあいだ出る。背景の木・家より手前、景色・動物より奥。
  private func addGarland(to world: SKNode, area: ClosedRange<Double>) {
    let h = size.height
    let garland = FestiveLayout.garland(in: area)
    let wood = UIColor(red: 0.95, green: 0.78, blue: 0.5, alpha: 1)
    let baseY = h * CGFloat(FestiveLayout.poleBaseY) - h * 0.004
    let topY = h * CGFloat(garland.poleTopY)
    let posts = CGMutablePath()
    for pole in garland.poles {
      posts.addRoundedRect(
        in: CGRect(x: CGFloat(pole) - 6, y: baseY, width: 12, height: topY - baseY + 4),
        cornerWidth: 5, cornerHeight: 5)
    }
    world.addChild(shape(SKShapeNode(path: posts), fill: wood, line: 4, z: -36))
    for pole in garland.poles {
      let knob = shape(
        SKShapeNode(circleOfRadius: 10), fill: UIColor(red: 1, green: 0.8, blue: 0.3, alpha: 1),
        line: 4, z: -35.5)
      knob.position = CGPoint(x: CGFloat(pole), y: topY + 8)
      world.addChild(knob)
    }
    // ひも（1つのノード）。柱と柱のあいだを、細かい折れ線で たるませる。
    let rope = CGMutablePath()
    let steps = 16
    for (a, b) in zip(garland.poles, garland.poles.dropFirst()) {
      for step in 0...steps {
        let x = a + (b - a) * Double(step) / Double(steps)
        // 柱の真上は、右の間の はじまりとして計算されるので、柱の高さにそろえる。
        let y = step == 0 || step == steps ? garland.poleTopY : FestiveLayout.ropeY(at: x, in: area)
        let point = CGPoint(x: CGFloat(x), y: h * CGFloat(y))
        if step == 0 { rope.move(to: point) } else { rope.addLine(to: point) }
      }
    }
    let ropeLine = SKShapeNode(path: rope)
    ropeLine.strokeColor = Self.outline
    ropeLine.lineWidth = 4
    ropeLine.lineCap = .round
    ropeLine.lineJoin = .round
    ropeLine.zPosition = -35
    world.addChild(ropeLine)
    // 旗: 色ごとに 1つのノード。ほんの少しだけ、色ごとに ずれて上下する。
    let colors = [
      UIColor(red: 0.9, green: 0.33, blue: 0.29, alpha: 1), UIColor(red: 0.97, green: 0.79, blue: 0.28, alpha: 1),
      UIColor(red: 0.49, green: 0.76, blue: 0.42, alpha: 1), UIColor(red: 0.31, green: 0.66, blue: 0.88, alpha: 1),
      UIColor(red: 0.97, green: 0.66, blue: 0.7, alpha: 1),
    ]
    let flagWidth = unit * 0.034
    let flagHeight = unit * 0.046
    for (index, color) in colors.enumerated() {
      let path = CGMutablePath()
      for flag in garland.flags where flag.color == index {
        let top = CGPoint(x: CGFloat(flag.x), y: h * CGFloat(flag.yFraction) - 1)
        path.move(to: CGPoint(x: top.x - flagWidth / 2, y: top.y))
        path.addLine(to: CGPoint(x: top.x + flagWidth / 2, y: top.y))
        path.addLine(to: CGPoint(x: top.x, y: top.y - flagHeight))
        path.closeSubpath()
      }
      let node = shape(SKShapeNode(path: path), fill: color, line: 3, z: -34.5)
      if !reduceMotion {
        let flutter = SKAction.sequence([
          .moveBy(x: 0, y: -3, duration: 1.1), .moveBy(x: 0, y: 3, duration: 1.1),
        ])
        flutter.timingMode = .easeInEaseOut
        node.run(.sequence([.wait(forDuration: Double(index) * 0.35), .repeatForever(flutter)]))
      }
      world.addChild(node)
    }
  }

  /// 季節の飾り ひとつ。つるす物は ひもの下で ゆれ、立てる物は草の奥に立ち、空の物（はなび）は 丘の向こうの空にあがる。
  private func addFestive(
    _ object: PlacedObject, spot: FestiveSpot, to world: SKNode, objectSize: CGFloat
  ) {
    let h = size.height
    let image = WordArt.image(word: object.baseWord, size: 320)
    let node = SKSpriteNode(texture: SKTexture(image: image))
    node.name = object.id.uuidString
    let side = objectSize * CGFloat(spot.scale)
    node.size = CGSize(width: side, height: side)
    node.position = CGPoint(x: CGFloat(spot.x), y: h * CGFloat(spot.yFraction))
    let motion = FestiveLayout.motion(spot.style, reduceMotion: reduceMotion)
    let phase = Double(spot.index) * 0.45
    switch spot.style {
    case .hang:
      // 絵の上のはしを支点にする（絵のまわりの すきまの分だけ下げる）。
      let content = WordArt.contentFrame(word: object.baseWord)
      node.anchorPoint = CGPoint(x: content.midX, y: 1 - content.minY)
      node.zPosition = -30
      if let ropeY = spot.ropeY {
        let string = SKShapeNode(
          rect: CGRect(x: -1.5, y: 0, width: 3, height: h * CGFloat(ropeY - spot.yFraction) + 2))
        string.fillColor = Self.outline
        string.strokeColor = .clear
        string.zPosition = -1
        node.addChild(string)
      }
    case .stand:
      let content = WordArt.contentFrame(word: object.baseWord)
      node.anchorPoint = CGPoint(x: content.midX, y: 1 - content.maxY)
      // 景色（2〜4）と動物より奥、背景の木・家と はた より手前。
      node.zPosition = 1
    case .sky:
      // 雲（-85）より手前、丘（-80）より奥。
      node.zPosition = -83
    }
    world.addChild(node)
    guard let motion else { return }
    if motion.angle > 0 {
      let angle = CGFloat(motion.angle)
      let sway = SKAction.sequence([
        .rotate(toAngle: angle, duration: motion.period / 4),
        .rotate(toAngle: -angle, duration: motion.period / 2),
        .rotate(toAngle: 0, duration: motion.period / 4),
      ])
      sway.timingMode = .easeInEaseOut
      node.run(.sequence([.wait(forDuration: phase), .repeatForever(sway)]))
    }
    if motion.pulse > 0 {
      let pulse = SKAction.sequence([
        .group([
          .scale(to: 1 + CGFloat(motion.pulse), duration: motion.period / 2),
          .fadeAlpha(to: 1, duration: motion.period / 2),
        ]),
        .group([
          .scale(to: 1 - CGFloat(motion.pulse), duration: motion.period / 2),
          .fadeAlpha(to: 0.88, duration: motion.period / 2),
        ]),
      ])
      pulse.timingMode = .easeInEaseOut
      node.run(.sequence([.wait(forDuration: phase), .repeatForever(pulse)]))
    }
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
      let image = WordArt.image(word: object.baseWord, size: 240)
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
    // 横木は、段ごとに1本（着る物が増えて2段目からも出る。D178）。
    if childNode(withName: "rail\(row)") == nil {
      let rail = SKShapeNode(
        rect: CGRect(x: 40, y: railY, width: size.width - 80, height: 6), cornerRadius: 3)
      rail.fillColor = UIColor(red: 0.55, green: 0.38, blue: 0.22, alpha: 1)
      rail.strokeColor = .clear
      rail.name = "rail\(row)"
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
