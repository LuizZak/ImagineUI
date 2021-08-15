import SwiftBlend2D
import Text

struct Blend2DGlyphBufferIterator: GlyphBufferIterator {
    var iterator: BLGlyphRunIterator
    
    var index: Int {
        return iterator.index
    }
    
    var atEnd: Bool {
        return iterator.atEnd
    }
    
    var hasPlacement: Bool {
        return iterator.hasPlacement
    }
    
    var glyphId: UInt32? {
        return iterator.glyphId()
    }
    
    var advanceOffset: GlyphPlacement? {
        switch iterator.placementData {
        case .advanceOffset(let placement):
            return GlyphPlacement(placement: placement.placement.asIntPoint,
                                  advance: placement.advance.asIntPoint)
        default:
            return nil
        }
    }
    
    mutating func advance() {
        iterator.advance()
    }
}
