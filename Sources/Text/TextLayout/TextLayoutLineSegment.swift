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

    /// The advance to move the virtual pen forward after this segment's text
    /// before any next segment's text.
    public var advance: UIVector

    /// The computed ascent for this segment.
    public var ascent: Float

    /// The computed descent for this segment.
    public var descent: Float

    /// The computed underline position for this segment.
    public var underlinePosition: Float

    /// Boundaries of this line segment, relative to the line's origin.
    public var bounds: UIRectangle

    /// `bounds` property's value, mapped to the original transformation
    /// space before being multiplied by the font's transform matrix.
    public var originalBounds: UIRectangle

    public init(
        startCharacterIndex: Int,
        endCharacterIndex: Int,
        startIndex: String.Index,
        endIndex: String.Index,
        text: Substring,
        glyphBuffer: GlyphBuffer,
        glyphBufferMinusLineBreak: GlyphBuffer,
        font: Font,
        textSegment: AttributedText.TextSegment,
        advance: UIVector,
        ascent: Float,
        descent: Float,
        underlinePosition: Float,
        bounds: UIRectangle,
        originalBounds: UIRectangle
    ) {

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
        self.advance = advance
        self.ascent = ascent
        self.descent = descent
        self.underlinePosition = underlinePosition
        self.originalBounds = originalBounds
    }

    mutating func moveBaseline(to height: Double) {
        bounds = bounds.movingBottom(to: height + Double(descent))
    }

    func movingBaseline(to height: Double) -> Self {
        var copy = self
        copy.moveBaseline(to: height)
        return copy
    }
}
