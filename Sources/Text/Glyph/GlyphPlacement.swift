import Geometry

/// Glyph placement.
///
/// Provides information about glyph offset (x/y) and advance (x/y).
public struct GlyphPlacement {
    public var placement: UIIntPoint
    public var advance: UIIntPoint
    
    public init(placement: UIIntPoint, advance: UIIntPoint) {
        self.placement = placement
        self.advance = advance
    }
}
