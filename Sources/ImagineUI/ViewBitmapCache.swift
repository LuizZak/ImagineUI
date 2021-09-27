import Geometry
import Rendering

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

    public var isCachingEnabled: Bool {
        didSet {
            if !isCachingEnabled {
                invalidateCache()
            }
        }
    }
    public var scale: UIVector = UIVector(repeating: 1) {
        didSet {
            invalidateCache()
        }
    }

    public init(isCachingEnabled: Bool) {
        self.isCachingEnabled = isCachingEnabled
    }

    public func updateBitmapBounds(_ bounds: UIRectangle) {
        if self.rectangle != bounds {
            self.rectangle = bounds
            invalidateCache()
        }
    }

    public func invalidateCache() {
        bitmap = nil
    }

    public func cachingOrRendering(_ renderer: Renderer, _ closure: (Renderer) -> Void) {
        if !isCachingEnabled || bitmapWidth <= 0 || bitmapHeight <= 0 {
            closure(renderer)
            return
        }

        let rect = UIRectangle(x: rectangle.x, y: rectangle.y,
                             width: Double(bitmapWidth) / scale.x,
                             height: Double(bitmapHeight) / scale.y)

        if let bitmap = bitmap {
            renderer.drawImageScaled(bitmap, area: rect)
            return
        }
        
        let ctx = renderer.context.createImageRenderer(width: bitmapWidth, height: bitmapHeight)
        
        ctx.renderer.clear()
        
        ctx.renderer.translate(by: (-rectangle.location).ceil())
        ctx.renderer.scale(by: scale)
        
        closure(ctx.renderer)
        
        let image = ctx.renderedImage()
        
        renderer.drawImageScaled(image, area: rect)
        
        self.bitmap = image
    }
}
