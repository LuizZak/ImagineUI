import Geometry

/// Text metrics for a text segment.
public struct TextMetrics {
    var advance: Vector
    var leadingBearing: Vector
    var trailingBearing: Vector
    var boundingBox: Rectangle
    
    public init(advance: Vector,
                leadingBearing: Vector,
                trailingBearing: Vector,
                boundingBox: Rectangle) {
        
        self.advance = advance
        self.leadingBearing = leadingBearing
        self.trailingBearing = trailingBearing
        self.boundingBox = boundingBox
    }
}
