import SwiftBlend2D
import Rendering

public class Blend2DRenderer: Renderer {
    private var _stroke: StrokeStyle
    private var _fill: FillStyle
    internal var context: BLContext
    
    public init(image: BLImage, options: BLContext.CreateOptions? = nil) {
        _stroke = StrokeStyle(brush: .solid(.black))
        _fill = FillStyle(brush: .solid(.black))
        context = BLContext(image: image, options: options)!
    }
    
    public func setFill(_ style: FillStyle) {
        self._fill = style
        _fill.setStyle(in: context)
    }
    
    public func setStroke(_ style: StrokeStyle) {
        self._stroke = style
        _stroke.setStyle(in: context)
    }
    
    public func setStrokeWidth(_ width: Double) {
        _stroke.width = width
        context.setStrokeWidth(width)
    }
    
    public func fill(_ rect: Rectangle) {
        context.fillRect(rect.asBLRect)
    }
    
    public func fill(_ roundRect: RoundRectangle) {
        context.fillRoundRect(roundRect.asBLRoundRect)
    }
    
    public func fill(_ circle: Circle) {
        context.fillCircle(circle.asBLCircle)
    }
    
    public func fill(_ ellipse: Ellipse) {
        context.fillEllipse(ellipse.asBLEllipse)
    }
    
    public func stroke(_ line: Line) {
        context.strokeLine(line.asBLLine)
    }
    
    public func stroke(_ rect: Rectangle) {
        context.strokeRect(rect.asBLRect)
    }
    
    public func stroke(_ roundRect: RoundRectangle) {
        context.strokeRoundRect(roundRect.asBLRoundRect)
    }
    
    public func stroke(_ circle: Circle) {
        context.strokeCircle(circle.asBLCircle)
    }
    
    public func stroke(_ ellipse: Ellipse) {
        context.strokeEllipse(ellipse.asBLEllipse)
    }
}
