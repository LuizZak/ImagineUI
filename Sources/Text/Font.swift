/// Protocol for font types
public protocol Font: TextAttributeType {
    var size: Float { get }
    
    var metrics: FontMetrics { get }
    
    var matrix: FontMatrix { get }

    /// Gets the font face associated with this font.
    var fontFace: FontFace { get }
    
    /// Creates a glyph buffer for a given string segment
    func createGlyphBuffer<S: StringProtocol>(_ string: S) -> GlyphBuffer
    
    /// Gets the text metrics for a given glyph buffer
    /// Returns `nil` if the glyph buffer type is incompatible with the underlying
    /// font implementation.
    func getTextMetrics(_ buffer: GlyphBuffer) -> TextMetrics?
}
