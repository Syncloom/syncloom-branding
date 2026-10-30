// Renders an SVG to a PNG of the given pixel size using macOS's built-in SVG support.
// usage: swift render.swift in.svg out.png size [#hexcolor-for-currentColor]
import AppKit

let args = CommandLine.arguments
guard args.count >= 4, let size = Int(args[3]) else { fatalError("usage: render in.svg out.png size [color]") }
var svg = try String(contentsOfFile: args[1], encoding: .utf8)
if args.count > 4 { svg = svg.replacingOccurrences(of: "currentColor", with: args[4]) }
guard let image = NSImage(data: Data(svg.utf8)) else { fatalError("cannot load svg") }
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size, bitsPerSample: 8, samplesPerPixel: 4,
                           hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
NSColor.clear.set()
NSRect(x: 0, y: 0, width: size, height: size).fill()
image.draw(in: NSRect(x: 0, y: 0, width: size, height: size), from: .zero, operation: .sourceOver, fraction: 1)
NSGraphicsContext.restoreGraphicsState()
try rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: args[2]))
