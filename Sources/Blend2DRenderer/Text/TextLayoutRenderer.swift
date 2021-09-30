import Geometry
import SwiftBlend2D
import Rendering
import Text

class TextLayoutRenderer {
    typealias Line = TextLayoutLine
    typealias LineSegment = TextLayoutLineSegment
    
    let textLayout: TextLayoutType
    
    init(textLayout: TextLayoutType) {
        self.textLayout = textLayout
    }
    
    func strokeText(in context: BLContext, location: BLPoint) {
        iterateSegments { line, segment in
            let offset = line.bounds.topLeft
                + segment.bounds.topLeft
                + segment.offset
                + location.asVector2
            
            let font = toBLFont(segment.font)
            let glyphBufferMinusLineBreak = toBLGlyphBuffer(segment.glyphBufferMinusLineBreak)
            
            context.strokeGlyphRun(glyphBufferMinusLineBreak.glyphRun,
                                   at: offset.asBLPoint,
                                   font: font)
        }
    }
    
    func fillText(in context: BLContext, location: BLPoint) {
        iterateSegments { line, segment in
            let offset = line.bounds.topLeft
                + segment.bounds.topLeft
                + segment.offset
                + location.asVector2
            
            let font = toBLFont(segment.font)
            let glyphBufferMinusLineBreak = toBLGlyphBuffer(segment.glyphBufferMinusLineBreak)
            
            context.fillGlyphRun(glyphBufferMinusLineBreak.glyphRun,
                                 at: offset.asBLPoint,
                                 font: font)
        }
    }
    
    func render(in context: BLContext, location: BLPoint) {
        iterateSegments { line, segment in
            context.save()
            
            let font = toBLFont(segment.font)
            let glyphBufferMinusLineBreak = toBLGlyphBuffer(segment.glyphBufferMinusLineBreak)
            
            let offset = line.bounds.topLeft
                + segment.bounds.topLeft
                + segment.offset
                + location.asVector2
            
            // Background color attribute
            if let backColor = segment.textSegment.attribute(named: .backgroundColor,
                                                             type: Color.self) {
                context.save()
                context.setFillStyle(backColor.asBLRgba32)
                
                // Background bounds attribute
                let bounds: UIRectangle
                if let boundsType = segment.textSegment.attribute(named: .backgroundColorBounds,
                                                                  type: TextBackgroundBoundsAttribute.self) {
                    bounds = boundsForBackground(segment: segment,
                                                 line: line,
                                                 type: boundsType)
                } else {
                    bounds = boundsForBackground(segment: segment,
                                                 line: line,
                                                 type: .segmentBounds)
                }
                
                // Corner radius attribute
                if let radius = segment.textSegment.attribute(named: .cornerRadius,
                                                              type: UIVector.self) {
                    context.fillRoundRect(bounds.makeRoundedRectangle(radius: radius).asBLRoundRect)
                } else {
                    context.fillRect(bounds.asBLRect)
                }
                
                context.restore()
            }
            
            // Foreground color attribute
            if let foreColor = segment.textSegment.attribute(named: .foregroundColor,
                                                             type: Color.self) {
                context.setFillStyle(foreColor.asBLRgba32)
                context.setStrokeStyle(foreColor.asBLRgba32)
            }
            
            // Underline
            if let underlineStyle = segment.textSegment.attribute(named: .underlineStyle,
                                                                  type: UnderlineStyleTextAttribute.self) {
                context.save()
                
                if let color = segment.textSegment.attribute(named: .underlineColor,
                                                             type: Color.self) {
                    context.setStrokeStyle(color.asBLRgba32)
                }
                
                renderUnderline(segment: segment,
                                line: line,
                                style: underlineStyle,
                                offset: offset.asBLPoint,
                                to: context)
                
                context.restore()
            }
            
            context.fillGlyphRun(glyphBufferMinusLineBreak.glyphRun,
                                  at: offset.asBLPoint,
                                  font: font)
            
            // Stroke color attribute
            if let strokeColor = segment.textSegment.attribute(named: .strokeColor, type: Color.self) {
                let width = segment.textSegment.attribute(named: .strokeWidth, type: Double.self) ?? 0.0
                
                context.setStrokeWidth(width)
                context.setStrokeStyle(strokeColor.asBLRgba32)
                
                context.strokeGlyphRun(glyphBufferMinusLineBreak.glyphRun,
                                        at: offset.asBLPoint,
                                        font: font)
            }
            
            // Strikethrough
            if let strikethroughStyle = segment.textSegment.attribute(named: .strikethroughStyle, type: StrikethroughStyleTextAttribute.self) {
                context.save()
                
                if let color = segment.textSegment.attribute(named: .strikethroughColor, type: Color.self) {
                    context.setFillStyle(color.asBLRgba32)
                }
                
                renderStrikethrough(segment: segment,
                                    line: line,
                                    style: strikethroughStyle,
                                    offset: offset.asBLPoint,
                                    to: context)
                
                context.restore()
            }
            
            
            context.restore()
        }
    }
    
    private func renderUnderline(segment: LineSegment,
                                 line: Line,
                                 style: UnderlineStyleTextAttribute,
                                 offset: BLPoint,
                                 to context: BLContext) {
        
        let underlineOffset = Double(line.underlineOffset)
        
        switch style {
        case .single:
            let left = BLPoint(x: offset.x, y: offset.y + underlineOffset)
            let right = BLPoint(x: offset.x + segment.bounds.width, y: offset.y + underlineOffset)
            
            context.setStrokeWidth(Double(segment.font.metrics.underlineThickness))
            context.strokeLine(p0: left, p1: right)
        }
    }
    
    private func renderStrikethrough(segment: LineSegment,
                                     line: Line,
                                     style: StrikethroughStyleTextAttribute,
                                     offset: BLPoint,
                                     to context: BLContext) {
        
        let strikethroughOffset = Double(segment.font.metrics.strikethroughPosition)
        
        switch style {
        case .single:
            let left = BLPoint(x: offset.x, y: offset.y + strikethroughOffset)
            let right = BLPoint(x: offset.x + segment.bounds.width, y: offset.y + strikethroughOffset)
            
            context.setStrokeWidth(Double(segment.font.metrics.strikethroughThickness))
            context.strokeLine(p0: left, p1: right)
        }
    }
    
    private func boundsForBackground(segment: LineSegment,
                                     line: Line,
                                     type: TextBackgroundBoundsAttribute) -> UIRectangle {
        switch type {
        case .segmentBounds:
            return segment.bounds
            
        case .largestBaselineBounds:
            return segment
                .bounds
                .withSize(width: segment.bounds.width, height: line.bounds.height)
                .offsetBy(x: 0, y: -segment.bounds.y)
        }
    }
    
    private func iterateSegments(_ closure: (Line, LineSegment) -> Void) {
        for line in textLayout.lines {
            for segment in line.segments {
                closure(line, segment)
            }
        }
    }
    
    private func toBLFont(_ font: Font) -> BLFont {
        guard let font = font as? Blend2DFont else {
            fatalError("Unknown font type \(type(of: font)), expected type \(Blend2DFont.self)")
        }
        
        return font.font
    }
    
    private func toBLGlyphBuffer(_ buffer: GlyphBuffer) -> BLGlyphBuffer {
        guard let buffer = buffer as? Blend2DGlyphBuffer else {
            fatalError("Unknown glyph buffer type \(type(of: buffer)), expected type \(Blend2DGlyphBuffer.self)")
        }
        
        return buffer.buffer
    }
}
