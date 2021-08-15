import SwiftBlend2D
import Text
import Rendering

public class Blend2DRenderer: Renderer {
    private var _stroke: StrokeStyle
    private var _fill: FillStyle
    internal var _context: BLContext
    
    public var context: RenderContext { Blend2DRendererContext() }
    
    public init(context: BLContext) {
        _stroke = StrokeStyle(brush: .solid(.black))
        _fill = FillStyle(brush: .solid(.black))
        _context = context
    }
    
    public convenience init(image: BLImage, options: BLContext.CreateOptions? = nil) {
        self.init(context: BLContext(image: image, options: options)!)
    }
    
    // MARK: - Clear
    
    public func clear() {
        _context.clearAll()
    }
    
    // MARK: - Fill/Stroke Settings
    
    public func setFill(_ style: FillStyle) {
        self._fill = style
        _fill.setStyle(in: _context)
    }
    
    public func setFill(_ color: Color) {
        setFill(FillStyle(brush: .solid(color)))
    }
    
    public func setFill(_ gradient: Gradient) {
        setFill(FillStyle(brush: .gradient(gradient)))
    }
    
    public func setStroke(_ style: StrokeStyle) {
        self._stroke = style
        _stroke.setStyle(in: _context)
    }
    
    public func setStroke(_ color: Color) {
        setStroke(StrokeStyle(brush: .solid(color)))
    }
    
    public func setStroke(_ gradient: Gradient) {
        setStroke(StrokeStyle(brush: .gradient(gradient)))
    }
    
    public func setStrokeWidth(_ width: Double) {
        _stroke.width = width
        _context.setStrokeWidth(width)
    }
    
    // MARK: - Fill
    
    public func fill(_ rect: Rectangle) {
        _context.fillRect(rect.asBLRect)
    }
    
    public func fill(_ roundRect: RoundRectangle) {
        _context.fillRoundRect(roundRect.asBLRoundRect)
    }
    
    public func fill(_ circle: Circle) {
        _context.fillCircle(circle.asBLCircle)
    }
    
    public func fill(_ ellipse: Ellipse) {
        _context.fillEllipse(ellipse.asBLEllipse)
    }
    
    public func fill(_ polygon: Polygon) {
        _context.fillPolygon(polygon.vertices.map(\.asBLPoint))
    }
    
    // MARK: - Stroke
    
    public func stroke(_ line: Line) {
        _context.strokeLine(line.asBLLine)
    }
    
    public func stroke(_ rect: Rectangle) {
        _context.strokeRect(rect.asBLRect)
    }
    
    public func stroke(_ roundRect: RoundRectangle) {
        _context.strokeRoundRect(roundRect.asBLRoundRect)
    }
    
    public func stroke(_ circle: Circle) {
        _context.strokeCircle(circle.asBLCircle)
    }
    
    public func stroke(_ ellipse: Ellipse) {
        _context.strokeEllipse(ellipse.asBLEllipse)
    }
    
    public func stroke(_ polygon: Polygon) {
        _context.strokePolygon(polygon.vertices.map(\.asBLPoint))
    }
    
    public func strokeLine(start: Vector2, end: Vector2) {
        _context.strokeLine(p0: start.asBLPoint, p1: end.asBLPoint)
    }
    
    public func stroke(polyline: [Vector2]) {
        _context.strokePolyline(polyline.map(\.asBLPoint))
    }
    
    // MARK: - Bitmap
    
    public func drawImageScaled(_ image: Image, area: Rectangle) {
        let image = blImage(from: image)
        
        _context.blitScaledImage(image, rectangle: area.asBLRect)
    }
    
    public func drawImage(_ image: Image, at point: Vector2) {
        let image = blImage(from: image)
        
        _context.blitImage(image, at: point.asBLPoint)
    }
    
    // MARK: - Text
    
    public func drawTextLayout(_ layout: TextLayoutType, at point: Vector2) {
        let layout = textLayout(from: layout)
        
        let renderer = TextLayoutRenderer(textLayout: layout)
        renderer.render(in: _context, location: point.asBLPoint)
    }
    
    public func strokeTextLayout(_ layout: TextLayoutType, at point: Vector2) {
        let layout = textLayout(from: layout)
        
        let renderer = TextLayoutRenderer(textLayout: layout)
        renderer.strokeText(in: _context, location: point.asBLPoint)
    }
    
    public func fillTextLayout(_ layout: TextLayoutType, at point: Vector2) {
        let layout = textLayout(from: layout)
        
        let renderer = TextLayoutRenderer(textLayout: layout)
        renderer.fillText(in: _context, location: point.asBLPoint)
    }
    
    // MARK: - Transform
    
    public func transform(_ matrix: Matrix2D) {
        _context.transform(matrix.asBLMatrix2D)
    }
    
    public func resetTransform() {
        _context.resetMatrix()
    }
    
    public func translate(x: Double, y: Double) {
        _context.translate(x: x, y: y)
    }
    
    public func translate(by vec: Vector2) {
        _context.translate(x: vec.x, y: vec.y)
    }
    
    public func scale(x: Double, y: Double) {
        _context.scale(x: x, y: y)
    }
    
    public func scale(by factor: Vector2) {
        _context.scale(x: factor.x, y: factor.y)
    }
    
    public func rotate(by angle: Double) {
        _context.rotate(angle: angle)
    }
    
    public func rotate(by angle: Double, around center: Vector2) {
        _context.rotate(angle: angle, x: center.x, y: center.y)
    }
    
    // MARK: - Clipping
    
    public func clip(_ rect: Rectangle) {
        _context.clipToRect(rect.asBLRect)
    }
    
    public func restoreClipping() {
        _context.restoreClipping()
    }
    
    // MARK: - State
    
    public func saveState() -> RendererStateToken {
        let cookie = _context.saveWithCookie()
        
        return BLContextStateToken(cookie: cookie)
    }
    
    public func restoreState(_ state: RendererStateToken) {
        if let state = state as? BLContextStateToken {
            _context.restore(from: state.cookie)
        } else {
            fatalError("Unknown state type \(type(of: state))")
        }
    }
    
    public func restoreState() {
        _context.restore()
    }
    
    private func blImage(from image: Image) -> BLImage {
        guard let image = image as? Blend2DImage else {
            fatalError("Unknown image type \(type(of: image))")
        }
        
        return image.image
    }
    
    private func textLayout(from textLayout: TextLayoutType) -> TextLayout {
        guard let textLayout = textLayout as? TextLayout else {
            fatalError("Unknown text layout type \(type(of: textLayout))")
        }
        
        return textLayout
    }
}

struct BLContextStateToken: RendererStateToken {
    var cookie: BLContextCookie
}
