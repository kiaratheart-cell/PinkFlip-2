import Cocoa

/// The PinkFlip color palette.
enum PinkFlipPalette {

    /// Soft blush background.
    static let background = NSColor(hex: "FFC5D6")

    /// Gradient base.
    static let backgroundBase = NSColor(hex: "F5C7D9")

    /// Gradient light.
    static let backgroundLight = NSColor(hex: "FFE0E8")

    /// Flip card face.
    static let card = NSColor(hex: "FE5A9D")

    /// Slightly darker lower flap.
    static let cardShadowedHalf = NSColor(hex: "F04E90")

    /// Card border.
    static let cardBorder = NSColor(hex: "FE5A9D")

    /// Frosted acrylic card.
    static let cardBackground = NSColor.white.withAlphaComponent(0.95)

    /// Digit color.
    static let text = NSColor(hex: "FE5A9D")

    /// Acrylic overlay.
    static let cardFrostedOverlay =
        NSColor.white.withAlphaComponent(0.25)

    /// Card shadow.
    static let cardDropShadow =
        NSColor.black.withAlphaComponent(0.15)

    /// Highlight.
    static let cardHighlight =
        NSColor.white.withAlphaComponent(0.12)

    /// Flip shading.
    static let flapShading =
        NSColor.black.withAlphaComponent(0.20)

    /// Seam.
    static let seam =
        NSColor.black.withAlphaComponent(0.10)

    /// AM/PM label.
    static let ampmText =
        NSColor(hex: "FE5A9D").withAlphaComponent(0.85)

    /// Hinge decoration.
    static let hingeCapsuleColor =
        NSColor(hex: "FE5A9D")

    /// Inner glow.
    static let acrylicInnerGlow =
        NSColor.white.withAlphaComponent(0.18)
}
