import AppKit
// 場所の絵の一覧の画像を作る。使い方: 絵の SVG のあるフォルダで ./sheetplaces （Mac だけ）
let names = ["eki","michi","sora","dobutsuen","makiba","mori","ie","umi","kawa","omise","koen","uchu","kisetsu"]
let labels = ["えき","みち","そら","どうぶつえん","まきば","もり","おうち","うみ","かわ","おみせ","こうえん","うちゅう","きせつ の はた"]
let cols = 5, cell = 240, lab = 44, gap = 16
let rows = (names.count + cols - 1) / cols
let gridH = rows * (cell + lab + gap)
let W = gap + cols * (cell + gap), H = 2 * gridH + 3 * gap + 40
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: W, pixelsHigh: H, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
NSColor(red: 1, green: 0.965, blue: 0.878, alpha: 1).set()
NSRect(x: 0, y: 0, width: W, height: H).fill()
let para = NSMutableParagraphStyle(); para.alignment = .center
let attr: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 28, weight: .bold), .foregroundColor: NSColor(red: 0.29, green: 0.2, blue: 0.16, alpha: 1), .paragraphStyle: para]
// 上の段は絵、下の段は影絵（形だけで読めるか見る）。
for g in 0..<2 {
  let top = H - gap - g * (gridH + gap + 20)
  for (i, n) in names.enumerated() {
    let c = i % cols, r = i / cols
    let x = gap + c * (cell + gap)
    let y = top - (r + 1) * (cell + lab + gap) + lab + gap
    let img = NSImage(contentsOfFile: "\(n).svg")!
    if g == 0 {
      img.draw(in: NSRect(x: x, y: y, width: cell, height: cell))
    } else {
      let tmp = NSImage(size: NSSize(width: cell, height: cell))
      tmp.lockFocus()
      img.draw(in: NSRect(x: 0, y: 0, width: cell, height: cell))
      NSColor.black.set()
      NSRect(x: 0, y: 0, width: cell, height: cell).fill(using: .sourceIn)
      tmp.unlockFocus()
      tmp.draw(in: NSRect(x: x, y: y, width: cell, height: cell))
    }
    (labels[i] as NSString).draw(in: NSRect(x: x, y: y - lab, width: cell, height: lab - 4), withAttributes: attr)
  }
}
NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "sheet-places.png"))
