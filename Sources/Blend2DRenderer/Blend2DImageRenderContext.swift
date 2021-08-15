import SwiftBlend2D
import Rendering

class Blend2DImageRenderContext: ImageRenderContext {
    private let _context: BLContext
    private let _renderer: Blend2DRenderer
    private let _image: BLImage
    
    var renderer: Renderer {
        return _renderer
    }
    
    init(width: Int, height: Int) {
        _image = BLImage(width: width, height: height, format: .prgb32)
        _context = BLContext(image: _image)!
        _renderer = Blend2DRenderer(context: _context)
    }
    
    func renderedImage() -> Image {
        _context.end()
        
        return Blend2DImage(image: _image)
    }
}
