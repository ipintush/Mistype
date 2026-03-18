#!/usr/bin/env swift
import AppKit
import CoreGraphics
import CoreText
import ImageIO
import Foundation

// Headless AppKit (needed for NSImage SVG rendering)
NSApplication.shared.setActivationPolicy(.prohibited)

let width  = 660
let height = 490
let scale  = 2  // retina

let pw = width  * scale
let ph = height * scale

let cs  = CGColorSpaceCreateDeviceRGB()
let ctx = CGContext(data: nil, width: pw, height: ph,
                    bitsPerComponent: 8, bytesPerRow: 0,
                    space: cs,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

ctx.scaleBy(x: CGFloat(scale), y: CGFloat(scale))

// ── White background ──────────────────────────────────────────────────────────
ctx.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1))
ctx.fill(CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))

// ── Title "SwitchBack" ───────────────────────────────────────────────────────
let titleStr = "SwitchBack" as CFString
let titleFont = CTFontCreateWithName("Helvetica-Bold" as CFString, 30, nil)
let titleAttrs: [CFString: Any] = [
    kCTFontAttributeName: titleFont,
    kCTForegroundColorAttributeName: CGColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
]
let titleAttrStr = CFAttributedStringCreate(nil, titleStr, titleAttrs as CFDictionary)!
let titleLine = CTLineCreateWithAttributedString(titleAttrStr)
let titleWidth = CTLineGetTypographicBounds(titleLine, nil, nil, nil)
ctx.textPosition = CGPoint(x: (CGFloat(width) - titleWidth) / 2, y: 440)
CTLineDraw(titleLine, ctx)

// ── Subtitle (Hebrew, two lines) ──────────────────────────────────────────────
let subtitleFont = CTFontCreateWithName("Helvetica" as CFString, 13, nil)
let subtitleColor = CGColor(red: 0.45, green: 0.45, blue: 0.45, alpha: 1)
let subtitleAttrs: [CFString: Any] = [
    kCTFontAttributeName: subtitleFont,
    kCTForegroundColorAttributeName: subtitleColor
]

func drawCenteredLine(_ text: String, y: CGFloat) {
    let attrStr = CFAttributedStringCreate(nil, text as CFString, subtitleAttrs as CFDictionary)!
    let line = CTLineCreateWithAttributedString(attrStr)
    let w = CTLineGetTypographicBounds(line, nil, nil, nil)
    ctx.textPosition = CGPoint(x: (CGFloat(width) - w) / 2, y: y)
    CTLineDraw(line, ctx)
}

drawCenteredLine("עברית יצאה אנגלית? אנגלית יצאה עברית? זה קורה לכולם.", y: 418)
drawCenteredLine("SwitchBack על זה – מסמנים > לוחצים > נגמר", y: 400)
drawCenteredLine("לא מחובר ל-Mac App Store? אין בעיה.", y: 90)
drawCenteredLine("לחץ פעמיים על Install SwitchBack לפניך ←", y: 68)

// ── Separator line ────────────────────────────────────────────────────────────
ctx.setStrokeColor(CGColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1))
ctx.setLineWidth(0.5)
ctx.move(to: CGPoint(x: 60, y: 380))
ctx.addLine(to: CGPoint(x: 600, y: 380))
ctx.strokePath()

// ── slider.svg centered at (330, 226) ─────────────────────────────────────────
let svgPath = URL(fileURLWithPath: "slider.svg")
if let sliderImage = NSImage(contentsOf: svgPath) {
    let imgRect = NSRect(x: 285, y: 181, width: 90, height: 90)
    let nsCtx = NSGraphicsContext(cgContext: ctx, flipped: false)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = nsCtx
    sliderImage.draw(in: imgRect)
    NSGraphicsContext.restoreGraphicsState()
} else {
    print("Warning: could not load slider.svg")
}

// ── Write PNG @ 144 DPI ───────────────────────────────────────────────────────
let img  = ctx.makeImage()!
let dest = CGImageDestinationCreateWithURL(
    URL(fileURLWithPath: "SwitchBack-bg.png") as CFURL,
    "public.png" as CFString, 1, nil)!
let props: CFDictionary = [kCGImagePropertyDPIWidth: 144,
                            kCGImagePropertyDPIHeight: 144] as CFDictionary
CGImageDestinationAddImage(dest, img, props)
CGImageDestinationFinalize(dest)
print("Generated SwitchBack-bg.png (\(width)x\(height) @2x)")
