import Geometry
import SwiftBlend2D
import Blend2DRenderer
import TestUtils

@testable import Text

class TestFont: Font {
    let font: Blend2DFont
    
    var size: Float {
        return font.size
    }
    var metrics: FontMetrics {
        return font.metrics
    }
    var matrix: FontMatrix {
        return font.matrix
    }
    
    init(size: Float) {
        let face = try! BLFontFace(fromFile: TestPaths.pathToTestFontFace())
        font = Blend2DFont(font: BLFont(fromFace: face, size: size))
    }
    
    func createGlyphBuffer<S>(_ string: S) -> GlyphBuffer where S : StringProtocol {
        return font.createGlyphBuffer(string)
    }
    
    func getTextMetrics(_ buffer: GlyphBuffer) -> TextMetrics? {
        return font.getTextMetrics(buffer)
    }
    
    func isEqual(to other: TextAttributeType) -> Bool {
        guard let other = other as? TestFont else {
            return false
        }
        
        return font.isEqual(to: other.font)
    }
}
