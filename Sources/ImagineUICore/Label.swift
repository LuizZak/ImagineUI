import Geometry
import Text
import Rendering

open class Label: View {
    /// Whether to cache all labels' text as a bitmap.
    ///
    /// This increases memory usage and reduces quality of text in scaled scenarios,
    /// but reduces CPU usage when rendering the same label.
    public static var globallyCacheAsBitmap: Bool = false

    /// The bare text layout with no external text sizing constraints applied
    var minimalTextLayout: TextLayoutType

    /// Latest cached text layout instance
    private var _cachedTextLayout: TextLayoutType?

    private var _bitmapCache = ViewBitmapCache(isCachingEnabled: Label.globallyCacheAsBitmap)

    /// Same as `minimalTextLayout`, but with view boundaries constraints taken
    /// into account.
    var textLayout: TextLayoutType {
        return InnerLabelTextLayout(label: self)
    }

    // TODO: Account for vertical alignments other than `.near` when computing
    // TODO: the baseline height for constraint layout
    var baselineHeight: Double {
        return Double(minimalTextLayout.baselineHeightForLine(atIndex: 0))
    }

    /// Overrides the default `Label.globallyCacheAsBitmap` value with a specified
    /// boolean value. If `nil`, the global value is used, instead.
    public var cacheAsBitmap: Bool? = nil {
        didSet {
            guard cacheAsBitmap != oldValue else { return }

            _bitmapCache.invalidateCache()
            invalidate()
        }
    }

    /// The current default font to render text with.
    /// Custom fonts in `attributedText` override this property.
    open var font: Font {
        didSet {
            invalidate()
            setNeedsLayout()

            recreateMinimalTextLayout()
        }
    }

    /// Convenience for changing the current font's size.
    /// Same as `self.font.size`, setting this property updates the font to be
    /// `self.font = self.font.fontFace.font(withSize: newValue)`.
    /// Custom fonts in `attributedText` override this property.
    open var fontSize: Float {
        get { font.size }
        set { font = font.fontFace.font(withSize: newValue) }
    }

    open var text: String {
        get { attributedText.string }
        set {
            if !attributedText.hasAttributes && attributedText.string == newValue { return }

            attributedText = AttributedText(newValue)
        }
    }

    open var attributedText: AttributedText = AttributedText() {
        didSet {
            if attributedText == oldValue { return }

            invalidate()
            setNeedsLayout()
            recreateMinimalTextLayout()
        }
    }

    open var textColor: Color {
        didSet {
            if textColor == oldValue { return }

            _bitmapCache.invalidateCache()

            invalidate()
        }
    }

    open override var bounds: UIRectangle {
        didSet {
            // TODO: Avoid thrashing cache if changes to label's size do not
            // TODO: affect the positioning of the text.
            if bounds.size != oldValue.size {
                clearCachedTextLayout()
            }
        }
    }

    open override var intrinsicSize: UISize? { minimalTextLayout.size }

    open var horizontalTextAlignment: HorizontalTextAlignment = .leading {
        didSet {
            clearCachedTextLayout()
            _bitmapCache.invalidateCache()
            invalidate()
        }
    }

    open var verticalTextAlignment: VerticalTextAlignment = .near {
        didSet {
            clearCachedTextLayout()
            _bitmapCache.invalidateCache()
            invalidate()
        }
    }

    public init(textColor: Color) {
        self.textColor = textColor
        self.font = Fonts.defaultFont(size: 12)
        minimalTextLayout = TextLayout(font: font, attributedText: AttributedText())

        super.init()
    }

    public init(textColor: Color, font: Font) {
        self.textColor = textColor
        self.font = font
        minimalTextLayout = TextLayout(font: font, attributedText: AttributedText())

        super.init()
    }

    open override func render(in renderer: Renderer, screenRegion: ClipRegionType) {
        super.render(in: renderer, screenRegion: screenRegion)

        _bitmapCache.isCachingEnabled = cacheAsBitmap ?? Label.globallyCacheAsBitmap
        _bitmapCache.updateBitmapBounds(bounds)
        _bitmapCache.cachingOrRendering(renderer) { renderer in
            renderer.setFill(textColor)
            renderer.setStroke(textColor)
            renderer.drawTextLayout(textLayout, at: .zero)
        }
    }

    open override func layoutSizeFitting(size: UISize) -> UISize {
        guard let intrinsicSize = intrinsicSize else {
            return size
        }

        return max(size, intrinsicSize)
    }

    internal func autoSize() {
        withSuspendedLayout(setNeedsLayout: false) {
            bounds.size = intrinsicSize ?? .zero
        }
    }

    private func recreateMinimalTextLayout() {
        clearCachedTextLayout()
        _bitmapCache.invalidateCache()

        minimalTextLayout = TextLayout(font: font, attributedText: attributedText)
    }

    private func clearCachedTextLayout() {
        _cachedTextLayout = nil
    }

    private func recreateCachedTextLayout() -> TextLayoutType {
        let layout = TextLayout(font: font, attributedText: attributedText,
                                availableSize: bounds.size,
                                horizontalAlignment: horizontalTextAlignment,
                                verticalAlignment: verticalTextAlignment)

        _cachedTextLayout = layout

        return layout
    }

    private class InnerLabelTextLayout: TextLayoutType {
        let label: Label
        var textLayout: TextLayoutType {
            if let cached = label._cachedTextLayout {
                return cached
            }
            return label.recreateCachedTextLayout()
        }

        var lines: [TextLayoutLine] { textLayout.lines }
        var font: Font { textLayout.font }
        var text: String { textLayout.text }
        var attributedText: AttributedText { textLayout.attributedText }
        var horizontalAlignment: HorizontalTextAlignment { textLayout.horizontalAlignment }
        var verticalAlignment: VerticalTextAlignment { textLayout.verticalAlignment }
        var numberOfLines: Int { textLayout.numberOfLines }
        var size: UISize { textLayout.size }

        init(label: Label) {
            self.label = label
        }

        func locationOfCharacter(index: Int) -> UIVector {
            return textLayout.locationOfCharacter(index: index)
        }
        func boundsForCharacters(startIndex: Int, length: Int) -> [UIRectangle] {
            return textLayout.boundsForCharacters(startIndex: startIndex, length: length)
        }
        func boundsForCharacters(in range: TextRange) -> [UIRectangle] {
            return textLayout.boundsForCharacters(in: range)
        }
        func hitTestPoint(_ point: UIVector) -> TextLayoutHitTestResult {
            return textLayout.hitTestPoint(point)
        }
        func font(atLocation index: Int) -> Font {
            return textLayout.font(atLocation: index)
        }
        func baselineHeightForLine(atIndex index: Int) -> Float {
            return textLayout.baselineHeightForLine(atIndex: index)
        }

        func strokeText(in renderer: Renderer, location: UIVector) {
            renderer.strokeTextLayout(self, at: location)
        }
        func fillText(in renderer: Renderer, location: UIVector) {
            renderer.fillTextLayout(self, at: location)
        }
        func renderText(in renderer: Renderer, location: UIVector) {
            renderer.drawTextLayout(self, at: location)
        }
    }
}
