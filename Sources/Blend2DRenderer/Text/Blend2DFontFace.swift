import SwiftBlend2D
import Text

class Blend2DFontFace: FontFace {
    var fontFace: BLFontFace
    
    init(fontFace: BLFontFace) {
        self.fontFace = fontFace
    }
    
    func font(with size: Float) -> Font {
        return Blend2DFont(font: BLFont(fromFace: fontFace, size: size))
    }
}
