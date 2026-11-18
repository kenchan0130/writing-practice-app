import AppKit
let names = ["sori","ushi","kutsu"]
let cell = 400, pad = 30
let W = pad + (cell+pad)*3, H = pad + (cell+pad)*2 + 150
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: W, pixelsHigh: H, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
NSColor(red: 1, green: 0.965, blue: 0.878, alpha: 1).set()
NSRect(x: 0, y: 0, width: W, height: H).fill()
for (i,n) in names.enumerated() {
  let x = pad + i*(cell+pad)
  let img = NSImage(contentsOfFile: "\(n).svg")!
  img.draw(in: NSRect(x: x, y: H - pad - cell, width: cell, height: cell))
  let sil = NSImage(contentsOfFile: "\(n)-sil.png")!
  sil.draw(in: NSRect(x: x, y: H - 2*(pad+cell), width: cell, height: cell))
  // 120px thumbnail
  let th = NSImage(contentsOfFile: "\(n)-120.png")!
  th.draw(in: NSRect(x: x + 140, y: 15, width: 120, height: 120))
}
NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "sheet.png"))
