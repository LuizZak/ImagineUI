public struct AttributedText: Equatable {
    public typealias Attributes = [AttributeName: TextAttributeType]

    private var text: String
    private var segments: [TextSegment]

    /// Gets the length of this attribute text's text string
    public var length: Int {
        return text.count
    }

    /// Gets the entire text segment buffer on this attributed text
    public var string: String {
        return text
    }

    /// Returns true if there are attributes on this attributed text
    public var hasAttributes: Bool {
        return segments.contains(where: { !$0.textAttributes.isEmpty })
    }

    /// Returns true if this attributed text's contents are empty.
    ///
    /// Certain attributes are flagged as non-empty even if the attached text
    /// segments are textually empty, like image attributes.
    public var isEmpty: Bool {
        return segments.allSatisfy(\.isEmpty)
    }

    /// Returns true if this attributed text's string contents are empty.
    public var isTextEmpty: Bool {
        return text.isEmpty
    }

    /// Returns the text segments for this attributed string.
    public var textSegments: [TextSegment] {
        return segments
    }

    /// Returns a text range that completely covers the entire string text in
    /// this attributed text
    public var textRange: TextRange {
        return TextRange(start: 0, length: length)
    }

    /// Initializes a new empty `AttributedText` instance.
    public init() {
        self.init("")
    }

    /// Initializes a new `AttributedText` instance with a given non-attributed
    /// text segment.
    public init(_ text: String) {
        self.init(text, attributes: [:])
    }

    /// Initializes a new `AttributedText` instance with a given text segment and
    /// attribute set.
    public init(_ text: String, attributes: Attributes) {
        self.text = text
        segments = [
            TextSegment(
                text: text,
                textAttributes: attributes,
                textRange: TextRange(start: 0, length: text.count)
            )
        ]
    }

    /// Returns the list of attributes for the text at a given position.
    ///
    /// - precondition: `index >= 0 && index < length`
    public func attributes(at index: Int) -> Attributes {
        precondition(index >= 0 && index < length)

        guard let segment = segmentUnder(index) else {
            return [:]
        }

        return segment.textAttributes
    }

    /// Reserves a specified number of segments to be added to this `AttributedText`
    /// instance.
    public mutating func reserveCapacity(segmentCount: Int) {
        segments.reserveCapacity(segmentCount)
    }

    /// Removes all segments, replacing them with a given non-attributed textual
    /// string.
    public mutating func setText(_ text: String) {
        self.text = ""
        segments.removeAll()

        append(text)
    }

    /// Appends a new non-attributed segment at the end of this attributed text.
    public mutating func append(_ string: String) {
        append(string, attributes: [:])
    }

    /// Appends an attributed segment at the end of this attributed text.
    public mutating func append(_ string: String, attributes: Attributes) {
        if isEmpty {
            // Remove dummy empty segment
            segments.removeAll()
        }

        let segment = TextSegment(
            text: string,
            textAttributes: attributes,
            textRange: TextRange(start: text.count, length: string.count)
        )

        segments.append(segment)

        text += string

        mergeSegments()
    }

    /// Appends a given attributed text at the end of this attributed text.
    public mutating func append(_ attributedText: AttributedText) {
        let newLimit = text.count

        segments.append(contentsOf: attributedText.segments.map { seg in
            var seg = seg

            seg.textRange.start += newLimit

            return seg
        })

        text += attributedText.text

        mergeSegments()
    }

    /// Sets the attributes for a given textual range within this attributed text.
    public mutating func setAttributes(_ range: TextRange, _ attributes: Attributes) {
        if range.length == 0 {
            return
        }

        splitSegments(in: range)

        let indices = segmentIndicesIntersecting(range)

        for i in indices {
            segments[i] = segments[i].cloneWithAttributes(attributes)
        }

        mergeSegments()
    }

    /// Appends attributes to already existing attributes at a given textual range
    /// within this attributed text.
    public mutating func addAttributes(_ range: TextRange, _ attributes: Attributes) {
        if range.length == 0 {
            return
        }

        splitSegments(in: range)

        let indices = segmentIndicesIntersecting(range)

        for i in indices {
            let newAttributes =
                segments[i]
                    .textAttributes
                    .merging(attributes, uniquingKeysWith: { $1 })

            segments[i] = segments[i].cloneWithAttributes(newAttributes)
        }

        mergeSegments()
    }

    /// Removes all attributes on a given textual range within this attributed
    /// text.
    public mutating func removeAllAttributes(_ range: TextRange) {
        if range.length == 0 {
            return
        }

        splitSegments(in: range)

        let indices = segmentIndicesIntersecting(range)

        for i in indices {
            segments[i].textAttributes.removeAll()
        }

        mergeSegments()
    }

    /// Removes all attributes matching the given keys on a given textual range
    /// within this attributed text.
    public mutating func removeAttributes(_ range: TextRange, attributeKeys: Set<Attributes.Key>) {
        if range.length == 0 {
            return
        }

        splitSegments(in: range)

        let indices = segmentIndicesIntersecting(range)

        for i in indices {
            let attributes =
                segments[i]
                    .textAttributes
                    .filter { !attributeKeys.contains($0.key) }

            segments[i].textAttributes = attributes
        }

        mergeSegments()
    }

    /// Inserts a new segment with an optional set of attributes at a given
    /// grapheme-cluster index within this attributed text.
    public mutating func insert(_ string: String, at index: Int, attributes: Attributes = [:]) {
        splitSegmentUnder(index)

        for (i, segment) in segments.enumerated() {
            if segment.textRange.start >= index {
                segments[i].textRange = segment.textRange.offsetting(by: string.count)
            }
        }

        let segment = TextSegment(
            text: string,
            textAttributes: attributes,
            textRange: TextRange(start: index, length: string.count)
        )
        let segmentIndex =
            segments.firstIndex(where: {
                $0.textRange.start > index
            }) ?? segments.count

        segments.insert(segment, at: segmentIndex)

        let offset = text.index(text.startIndex, offsetBy: index)
        text.insert(contentsOf: string, at: offset)

        mergeSegments()
    }

    /// Inserts an attributed text as a segment with an optional set of overriden
    /// attributes at a given grapheme-cluster index within this attributed text.
    public mutating func insert(_ attributed: AttributedText, at index: Int, attributes: Attributes = [:]) {
        splitSegmentUnder(index)

        for (i, segment) in segments.enumerated() {
            if segment.textRange.start >= index {
                segments[i].textRange = segment.textRange.offsetting(by: attributed.text.count)
            }
        }

        let newSegments = attributed.segments.map { segment -> TextSegment in
            var segment = segment
            segment.textRange = segment.textRange.offsetting(by: index)
            return segment
        }

        let segmentIndex = segments.firstIndex(where: { $0.textRange.start > index }) ?? segments.count
        segments.insert(contentsOf: newSegments, at: segmentIndex)

        let offset = text.index(text.startIndex, offsetBy: index)
        text.insert(contentsOf: attributed.text, at: offset)

        mergeSegments()
    }

    /// Replaces the given range with a replacement string.
    ///
    /// Attributes of text ranges that are fully contained within the replacement
    /// string's range are erased.
    public mutating func replace(_ range: TextRange, with replacement: String) {
        if range.length == 0 {
            let attributes = attributes(at: range.start)
            insert(replacement, at: range.start, attributes: attributes)
            return
        }

        // Replace in-place in current segments
        var remaining: String = String(range.withStart(0).substring(in: replacement))
        var index = range.start

        while let nextChar = remaining.first {
            guard let segmentIndex = segmentIndexUnder(index) else {
                continue
            }

            var segment = segments[segmentIndex]
            let offset = segment.textRange.start - index
            let stringIndex = segment.text.index(segment.text.startIndex, offsetBy: offset)

            segment.text.replaceSubrange(stringIndex...stringIndex, with: String(nextChar))

            segments[segmentIndex] = segment

            remaining = String(remaining.dropFirst())
            index += 1
        }

        // Remaining characters get inserted at the end
        let attributes = attributes(at: min(index, length - 1))
        let toInsertRange = TextRange(start: range.length, length: replacement.count - range.length)
        let toInsert = toInsertRange.substring(in: replacement)

        insert(String(toInsert), at: index, attributes: attributes)
    }

    @discardableResult
    private mutating func splitSegments(in range: TextRange) -> [TextSegment] {
        if range.length == 0 {
            return []
        }

        // Splits segments like so:
        //
        // Current: |----------|---------|
        // Input:         | -  -  -  - |
        //
        // Result:  |-----|----|-------|-|

        // Current: |----------|--|-|----|
        // Input:         | -  -  -  - |
        //
        // Result:  |-----|----|--|-|--|-|

        // Find segments that contain the start and end positions
        // of the passed range to split
        splitSegmentUnder(range.start)
        splitSegmentUnder(range.end)

        return segmentsIntersecting(range)
    }

    private mutating func splitSegmentUnder(_ position: Int) {
        precondition(position >= 0 && position <= length,
                     "Position must be greater than 0 and less than or equal to Length")

        if position == 0 || position == length {
            return
        }

        guard let segment = segmentUnder(position) else {
            return
        }
        if segment.textRange.start == position || segment.textRange.end == position {
            return
        }

        let firstHalfSeg = TextRange.fromOffsets(segment.textRange.start, position)
        let secondHalfSeg = TextRange.fromOffsets(position, segment.textRange.end)

        let offset = position - segment.textRange.start

        let firstHalf = TextSegment(
            text: String(segment.text[characterRange: 0..<offset]),
            textAttributes: segment.textAttributes,
            textRange: firstHalfSeg
        )

        let secondHalf = TextSegment(
            text: String(segment.text[characterRange: offset...]),
            textAttributes: segment.textAttributes,
            textRange: secondHalfSeg
        )

        guard let index = segments.firstIndex(of: segment) else {
            return
        }

        segments[index] = firstHalf

        segments.insert(secondHalf, at: index + 1)
    }

    public func segmentUnder(_ position: Int) -> TextSegment? {
        return segments.first(where: { $0.textRange.contains(position) })
    }

    public func segmentIndexUnder(_ position: Int) -> Int? {
        return segments.enumerated().first(where: { $0.element.textRange.contains(position) })?.offset
    }

    private func segmentsIntersecting(_ range: TextRange) -> [TextSegment] {
        return segments.filter { $0.textRange.intersects(range) }
    }

    private func segmentIndicesIntersecting(_ range: TextRange) -> [Int] {
        return segments.enumerated().filter { $1.textRange.intersects(range) }.map { $0.offset }
    }

    private mutating func mergeSegments() {
        var index = 0
        while index < segments.count - 1 {
            if segments[index].attributesMatch(segments[index + 1]) {
                segments[index] = segments[index].merging(with: segments[index + 1])
                segments.remove(at: index + 1)
            } else {
                index += 1
            }
        }
    }

    // TODO: Find a way to re-enable this in one of the dependents (Rendering or Blend2DRenderer)
//
//    private func assertAttributes(_ attributes: Attributes) {
//        func assertIsType<T>(_ key: AttributeName, type: T.Type) {
//            if let value = attributes[key] {
//                assert(value is T,
//                       "Attribute AttributeName.\(key.rawValue) is not a \(type) type")
//            }
//        }
//
//        func assertIsColor(_ key: AttributeName) {
//            if let value = attributes[key] {
//                switch value {
//                case is Color:
//                    break
//                default:
//                    assertionFailure("Attribute AttributeName.\(key.rawValue) is not a Color type")
//                }
//            }
//        }
//
//        assertIsType(.font, type: Font.self)
//
//        assertIsColor(.foregroundColor)
//
//        assertIsColor(.backgroundColor)
//        assertIsType(.cornerRadius, type: Vector2.self)
//        assertIsType(.backgroundColorBounds, type: TextBackgroundBoundsAttribute.self)
//
//        assertIsColor(.strokeColor)
//        assertIsType(.strokeWidth, type: Double.self)
//
//        assertIsType(.underlineStyle, type: UnderlineStyleTextAttribute.self)
//        assertIsColor(.underlineColor)
//
//        assertIsType(.strikethroughStyle, type: StrikethroughStyleTextAttribute.self)
//        assertIsColor(.strikethroughColor)
//    }
//

    // TODO: Implement attribute-only text segments for inline images and other
    // TODO: dynamic content.

    public struct TextSegment: Equatable {
        public var text: String
        public var textAttributes: Attributes
        public var textRange: TextRange

        /// Returns `true` if this text segment is considered empty, i.e. it has
        /// no text nor content-attributes like images.
        public var isEmpty: Bool {
            guard text.isEmpty else {
                return false
            }

            return !textAttributes.values.contains(where: \.isContentAttribute)
        }

        public func attribute<T: TextAttributeType>(named name: AttributeName, type: T.Type) -> T? {
            return textAttributes[name] as? T
        }

        func cloneWithAttributes(_ attributes: Attributes) -> TextSegment {
            return TextSegment(
                text: text,
                textAttributes: attributes,
                textRange: textRange
            )
        }

        func attributesMatch(_ other: TextSegment) -> Bool {
            guard textAttributes.count == other.textAttributes.count else {
                return false
            }

            for (key, value) in textAttributes {
                guard let otherValue = other.textAttributes[key] else {
                    return false
                }

                if !value.isEqual(to: otherValue) {
                    return false
                }
            }

            return true
        }

        func merging(with other: TextSegment) -> TextSegment {
            return TextSegment(
                text: text + other.text,
                textAttributes: textAttributes.merging(other.textAttributes, uniquingKeysWith: { $1 }),
                textRange: textRange.union(other.textRange)
            )
        }

        public static func == (lhs: AttributedText.TextSegment, rhs: AttributedText.TextSegment) -> Bool {
            guard lhs.text == rhs.text && lhs.textRange == rhs.textRange && lhs.textAttributes.count == rhs.textAttributes.count else {
                return false
            }

            if !lhs.textAttributes.isEmpty {
                for (key, lhsValue) in lhs.textAttributes {
                    guard let rhsAttribute = rhs.textAttributes[key] else {
                        return false
                    }

                    if !lhsValue.isEqual(to: rhsAttribute) {
                        return false
                    }
                }
            }

            return true
        }
    }
}

extension AttributedText: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension AttributedText: ExpressibleByStringInterpolation {
    public init(stringInterpolation: StringInterpolation) {
        self = stringInterpolation.output
    }

    public struct StringInterpolation: StringInterpolationProtocol {
        public var output: AttributedText = ""

        public init(literalCapacity: Int, interpolationCount: Int) {
            output.reserveCapacity(segmentCount: interpolationCount)
        }

        public mutating func appendLiteral(_ literal: String) {
            output.append(literal)
        }

        public mutating func appendInterpolation(_ literal: AttributedText) {
            output.append(literal)
        }

        public mutating func appendInterpolation<T>(_ literal: T, attributes: AttributedText.Attributes) {
            output.append("\(literal)", attributes: attributes)
        }

        public mutating func appendInterpolation<T>(_ literal: T) {
            output.append("\(literal)")
        }
    }
}

extension AttributedText: AttributedTextConvertible {
    public func attributedText() -> AttributedText {
        return self
    }
}

// TODO: Use typed system to define attribute name and attribute values so mis-typing attributes is not possible

struct Attribute<T> {
    var name: String

    init(name: String) {
        self.name = name
    }

    func getValue(in attributes: AttributedText.Attributes) -> T? {
        return attributes[AttributedText.AttributeName(rawValue: name)] as? T
    }
}

// MARK: - Attribute definitions

/// Describes a type that can be used as a text attribute value in an
/// `AttributedText`'s attributes dictionary
public protocol TextAttributeType {
    /// Returns `true` if the presence of this text attribute alone should constitute
    /// as content in a segment it decorates.
    ///
    /// Should be `false` for attributes that strictly decorates attached text.
    var isContentAttribute: Bool { get }

    func isEqual(to other: TextAttributeType) -> Bool
}

public extension TextAttributeType {
    var isContentAttribute: Bool { false }
}

public extension TextAttributeType where Self: Equatable {
    func isEqual(to other: TextAttributeType) -> Bool {
        self == (other as? Self)
    }
}

public extension AttributedText {
    struct AttributeName: RawRepresentable, Hashable {
        public var rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

public extension AttributedText.AttributeName {
    static let font = Self(rawValue: "fontName")
    static let backgroundColor = Self(rawValue: "backgroundColor")
    static let foregroundColor = Self(rawValue: "foregroundColor")

    /// Specifies the type of bounds to use when rendering any available background
    /// color attribute.
    ///
    /// Behavior or rendering matches `TextBackgroundBoundsAttribute.segmentBounds`,
    /// if not specified.
    ///
    /// Should be a `TextBackgroundBoundsAttribute` attribute type.
    static let backgroundColorBounds = Self(rawValue: "backgroundColorBounds")

    /// Specifies the radius of the corner of the rectangle to draw along with
    /// the `backgroundColor` attribute.
    ///
    /// Should be a `Vector2` attribute type.
    static let cornerRadius = Self(rawValue: "cornerRadius")

    /// Specifies the stroke color to draw the text segment with.
    ///
    /// Should be a `Color` color structure.
    static let strokeColor = Self(rawValue: "strokeColor")

    /// Specifies the width of the line to stroke the outlines of the text segment
    /// with.
    ///
    /// Should be a `Double` attribute type.
    static let strokeWidth = Self(rawValue: "strokeWidth")

    /// Specifies the underline style of the text.
    ///
    /// Should be an `UnderlineStyleTextAttribute` attribute type.
    static let underlineStyle = Self(rawValue: "underlineStyle")

    /// Specifies the color to draw the underline style with.
    /// If not specified, defaults to the foreground color.
    ///
    /// Should be a `Color` color structure.
    static let underlineColor = Self(rawValue: "underlineColor")

    /// Specifies the strikethrough style of the text.
    ///
    /// Should be a `StrikethroughStyleTextAttribute` attribute type.
    static let strikethroughStyle = Self(rawValue: "strikethroughStyle")

    /// Specifies the color to draw the strikethrough style with.
    /// If not specified, defaults to the foreground color.
    ///
    /// Should be a `Color` color structure.
    static let strikethroughColor = Self(rawValue: "strikethroughColor")

    /// Specifies an image to be displayed inline with the text. The image will
    /// displace text within the line to comport it without affecting surrounding
    /// lines. The image will always render at the beginning of the segment it is
    /// associated with, displacing the remaining text to the sides.
    ///
    /// Should be an `ImageAttribute` image structure.
    static let image = Self(rawValue: "image")

    /// Specifies the vertical alignment of an image attribute. By default, the
    /// alignment is set to `ImageVerticalAlignmentAttribute.baseline`.
    ///
    /// If no `.image` attribute exists within the segment, this attribute is
    /// ignored.
    ///
    /// Should be an `ImageVerticalAlignmentAttribute` structure.
    static let imageVerticalAlignment = Self(rawValue: "imageVerticalAlignment")
}
