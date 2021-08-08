import Geometry
import SwiftBlend2D

open class Label: View {
    /// Whether to cache all labels' text as a bitmap.
    /// This increases memory usage, but reduces CPU usage when redrawing the
    /// label over and over.
    public static var cacheAsBitmap: Bool = true

    /// The bare text layout with no external text sizing constraints applied
    var minimalTextLayout: TextLayout

    /// Latest cached text layout instance
    private var _cachedTextLayout: TextLayout?

    private var _bitmapCache = ViewBitmapCache(isCachingEnabled: Label.cacheAsBitmap)

    /// Same as `minimalTextLayout`, but with view boundaries constraints taken
    /// into account.
    var textLayout: TextLayoutType {
        return InnerLabelTextLayout(label: self)
    }
    
    var baselineHeight: Double {
        return Double(minimalTextLayout.baselineHeightForLine(atIndex: 0))
    }
    
    open var font: BLFont {
        didSet {
            if font == oldValue { return }

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

    open var textColor: BLRgba32 = .white {
        didSet {
            if textColor == oldValue { return }

            _bitmapCache.invalidateCache()

            invalidate()
        }
    }

    open override var bounds: Rectangle {
        didSet {
            if bounds.size != oldValue.size {
                clearCachedTextLayout()
            }
        }
    }

    open override var intrinsicSize: Size? {
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

    public override init() {
        self.font = Fonts.defaultFont(size: 11)
        minimalTextLayout = TextLayout(font: font, attributedText: AttributedText())

        super.init()
    }

    public init(font: BLFont) {
        self.font = font
        minimalTextLayout = TextLayout(font: font, attributedText: AttributedText())

        super.init()
    }

    open override func render(in context: BLContext, screenRegion: BLRegion) {
        super.render(in: context, screenRegion: screenRegion)

        _bitmapCache.isCachingEnabled = Label.cacheAsBitmap
        _bitmapCache.updateBitmapBounds(bounds)
        _bitmapCache.cachingOrRendering(context) { context in
            context.setFillStyle(textColor)
            context.setStrokeStyle(textColor)
            textLayout.renderText(in: context, location: .zero)
        }
    }
    
    internal func autoSize() {
        var resumeLayoutAfter = false
        if !isLayoutSuspended {
            suspendLayout()
            resumeLayoutAfter = true
        }
        
        bounds.size = intrinsicSize ?? .zero
        
        if resumeLayoutAfter {
            resumeLayout(setNeedsLayout: false)
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

    private func recreateCachedTextLayout() -> TextLayout {
        _cachedTextLayout = TextLayout(font: font, attributedText: attributedText,
                                       availableSize: bounds.size,
                                       horizontalAlignment: horizontalTextAlignment,
                                       verticalAlignment: verticalTextAlignment)

        return _cachedTextLayout!
    }

    private class InnerLabelTextLayout: TextLayoutType {
        let label: Label
        var textLayout: TextLayout {
            if let cached = label._cachedTextLayout {
                return cached
            }
            return label.recreateCachedTextLayout()
        }

        var font: BLFont { textLayout.font }
        var text: String { textLayout.text }
        var attributedText: AttributedText { textLayout.attributedText }
        var horizontalAlignment: HorizontalTextAlignment { textLayout.horizontalAlignment }
        var verticalAlignment: VerticalTextAlignment { textLayout.verticalAlignment }
        var numberOfLines: Int { textLayout.numberOfLines }
        var size: Size { textLayout.size }

        init(label: Label) {
            self.label = label
        }

        func locationOfCharacter(index: Int) -> Vector2 {
            return textLayout.locationOfCharacter(index: index)
        }
        func boundsForCharacters(startIndex: Int, length: Int) -> [Rectangle] {
            return textLayout.boundsForCharacters(startIndex: startIndex, length: length)
        }
        func boundsForCharacters(in range: TextRange) -> [Rectangle] {
            return textLayout.boundsForCharacters(in: range)
        }
        func hitTestPoint(_ point: Vector2) -> TextLayoutHitTestResult {
            return textLayout.hitTestPoint(point)
        }
        func font(atLocation index: Int) -> BLFont {
            return textLayout.font(atLocation: index)
        }
        func baselineHeightForLine(atIndex index: Int) -> Float {
            return textLayout.baselineHeightForLine(atIndex: index)
        }

        func strokeText(in context: BLContext, location: BLPoint) {
            return textLayout.strokeText(in: context, location: location)
        }
        func fillText(in context: BLContext, location: BLPoint) {
            return textLayout.fillText(in: context, location: location)
        }
        func renderText(in context: BLContext, location: BLPoint) {
            return textLayout.renderText(in: context, location: location)
        }
    }
}
