import Geometry
import Rendering

// TODO: Provide an abstract view cache API to support custom cache implementations from clients

/// Utility class used to cache view bitmaps.
/// Used primarily by `ControlView`
public class ViewBitmapCache {
    var bitmap: Image?
    var rectangle: UIRectangle = .zero

    var bitmapWidth: Int {
        return Int((rectangle.width * scale.x).rounded(.up))
    }
    var bitmapHeight: Int {
        return Int((rectangle.height * scale.y).rounded(.up))
    }

    var isCacheWithinSizeLimit: Bool {
        return bitmapWidth < maximumCachedBitmapSize.width
            || bitmapHeight > maximumCachedBitmapSize.height
    }

    /// Controls the maximum size the cached bitmap can have before it can no
    /// longer be cached, resulting in further `cacheOrRender` operations always
    /// live rendering the content, as if caching was disabled.
    ///
    /// Caching behaviour resumes once the cached bitmap size shrinks to less
    /// than this value.
    ///
    /// When setting, if the currently cached bitmap exceeds these dimensions,
    /// the cache is invalidated.
    public var maximumCachedBitmapSize = UIIntSize(width: 4096, height: 4096) {
        didSet {
            if maximumCachedBitmapSize.width < 0 || maximumCachedBitmapSize.height < 0 {
                maximumCachedBitmapSize = .zero
            }

            if !isCacheWithinSizeLimit {
                invalidateCache()
            }
        }
    }

    /// Controls whether bitmap caching is currently enabled. Setting this value
    /// to `false` invalidates the current cached image and releases its memory
    /// contents.
    public var isCachingEnabled: Bool {
        didSet {
            if !isCachingEnabled {
                invalidateCache()
            }
        }
    }

    /// The scale of the internal bitmap used for caching. Values different than
    /// 1 produce bitmap caches that are that fraction of the size of the cached
    /// contents.
    ///
    /// This invalidates the cache and requires a redraw to refresh.
    public var scale: UIVector = UIVector(repeating: 1) {
        didSet {
            invalidateCache()
        }
    }

    public init(isCachingEnabled: Bool) {
        self.isCachingEnabled = isCachingEnabled
    }

    /// Requests that the size of the cached bitmap bounds be updated to a
    /// specified value.
    ///
    /// This invalidates the cache and requires a redraw to refresh.
    public func updateBitmapBounds(_ bounds: UIRectangle) {
        guard rectangle != bounds else {
            return
        }

        rectangle = bounds
        invalidateCache()
    }

    /// Invalidates the cache by releasing the memory associated with its
    /// current cached image.
    public func invalidateCache() {
        bitmap = nil
    }

    /// Performs a deferred rendering operation that either redraws the cache
    /// bitmap if it's been invalidated through `closure` and then draws it on
    /// `renderer`, or if a cached bitmap is already present, draws the cached
    /// bitmap to `renderer` and skips invoking `closure`. 
    public func cachingOrRendering(_ renderer: Renderer, _ closure: (Renderer) -> Void) {
        if !isCachingEnabled || !isCacheWithinSizeLimit || bitmapWidth <= 0 || bitmapHeight <= 0 {
            closure(renderer)
            return
        }

        let rect = rectangle.withSize(
            width: Double(bitmapWidth) / scale.x,
            height: Double(bitmapHeight) / scale.y
        )

        if let bitmap = bitmap {
            renderer.drawImageScaled(bitmap, area: rect)
            return
        }
        
        let ctx = renderer.context.createImageRenderer(width: bitmapWidth, height: bitmapHeight)

        let image = ctx.withRenderer { renderer in
            renderer.clear()
            
            renderer.translate(by: (-rectangle.location).ceil())
            renderer.scale(by: scale)

            closure(renderer)
        }
        
        renderer.drawImageScaled(image, area: rect)
        
        self.bitmap = image
    }
}
