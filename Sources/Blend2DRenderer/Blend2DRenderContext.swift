import SwiftBlend2D
import Rendering

public class Blend2DRendererContext: RenderContext {
    public var fontManager: FontManager {
        return Blend2DFontManager()
    }

    public init() {

    }

    public func createImage(width: Int, height: Int) -> Image {
        let img = BLImage(width: width, height: height, format: .prgb32)

        let ctx = BLContext(image: img, options: nil)!
        ctx.setFillStyle(BLRgba32.transparentBlack)
        ctx.fillRect(BLRectI(x: 0, y: 0, w: Int32(width), h: Int32(height)))

        return Blend2DImage(image: img)
    }

    public func createImageRenderer(width: Int, height: Int) -> ImageRenderContext {
        return Blend2DImageRenderContext(width: width, height: height)
    }
}
