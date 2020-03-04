import SwiftBlend2D

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
    
    /// Returns true if this attributed text's string contents are empty.
    public var isEmpty: Bool {
        return text.isEmpty
    }
    
    /// Returns the text segments for this attributed string
    public var textSegments: [TextSegment] {
        return segments
    }
    
    public init() {
        self.init("")
    }
    
    public init(_ text: String) {
        self.init(text, attributes: [:])
    }
    
    public init(_ text: String, attributes: Attributes) {
        self.text = text
        segments = [
            TextSegment(text: text,
                        textAttributes: attributes,
                        textRange: TextRange(start: 0, length: text.count))
        ]
    }
    
    public mutating func setText(_ text: String) {
        self.text = ""
        segments.removeAll()
        
        append(text)
    }
    
    public mutating func append(_ string: String) {
        append(string, attributes: [:])
    }
    
    public mutating func append(_ string: String, attributes: Attributes) {
        if text.isEmpty {
            // Remove dummy empty segment
            segments.removeAll()
        }
        
        assertAttributes(attributes)
        
        let segment = TextSegment(text: string,
                                  textAttributes: attributes,
                                  textRange: TextRange(start: text.count, length: string.count))
        
        segments.append(segment)
        
        text += string
        
        mergeSegments()
    }
    
    public mutating func append(_ attributedText: AttributedText) {
        let newLimit = text.count
        
        segments.append(contentsOf: attributedText.segments.map { seg in
            var seg = seg
            
            let range = TextRange(start: seg.textRange.start + newLimit,
                                  length: seg.textRange.length)
            
            seg.textRange = range
            
            return seg
        })
        
        mergeSegments()
    }
    
    public mutating func setAttributes(_ range: TextRange, _ attributes: Attributes) {
        assertAttributes(attributes)
        
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
    
    /// Removes all attributes on a given text range
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
    
    public mutating func removeAttributes(_ range: TextRange, attributeKeys: Set<Attributes.Key>) {
        if range.length == 0 {
            return
        }
        
        splitSegments(in: range)
        
        let indices = segmentIndicesIntersecting(range)
        
        for i in indices {
            let attributes = segments[i].textAttributes.filter { !attributeKeys.contains($0.key) }
            
            segments[i].textAttributes = attributes
        }
        
        mergeSegments()
    }
    
    public mutating func insert(_ string: String, at index: Int, attributes: Attributes = [:]) {
        splitSegmentUnder(index)
        
        for (i, segment) in segments.enumerated() {
            if segment.textRange.start >= index {
                segments[i].textRange = segment.textRange.offseting(by: string.count)
            }
        }
        
        let segment = TextSegment(text: string,
                                  textAttributes: attributes,
                                  textRange: TextRange(start: index, length: string.count))
        let segmentIndex = segments.firstIndex(where: { $0.textRange.start > index }) ?? segments.count
        segments.insert(segment, at: segmentIndex)
        
        let offset = text.index(text.startIndex, offsetBy: index)
        text.insert(contentsOf: string, at: offset)
        
        mergeSegments()
    }
    
    public mutating func insert(_ attributed: AttributedText, at index: Int, attributes: Attributes = [:]) {
        splitSegmentUnder(index)
        
        for (i, segment) in segments.enumerated() {
            if segment.textRange.start >= index {
                segments[i].textRange = segment.textRange.offseting(by: attributed.text.count)
            }
        }
        
        let newSegments = attributed.segments.map { segment -> TextSegment in
            var segment = segment
            segment.textRange = segment.textRange.offseting(by: index)
            return segment
        }
        
        let segmentIndex = segments.firstIndex(where: { $0.textRange.start > index }) ?? segments.count
        segments.insert(contentsOf: newSegments, at: segmentIndex)
        
        let offset = text.index(text.startIndex, offsetBy: index)
        text.insert(contentsOf: attributed.text, at: offset)
        
        mergeSegments()
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

        if position == length {
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
        
        let firstHalf = TextSegment(text: String(segment.text[characterRange: 0..<offset]),
                                    textAttributes: segment.textAttributes,
                                    textRange: firstHalfSeg)
        
        let secondHalf = TextSegment(text: String(segment.text[characterRange: offset...]),
                                     textAttributes: segment.textAttributes,
                                     textRange: secondHalfSeg)

        guard let index = segments.firstIndex(of: segment) else {
            return
        }

        segments[index] = firstHalf

        if index == segments.count - 1 {
            segments.append(secondHalf)
        } else {
            segments.insert(secondHalf, at: index + 1)
        }
    }
    
    public func segmentUnder(_ position: Int) -> TextSegment? {
        return segments.first(where: { $0.textRange.contains(position) })
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
    
    private func assertAttributes(_ attributes: Attributes) {
        func assertIsColor(_ value: Any, _ description: String) {
            switch value {
            case is BLRgba32, is BLRgba64:
                break
            default:
                assertionFailure(description)
            }
        }
        
        if let font = attributes[.font] {
            assert(font is BLFont,
                   "Attribute AttributeName.font is not a BLFont type")
        }
        if let backColor = attributes[.backgroundColor] {
            assertIsColor(backColor, "Attribute AttributeName.backgroundColor is not a BLRgba- color type type")
        }
        if let foreColor = attributes[.foregroundColor] {
            assertIsColor(foreColor, "Attribute AttributeName.foregroundColor is not a BLRgba- color type type")
        }
        if let cornerRadius = attributes[.cornerRadius] {
            assert(cornerRadius is Vector2,
                   "Attribute AttributeName.cornerRadius is not a Vector2 type")
        }
        if let boundsAttribute = attributes[.backgroundColorBounds] {
            assert(boundsAttribute is TextBackgroundBoundsAttribute,
                   "Attribute AttributeName.backgroundColorBounds is not a type")
        }
    }
    
    public struct TextSegment: Equatable {
        public var text: String
        public var textAttributes: Attributes
        public var textRange: TextRange
        
        func cloneWithAttributes(_ attributes: Attributes) -> TextSegment {
            return TextSegment(text: text, textAttributes: attributes, textRange: textRange)
        }
        
        func attribute<T>(named name: AttributeName, type: T.Type) -> T? {
            return textAttributes[name] as? T
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
            return TextSegment(text: text + other.text,
                               textAttributes: textAttributes.merging(other.textAttributes, uniquingKeysWith: { $1 }),
                               textRange: textRange.union(other.textRange))
        }
        
        public static func == (lhs: AttributedText.TextSegment, rhs: AttributedText.TextSegment) -> Bool {
            guard lhs.text == rhs.text && lhs.textRange == rhs.textRange && lhs.textAttributes.count == rhs.textAttributes.count else {
                return false
            }
            
            for (key, lhsValue) in lhs.textAttributes {
                guard let rhsAttribute = rhs.textAttributes[key] else {
                    return false
                }
                
                if !lhsValue.isEqual(to: rhsAttribute) {
                    return false
                }
            }
            
            return true
        }
    }
}

// MARK: - Rendering
public extension AttributedText {
    /// Renders this attributed text to a given context.
    ///
    /// - Parameter context: The context to render the text to.
    /// - Parameter origin: The top-left origin of the text in respect to the
    /// context.
    /// - Parameter baseFont: The base font to use when a text segment specifies
    /// no font attribute. Does not override fonts specified by attributes.
    /// - Parameter horizontalAlignment: Horizontal alignment of the text layout.
    /// - Parameter verticalAlignment: Vertical alignment of the text layout.
    func render(to context: BLContext,
                origin: BLPoint,
                baseFont: BLFont,
                horizontalAlignment: HorizontalTextAlignment = .leading,
                verticalAlignment: VerticalTextAlignment = .near) {
        
        let layout = TextLayout(font: baseFont,
                                attributedText: self,
                                horizontalAlignment: horizontalAlignment,
                                verticalAlignment: verticalAlignment)
        
        layout.renderText(in: context, location: origin)
    }
}

// MARK: -

/// Describes a type that can be used as a text attribute value in an
/// `AttributedText`'s attributes dictionary
public protocol TextAttributeType {
    func isEqual(to other: TextAttributeType) -> Bool
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
    /// Defaults to `segmentBounds`.
    ///
    /// Should be a `TextBackgroundBoundsAttribute` attribute type.
    static let backgroundColorBounds = Self(rawValue: "backgroundColorBounds")
    
    /// Specifies the radius of the corner of the rectangle to draw along with
    /// the `backgroundColor` attribute.
    ///
    /// Should be a `Vector2` attribute type.
    static let cornerRadius = Self(rawValue: "cornerRadius")
}
