//
//  Colors.swift
//  PinkFlip
//
//  Central definition of the PinkFlip color palette. Colors are defined
//  both as static NSColor constants (used directly by CALayer/CGColor
//  based drawing) and mirrored inside Assets.xcassets so they are also
//  available to Interface Builder / SwiftUI previews if needed.
//

import Cocoa

/// The PinkFlip color palette.
///
/// Background:  Soft pink radial gradient
/// Flip cards:  Frosted acrylic glass with #FE5A9D border
/// Text:        #FE5A9D (pink digits)
enum PinkFlipPalette {

    /// Soft blush background behind the entire screensaver (base gradient color).
    static let backgroundBase = NSColor(hex: "F5C7D9")
    
    /// Lighter gradient end for radial effect.
    static let backgroundLight = NSColor(hex: "FFE0E8")

    /// The flip card border and accent color - vivid bright pink.
    static let cardBorder = NSColor(hex: "FE5A9D")
    
    /// Card background - white/off-white with transparency for frosted effect.
    static let cardBackground = NSColor.white.withAlphaComponent(0.95)

    /// Digit / label text color (pink digits on frosted cards).
    static let text = NSColor(hex: "FE5A9D")

    /// White frosted overlay to create translucent acrylic glass effect (enhanced).
    static let cardFrostedOverlay = NSColor.white.withAlphaComponent(0.25)

    /// Premium soft shadow cast by each card onto the background (stronger).
    static let cardDropShadow = NSColor.black.withAlphaComponent(0.15)

    /// Very subtle highlight along the top edge of each card.
    static let cardHighlight = NSColor.white.withAlphaComponent(0.12)

    /// Subtle shading overlay used while a flap is rotating, to simulate
    /// changing light as the card turns in 3D space.
    static let flapShading = NSColor.black.withAlphaComponent(0.20)

    /// Thin elegant seam color drawn at the center hinge of each flip card.
    static let seam = NSColor.black.withAlphaComponent(0.10)

    /// Color used for the small AM/PM indicator label.
    static let ampmText = NSColor(hex: "FE5A9D").withAlphaComponent(0.85)

    /// Rounded capsule hinge tab color (decorative elements flanking the hinge).
    static let hingeCapsuleColor = NSColor(hex: "FE5A9D")
    
    /// Inner glow/reflection for acrylic glass effect.
    static let acrylicInnerGlow = NSColor.white.withAlphaComponent(0.18)
}
