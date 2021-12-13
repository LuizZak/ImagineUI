import SwiftBlend2D
import Text

public struct Blend2DGlyphBufferIterator: GlyphBufferIterator {
    var iterator: BLGlyphRunIterator
    
    public var index: Int {
        return iterator.index
    }
    
    public var atEnd: Bool {
        return iterator.atEnd
    }
    
    public var hasPlacement: Bool {
        return iterator.hasPlacement
    }
    
    public var glyphId: UInt32? {
        return iterator.glyphId()
    }
    
    public var advanceOffset: GlyphPlacement? {
        switch iterator.placementData {
        case .advanceOffset(let placement):
            return GlyphPlacement(placement: placement.placement.asIntPoint,
                                  advance: placement.advance.asIntPoint)
        default:
            return nil
        }
    }
    
    public mutating func advance() {
        iterator.advance()
    }
}
