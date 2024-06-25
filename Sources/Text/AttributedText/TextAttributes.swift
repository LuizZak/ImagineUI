import Geometry
import RenderingCommon

extension Color: TextAttributeType { }
extension UIVector: TextAttributeType { }
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

/// Used to wrap an ``Image`` for usage as a text attribute.
public struct ImageAttribute: TextAttributeType {
    public let image: Image
    public let offset: UIVector

    public init(image: Image, offset: UIVector = .zero) {
        self.image = image
        self.offset = .zero
    }

    /// Returns `true` if `other` is another instance of `ImageAttribute`, and
    /// `self.image.instanceEquals(to: other.image)` is true, and both attributes
    /// have the same offset vector.
    public func isEqual(to other: TextAttributeType) -> Bool {
        guard let other = other as? Self else {
            return false
        }

        return offset == other.offset && image.instanceEquals(to: other.image)
    }
}

/// Specifies the vertical alignment of inline ``ImageAttribute`` instances in
/// a text segment.
public enum ImageVerticalAlignmentAttribute: TextAttributeType {
    /// Aligns the image along the bottom of the text's baseline.
    /// The default vertical alignment of images in text.
    case baseline

    /// Aligns the image along the bottom of the text's underline height.
    case underline

    /// Aligns the image along the top of the text's ascent.
    case ascent

    /// Aligns the image along the top of the text's cap height.
    case capHeight

    /// Aligns the image such that the center of the image lies on the center of
    /// the text's center line, or x-height.
    case centralized
}
