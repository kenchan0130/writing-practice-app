import UIKit

/// 絵ができるまでの仮の絵（SF Symbols）。M0 の乗り物の型のことば（D78）。
enum PlaceholderArt {
  static let vehicleWords: [(word: String, symbol: String)] = [
    ("くるま", "car.side.fill"),
    ("ふね", "ferry.fill"),
    ("でんしゃ", "tram.fill"),
    ("じてんしゃ", "bicycle"),
    ("しんかんせん", "train.side.front.car"),
  ]

  static func symbol(for word: String) -> String {
    vehicleWords.first { $0.word == word }?.symbol ?? "questionmark.square.dashed"
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
