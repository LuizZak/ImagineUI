import Geometry

/// A segment of a line on a ``TextLayoutType`` object
public struct TextLayoutLineSegment {
    public var textRange: TextRange {
        return TextRange.fromOffsets(startCharacterIndex, endCharacterIndex)
    }
    
    public var startCharacterIndex: Int
    public var endCharacterIndex: Int
    public var startIndex: String.Index
    public var endIndex: String.Index
    public var text: Substring
    public var glyphBuffer: GlyphBuffer
    public var glyphBufferMinusLineBreak: GlyphBuffer
    public var font: Font
    public var textSegment: AttributedText.TextSegment
    
    /// Boundaries of this line segment, relative to the line's origin
    public var bounds: UIRectangle
    
    /// Rendering offset to apply to this segment
    public var offset: UIVector
    
    /// `bounds` property's value, mapped to the original transformation
    /// space before being multiplied by the font's transform matrix
    public var originalBounds: UIRectangle
    
    public init(startCharacterIndex: Int,
                endCharacterIndex: Int,
                startIndex: String.Index,
                endIndex: String.Index,
                text: Substring,
                glyphBuffer: GlyphBuffer,
                glyphBufferMinusLineBreak: GlyphBuffer,
                font: Font,
                textSegment: AttributedText.TextSegment,
                bounds: UIRectangle,
                offset: UIVector,
                originalBounds: UIRectangle) {
        
        self.startCharacterIndex = startCharacterIndex
        self.endCharacterIndex = endCharacterIndex
        self.startIndex = startIndex
        self.endIndex = endIndex
        self.text = text
        self.glyphBuffer = glyphBuffer
        self.glyphBufferMinusLineBreak = glyphBufferMinusLineBreak
        self.font = font
        self.textSegment = textSegment
        self.bounds = bounds
        self.offset = offset
        self.originalBounds = originalBounds
    }
}
