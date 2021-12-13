import SwiftBlend2D
import Text

public struct Blend2DGlyphBuffer: GlyphBuffer {
    let buffer: BLGlyphBuffer
    
    public func makeIterator() -> GlyphBufferIterator {
        return Blend2DGlyphBufferIterator(iterator: BLGlyphRunIterator(glyphRun: buffer.glyphRun))
    }
}
