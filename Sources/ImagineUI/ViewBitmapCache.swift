import SwiftBlend2D

/// Utility class used to cache view bitmaps.
/// Used primarily by `ControlView`
public class ViewBitmapCache {
    var bitmap: BLImage?
    var rectangle: Rectangle = .zero

    var bitmapWidth: Int {
        return Int(ceil(rectangle.width * scale.x))
    }
    var bitmapHeight: Int {
        return Int(ceil(rectangle.height * scale.y))
    }

    public var isCachingEnabled: Bool {
        didSet {
            if !isCachingEnabled {
                invalidateCache()
            }
        }
    }
    public var scale: Vector2 = UISettings.scale {
        didSet {
            invalidateCache()
        }
    }

    public init(isCachingEnabled: Bool) {
        self.isCachingEnabled = isCachingEnabled
    }

    public func updateBitmapBounds(_ bounds: Rectangle) {
        if self.rectangle != bounds {
            self.rectangle = bounds
            invalidateCache()
        }
    }

    public func invalidateCache() {
        bitmap = nil
    }

    public func cachingOrRendering(_ context: BLContext, _ closure: (BLContext) -> Void) {
        if !isCachingEnabled || bitmapWidth <= 0 || bitmapHeight <= 0 {
            closure(context)
            return
        }

        let rect = BLRect(x: rectangle.x, y: rectangle.y,
                          w: Double(bitmapWidth) / scale.x,
                          h: Double(bitmapHeight) / scale.y)

        if let bitmap = bitmap {
            context.blitScaledImage(bitmap, rectangle: rect)
            return
        }

        let bitmap = BLImage(width: bitmapWidth, height: bitmapHeight, format: .prgb32)
        let ctx = BLContext(image: bitmap)!
        ctx.clearAll()

        ctx.translate(x: ceil(-rectangle.x), y: ceil(-rectangle.y))
        ctx.scale(by: scale.asBLPoint)

        closure(ctx)

        ctx.end()

        context.blitScaledImage(bitmap, rectangle: rect)

        self.bitmap = bitmap
    }
}
