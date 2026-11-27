// ステッカーと おたのしみ ボックスの一覧（Content/Art/sheet-stickers.png）を作る。
// 使い方: Scripts/art/stickers.sh が呼ぶ（引数: SVG のフォルダ、部品のフォルダ、出力先、名前…）。
import AppKit
let args = CommandLine.arguments
let (dir, parts, out) = (args[1], args[2], args[3])
let names = Array(args.dropFirst(4))
let cell = 220, pad = 16, cols = 6
let rows = (names.count + cols - 1) / cols
let W = pad + (cell + pad) * cols, H = pad + (cell + pad) * (rows + 1)
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: W, pixelsHigh: H, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
NSColor(red: 0.62, green: 0.82, blue: 0.46, alpha: 1).set()
NSRect(x: 0, y: 0, width: W, height: H).fill()
NSColor(red: 0.50, green: 0.78, blue: 1, alpha: 1).set()
NSRect(x: 0, y: H / 2, width: W, height: H / 2).fill()
for (i, n) in names.enumerated() {
  let x = pad + (i % cols) * (cell + pad), y = H - (pad + cell) * (i / cols + 1)
  NSImage(contentsOfFile: "\(dir)/\(n).svg")!.draw(in: NSRect(x: x, y: y, width: cell, height: cell))
}
// いちばん下の段: 箱（ふた つき）、箱だけ、ふた だけ、小さい大きさ（まちで見る 90px）。
let y = pad
let box = NSImage(contentsOfFile: "\(parts)/otanoshimi-box.svg")!
let lid = NSImage(contentsOfFile: "\(parts)/otanoshimi-lid.svg")!
box.draw(in: NSRect(x: pad, y: y, width: cell, height: cell))
lid.draw(in: NSRect(x: pad, y: y, width: cell, height: cell))
box.draw(in: NSRect(x: pad + (cell + pad), y: y, width: cell, height: cell))
lid.draw(in: NSRect(x: pad + (cell + pad) * 2, y: y, width: cell, height: cell))
for (i, n) in names.prefix(8).enumerated() {
  NSImage(contentsOfFile: "\(dir)/\(n).svg")!.draw(in: NSRect(x: pad + (cell + pad) * 3 + i * 86, y: y + 20, width: 80, height: 80))
}
NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
