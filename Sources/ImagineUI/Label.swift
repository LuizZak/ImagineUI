import Geometry
import Text
import Rendering

open class Label: View {
    /// Whether to cache all labels' text as a bitmap.
    /// This increases memory usage, but reduces CPU usage when redrawing the
    /// label over and over.
    public static var cacheAsBitmap: Bool = true

    /// The bare text layout with no external text sizing constraints applied
    var minimalTextLayout: TextLayoutType

    /// Latest cached text layout instance
    private var _cachedTextLayout: TextLayoutType?

    private var _bitmapCache = ViewBitmapCache(isCachingEnabled: Label.cacheAsBitmap)

    /// Same as `minimalTextLayout`, but with view boundaries constraints taken
    /// into account.
    var textLayout: TextLayoutType {
        return InnerLabelTextLayout(label: self)
    }

    var baselineHeight: Double {
        return Double(minimalTextLayout.baselineHeightForLine(atIndex: 0))
    }

    open var font: Font {
        didSet {
            invalidate()
            setNeedsLayout()

            recreateMinimalTextLayout()
        }
    }
    open var text: String {
        get {
            return attributedText.string
        }
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
            if bounds.size != oldValue.size {
                clearCachedTextLayout()
            }
        }
    }

    open override var intrinsicSize: UISize? {
        return minimalTextLayout.size
    }

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
        self.font = Fonts.defaultFont(size: 11)
        minimalTextLayout = TextLayout(font: font, attributedText: AttributedText())

        super.init()
    }

    public init(textColor: Color, font: Font) {
        self.textColor = textColor
        self.font = font
        minimalTextLayout = TextLayout(font: font, attributedText: AttributedText())

        super.init()
    }

    open override func render(in renderer: Renderer, screenRegion: ClipRegion) {
        super.render(in: renderer, screenRegion: screenRegion)

        _bitmapCache.isCachingEnabled = Label.cacheAsBitmap
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
