import ContentModel
import SwiftUI
import UIKit

/// 絵ができるまでの仮の絵（SF Symbols）。M0 の3つの型のことば（D78）。ことばの一覧は WordCatalog。
enum PlaceholderArt {
  struct Item {
    let entry: WordEntry
    let symbol: String
    let color: UIColor
  }

  /// SF Symbols ではなく、このアプリで描く絵の印。
  static let sledID = "mojimachi.sled"
  private static let customIDs: Set<String> = [sledID]

  static func isCustom(_ symbol: String) -> Bool { customIDs.contains(symbol) }

  private static let vehicleColor = UIColor(red: 0.85, green: 0.3, blue: 0.25, alpha: 1)
  private static let animalColor = UIColor(red: 0.62, green: 0.4, blue: 0.2, alpha: 1)
  private static let clothesColor = UIColor(red: 0.25, green: 0.45, blue: 0.85, alpha: 1)

  /// SF Symbols に無い物（うし・うま・しか・くま・ゆかた）は、近い物で代わりにする。そりだけは自分で描く（`sledID`）。
  private static let symbols: [String: String] = [
    "そり": sledID, "くるま": "car.side.fill", "ふね": "ferry.fill",
    "でんしゃ": "tram.fill", "じてんしゃ": "bicycle", "しんかんせん": "train.side.front.car",
    "うし": "pawprint.fill", "いぬ": "dog.fill", "ねこ": "cat.fill", "うま": "pawprint.fill",
    "くま": "pawprint.fill", "しか": "pawprint.fill", "りす": "hare.fill",
    "ふく": "tshirt.fill", "くつ": "shoe.fill", "ぼうし": "hat.widebrim.fill",
    "ゆかた": "figure.stand.dress", "くつした": "shoe.2.fill", "きもの": "jacket.fill",
  ]

  static let words: [Item] = WordCatalog.all.map { entry in
    let color: UIColor =
      switch entry.kind {
      case .vehicle: vehicleColor
      case .animal: animalColor
      case .clothes: clothesColor
      }
    return Item(
      entry: entry, symbol: symbols[entry.text] ?? "questionmark.square.dashed", color: color)
  }

  static func symbol(for word: String) -> String {
    words.first { $0.entry.text == word }?.symbol ?? "questionmark.square.dashed"
  }

  /// SwiftUI で仮の絵を出す。自分で描いた絵は、色をつけられる形（template）の画像にする。
  /// `pointSize` は SF Symbols の文字の大きさ。自分で描いた絵は、同じ大きさの四角に収める。
  @ViewBuilder
  static func swiftUIImage(symbol: String, pointSize: CGFloat) -> some View {
    if isCustom(symbol) {
      Image(uiImage: image(symbol: symbol, size: 256, color: .black))
        .renderingMode(.template)
        .resizable().scaledToFit()
        .frame(width: pointSize, height: pointSize)
    } else {
      Image(systemName: symbol).font(.system(size: pointSize))
    }
  }

  /// 大きさに合わせて広がる絵（影絵用）。
  static func resizableImage(symbol: String) -> Image {
    if isCustom(symbol) {
      return Image(uiImage: image(symbol: symbol, size: 256, color: .black))
        .renderingMode(.template).resizable()
    }
    return Image(systemName: symbol).resizable()
  }

  /// 自分で描く絵（そり）の形。0〜100 の四角の中。横から見た木のそりで、前（右）に向かって、すべり板が反り上がる。
  private static func sledParts() -> [CGPath] {
    var parts: [CGPath] = []
    // すべり板（下の2本の線を、横から見て1本に）。前が丸く反り上がる。
    let runner = CGMutablePath()
    runner.move(to: CGPoint(x: 8, y: 76))
    runner.addLine(to: CGPoint(x: 70, y: 76))
    runner.addCurve(
      to: CGPoint(x: 91, y: 48), control1: CGPoint(x: 86, y: 76), control2: CGPoint(x: 92, y: 62))
    parts.append(
      runner.copy(strokingWithWidth: 8, lineCap: .round, lineJoin: .round, miterLimit: 10))
    // 足（短い柱）
    for x in [20.0, 46.0, 70.0] {
      parts.append(
        CGPath(
          roundedRect: CGRect(x: x, y: 44, width: 8, height: 30), cornerWidth: 2,
          cornerHeight: 2, transform: nil))
    }
    // 座る板。細長い板を2枚、すきまをあけて重ねる。
    parts.append(
      CGPath(
        roundedRect: CGRect(x: 8, y: 32, width: 78, height: 8), cornerWidth: 4, cornerHeight: 4,
        transform: nil))
    parts.append(
      CGPath(
        roundedRect: CGRect(x: 8, y: 43, width: 78, height: 8), cornerWidth: 4, cornerHeight: 4,
        transform: nil))
    return parts
  }

  private static func drawSled(size: CGFloat, color: UIColor, in context: CGContext) {
    let parts = sledParts()
    let box = parts.dropFirst().reduce(parts[0].boundingBoxOfPath) {
      $0.union($1.boundingBoxOfPath)
    }
    let scale = size * 0.9 / max(box.width, box.height)
    var transform = CGAffineTransform(scaleX: scale, y: scale)
      .concatenating(
        CGAffineTransform(
          translationX: (size - box.width * scale) / 2 - box.minX * scale,
          y: (size - box.height * scale) / 2 - box.minY * scale))
    context.setFillColor(color.cgColor)
    // 重なる部分で穴があかないよう、部品ごとに塗る。
    for part in parts {
      if let moved = part.copy(using: &transform) {
        context.addPath(moved)
        context.fillPath(using: .winding)
      }
    }
  }

  /// 仮の絵を、`size` 四方の画像にする。
  static func image(symbol: String, size: CGFloat, color: UIColor = .black) -> UIImage {
    if isCustom(symbol) {
      let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
      return renderer.image { ctx in drawSled(size: size, color: color, in: ctx.cgContext) }
    }
    let config = UIImage.SymbolConfiguration(pointSize: size * 0.7, weight: .regular)
    let symbolImage =
      UIImage(systemName: symbol, withConfiguration: config)?
      .withTintColor(color, renderingMode: .alwaysOriginal) ?? UIImage()
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
    return renderer.image { _ in
      let s = symbolImage.size
      let scale = min(size / max(s.width, 1), size / max(s.height, 1)) * 0.9
      let w = s.width * scale
      let h = s.height * scale
      symbolImage.draw(in: CGRect(x: (size - w) / 2, y: (size - h) / 2, width: w, height: h))
    }
  }

  /// 画像の色のある部分から、線が集まる先の点を取る（D55・D110）。座標は画像の左上が原点。
  static func targetPoints(in image: UIImage, count: Int) -> [CGPoint] {
    guard let cg = image.cgImage else { return [] }
    let width = cg.width
    let height = cg.height
    var pixels = [UInt8](repeating: 0, count: width * height * 4)
    guard
      let context = CGContext(
        data: &pixels, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
    else { return [] }
    context.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))
    var opaque: [CGPoint] = []
    let step = max(1, Int((Double(width * height) / Double(count * 6)).squareRoot()))
    for y in stride(from: 0, to: height, by: step) {
      for x in stride(from: 0, to: width, by: step) where pixels[(y * width + x) * 4 + 3] > 128 {
        // CGContext は下が原点なので、上を原点に直す。
        opaque.append(
          CGPoint(
            x: CGFloat(x) / CGFloat(width) * image.size.width,
            y: CGFloat(height - 1 - y) / CGFloat(height) * image.size.height))
      }
    }
    guard opaque.count > count else { return opaque }
    // 決まった順に間引く（毎回同じ結果にする）。
    let stride = Double(opaque.count) / Double(count)
    return (0..<count).map { opaque[Int(Double($0) * stride)] }
  }
}
