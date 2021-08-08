import Geometry
import SwiftBlend2D

class TextLayoutRenderer {
    typealias Line = TextLayout.Line
    typealias LineSegment = TextLayout.LineSegment
    
    let textLayout: TextLayout
    
    init(textLayout: TextLayout) {
        self.textLayout = textLayout
    }
    
    func render(to context: BLContext, origin: BLPoint) {
        iterateSegments { line, segment in
            context.save()
            
            let offset = line.bounds.topLeft
                + segment.bounds.topLeft
                + segment.offset
                + origin
            
            // Background color attribute
            if let backColor = segment.textSegment.attribute(named: .backgroundColor, type: _ColorType.self) {
                context.save()
                backColor.setFillInContext(context)
                
                // Background bounds attribute
                let bounds: BLRect
                if let boundsType = segment.textSegment.attribute(named: .backgroundColorBounds, type: TextBackgroundBoundsAttribute.self) {
                    bounds = boundsForBackground(segment: segment,
                                                 line: line,
                                                 type: boundsType)
                } else {
                    bounds = boundsForBackground(segment: segment,
                                                 line: line,
                                                 type: .segmentBounds)
                }
                
                // Corner radius attribute
                if let radius = segment.textSegment.attribute(named: .cornerRadius, type: Vector2.self) {
                    context.fillRoundRect(BLRoundRect(rect: bounds,
                                                      radius: radius.asBLPoint))
                } else {
                    context.fillRect(bounds)
                }
                
                context.restore()
            }
            
            // Foreground color attribute
            if let foreColor = segment.textSegment.attribute(named: .foregroundColor, type: _ColorType.self) {
                foreColor.setFillInContext(context)
                foreColor.setStrokeInContext(context)
            }
            
            // Underline
            if let underlineStyle = segment.textSegment.attribute(named: .underlineStyle, type: UnderlineStyleTextAttribute.self) {
                context.save()
                
                if let color = segment.textSegment.attribute(named: .underlineColor, type: _ColorType.self) {
                    color.setStrokeInContext(context)
                }
                
                renderUnderline(segment: segment,
                                line: line,
                                style: underlineStyle,
                                offset: offset,
                                to: context)
                
                context.restore()
            }
            
            context.fillGlyphRun(segment.glyphBufferMinusLineBreak.glyphRun,
                                 at: offset,
                                 font: segment.font)
            
            // Stroke color attribute
            if let strokeColor = segment.textSegment.attribute(named: .strokeColor, type: _ColorType.self) {
                let width = segment.textSegment.attribute(named: .strokeWidth, type: Double.self) ?? 0.0
                
                context.setStrokeWidth(width)
                strokeColor.setStrokeInContext(context)
                
                context.strokeGlyphRun(segment.glyphBufferMinusLineBreak.glyphRun,
                                       at: offset,
                                       font: segment.font)
            }
            
            // Strikethrough
            if let strikethroughStyle = segment.textSegment.attribute(named: .strikethroughStyle, type: StrikethroughStyleTextAttribute.self) {
                context.save()
                
                if let color = segment.textSegment.attribute(named: .strikethroughColor, type: _ColorType.self) {
                    color.setStrokeInContext(context)
                }
                
                renderStrikethrough(segment: segment,
                                    line: line,
                                    style: strikethroughStyle,
                                    offset: offset,
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
            let right = BLPoint(x: offset.x + segment.bounds.w, y: offset.y + underlineOffset)
            
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
            let right = BLPoint(x: offset.x + segment.bounds.w, y: offset.y + strikethroughOffset)
            
            context.setStrokeWidth(Double(segment.font.metrics.strikethroughThickness))
            context.strokeLine(p0: left, p1: right)
        }
    }
    
    private func boundsForBackground(segment: LineSegment,
                                     line: Line,
                                     type: TextBackgroundBoundsAttribute) -> BLRect {
        switch type {
        case .segmentBounds:
            return segment.bounds
            
        case .largestBaselineBounds:
            return segment.bounds.resized(width: segment.bounds.w, height: line.bounds.h).offsetBy(x: 0, y: -segment.bounds.y)
        }
    }
    
    private func iterateSegments(_ closure: (Line, LineSegment) -> Void) {
        for line in textLayout.lines {
            for segment in line.segments {
                closure(line, segment)
            }
        }
    }
}

private protocol _ColorType {
    func setFillInContext(_ context: BLContext)
    func setStrokeInContext(_ context: BLContext)
}

extension BLRgba32: _ColorType {
    func setFillInContext(_ context: BLContext) {
        context.setFillStyle(self)
    }
    
    func setStrokeInContext(_ context: BLContext) {
        context.setStrokeStyle(self)
    }
}
extension BLRgba64: _ColorType {
    func setFillInContext(_ context: BLContext) {
        context.setFillStyle(self)
    }
    
    func setStrokeInContext(_ context: BLContext) {
        context.setStrokeStyle(self)
    }
}
