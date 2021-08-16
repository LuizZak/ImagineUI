import Geometry

/// Text metrics for a text segment.
public struct TextMetrics {
    var advance: Vector2
    var leadingBearing: Vector2
    var trailingBearing: Vector2
    var boundingBox: Rectangle
    
    public init(advance: Vector2,
                leadingBearing: Vector2,
                trailingBearing: Vector2,
                boundingBox: Rectangle) {
        
        self.advance = advance
        self.leadingBearing = leadingBearing
        self.trailingBearing = trailingBearing
        self.boundingBox = boundingBox
    }
}
