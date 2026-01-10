/// Specifies a range on a text string
public struct TextRange: Hashable, CustomStringConvertible {
    public var start: Int
    public var length: Int

    /// End of range; Equivalent to `start + length`.
    public var end: Int { start + length }

    public var description: String {
        return "[ \(start) : \(length) ]"
    }

    public init(start: Int, length: Int) {
        self.start = start
        self.length = length
    }

    /// Returns the subrange of `string` by indexing with this `TextRange`.
    public func substring<StringType: StringProtocol>(in string: StringType) -> StringType.SubSequence where StringType: StringProtocol {
        let startIndex = string.index(string.startIndex, offsetBy: start)
        let endIndex = string.index(string.startIndex, offsetBy: end)

        return string[startIndex..<endIndex]
    }

    /// Returns true if `value >= start && value < end`
    public func contains(_ value: Int) -> Bool {
        return value >= start && value < end
    }

    /// Returns whether this range intersects another range.
    public func intersects(_ other: TextRange) -> Bool {
        return start < other.end && other.start < end
    }

    /// Returns the intersection between this text range and another text range.
    ///
    /// Intersection between the two ranges must have at least length 1 to be
    /// valid.
    ///
    /// Returns nil, if the ranges do not intersect.
    public func intersection(_ other: TextRange) -> TextRange? {
        // Not intersecting
        if end <= other.start || other.end <= start {
            return nil
        }

        let s = max(start, other.start)
        let e = min(end, other.end)

        return TextRange(start: s, length: e - s)
    }

    /// Returns the overlap between this text range and another text range.
    ///
    /// Overlap between the two ranges can occur with 0-length overlaps; final
    /// overlap will also have 0 `length`.
    ///
    /// Returns null, if the ranges do not overlap.
    public func overlap(_ other: TextRange) -> TextRange? {
        // Not intersecting
        if end < other.start || other.end < start {
            return nil
        }

        let s = max(start, other.start)
        let e = min(end, other.end)

        return TextRange(start: s, length: e - s)
    }

    /// Returns the result of the union operation between this and another text
    /// range.
    public func union(_ other: TextRange) -> TextRange {
        return TextRange.fromOffsets(min(start, other.start),
                                     max(end, other.end))
    }

    /// Returns a copy of this `TextRange` with `start` set to a given value.
    public func withStart(_ start: Int) -> TextRange {
        TextRange(start: start, length: length)
    }

    /// Returns a new text range which is the same length as this text range, but
    /// with the starting index offset by a given value
    public func offsetting(by value: Int) -> TextRange {
        TextRange(start: start + value, length: length)
    }

    /// Given two string offsets, returns a `TextRange` where `Start` is the
    /// minimum of the two offsets, and `Length` is the different between the
    /// two offsets.
    @inlinable
    public static func fromOffsets(_ offset1: Int, _ offset2: Int) -> TextRange {
        let minOffset = min(offset1, offset2)
        let maxOffset = max(offset1, offset2)

        return TextRange(start: minOffset, length: maxOffset - minOffset)
    }
}
