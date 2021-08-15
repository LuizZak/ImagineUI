import SwiftBlend2D
import Text

struct Blend2DGlyphBuffer: GlyphBuffer {
    let buffer: BLGlyphBuffer
    
    func makeIterator() -> GlyphBufferIterator {
        return Blend2DGlyphBufferIterator(iterator: BLGlyphRunIterator(glyphRun: buffer.glyphRun))
    }
}
