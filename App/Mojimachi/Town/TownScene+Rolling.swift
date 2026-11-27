import PracticeKit
import SpriteKit
import UIKit

/// 傾けると転がる物（§3.3・D133）。丸い くだもの・やさい・木の実が、iPad を傾けた向きへ少し転がる。
/// 押しても転がる（傾きのセンサーのない Mac でも同じ遊び方）。動きの計算は `Rolling`。
/// もとの場所から少ししか動かず、陸のまちの外へは出ない。「動きを減らす」なら転がらない。
struct Roller {
  let node: SKSpriteNode
  /// もとの場所。
  let homeX: CGFloat
  /// 転がる半径（中身の高さの半分）。
  let radius: CGFloat
  /// ずれの動ける はんい（ポイント）。
  let range: ClosedRange<Double>
  var state = RollState()
}

extension TownScene {
  /// 景色の物を、転がる物にする。絵の中身の真ん中を軸にして回るように、支点を移す。
  func makeRoller(_ node: SKSpriteNode, word: String) {
    guard !reduceMotion else { return }
    let content = WordArt.contentFrame(word: word)
    let side = node.size.width
    let anchor = CGPoint(x: content.midX, y: 1 - content.midY)
    node.position.x += (anchor.x - node.anchorPoint.x) * side
    node.position.y += (anchor.y - node.anchorPoint.y) * side
    node.anchorPoint = anchor
    let radius = max(content.height * side / 2, 8)
    let reach = Double(unit * 0.22)
    let home = Double(node.position.x)
    let lower = max(-reach, Double(landMinX + radius) - home)
    let upper = min(reach, Double(landMinX + landWidth - radius) - home)
    guard lower < 0, upper > 0 else { return }
    rollers.append(
      Roller(node: node, homeX: node.position.x, radius: radius, range: lower...upper))
  }

  /// 1こま分、転がす。止まっている物には何もしない。
  func stepRollers(_ time: TimeInterval) {
    defer { lastUpdateTime = time }
    guard !rollers.isEmpty, let last = lastUpdateTime else { return }
    let tilt = reduceMotion ? 0 : (tiltProvider?() ?? 0)
    let dt = time - last
    for index in rollers.indices {
      let roller = rollers[index]
      let next = Rolling.step(roller.state, tilt: tilt, dt: dt, range: roller.range)
      guard next != roller.state else { continue }
      rollers[index].state = next
      roller.node.position.x = roller.homeX + CGFloat(next.offset)
      roller.node.zRotation = CGFloat(
        Rolling.angle(offset: next.offset, radius: Double(roller.radius)))
    }
  }

  /// 転がる物を押した。押したところの反対へ、ころんと転がる（D133）。
  func tapRoller(at point: CGPoint) -> Bool {
    let hits = rollers.indices.compactMap { index -> (index: Int, distance: CGFloat)? in
      let node = rollers[index].node
      // 押せる部分は、絵より小さくしない（104pt 角。D101）。
      let reach = max(rollers[index].radius, 52)
      let dx = abs(node.position.x - point.x)
      let dy = abs(node.position.y - point.y)
      guard dx <= reach, dy <= reach else { return nil }
      return (index, hypot(dx, dy))
    }
    guard let hit = hits.min(by: { $0.distance < $1.distance }) else { return false }
    let roller = rollers[hit.index]
    rollers[hit.index].state = Rolling.tapped(
      roller.state, tappedRightSide: point.x > roller.node.position.x, range: roller.range)
    SoundPlayer.shared.play(.tap)
    return true
  }
}
