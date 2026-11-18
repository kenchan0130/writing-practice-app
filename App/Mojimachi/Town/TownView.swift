import SpriteKit
import SwiftUI

/// わたしのまち（試作。D8・D53）。乗り物と動物は動きまわり、服は横木にかかって揺れる（D53）。
struct TownView: View {
  private let store = ProgressStore.shared
  @State private var scene: TownScene

  init(layer: TownScene.Layer = .town) {
    _scene = State(initialValue: TownScene(layer: layer))
  }

  /// まちの看板（「ゆうとの まち」。呼び名がなければ「わたしの まち」。§3.9）。
  private var title: String {
    let name = store.currentProfile?.name.trimmingCharacters(in: .whitespaces) ?? ""
    let base = scene.layer == .closet ? "クローゼット" : "まち"
    return name.isEmpty ? (scene.layer == .closet ? "わたしの クローゼット" : "わたしの まち") : "\(name)の \(base)"
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(title).font(.learning(40)).foregroundStyle(Theme.ink)
      GeometryReader { proxy in
        SpriteView(scene: scene)
          .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.paper))
          .softShadow()
          .onAppear {
            scene.size = proxy.size
            #if DEBUG
              debugSeedTown(store)
            #endif
            scene.show(store.placed)
          }
          .onChange(of: store.placed) { _, placed in scene.show(placed) }
      }
    }
    .padding(32)
  }
}

#if DEBUG
  /// 確かめ用: `-seedTown YES` で、3つの型を1つずつ（くるま・いぬ・ねこ・うま・ふく・ぼうし）置く。
  @MainActor func debugSeedTown(_ store: ProgressStore) {
    guard UserDefaults.standard.bool(forKey: "seedTown"), store.placed.isEmpty else { return }
    let seeds = ["くるま", "いぬ", "でんしゃ", "ねこ", "ふく", "うま", "ぼうし", "ふね", "ゆかた"]
    for text in seeds {
      guard let item = WordArt.words.first(where: { $0.entry.text == text }) else {
        continue
      }
      store.place(PlacedObject(word: text, symbol: item.asset, kind: item.entry.kind))
    }
  }
#else
  @MainActor func debugSeedTown(_ store: ProgressStore) {}
#endif

/// まちの場面（SpriteKit）。空・草・置いた物。乗り物と動物は動きまわり、服は横木にかかる（D53）。
final class TownScene: SKScene {
  /// まち（乗り物と動物）か、クローゼット（服）か。
  enum Layer { case town, closet }
  let layer: Layer
  private var shown: Set<UUID> = []
  /// 横木にかけた服の数（かけ場所の番号に使う）。
  private var shownClothes = 0

  init(layer: Layer = .town) {
    self.layer = layer
    super.init(size: CGSize(width: 1000, height: 700))
    scaleMode = .resizeFill
    backgroundColor =
      layer == .closet
      ? UIColor(red: 1, green: 0.93, blue: 0.84, alpha: 1)
      : UIColor(red: 0.78, green: 0.9, blue: 1, alpha: 1)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func didChangeSize(_ oldSize: CGSize) {
    childNode(withName: "road")?.removeFromParent()
    guard layer == .town else { return }
    let road = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height * 0.3))
    road.fillColor = UIColor(red: 0.55, green: 0.75, blue: 0.45, alpha: 1)
    road.strokeColor = .clear
    road.name = "road"
    road.zPosition = -1
    addChild(road)
  }

  /// 置いた物の一覧に合わせて、足したり消したりする（子どもを切り替えたときなど）。
  func show(_ all: [PlacedObject]) {
    let placed = all.filter { ($0.kind == .clothes) == (layer == .closet) }
    let ids = Set(placed.map(\.id))
    for node in children
    where node.name.flatMap(UUID.init(uuidString:)).map({ !ids.contains($0) }) ?? false {
      node.removeFromParent()
    }
    shown = shown.intersection(ids)
    var clothesCount = 0
    for (index, object) in placed.enumerated() where !shown.contains(object.id) {
      shown.insert(object.id)
      // 絵は、保存した名前ではなく、ことばから決める（前に置いた物も新しい絵になる）。
      let image = WordArt.image(word: object.word, size: 240)
      let node = SKSpriteNode(texture: SKTexture(image: image))
      node.name = object.id.uuidString
      node.size = CGSize(width: 160, height: 160)
      addChild(node)
      switch object.kind {
      case .vehicle: roamVehicle(node, index: index)
      case .animal: roamAnimal(node, index: index)
      case .clothes:
        hangClothes(node, slot: clothesCount + shownClothes)
        clothesCount += 1
      }
    }
    shownClothes += clothesCount
  }

  /// 乗り物: 道をはずみながら行ったり来たりする。
  private func roamVehicle(_ node: SKSpriteNode, index: Int) {
    let lane = CGFloat(index % 3)
    // 物が重ならないよう、出発の位置と道の高さを散らす。
    let startX = 120 + CGFloat((index * 3) % 7) * max(size.width - 320, 100) / 7
    node.position = CGPoint(x: startX, y: size.height * 0.08 + lane * size.height * 0.07)
    node.zPosition = 3 - lane
    let distance = max(size.width - 240 - startX, 80)
    let duration = 3.0 + Double(index % 3)
    node.run(
      .repeatForever(
        .sequence([
          .moveBy(x: distance, y: 0, duration: duration),
          .scaleX(to: -1, duration: 0.1),
          .moveBy(x: -distance, y: 0, duration: duration),
          .scaleX(to: 1, duration: 0.1),
        ])))
  }

  /// 四つ足の動物: 草の上をぴょんぴょん歩き、ときどきたちどまって、向きを変える。
  private func roamAnimal(_ node: SKSpriteNode, index: Int) {
    let lane = CGFloat(index % 3)
    let startX = 160 + CGFloat((index * 5) % 7) * max(size.width - 380, 100) / 7
    node.position = CGPoint(x: startX, y: size.height * 0.14 + lane * size.height * 0.05)
    node.zPosition = 3 - lane
    let distance = max(size.width - 320 - startX, 100)
    let hop = SKAction.sequence([
      .moveBy(x: 0, y: 22, duration: 0.14), .moveBy(x: 0, y: -22, duration: 0.14),
    ])
    func trot(_ x: CGFloat) -> SKAction {
      let steps = max(Int(abs(x) / 50), 2)
      return .group([
        .repeat(hop, count: steps),
        .moveBy(x: x, y: 0, duration: 0.28 * Double(steps)),
      ])
    }
    let pause = SKAction.wait(forDuration: 0.8 + Double(index % 3) * 0.4)
    node.run(
      .repeatForever(
        .sequence([
          .wait(forDuration: Double(index % 4) * 0.3),
          trot(distance / 2), pause, trot(distance / 2), pause,
          .scaleX(to: -1, duration: 0.12),
          trot(-distance / 2), pause, trot(-distance / 2), pause,
          .scaleX(to: 1, duration: 0.12),
        ])))
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
