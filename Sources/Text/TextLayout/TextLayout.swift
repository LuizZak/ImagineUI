import Foundation
import Geometry

public class TextLayout: TextLayoutType {
    internal var minimalSize: Size = Size()
    
    public let font: Font
    
    public internal(set) var lines: [TextLayoutLine] = []
    
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

    public init(font: Font,
                text: String,
                availableSize: Size? = nil,
                horizontalAlignment: HorizontalTextAlignment = .leading,
                verticalAlignment: VerticalTextAlignment = .near) {

        self.font = font
        attributedText = AttributedText(text)
        self.availableSize = availableSize
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment

        layoutLines()
    }
    
    public init(font: Font,
                attributedText: AttributedText,
                availableSize: Size? = nil,
                horizontalAlignment: HorizontalTextAlignment = .leading,
                verticalAlignment: VerticalTextAlignment = .near) {

        self.font = font
        self.attributedText = attributedText
        self.availableSize = availableSize
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment

        layoutLines()
    }

    public func locationOfCharacter(index: Int) -> Vector {
        func offsetFromLineSegment(line: TextLayoutLine,
                                   segment: TextLayoutLineSegment,
                                   offset: Int) -> Vector {
            
            let offsetIndex = offset - segment.startCharacterIndex
            
            var location = line.bounds.topLeft + segment.bounds.topLeft
            var iterator = segment.glyphBuffer.makeIterator()
            for _ in 0..<offsetIndex {
                if let placement = iterator.advanceOffset {
                    location += segment.font.matrix.transform(Vector(placement.advance))
                }
                
                iterator.advance()
            }
            
            return location
        }
        
        if index <= 0 {
            return lines[0].bounds.topLeft + lines[0].segments[0].bounds.topLeft
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
    
    /// Returns the rectangular boundaries for a glyph at a given index.
    /// - precondition: `index >= 0 && index < text.count`
    public func boundsForCharacter(at index: Int) -> Rectangle {
        precondition(index >= 0 && index < text.count)
        
        return boundsForCharacters(in: TextRange(start: index, length: 1))[0]
    }
    
    public func boundsForCharacters(startIndex: Int, length: Int) -> [Rectangle] {
        return boundsForCharacters(in: TextRange(start: startIndex, length: length))
    }
    
    public func boundsForCharacters(in range: TextRange) -> [Rectangle] {
        var boundsList: [Rectangle] = []
        
        for line in lines where line.textRange.intersects(range) {
            for segment in line.segments(intersecting: range) {
                guard let intersection = segment.textRange.intersection(range) else {
                    continue
                }
                
                let height = Double(segment.font.metrics.ascent + segment.font.metrics.descent)
                
                var advanceOffset: Vector = .zero
                
                var iterator = segment.glyphBuffer.makeIterator()
                while !iterator.atEnd {
                    defer { iterator.advance() }
                    guard let advance = iterator.advanceOffset else {
                        continue
                    }
                    
                    let index = segment.startCharacterIndex + iterator.index
                    
                    if intersection.contains(index) {
                        var bounds = Rectangle(x: advanceOffset.x,
                                               y: advanceOffset.y,
                                               width: Double(advance.advance.x),
                                               height: 0)
                        
                        bounds = segment.font.matrix.transform(bounds)
                        bounds = bounds
                            .withSize(width: bounds.width, height: height)
                            .offsetBy(x: line.bounds.topLeft.x + segment.bounds.topLeft.x,
                                      y: line.bounds.topLeft.y + segment.bounds.topLeft.y)
                        
                        boundsList.append(bounds)
                    } else if intersection.end < index {
                        break
                    }
                    
                    advanceOffset += advance.advance
                }
            }
        }
        
        return boundsList
    }
    
    public func hitTestPoint(_ point: Vector) -> TextLayoutHitTestResult {
        guard let line = lineAtHeight(point.y) else {
            return TextLayoutHitTestResult(isInside: false,
                                           textPosition: 0,
                                           stringIndex: text.startIndex,
                                           isTrailing: false,
                                           width: 0,
                                           height: 0)
        }
        
        var closestIndex = 0
        var closestRect = Rectangle.zero
        
        var absoluteIndex = 0
        for segment in line.segments {
            let height = Double(segment.font.metrics.ascent + segment.font.metrics.descent)
            
            // TODO: Support cases where font's transform matrix doesn't in fact
            // inverts Y axis (so we would need to fetch the topLeft corner,
            // instead)
            var advanceOffset = segment.originalBounds.bottomLeft // Inverted Y axis
            
            var iterator = segment.glyphBuffer.makeIterator()
            while !iterator.atEnd {
                defer { absoluteIndex += 1 }
                defer { iterator.advance() }
                guard let advance = iterator.advanceOffset else {
                    continue
                }
                
                var rect = Rectangle(x: advanceOffset.x,
                                     y: advanceOffset.y,
                                     width: Double(advance.advance.x),
                                     height: 0)
                
                rect = segment.font.matrix.transform(rect)
                rect = rect
                    .withSize(width: rect.width, height: height)
                    .offsetBy(x: line.bounds.topLeft.x + segment.bounds.topLeft.x,
                              y: line.bounds.topLeft.y + segment.bounds.topLeft.y)
                
                if rect.contains(point) {
                    return
                        TextLayoutHitTestResult(
                            isInside: true,
                            textPosition: segment.startCharacterIndex + iterator.index,
                            stringIndex: text.index(segment.startIndex, offsetBy: iterator.index),
                            isTrailing: rect.center.x < point.x,
                            width: rect.width,
                            height: rect.height)
                }
                
                // TODO: Should do distance to corner of rect, not its center
                if iterator.index == 0 {
                    closestRect = rect
                } else if closestRect.center.distanceSquared(to: point) > rect.center.distanceSquared(to: point) {
                    closestIndex = absoluteIndex
                    closestRect = rect
                }
                
                advanceOffset += advance.advance
            }
        }
        
        return TextLayoutHitTestResult(isInside: false,
                                       textPosition: line.startCharacterIndex + closestIndex,
                                       stringIndex: text.index(line.startIndex, offsetBy: closestIndex),
                                       isTrailing: closestRect.center.x < point.x,
                                       width: closestRect.width,
                                       height: closestRect.height)
    }
    
    public func font(atLocation index: Int) -> Font {
        let line = lines.first(where: { $0.textRange.contains(index) })
        guard let segment = line?.segment(containing: index) else {
            return font
        }
        
        return segment.font
    }
    
    public func baselineHeightForLine(atIndex index: Int) -> Float {
        return lines[index].baselineHeight
    }
    
    private func lineAtHeight(_ height: Double) -> TextLayoutLine? {
        if height < 0 {
            return lines.first
        }
        for line in lines {
            if line.bounds.contains(x: line.bounds.x, y: height) {
                return line
            }
        }
        
        return lines.last
    }
    
    public func iterateSegments(_ closure: (TextLayoutLine, TextLayoutLineSegment) -> Void) {
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
            var rect = line.bounds

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
                accumulatedHeight += line.bounds.height
            case .far:
                rect = rect.movingTop(to: size.y - minimalSize.y + accumulatedHeight)
                accumulatedHeight += line.bounds.height
            }
            
            lines[i].bounds = rect
        }
        
        // Vertical centered text
        if verticalAlignment == .center {
            let centerY: Double = lines.reduce(0) { $0 + $1.bounds.height } / 2
            let offset = size.y / 2 - centerY
            
            for (i, line) in lines.enumerated() {
                lines[i].bounds = line.bounds.offsetBy(x: 0, y: offset)
            }
        }
    }
    
    private func isLineBreak(_ character: Character) -> Bool {
        return character.unicodeScalars.contains(where: CharacterSet.newlines.contains)
    }
}

private class LineCollector {
    private var currentWorkingSegment: WorkingSegment
    private var currentWorkingLine: WorkingLine
    private var currentSegment: AttributedText.TextSegment
    
    let attributedText: AttributedText
    let font: Font
    var index: String.Index
    var intIndex: Int
    var lines: [TextLayoutLine] = []
    var minimalSize: Size
    
    var text: String {
        return attributedText.string
    }
    
    init(attributedText: AttributedText, font: Font) {
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
        text.formIndex(after: &index)
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
        
        minimalSize = max(minimalSize, line.bounds.bottomRight)
        
        prepareWorkingLineFromCurrentState(topLeft: line.bounds.bottomLeft)
    }
    
    private func prepareWorkingSegmentFromCurrentState(topLeft: Vector) {
        let segmentFontAttribute = currentSegment.textAttributes[.font] as? Font
        let segmentFont = segmentFontAttribute ?? font
        
        currentWorkingSegment =
            WorkingSegment(font: segmentFont,
                           startIndex: index,
                           startCharIndex: intIndex,
                           topLeft: topLeft)
    }
    
    private func prepareWorkingLineFromCurrentState(topLeft: Vector) {
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
        var font: Font
        var startIndex: String.Index
        var startCharIndex: Int
        var topLeft: Vector
        
        func makeLineSegment(endCharIndex: Int, endIndex: String.Index,
                             text: String,
                             segment: AttributedText.TextSegment) -> TextLayoutLineSegment {
            
            let substring = text[startIndex..<endIndex]
            let substringMinusLineBreaks = substring.filter { !isLineBreak($0) }
            let lineGap = startIndex == text.startIndex ? 0.0 : font.metrics.lineGap
            let minHeight = Double(font.metrics.ascent + font.metrics.descent + lineGap)
            
            let glyphBuffer = font.createGlyphBuffer(substring)
            let glyphBufferMinusLineBreak = font.createGlyphBuffer(substringMinusLineBreaks)
            
            // Ok to force-unwrap: FontType.createGlyphBuffer guarantees a glyph
            // buffer that works with the same FontType.getTextMetrics
            let metrics = font.getTextMetrics(glyphBufferMinusLineBreak)!
            
            let bounds = Rectangle(x: topLeft.x,
                                   y: topLeft.y,
                                   width: metrics.advance.x,
                                   height: max(minHeight, metrics.boundingBox.height))
            
            let originalBounds = font.matrix.toMatrix2D().inverted().transform(bounds)
            
            let offset = Vector(x: 0, y: Double(font.metrics.ascent))
            
            return TextLayoutLineSegment(
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
        var segments: [TextLayoutLineSegment]
        var topLeft: Vector
        
        func makeLine(text: String) -> TextLayoutLine {
            let startIndex = segments[0].startIndex
            let startCharIndex = segments[0].startCharacterIndex
            let endIndex = segments.last!.endIndex
            let endCharIndex = segments.last!.endCharacterIndex
            
            let substring = text[startIndex..<endIndex]
            
            var bounds: Rectangle = .zero
            
            var segments = self.segments
            var highestDescent: Float = 0
            var highestAscent: Float = 0
            var highestUnderline: Float = 0
            
            for segment in segments {
                bounds = bounds.union(segment.bounds)
                highestAscent = max(highestAscent, segment.font.metrics.ascent)
                highestDescent = max(highestDescent, segment.font.metrics.descent)
                highestUnderline = max(highestUnderline, segment.font.metrics.underlinePosition)
            }
            
            // Align segments down to the largest baseline
            for (i, segment) in segments.enumerated() {
                let bottom =
                    bounds.bottom
                        - Double(highestDescent)
                        + Double(segment.font.metrics.descent)
                    
                segments[i].bounds =
                    segment.bounds.movingBottom(to: bottom)
                
                segments[i].originalBounds =
                    segments[i].font.matrix.transform(segments[i].bounds)
            }
            
            return TextLayoutLine(
                segments: segments,
                startCharacterIndex: startCharIndex,
                endCharacterIndex: endCharIndex,
                startIndex: startIndex,
                endIndex: endIndex,
                text: substring,
                baselineHeight: highestAscent,
                underlineOffset: highestUnderline,
                bounds: bounds.withLocation(topLeft))
        }
    }
}
