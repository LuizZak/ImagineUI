import SwiftBlend2D
import Rendering

class Blend2DImageRenderContext: ImageRenderContext {
    private let size: UIIntSize
    
    init(width: Int, height: Int) {
        size = .init(width: width, height: height)
    }

    func withRenderer(_ block: (Renderer) -> Void) -> Image {
        let image = BLImage(width: size.width, height: size.height, format: .prgb32)
        let context = BLContext(image: image)!
        let renderer = Blend2DRenderer(context: context)

        block(renderer)

        context.end()

        return Blend2DImage(image: image)
    }
}
