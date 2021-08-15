import Geometry

/// Glyph placement.
///
/// Provides information about glyph offset (x/y) and advance (x/y).
public struct GlyphPlacement {
    public var placement: IntPoint
    public var advance: IntPoint
    
    public init(placement: IntPoint, advance: IntPoint) {
        self.placement = placement
        self.advance = advance
    }
}
