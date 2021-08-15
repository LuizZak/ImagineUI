import Geometry
import Text

extension Color: TextAttributeType { }
extension Vector2: TextAttributeType { }
extension Double: TextAttributeType { }

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

/// Specifies the styling of an underline of an attributed text's segment.
public enum UnderlineStyleTextAttribute: TextAttributeType {
    /// A single line running under the text
    case single
}

/// Specifies the styling of a strikethrough of an attributed text's segment.
public enum StrikethroughStyleTextAttribute: TextAttributeType {
    /// A single line running through the text
    case single
}
