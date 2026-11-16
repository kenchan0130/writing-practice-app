import SpriteKit
import SwiftUI

/// わたしのまち（試作。D8・D53）。置いた乗り物が、道を行ったり来たりする（「動きまわる」型）。
struct TownView: View {
  private let store = ProgressStore.shared
  @State private var scene = TownScene()

  /// まちの看板（「ゆうとの まち」。呼び名がなければ「わたしの まち」。§3.9）。
  private var title: String {
    let name = store.currentProfile?.name.trimmingCharacters(in: .whitespaces) ?? ""
    return name.isEmpty ? "わたしの まち" : "\(name)の まち"
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(title).font(.system(size: 40, weight: .bold))
      GeometryReader { proxy in
        SpriteView(scene: scene)
          .clipShape(RoundedRectangle(cornerRadius: 16))
          .onAppear {
            scene.size = proxy.size
            #if DEBUG
              // 確かめ用: `-seedTown YES` で、乗り物を置いた状態にする。
              if UserDefaults.standard.bool(forKey: "seedTown"), store.placed.isEmpty {
                for item in PlaceholderArt.vehicleWords {
                  store.place(PlacedObject(word: item.word, symbol: item.symbol))
                }
              }
            #endif
            scene.show(store.placed)
          }
          .onChange(of: store.placed) { _, placed in scene.show(placed) }
      }
    }
    .padding(32)
  }
}

/// まちの場面（SpriteKit）。空・道・置いた物。
final class TownScene: SKScene {
  private var shown: Set<UUID> = []

  override init() {
    super.init(size: CGSize(width: 1000, height: 700))
    scaleMode = .resizeFill
    backgroundColor = UIColor(red: 0.78, green: 0.9, blue: 1, alpha: 1)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func didChangeSize(_ oldSize: CGSize) {
    childNode(withName: "road")?.removeFromParent()
    let road = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height * 0.3))
    road.fillColor = UIColor(red: 0.55, green: 0.75, blue: 0.45, alpha: 1)
    road.strokeColor = .clear
    road.name = "road"
    road.zPosition = -1
    addChild(road)
  }

  /// 置いた物の一覧に合わせて、足したり消したりする（子どもを切り替えたときなど）。
  func show(_ placed: [PlacedObject]) {
    let ids = Set(placed.map(\.id))
    for node in children
    where node.name.flatMap(UUID.init(uuidString:)).map({ !ids.contains($0) }) ?? false {
      node.removeFromParent()
    }
    shown = shown.intersection(ids)
    for (index, object) in placed.enumerated() where !shown.contains(object.id) {
      shown.insert(object.id)
      let image = PlaceholderArt.image(
        symbol: object.symbol, size: 240,
        color: UIColor(red: 0.85, green: 0.3, blue: 0.25, alpha: 1))
      let node = SKSpriteNode(texture: SKTexture(image: image))
      node.name = object.id.uuidString
      node.size = CGSize(width: 160, height: 160)
      let lane = CGFloat(index % 3)
      // 物が重ならないよう、出発の位置と道の高さを散らす。
      let startX = 120 + CGFloat((index * 3) % 7) * max(size.width - 320, 100) / 7
      node.position = CGPoint(x: startX, y: size.height * 0.08 + lane * size.height * 0.07)
      node.zPosition = 3 - lane
      addChild(node)
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
  }
}
