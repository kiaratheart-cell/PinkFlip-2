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

        // White frosted overlay for acrylic glass effect.
        context.addPath(path)
        context.setFillColor(PinkFlipPalette.cardFrostedOverlay.cgColor)
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

        // Thin elegant seam: a hairline shadow across the vertical middle
        // of the card, mimicking the physical split of a flip card.
        let seamHeight: CGFloat = max(1.0, size.height * 0.005)
        let seamRect = CGRect(x: 0, y: bounds.midY - seamHeight / 2, width: size.width, height: seamHeight)
        context.setFillColor(PinkFlipPalette.seam.cgColor)
        context.fill(seamRect)

        // Rounded capsule hinge tabs (decorative elements flanking the hinge).
        let tabWidth: CGFloat = size.width * 0.08
        let tabHeight: CGFloat = size.height * 0.08
        let tabRadius: CGFloat = tabHeight / 2.0
        let tabY = bounds.midY - tabHeight / 2.0

        // Left tab
        let leftTabRect = CGRect(x: bounds.minX + size.width * 0.08, y: tabY, width: tabWidth, height: tabHeight)
        let leftTabPath = CGPath(roundedRect: leftTabRect, cornerWidth: tabRadius, cornerHeight: tabRadius, transform: nil)
        context.addPath(leftTabPath)
        context.setFillColor(PinkFlipPalette.hingeCapsuleColor.cgColor)
        context.fillPath()

        // Right tab
        let rightTabRect = CGRect(x: bounds.maxX - size.width * 0.08 - tabWidth, y: tabY, width: tabWidth, height: tabHeight)
        let rightTabPath = CGPath(roundedRect: rightTabRect, cornerWidth: tabRadius, cornerHeight: tabRadius, transform: nil)
        context.addPath(rightTabPath)
        context.setFillColor(PinkFlipPalette.hingeCapsuleColor.cgColor)
        context.fillPath()

        // Thick pink border stroke to frame the card.
        let borderWidth: CGFloat = size.height * 0.055
        let borderPath = CGPath(roundedRect: bounds.insetBy(dx: borderWidth / 2, dy: borderWidth / 2),
                                cornerWidth: max(0, cornerRadius - borderWidth / 2),
                                cornerHeight: max(0, cornerRadius - borderWidth / 2),
                                transform: nil)
        context.addPath(borderPath)
        context.setStrokeColor(PinkFlipPalette.card.cgColor)
        context.setLineWidth(borderWidth)
        context.strokePath()

        // Glyph. Uses SF Pro Rounded system font with pink color.
        let fontSize = size.height * 0.72
        let font: NSFont
        if #available(macOS 11.0, *) {
            font = NSFont.systemFont(ofSize: fontSize, weight: .medium)
        } else {
            font = NSFont.systemFont(ofSize: fontSize, weight: .medium)
        }

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
