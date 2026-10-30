// Packs PNG files into a Windows .ico (PNG-compressed entries). usage: swift makeico.swift out.ico a.png b.png ...
import Foundation
let a = CommandLine.arguments
let pngs = try a.dropFirst(2).map { try Data(contentsOf: URL(fileURLWithPath: $0)) }
func le16(_ v: Int) -> [UInt8] { [UInt8(v & 255), UInt8((v >> 8) & 255)] }
func le32(_ v: Int) -> [UInt8] { [UInt8(v & 255), UInt8((v >> 8) & 255), UInt8((v >> 16) & 255), UInt8((v >> 24) & 255)] }
var out = Data([0, 0, 1, 0] + le16(pngs.count))
var offset = 6 + 16 * pngs.count
for (i, p) in pngs.enumerated() {
    // width/height are stored in the PNG IHDR; 0 means 256
    let w = Int(p[19]) | (Int(p[18]) << 8), h = Int(p[23]) | (Int(p[22]) << 8)
    _ = i
    out.append(contentsOf: [UInt8(w >= 256 ? 0 : w), UInt8(h >= 256 ? 0 : h), 0, 0] + le16(1) + le16(32) + le32(p.count) + le32(offset))
    offset += p.count
}
for p in pngs { out.append(p) }
try out.write(to: URL(fileURLWithPath: a[1]))
