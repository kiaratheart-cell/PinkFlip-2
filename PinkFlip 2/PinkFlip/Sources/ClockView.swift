//
//  ClockView.swift
//  PinkFlip
//
//  Composes six flip cards (H H : M M) plus a small AM/PM indicator
//  into the full PinkFlip clock face, and owns the TimeProvider that
//  drives updates. Sizing is fully responsive: `layout()` recomputes
//  card dimensions from the view's own bounds every time it changes,
//  so the clock scales cleanly to any monitor size and stays crisp on
//  Retina displays (each FlipDigitView re-rasterizes at the current
//  backing scale factor whenever its size changes).
//

import Cocoa

final class ClockView: NSView {

    // MARK: Subviews

    private let hourTens = FlipDigitView(glyph: "0")
    private let hourOnes = FlipDigitView(glyph: "0")
    private let minuteTens = FlipDigitView(glyph: "0")
    private let minuteOnes = FlipDigitView(glyph: "0")
    private let colonLabel = CATextLayer()
    private let ampmLabel = CATextLayer()

    private let timeProvider = TimeProvider()

    /// Target aspect ratio (width : height) for each individual flip
    /// card, matching the classic, slightly-taller-than-wide split-flap
    /// proportions used by premium flip clocks.
    private let cardAspect: CGFloat = 0.74

    /// Spacing between cards, expressed as a fraction of card width.
    private let cardSpacingFraction: CGFloat = 0.16

    /// Spacing given to the colon, as a fraction of card width.
    private let colonWidthFraction: CGFloat = 0.42

    // MARK: Init

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    private func setUp() {
        ensureLayerBacked()
        layer!.backgroundColor = NSColor.clear.cgColor

        for digitView in [hourTens, hourOnes, minuteTens, minuteOnes] {
            addSubview(digitView)
        }

        colonLabel.string = ":"
        colonLabel.alignmentMode = .center
        colonLabel.foregroundColor = PinkFlipPalette.card.cgColor
        colonLabel.contentsScale = window?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 2.0
        layer!.addSublayer(colonLabel)

        ampmLabel.string = ""
        ampmLabel.alignmentMode = .center
        ampmLabel.foregroundColor = PinkFlipPalette.ampmText.cgColor
        ampmLabel.contentsScale = window?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 2.0
        layer!.addSublayer(ampmLabel)

        timeProvider.onTimeChanged = { [weak self] time in
            self?.apply(time: time, animated: true)
        }
    }

    // MARK: Lifecycle

    func start() {
        timeProvider.start()
    }

    func stop() {
        timeProvider.stop()
    }

    // MARK: Time application

    private var hasAppliedInitialTime = false

    private func apply(time: ClockTime, animated: Bool) {
        // The very first application (when the screensaver launches)
        // should snap directly to the correct time without playing a
        // flip animation, since there is no meaningful "previous" value
        // to flip from.
        let shouldAnimate = animated && hasAppliedInitialTime

        hourTens.setGlyph(Character(String(time.hourTens)), animated: shouldAnimate)
        hourOnes.setGlyph(Character(String(time.hourOnes)), animated: shouldAnimate)
        minuteTens.setGlyph(Character(String(time.minuteTens)), animated: shouldAnimate)
        minuteOnes.setGlyph(Character(String(time.minuteOnes)), animated: shouldAnimate)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        ampmLabel.string = time.isPM ? "PM" : "AM"
        CATransaction.commit()

        hasAppliedInitialTime = true
    }

    // MARK: Layout

    override func layout() {
        super.layout()
        guard bounds.width > 0, bounds.height > 0 else { return }

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        // Solve for the largest card size that fits the available
        // width, accounting for four cards, a colon gap, and spacing
        // between every element, while also respecting the available
        // height (card height = card width / cardAspect).
        let spacingUnits: CGFloat = 3 // gaps: H-H, H:M, M-M  (colon counted separately)
        let totalWidthUnits: CGFloat = 4 + colonWidthFraction + spacingUnits * cardSpacingFraction

        let widthConstrainedCardWidth = bounds.width * 0.86 / totalWidthUnits
        let heightConstrainedCardWidth = (bounds.height * 0.62) * cardAspect

        let cardWidth = max(20, min(widthConstrainedCardWidth, heightConstrainedCardWidth))
        let cardHeight = cardWidth / cardAspect
        let spacing = cardWidth * cardSpacingFraction
        let colonWidth = cardWidth * colonWidthFraction

        let totalWidth = cardWidth * 4 + colonWidth + spacing * 3
        let originX = bounds.midX - totalWidth / 2
        let centerY = bounds.midY + cardHeight * 0.04 // optical centering, leaving room for AM/PM below

        var x = originX

        hourTens.frame = CGRect(x: x, y: centerY - cardHeight / 2, width: cardWidth, height: cardHeight)
        x += cardWidth + spacing

        hourOnes.frame = CGRect(x: x, y: centerY - cardHeight / 2, width: cardWidth, height: cardHeight)
        x += cardWidth

        let colonRect = CGRect(x: x, y: centerY - cardHeight / 2, width: colonWidth, height: cardHeight)
        colonLabel.frame = colonRect
        colonLabel.fontSize = cardHeight * 0.62
        colonLabel.font = NSFont.systemFont(ofSize: colonLabel.fontSize, weight: .semibold)
        colonLabel.foregroundColor = PinkFlipPalette.card.cgColor
        colonLabel.contentsScale = window?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 2.0
        x += colonWidth

        minuteTens.frame = CGRect(x: x, y: centerY - cardHeight / 2, width: cardWidth, height: cardHeight)
        x += cardWidth + spacing

        minuteOnes.frame = CGRect(x: x, y: centerY - cardHeight / 2, width: cardWidth, height: cardHeight)
        x += cardWidth

        let ampmFontSize = cardHeight * 0.16
        let ampmHeight = ampmFontSize * 1.4
        ampmLabel.frame = CGRect(x: originX, y: centerY - cardHeight / 2 - ampmHeight - cardHeight * 0.06,
                                  width: totalWidth, height: ampmHeight)
        ampmLabel.fontSize = ampmFontSize
        ampmLabel.font = NSFont.systemFont(ofSize: ampmFontSize, weight: .medium)
        ampmLabel.alignmentMode = .center
        ampmLabel.contentsScale = window?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 2.0

        CATransaction.commit()
    }

    /// The natural (unclamped) size the clock would like to occupy,
    /// useful for the host view when computing burn-in drift bounds.
    var intrinsicClockSize: CGSize {
        return bounds.size
    }
}
