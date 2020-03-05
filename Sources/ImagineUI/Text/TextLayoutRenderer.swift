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
            
            if let underlineStyle = segment.textSegment.attribute(named: .underlineStyle, type: UnderlineStyleAttribute.self) {
                // TODO: Implement underline coloring
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
            
            context.restore()
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
