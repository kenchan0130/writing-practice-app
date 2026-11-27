import AppKit
// 並べることばは sheet-names.tsv（Scripts/art/sheet_names.py が作る。1行に「絵の名前<TAB>かな」）から読む。
let rowsTSV = (try! String(contentsOfFile: "sheet-names.tsv", encoding: .utf8)).split(separator: "\n").map { $0.split(separator: "\t").map(String.init) }.filter { $0.count == 2 }
let names = rowsTSV.map { $0[0] }
let labels = rowsTSV.map { $0[1] }
let cols = 5, cell = 220, lab = 44, gap = 16
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
for g in 0..<2 {
  let top = H - gap - g * (gridH + gap + 20)
  for (i, n) in names.enumerated() {
    let c = i % cols, r = i / cols
    let x = gap + c * (cell + gap)
    let y = top - (r + 1) * (cell + lab + gap) + lab + gap
    let img = g == 0 ? NSImage(contentsOfFile: "\(n).svg")! : NSImage(contentsOfFile: "\(n)-sil.png")!
    img.draw(in: NSRect(x: x, y: y, width: cell, height: cell))
    (labels[i] as NSString).draw(in: NSRect(x: x, y: y - lab, width: cell, height: lab - 4), withAttributes: attr)
  }
}
NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "sheet-all.png"))
