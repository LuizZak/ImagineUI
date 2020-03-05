import Foundation
import SwiftBlend2D

public protocol TextLayoutType {
    var font: BLFont { get }
    var text: String { get }
    var attributedText: AttributedText { get }
    var horizontalAlignment: HorizontalTextAlignment { get }
    var verticalAlignment: VerticalTextAlignment { get }
    var numberOfLines: Int { get }

    /// Total size of text layout area
    var size: Size { get }

    func locationOfCharacter(index: Int) -> Vector2
    func boundsForCharacters(startIndex: Int, length: Int) -> [Rectangle]
    func boundsForCharacters(in range: TextRange) -> [Rectangle]
    func hitTestPoint(_ point: Vector2) -> TextLayoutHitTestResult
    func font(atLocation index: Int) -> BLFont
    func baselineHeightForLine(atIndex index: Int) -> Float

    func strokeText(in context: BLContext, location: BLPoint)
    func fillText(in context: BLContext, location: BLPoint)
    
    /// Fully renders the contained text by utilizing information associated with
    /// the attributed text structure
    func renderText(in context: BLContext, location: BLPoint)
}

public class TextLayout: TextLayoutType {
    internal var lines: [Line] = []
    internal var minimalSize: Size = Size()

    public let font: BLFont
    public var text: String {
        return attributedText.string
    }
    public let attributedText: AttributedText
    public let horizontalAlignment: HorizontalTextAlignment
    public let verticalAlignment: VerticalTextAlignment
    public var numberOfLines: Int {
        return lines.count
    }

    public let availableSize: Size?
    public var size: Size {
        return availableSize ?? minimalSize
    }

    public init(font: BLFont, text: String, availableSize: Size? = nil,
                horizontalAlignment: HorizontalTextAlignment = .leading,
                verticalAlignment: VerticalTextAlignment = .near) {

        self.font = font
        attributedText = AttributedText(text)
        self.availableSize = availableSize
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment

        layoutLines()
    }
    
    public init(font: BLFont, attributedText: AttributedText, availableSize: Size? = nil,
                horizontalAlignment: HorizontalTextAlignment = .leading,
                verticalAlignment: VerticalTextAlignment = .near) {

        self.font = font
        self.attributedText = attributedText
        self.availableSize = availableSize
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment

        layoutLines()
    }

    public func locationOfCharacter(index: Int) -> Vector2 {
        func offsetFromLineSegment(line: Line, segment: LineSegment, offset: Int) -> Vector2 {
            let offsetIndex = offset - segment.startCharacterIndex
            
            var location = line.bounds.topLeft + segment.bounds.topLeft
            var iterator = BLGlyphRunIterator(glyphRun: segment.glyphBuffer.glyphRun)
            for _ in 0..<offsetIndex {
                if case .advanceOffset(let placement) = iterator.placementData {
                    location += segment.font.matrix.mapPoint(BLPoint(placement.advance))
                }
                
                iterator.advance()
            }
            
            return location.asVector2
        }
        
        if index <= 0 {
            return (lines[0].bounds.topLeft + lines[0].segments[0].bounds.topLeft).asVector2
        }
        
        for line in lines {
            guard index >= line.startCharacterIndex && index <= line.endCharacterIndex else {
                continue
            }
            
            if let segment = line.segment(containing: index) {
                return offsetFromLineSegment(line: line, segment: segment, offset: index)
            }
        }
        
        if let last = lines.last, last.endCharacterIndex < index {
            return offsetFromLineSegment(line: last,
                                         segment: last.segments[last.segments.count - 1],
                                         offset: last.endCharacterIndex)
        }

        return .zero
    }
    
    public func boundsForCharacters(startIndex: Int, length: Int) -> [Rectangle] {
        return boundsForCharacters(in: TextRange(start: startIndex, length: length))
    }
    
    public func boundsForCharacters(in range: TextRange) -> [Rectangle] {
        var boundsList: [BLRect] = []

        for line in lines where line.textRange.intersects(range) {
            for segment in line.segments(intersecting: range) {
                guard let intersection = segment.textRange.intersection(range) else {
                    continue
                }
                
                var segmentBounds: [BLRect] = []
                
                var advanceOffset: BLPoint = .zero
                
                var iterator = BLGlyphRunIterator(glyphRun: segment.glyphBuffer.glyphRun)
                while !iterator.atEnd {
                    defer { iterator.advance() }
                    guard case .advanceOffset(let advance) = iterator.placementData else {
                        continue
                    }
                    
                    if intersection.contains(segment.startCharacterIndex + iterator.index) {
                        let bounds = BLRect(x: advanceOffset.x,
                                            y: advanceOffset.y,
                                            w: Double(advance.advance.x),
                                            h: 0)
                        
                        segmentBounds.append(bounds)
                    }
                    
                    advanceOffset += BLPoint(advance.advance)
                }
                
                segmentBounds = segmentBounds
                    .map(segment.font.matrix.mapRect)
                    .map {
                        $0.resized(width: $0.w, height: Double(segment.font.metrics.ascent + segment.font.metrics.descent))
                            .offsetBy(x: line.bounds.topLeft.x + segment.bounds.topLeft.x,
                                      y: line.bounds.topLeft.y + segment.bounds.topLeft.y)
                    }
                
                boundsList.append(contentsOf: segmentBounds)
            }
        }
        
        return boundsList.map { $0.asRectangle }
    }
    
    public func hitTestPoint(_ point: Vector2) -> TextLayoutHitTestResult {
        let point = point.asBLPoint

        guard let line = lineAtHeight(point.y) else {
            return TextLayoutHitTestResult(isInside: false,
                                           textPosition: 0,
                                           stringIndex: text.startIndex,
                                           isTrailing: false,
                                           width: 0,
                                           height: 0)
        }
        
        var boxes: [BLBox] = []
        
        for segment in line.segments {
            var advanceOffset: BLPoint = .zero
            
            // TODO: Support cases where font's transform matrix doesn't in fact
            // inverts Y axis (so we would need to fetch the topLeft corner,
            // instead)
            advanceOffset += segment.originalBounds.bottomLeft // Inverted Y axis
            
            var segBoxes: [BLBox] = []
            
            var iterator = BLGlyphRunIterator(glyphRun: segment.glyphBuffer.glyphRun)
            while !iterator.atEnd {
                defer { iterator.advance() }
                guard case .advanceOffset(let advance) = iterator.placementData else {
                    continue
                }
                
                segBoxes.append(BLBox(x: advanceOffset.x,
                                      y: advanceOffset.y,
                                      w: Double(advance.advance.x),
                                      h: 0))

                advanceOffset += BLPoint(advance.advance)
            }

            segBoxes = segBoxes
                .map(segment.font.matrix.mapBox)
                .map {
                    $0.resized(width: $0.w, height: Double(segment.font.metrics.ascent + segment.font.metrics.descent))
                        .offsetBy(x: line.bounds.topLeft.x + segment.bounds.topLeft.x,
                                  y: line.bounds.topLeft.y + segment.bounds.topLeft.y)
                }
            
            boxes.append(contentsOf: segBoxes)
        }
        
        guard !boxes.isEmpty else {
            return TextLayoutHitTestResult(isInside: false,
                                           textPosition: 0,
                                           stringIndex: text.startIndex,
                                           isTrailing: false,
                                           width: 0,
                                           height: 0)
        }
        
        var closest = 0
        for (i, box) in boxes.enumerated() {
            if box.contains(point) {
                return
                    TextLayoutHitTestResult(
                        isInside: true,
                        textPosition: line.startCharacterIndex + i,
                        stringIndex: text.index(line.startIndex, offsetBy: i),
                        isTrailing: box.center.x < point.x,
                        width: box.w,
                        height: box.h)
            }
            
            // TODO: Should do distance to corner of box, not its center
            if boxes[closest].center.distanceSquared(to: point) > box.center.distanceSquared(to: point) {
                closest = i
            }
        }
        
        return TextLayoutHitTestResult(isInside: false,
                                       textPosition: line.startCharacterIndex + closest,
                                       stringIndex: text.index(line.startIndex, offsetBy: closest),
                                       isTrailing: boxes[closest].center.x < point.x,
                                       width: boxes[closest].w,
                                       height: boxes[closest].h)
    }
    
    public func font(atLocation index: Int) -> BLFont {
        let line = lines.first(where: { $0.textRange.contains(index) })
        guard let segment = line?.segment(containing: index) else {
            return font
        }
        
        return segment.font
    }
    
    public func baselineHeightForLine(atIndex index: Int) -> Float {
        return lines[index].baselineHeight
    }
    
    private func lineAtHeight(_ height: Double) -> Line? {
        if height < 0 {
            return lines.first
        }
        for line in lines {
            if line.bounds.contains(line.bounds.x, height) {
                return line
            }
        }
        
        return lines.last
    }

    public func strokeText(in context: BLContext, location: BLPoint) {
        iterateSegments { line, segment in
            let offset = line.bounds.topLeft
                + segment.bounds.topLeft
                + segment.offset
                + location
                
            context.strokeGlyphRun(segment.glyphBufferMinusLineBreak.glyphRun,
                                   at: offset,
                                   font: segment.font)
        }
    }

    public func fillText(in context: BLContext, location: BLPoint) {
        iterateSegments { line, segment in
            let offset = line.bounds.topLeft
                + segment.bounds.topLeft
                + segment.offset
                + location
            
            context.fillGlyphRun(segment.glyphBufferMinusLineBreak.glyphRun,
                                 at: offset,
                                 font: segment.font)
        }
    }
    
    public func renderText(in context: BLContext, location: BLPoint) {
        let renderer = TextLayoutRenderer(textLayout: self)
        renderer.render(to: context, origin: location)
    }
    
    private func iterateSegments(_ closure: (Line, LineSegment) -> Void) {
        for line in lines {
            for segment in line.segments {
                closure(line, segment)
            }
        }
    }

    private func layoutLines() {
        let collector = LineCollector(attributedText: attributedText, font: font)
        collector.collect()
        
        self.lines = collector.lines
        self.minimalSize = collector.minimalSize

        adjustAlignment()
    }

    private func adjustAlignment() {
        guard !lines.isEmpty else { return }

        /// By default, text layouts are already produced with a top-left text
        /// alignment
        if horizontalAlignment == .leading && verticalAlignment == .near { return }

        var accumulatedHeight: Double = 0

        for (i, line) in lines.enumerated() {
            var rect = line.bounds.asRectangle

            // Horizontal alignment
            switch horizontalAlignment {
            case .leading:
                rect = rect.movingLeft(to: 0)
            case .center:
                rect = rect.movingCenter(toX: size.x / 2, y: line.bounds.center.y)
            case .trailing:
                rect = rect.movingRight(to: size.x)
            }

            // Vertical alignment
            switch verticalAlignment {
            case .near, .center:
                rect = rect.movingTop(to: accumulatedHeight)
                accumulatedHeight += line.bounds.h
            case .far:
                rect = rect.movingTop(to: size.y - minimalSize.y + accumulatedHeight)
                accumulatedHeight += line.bounds.h
            }

            lines[i].bounds = rect.asBLRect
        }

        // Vertical centered text
        if verticalAlignment == .center {
            let centerY = lines.reduce(0) { $0 + $1.bounds.h } / 2
            let offset = size.y / 2 - centerY

            for (i, line) in lines.enumerated() {
                lines[i].bounds = line.bounds.asRectangle.offsetBy(x: 0, y: offset).asBLRect
            }
        }
    }

    private func isLineBreak(_ character: Character) -> Bool {
        return character.unicodeScalars.contains(where: CharacterSet.newlines.contains)
    }
    
    internal struct LineSegment {
        var textRange: TextRange {
            return TextRange.fromOffsets(startCharacterIndex, endCharacterIndex)
        }
        
        var startCharacterIndex: Int
        var endCharacterIndex: Int
        var startIndex: String.Index
        var endIndex: String.Index
        var text: Substring
        var glyphBuffer: BLGlyphBuffer
        var glyphBufferMinusLineBreak: BLGlyphBuffer
        var font: BLFont
        var textSegment: AttributedText.TextSegment
        
        /// Boundaries of this line segment, relative to the line's origin
        var bounds: BLRect
        
        /// Rendering offset to apply to this segment
        var offset: BLPoint
        
        /// `bounds` property's value, mapped to the original transformation
        /// space before being multiplied by the font's transform matrix
        var originalBounds: BLRect
    }

    internal struct Line {
        var textRange: TextRange {
            return TextRange.fromOffsets(startCharacterIndex, endCharacterIndex)
        }
        
        var segments: [LineSegment]
        
        var startCharacterIndex: Int
        var endCharacterIndex: Int
        var startIndex: String.Index
        var endIndex: String.Index
        var text: Substring
        var baselineHeight: Float
        
        /// The largest descent height from the line
        var descentHeight: Float
        
        /// Boundaries of line, in screen-space coordinates
        var bounds: BLRect
        
        func segment(containing index: Int) -> LineSegment? {
            return segments.first(where: { index >= $0.startCharacterIndex && index <= $0.endCharacterIndex })
        }
        
        func segments(intersecting range: TextRange) -> [LineSegment] {
            return segments.filter { $0.textRange.intersects(range) }
        }
    }
}

class LineCollector {
    private var currentWorkingSegment: WorkingSegment
    private var currentWorkingLine: WorkingLine
    private var currentSegment: AttributedText.TextSegment
    
    let attributedText: AttributedText
    let font: BLFont
    var index: String.Index
    var intIndex: Int
    var lines: [TextLayout.Line] = []
    var minimalSize: Size
    
    var text: String {
        return attributedText.string
    }
    
    init(attributedText: AttributedText, font: BLFont) {
        self.attributedText = attributedText
        self.font = font
        self.index = attributedText.string.startIndex
        self.intIndex = 0
        self.minimalSize = .zero
        
        currentWorkingSegment =
            WorkingSegment(font: font,
                           startIndex: index,
                           startCharIndex: 0,
                           topLeft: .zero)
        
        currentWorkingLine =
            WorkingLine(startIndex: index,
                        startCharIndex: intIndex,
                        segments: [],
                        topLeft: .zero)
        
        currentSegment = attributedText.textSegments[0]
        
        prepareWorkingLineFromCurrentState(topLeft: .zero)
    }
    
    func collect() {
        while index < text.endIndex {
            defer { moveForward() }
            
            if LineCollector.isLineBreak(text[index]) {
                moveForward()
                flushLine()
            } else if currentSegment != textSegmentUnderIndex() {
                flushSegment()
            }
        }
        
        // Flush last remaining line and segment
        flushLine()
    }
    
    private func moveForward() {
        index = text.index(after: index)
        intIndex += 1
    }
    
    private func flushSegment() {
        let lineSegment =
            currentWorkingSegment
                .makeLineSegment(endCharIndex: intIndex,
                                 endIndex: index,
                                 text: text,
                                 segment: currentSegment)
        
        currentWorkingLine.segments.append(lineSegment)
        
        currentSegment = textSegmentUnderIndex() ?? currentSegment
        
        prepareWorkingSegmentFromCurrentState(topLeft: lineSegment.bounds.topRight)
    }
    
    private func flushLine() {
        flushSegment()
        
        let line = currentWorkingLine.makeLine(text: text)
        
        lines.append(line)
        
        minimalSize = max(minimalSize, line.bounds.bottomRight.asVector2)
        
        prepareWorkingLineFromCurrentState(topLeft: line.bounds.bottomLeft)
    }
    
    private func prepareWorkingSegmentFromCurrentState(topLeft: BLPoint) {
        let segmentFontAttribute = currentSegment.textAttributes[.font] as? BLFont
        let segmentFont = segmentFontAttribute ?? font
        
        currentWorkingSegment =
            WorkingSegment(font: segmentFont,
                           startIndex: index,
                           startCharIndex: intIndex,
                           topLeft: topLeft)
    }
    
    private func prepareWorkingLineFromCurrentState(topLeft: BLPoint) {
        prepareWorkingSegmentFromCurrentState(topLeft: .zero)
        
        currentWorkingLine =
            WorkingLine(startIndex: index,
                        startCharIndex: intIndex,
                        segments: [],
                        topLeft: topLeft)
    }
    
    private func textSegmentUnderIndex() -> AttributedText.TextSegment? {
        return attributedText.segmentUnder(intIndex)
    }
    
    private static func isLineBreak(_ character: Character) -> Bool {
        return character.unicodeScalars.contains(where: CharacterSet.newlines.contains)
    }
    
    private struct WorkingSegment {
        var font: BLFont
        var startIndex: String.Index
        var startCharIndex: Int
        var topLeft: BLPoint
        
        func makeLineSegment(endCharIndex: Int, endIndex: String.Index,
                             text: String,
                             segment: AttributedText.TextSegment) -> TextLayout.LineSegment {
            
            let substring = text[startIndex..<endIndex]
            let lineGap = startIndex == text.startIndex ? 0.0 : font.metrics.lineGap
            let minHeight = Double(font.metrics.ascent + font.metrics.descent + lineGap)
            
            let glyphBuffer = BLGlyphBuffer(text: substring)
            let glyphBufferMinusLineBreak = BLGlyphBuffer(text: substring.filter { !isLineBreak($0) })
            font.shape(glyphBuffer)
            font.shape(glyphBufferMinusLineBreak)
            
            let metrics = font.getTextMetrics(glyphBufferMinusLineBreak)
            
            let bounds = BLRect(x: topLeft.x,
                                y: topLeft.y,
                                w: metrics.advance.x,
                                h: max(minHeight, metrics.boundingBox.h))
            
            let originalBounds = font.matrix.toMatrix2D().inverted.mapRect(bounds)
            
            let offset = BLPoint(x: 0, y: Double(font.metrics.ascent))
            
            return TextLayout.LineSegment(
                startCharacterIndex: startCharIndex,
                endCharacterIndex: endCharIndex,
                startIndex: startIndex,
                endIndex: endIndex,
                text: substring,
                glyphBuffer: glyphBuffer,
                glyphBufferMinusLineBreak: glyphBufferMinusLineBreak,
                font: font,
                textSegment: segment,
                bounds: bounds,
                offset: offset,
                originalBounds: originalBounds)
        }
    }
    
    private struct WorkingLine {
        var startIndex: String.Index
        var startCharIndex: Int
        var segments: [TextLayout.LineSegment]
        var topLeft: BLPoint
        
        func makeLine(text: String) -> TextLayout.Line {
            
            let startIndex = segments[0].startIndex
            let startCharIndex = segments[0].startCharacterIndex
            let endIndex = segments.last!.endIndex
            let endCharIndex = segments.last!.endCharacterIndex
            
            let substring = text[startIndex..<endIndex]
            
            var bounds: Rectangle = .empty
            
            var segments = self.segments
            var highestDescent: Float = 0
            var highestAscent: Float = 0
            
            for segment in segments {
                bounds = bounds.formUnion(segment.bounds.asRectangle)
                highestAscent = max(highestAscent, segment.font.metrics.ascent)
                highestDescent = max(highestDescent, segment.font.metrics.descent)
            }
            
            // Align segments down to the largest baseline
            for (i, segment) in segments.enumerated() {
                let bottom =
                    bounds.bottom
                        - Double(highestDescent)
                        + Double(segment.font.metrics.descent)
                    
                segments[i].bounds =
                    segment.bounds.asRectangle.movingBottom(to: bottom).asBLRect
                
                segments[i].originalBounds =
                    segments[i].font.matrix.mapRect(segments[i].bounds)
            }
            
            return TextLayout.Line(
                segments: segments,
                startCharacterIndex: startCharIndex,
                endCharacterIndex: endCharIndex,
                startIndex: startIndex,
                endIndex: endIndex,
                text: substring,
                baselineHeight: highestAscent,
                descentHeight: highestDescent,
                bounds: bounds.withLocation(topLeft.asVector2).asBLRect)
        }
    }
}

public struct TextLayoutHitTestResult {
    public var isInside: Bool
    public var textPosition: Int
    public var stringIndex: String.Index
    public var isTrailing: Bool
    public var width: Double
    public var height: Double
}
