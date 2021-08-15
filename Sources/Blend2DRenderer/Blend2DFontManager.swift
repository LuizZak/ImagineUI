import SwiftBlend2D
import Text
import Rendering

public class Blend2DFontManager: FontManager {
    public init() {
        
    }
    
    public func loadFontFace(fromPath path: String) throws -> FontFace {
        let face = try BLFontFace(fromFile: path)
        return Blend2DFontFace(fontFace: face)
    }
}
