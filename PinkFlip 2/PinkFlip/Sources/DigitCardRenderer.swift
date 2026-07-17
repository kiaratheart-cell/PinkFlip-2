//
//  DigitCardRenderer.swift
//  PinkFlip
//
//  Renders a full flip-card face (rounded rect, background color,
//  centered glyph, subtle highlight/shadow, and a hairline center seam)
//  into a CGImage. FlipDigitView slices the resulting image in half via
//  CALayer.contentsRect, which is far cheaper than maintaining separate
//  live text layers for every flap and back layer.
//

import Cocoa

enum DigitCardRenderer {

    /// Renders a single flip card face for the given glyph.
    ///
    /// - Parameters:
    ///   - glyph: the character to draw, e.g. "0"..."9" or ":".
    ///   - size: the size of the full card, in points.
    ///   - scale: the backing scale factor (2.0/3.0 on Retina displays).
    ///   - cornerRadius: corner radius applied to all four corners of the
    ///     full card (each half layer masks its own visible corners).
    /// - Returns: a CGImage sized `size * scale`, ready to be assigned to
    ///   a CALayer's `contents`.
    static func renderCard(glyph: Character,
                            size: CGSize,
                            scale: CGFloat,
                            cornerRadius: CGFloat) -> CGImage {
        let pixelWidth = max(1, Int((size.width * scale).rounded()))
        let pixelHeight = max(1, Int((size.height * scale).rounded()))

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil,
                                 width: pixelWidth,
                                 height: pixelHeight,
                                 bitsPerComponent: 8,
                                 bytesPerRow: 0,
                                 space: colorSpace,
                                 bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

        context.scaleBy(x: scale, y: scale)

        let bounds = CGRect(origin: .zero, size: size)

        // Card background.
        let path = CGPath(roundedRect: bounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
        context.addPath(path)
        context.setFillColor(PinkFlipPalette.card.cgColor)
        context.fillPath()

        // Very subtle vertical gradient: a soft highlight near the top,
        // a soft shadow near the bottom, for gentle luxury depth.
        context.saveGState()
        context.addPath(path)
        context.clip()

        if let gradient = CGGradient(
            colorsSpace: colorSpace,
            colors: [
                NSColor.white.withAlphaComponent(0.10).cgColor,
                NSColor.white.withAlphaComponent(0.0).cgColor,
                NSColor.black.withAlphaComponent(0.0).cgColor,
                NSColor.black.withAlphaComponent(0.14).cgColor
            ] as CFArray,
            locations: [0.0, 0.18, 0.75, 1.0]
        ) {
            context.drawLinearGradient(gradient,
                                        start: CGPoint(x: bounds.midX, y: bounds.maxY),
                                        end: CGPoint(x: bounds.midX, y: bounds.minY),
                                        options: [])
        }
        context.restoreGState()

        // Center hinge seam: a hairline shadow across the vertical middle
        // of the card, mimicking the physical split of a flip card.
        let seamHeight: CGFloat = max(1.0, size.height * 0.012)
        let seamRect = CGRect(x: 0, y: bounds.midY - seamHeight / 2, width: size.width, height: seamHeight)
        context.setFillColor(PinkFlipPalette.seam.cgColor)
        context.fill(seamRect)

        // Glyph. Uses the system's built-in monospaced-digit numeral
        // style so consecutive digits never shift horizontally.
        let fontSize = size.height * 0.72
        let font = NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .semibold)

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: PinkFlipPalette.text,
            .paragraphStyle: paragraph
        ]

        let string = String(glyph)
        let attributed = NSAttributedString(string: string, attributes: attributes)
        let textSize = attributed.size()

        let nsContext = NSGraphicsContext(cgContext: context, flipped: false)
        let previous = NSGraphicsContext.current
        NSGraphicsContext.current = nsContext

        // Optically center: system fonts sit slightly above true visual
        // center, so nudge down a touch for perfect balance inside the
        // card, matching the restrained, precise look of a quality flip
        // clock face.
        let drawRect = CGRect(
            x: bounds.midX - textSize.width / 2,
            y: bounds.midY - textSize.height / 2 - size.height * 0.02,
            width: textSize.width,
            height: textSize.height
        )
        attributed.draw(in: drawRect)

        NSGraphicsContext.current = previous

        return context.makeImage()!
    }
}
