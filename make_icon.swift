#!/usr/bin/env swift
import AppKit

// Initialize NSApplication so AppKit font/drawing is available
_ = NSApplication.shared

let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let iconsetDir = cwd.appendingPathComponent("AppIcon.iconset")
let icnsURL    = cwd.appendingPathComponent("AppIcon.icns")

try! FileManager.default.createDirectory(at: iconsetDir, withIntermediateDirectories: true)

let rotationURL = URL(fileURLWithPath: "rotation.svg")
let rotationImage: NSImage? = NSImage(contentsOf: rotationURL)

// (pixelSize, filename)
let sizes: [(Int, String)] = [
    (16,   "icon_16x16.png"),
    (32,   "icon_16x16@2x.png"),
    (32,   "icon_32x32.png"),
    (64,   "icon_32x32@2x.png"),
    (128,  "icon_128x128.png"),
    (256,  "icon_128x128@2x.png"),
    (256,  "icon_256x256.png"),
    (512,  "icon_256x256@2x.png"),
    (512,  "icon_512x512.png"),
    (1024, "icon_512x512@2x.png"),
]

func drawIcon(pixels: Int, rotationImage: NSImage?) -> NSImage {
    let s = CGFloat(pixels)
    let image = NSImage(size: NSSize(width: s, height: s))
    image.lockFocus()

    guard let ctx = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }

    // Rounded-rect clip
    let r = s * 0.2
    let path = CGPath(roundedRect: CGRect(x: 0, y: 0, width: s, height: s),
                      cornerWidth: r, cornerHeight: r, transform: nil)
    ctx.addPath(path)
    ctx.clip()

    // Solid teal background
    ctx.setFillColor(CGColor(red: 0.3137, green: 0.7294, blue: 0.6824, alpha: 1))
    ctx.fill(CGRect(x: 0, y: 0, width: s, height: s))

    // Helper: draw centred-Y string at a given x
    func draw(_ str: String, font: NSFont, color: NSColor, x: CGFloat) {
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let ns = NSAttributedString(string: str, attributes: attrs)
        let sz = ns.size()
        ns.draw(at: NSPoint(x: x, y: (s - sz.height) / 2))
    }

    let mainFont  = NSFont.boldSystemFont(ofSize: s * 0.38)
    let white     = NSColor.white

    // "A" — left
    let aStr   = NSAttributedString(string: "A",
                                    attributes: [.font: mainFont, .foregroundColor: white])
    let aSize  = aStr.size()
    aStr.draw(at: NSPoint(x: s * 0.11, y: (s - aSize.height) / 2))

    // "א" — right (use non-bold so it matches visual weight of aleph glyph)
    let heFont = NSFont.systemFont(ofSize: s * 0.38)
    let heStr  = NSAttributedString(string: "ש",
                                    attributes: [.font: heFont, .foregroundColor: white])
    let heSize = heStr.size()
    heStr.draw(at: NSPoint(x: s - heSize.width - s * 0.11, y: (s - heSize.height) / 2))

    // rotation.svg — centre, white-tinted (only drawn at ≥64 px for legibility)
    if pixels >= 64, let rotImg = rotationImage {
        let size = s * 0.32
        let iconRect = NSRect(x: (s - size) / 2, y: (s - size) / 2,
                              width: size, height: size)
        ctx.saveGState()
        ctx.beginTransparencyLayer(in: iconRect, auxiliaryInfo: nil)
        rotImg.draw(in: iconRect)
        NSColor.white.withAlphaComponent(0.85).set()
        iconRect.fill(using: .sourceAtop)
        ctx.endTransparencyLayer()
        ctx.restoreGState()
    }

    image.unlockFocus()
    return image
}

// Cache images per unique pixel size to avoid redundant drawing
var cache: [Int: NSImage] = [:]

for (pixels, filename) in sizes {
    let image = cache[pixels] ?? drawIcon(pixels: pixels, rotationImage: rotationImage)
    cache[pixels] = image

    guard let tiff = image.tiffRepresentation,
          let rep  = NSBitmapImageRep(data: tiff),
          let png  = rep.representation(using: .png, properties: [:]) else {
        print("ERROR: failed to render \(filename)")
        continue
    }

    let dest = iconsetDir.appendingPathComponent(filename)
    try! png.write(to: dest)
    print("  wrote \(filename)")
}

print("Running iconutil...")
let proc = Process()
proc.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
proc.arguments    = ["-c", "icns", iconsetDir.path, "-o", icnsURL.path]
try! proc.run()
proc.waitUntilExit()

if proc.terminationStatus == 0 {
    print("Created AppIcon.icns")
} else {
    print("ERROR: iconutil exited with status \(proc.terminationStatus)")
    exit(1)
}
