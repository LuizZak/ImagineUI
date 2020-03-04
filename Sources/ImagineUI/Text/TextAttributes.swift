import SwiftBlend2D

extension BLFont: TextAttributeType { }
extension BLRgba32: TextAttributeType { }
extension BLRgba64: TextAttributeType { }
extension Vector2: TextAttributeType { }

/// Specifies which bounds are used when rendering a background color text
/// attribute.
public enum TextBackgroundBoundsAttribute: TextAttributeType {
    /// Bounds of background color are derived from each individual segment's
    /// bounds.
    case segmentBounds
    
    /// Bounds of background color are derived from the largest baseline bounds
    /// from the same line the segment finds itself into.
    case largestBaselineBounds
}
