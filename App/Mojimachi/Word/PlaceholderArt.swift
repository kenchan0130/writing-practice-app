import ContentModel
import UIKit

/// 絵ができるまでの仮の絵（SF Symbols）。M0 の3つの型のことば（D78）。ことばの一覧は WordCatalog。
enum PlaceholderArt {
  struct Item {
    let entry: WordEntry
    let symbol: String
    let color: UIColor
  }

  private static let vehicleColor = UIColor(red: 0.85, green: 0.3, blue: 0.25, alpha: 1)
  private static let animalColor = UIColor(red: 0.62, green: 0.4, blue: 0.2, alpha: 1)
  private static let clothesColor = UIColor(red: 0.25, green: 0.45, blue: 0.85, alpha: 1)

  /// SF Symbols に無い物（うし・うま・しか・くま・そり・ゆかた）は、近い物で代わりにする。
  private static let symbols: [String: String] = [
    "そり": "figure.skiing.downhill", "くるま": "car.side.fill", "ふね": "ferry.fill",
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

  /// 仮の絵を、`size` 四方の画像にする。
  static func image(symbol: String, size: CGFloat, color: UIColor = .black) -> UIImage {
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
