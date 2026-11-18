import AppKit
let a = CommandLine.arguments
let size = Int(a[3])!
let silhouette = a.count > 4 && a[4] == "sil"
guard let img = NSImage(contentsOfFile: a[1]) else { fatalError("load") }
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
img.draw(in: NSRect(x: 0, y: 0, width: size, height: size))
if silhouette {
  NSColor.black.set()
  NSRect(x: 0, y: 0, width: size, height: size).fill(using: .sourceIn)
}
NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: a[2]))
