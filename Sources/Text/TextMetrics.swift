import Geometry

/// Text metrics for a text segment.
public struct TextMetrics {
    var advance: UIVector
    var leadingBearing: UIVector
    var trailingBearing: UIVector
    var boundingBox: UIRectangle
    
    public init(advance: UIVector,
                leadingBearing: UIVector,
                trailingBearing: UIVector,
                boundingBox: UIRectangle) {
        
        self.advance = advance
        self.leadingBearing = leadingBearing
        self.trailingBearing = trailingBearing
        self.boundingBox = boundingBox
    }
}
