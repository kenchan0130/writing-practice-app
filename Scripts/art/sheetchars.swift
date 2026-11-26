import AppKit
let chars = ["ton","run","hira"], labels = ["とん","るん","ひら"], poses = ["normal","wave","happy","sleep","blink"]
let cell = 260, labW = 120, gap = 10
let W = labW + poses.count * (cell + gap) + gap, H = 4 * (cell + gap) + gap + 40
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: W, pixelsHigh: H, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
NSColor(red: 1, green: 0.965, blue: 0.878, alpha: 1).set()
NSRect(x: 0, y: 0, width: W, height: H).fill()
let para = NSMutableParagraphStyle(); para.alignment = .center
let attr: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 40, weight: .bold), .foregroundColor: NSColor(red: 0.29, green: 0.2, blue: 0.16, alpha: 1), .paragraphStyle: para]
for (r, c) in chars.enumerated() {
  let y = H - gap - (r + 1) * (cell + gap)
  (labels[r] as NSString).draw(in: NSRect(x: 0, y: y + cell / 2 - 28, width: labW, height: 56), withAttributes: attr)
  for (i, p) in poses.enumerated() {
    NSImage(contentsOfFile: "\(c)-\(p).svg")!.draw(in: NSRect(x: labW + i * (cell + gap), y: y, width: cell, height: cell))
  }
}
let small: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 26, weight: .bold), .foregroundColor: NSColor(red: 0.29, green: 0.2, blue: 0.16, alpha: 1), .paragraphStyle: para]
("かげ" as NSString).draw(in: NSRect(x: 0, y: gap + cell / 2 - 18, width: labW, height: 40), withAttributes: small)
for (i, c) in chars.enumerated() {
  NSImage(contentsOfFile: "\(c)-normal-sil.png")!.draw(in: NSRect(x: labW + i * (cell + gap), y: gap, width: cell, height: cell))
}
NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "sheet-chars.png"))
