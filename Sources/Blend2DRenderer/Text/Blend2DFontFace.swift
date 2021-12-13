import SwiftBlend2D
import Text

public class Blend2DFontFace: FontFace {
    var fontFace: BLFontFace
    
    public init(fontFace: BLFontFace) {
        self.fontFace = fontFace
    }
    
    public func font(withSize size: Float) -> Font {
        return Blend2DFont(font: BLFont(fromFace: fontFace, size: size))
    }
}
