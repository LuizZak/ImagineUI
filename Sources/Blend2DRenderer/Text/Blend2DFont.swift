import SwiftBlend2D
import Text

public class Blend2DFont: Font, Equatable {
    public let font: BLFont
    
    /// The size of this font
    public var size: Float {
        return font.size
    }
    
    public var metrics: FontMetrics {
        let metrics = font.metrics
        
        return FontMetrics(size: metrics.size,
                           ascent: metrics.ascent,
                           vAscent: metrics.vAscent,
                           descent: metrics.descent,
                           vDescent: metrics.vDescent,
                           lineGap: metrics.lineGap,
                           xHeight: metrics.xHeight,
                           capHeight: metrics.capHeight,
                           underlinePosition: metrics.underlinePosition,
                           underlineThickness: metrics.underlineThickness,
                           strikethroughPosition: metrics.strikethroughPosition,
                           strikethroughThickness: metrics.strikethroughThickness)
    }
    
    public var matrix: FontMatrix {
        let matrix = font.matrix
        
        return FontMatrix(m11: matrix.m00, m12: matrix.m01, m21: matrix.m10, m22: matrix.m11)
    }
    
    public init(font: BLFont) {
        self.font = font
    }
    
    public func createGlyphBuffer<S>(_ string: S) -> GlyphBuffer where S: StringProtocol {
        let buffer = BLGlyphBuffer(text: string)
        
        font.shape(buffer)
        
        return Blend2DGlyphBuffer(buffer: buffer)
    }
    
    public func getTextMetrics(_ buffer: GlyphBuffer) -> TextMetrics? {
        guard let buffer = buffer as? Blend2DGlyphBuffer else {
            return nil
        }
        
        let metrics = font.getTextMetrics(buffer.buffer)
        
        return TextMetrics(advance: metrics.advance.asVector2,
                           leadingBearing: metrics.leadingBearing.asVector2,
                           trailingBearing: metrics.trailingBearing.asVector2,
                           boundingBox: metrics.boundingBox.asRectangle)
    }
    
    public static func == (lhs: Blend2DFont, rhs: Blend2DFont) -> Bool {
        return lhs.font == rhs.font
    }
    
    public func isEqual(to other: TextAttributeType) -> Bool {
        guard let other = other as? Blend2DFont else {
            return false
        }
        
        return self.font == other.font
    }
}
