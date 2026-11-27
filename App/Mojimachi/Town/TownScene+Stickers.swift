import SpriteKit
import UIKit

/// まちに貼ったステッカー 1枚（§3.3・D54）。
struct TownSticker: Equatable {
  var id: UUID
  /// 絵の名前（アセットは `sticker-<名前>`）。
  var sticker: String
  /// 横の位置。陸のまちの左はしから、画面の高さ いくつ分か（こうえんの上は負）。
  var x: Double
  /// 縦の位置（0 = 下、1 = 上）。
  var y: Double
}

/// まちに貼るステッカー。貼った場所に そのまま残り、まちを動かすと いっしょに動く。
/// ステッカーを貼っているあいだ（`stickerMode`）は、押すと はがれる。
extension TownScene {
  private static let prefix = "sticker:"

  /// ステッカーの大きさ（押せる部分は `StickerArt.minimumTarget` 以上にする）。
  var stickerSide: CGFloat { max(unit * 0.17, 76) }

  private func point(of sticker: TownSticker) -> CGPoint {
    let half = stickerSide / 2
    let x = landMinX + CGFloat(sticker.x) * size.height
    let y = CGFloat(sticker.y) * size.height
    // まちの外には出さない（まちの広さが変わっても、はしで止める）。
    return CGPoint(
      x: min(max(x, half), max(worldWidth - half, half)),
      y: min(max(y, half), max(size.height - half, half)))
  }

  /// 画面の点（SpriteView の中の座標）を、ステッカーの位置にする。
  func stickerSpot(viewPoint: CGPoint) -> (x: Double, y: Double) {
    let point = convertPoint(fromView: viewPoint)
    return spot(at: point)
  }

  private func spot(at point: CGPoint) -> (x: Double, y: Double) {
    let h = max(size.height, 1)
    return (Double((point.x - landMinX) / h), Double(min(max(point.y / h, 0), 1)))
  }

  /// 押して貼るときの場所: いま見えている空の、かさならない所（貼ってある数で少しずつ ずらす）。
  func defaultStickerSpot(index: Int) -> (x: Double, y: Double) {
    let column = CGFloat(index % 5) - 2
    let row = CGFloat((index / 5) % 3)
    let point = CGPoint(
      x: cameraNode.position.x + column * size.width * 0.16,
      y: size.height * (0.86 - row * 0.17 - (index % 2 == 0 ? 0 : 0.05)))
    return spot(at: point)
  }

  /// 貼ってあるステッカーを渡す。足りない分を足し、なくなった分を消す。
  func setStickers(_ list: [TownSticker]) {
    let before = townStickers
    townStickers = list
    guard layer == .town, let world = childNode(withName: "world") else { return }
    let ids = Set(list.map(\.id))
    for node in world.children {
      guard let name = node.name, name.hasPrefix(Self.prefix),
        let id = UUID(uuidString: String(name.dropFirst(Self.prefix.count))), !ids.contains(id)
      else { continue }
      node.name = nil
      node.removeAllActions()
      // はがれる: 小さくなって消える。
      node.run(
        .sequence([
          .group([
            .scale(to: 0.3, duration: reduceMotion ? 0.01 : 0.18),
            .fadeOut(withDuration: reduceMotion ? 0.01 : 0.18),
          ]),
          .removeFromParent(),
        ]))
    }
    for sticker in list {
      if let node = world.childNode(withName: Self.prefix + sticker.id.uuidString) {
        node.position = point(of: sticker)
      } else {
        let isNew = !before.contains { $0.id == sticker.id }
        world.addChild(makeSticker(sticker, pops: isNew))
      }
    }
  }

  /// まちを作り直したとき、貼ってあるステッカーを置き直す。
  func addStickers(to world: SKNode) {
    for sticker in townStickers { world.addChild(makeSticker(sticker, pops: false)) }
  }

  private func makeSticker(_ sticker: TownSticker, pops: Bool) -> SKSpriteNode {
    let image = WordArt.image(asset: StickerArt.assetName(sticker.sticker), size: 256)
    let node = SKSpriteNode(texture: image.map(SKTexture.init(image:)))
    node.name = Self.prefix + sticker.id.uuidString
    node.size = CGSize(width: stickerSide, height: stickerSide)
    node.position = point(of: sticker)
    // 物（〜30）より手前、時間帯の うすい色（99）の下。
    node.zPosition = 60
    // 手で貼ったように、1枚ずつ少しだけ かたむける（ステッカーごとに決まった向き）。
    node.zRotation = StickerArt.tilt(of: sticker.id)
    if pops, !reduceMotion {
      node.setScale(1.5)
      node.alpha = 0.4
      let press = SKAction.scale(to: 0.92, duration: 0.12)
      press.timingMode = .easeIn
      let settle = SKAction.scale(to: 1, duration: 0.14)
      settle.timingMode = .easeOut
      node.run(.group([.fadeIn(withDuration: 0.1), .sequence([press, settle])]))
    }
    if stickerMode { wiggle(node) }
    return node
  }

  /// ステッカーを貼る・はがす あいだ は、貼ってあるステッカーが小さく ゆれて「押せる」と分かる。
  func setStickerMode(_ on: Bool) {
    guard on != stickerMode else { return }
    stickerMode = on
    guard let world = childNode(withName: "world") else { return }
    for node in world.children where node.name?.hasPrefix(Self.prefix) == true {
      node.removeAction(forKey: "wiggle")
      if on {
        wiggle(node)
      } else if let id = node.name.flatMap({ UUID(uuidString: String($0.dropFirst(Self.prefix.count))) }) {
        node.zRotation = StickerArt.tilt(of: id)
      }
    }
  }

  private func wiggle(_ node: SKNode) {
    guard !reduceMotion else { return }
    let base = node.zRotation
    let action = SKAction.sequence([
      .rotate(toAngle: base + 0.07, duration: 0.35), .rotate(toAngle: base - 0.07, duration: 0.7),
      .rotate(toAngle: base, duration: 0.35),
    ])
    action.timingMode = .easeInEaseOut
    node.run(.repeatForever(action), withKey: "wiggle")
  }

  /// ステッカーを押した。貼る・はがす あいだ なら はがす。ふだんは、ぷるんと ゆれるだけ。
  func tapSticker(at point: CGPoint) -> Bool {
    guard let world = childNode(withName: "world") else { return false }
    let reach = max(stickerSide, StickerArt.minimumTarget) / 2
    let hits = world.children.compactMap { node -> (node: SKNode, id: UUID, distance: CGFloat)? in
      guard let name = node.name, name.hasPrefix(Self.prefix),
        let id = UUID(uuidString: String(name.dropFirst(Self.prefix.count)))
      else { return nil }
      let dx = abs(node.position.x - point.x)
      let dy = abs(node.position.y - point.y)
      guard dx <= reach, dy <= reach else { return nil }
      return (node, id, hypot(dx, dy))
    }
    guard let hit = hits.min(by: { $0.distance < $1.distance }) else { return false }
    SoundPlayer.shared.play(.tap)
    if stickerMode {
      onStickerPeel?(hit.id)
    } else if !reduceMotion {
      hit.node.run(
        .sequence([.scale(to: 1.18, duration: 0.1), .scale(to: 0.95, duration: 0.1), .scale(to: 1, duration: 0.1)]))
    }
    return true
  }
}
