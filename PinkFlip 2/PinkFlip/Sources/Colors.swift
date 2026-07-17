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
/// Background:  #FFC5D6
/// Flip cards:  #FE5A9D
/// Text:        #FFFFFF
enum PinkFlipPalette {

    /// Soft blush background behind the entire screensaver.
    static let background = NSColor(hex: "FFC5D6")

    /// The flip card face color.
    static let card = NSColor(hex: "FE5A9D")

    /// A very slightly darker tone used for the lower half of each card
    /// to create subtle depth between the two flap halves.
    static let cardShadowedHalf = NSColor(hex: "F04E90")

    /// Digit / label text color.
    static let text = NSColor.white

    /// Very subtle soft shadow cast by each card onto the background.
    static let cardDropShadow = NSColor.black.withAlphaComponent(0.18)

    /// Very subtle highlight along the top edge of each card.
    static let cardHighlight = NSColor.white.withAlphaComponent(0.14)

    /// Subtle shading overlay used while a flap is rotating, to simulate
    /// changing light as the card turns in 3D space.
    static let flapShading = NSColor.black.withAlphaComponent(0.28)

    /// Hairline seam color drawn at the center hinge of each flip card.
    static let seam = NSColor.black.withAlphaComponent(0.22)

    /// Color used for the small AM/PM indicator label.
    static let ampmText = NSColor.white.withAlphaComponent(0.92)
}
