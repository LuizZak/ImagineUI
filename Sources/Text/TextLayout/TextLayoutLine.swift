import Geometry

/// A line on a ``TextLayoutType`` object
public struct TextLayoutLine {
    public var textRange: TextRange {
        return TextRange.fromOffsets(startCharacterIndex, endCharacterIndex)
    }

    public var segments: [TextLayoutLineSegment]

    public var startCharacterIndex: Int
    public var endCharacterIndex: Int
    public var startIndex: String.Index
    public var endIndex: String.Index
    public var text: Substring

    /// The common baseline height for all segments within this line.
    public var baselineHeight: Float

    /// Largest underline offset from this line
    public var underlineOffset: Float

    /// Boundaries of line, in screen-space coordinates
    public var bounds: UIRectangle

    public init(
        segments: [TextLayoutLineSegment],
        startCharacterIndex: Int,
        endCharacterIndex: Int,
        startIndex: String.Index,
        endIndex: String.Index,
        text: Substring,
        baselineHeight: Float,
        underlineOffset: Float,
        bounds: UIRectangle
    ) {

        self.segments = segments
        self.startCharacterIndex = startCharacterIndex
        self.endCharacterIndex = endCharacterIndex
        self.startIndex = startIndex
        self.endIndex = endIndex
        self.text = text
        self.baselineHeight = baselineHeight
        self.underlineOffset = underlineOffset
        self.bounds = bounds
    }

    public func segment(containing index: Int) -> TextLayoutLineSegment? {
        return segments.first(where: { index >= $0.startCharacterIndex && index <= $0.endCharacterIndex })
    }

    public func segments(intersecting range: TextRange) -> [TextLayoutLineSegment] {
        return segments.filter { $0.textRange.intersects(range) }
    }
}
