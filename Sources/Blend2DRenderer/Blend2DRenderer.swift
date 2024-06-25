@_exported import SwiftBlend2D
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

    private func _setStrokeField<Value>(_ keyPath: WritableKeyPath<StrokeStyle, Value>, _ value: Value) {
        self._stroke[keyPath: keyPath] = value
        _stroke.setStyle(in: _context)
    }

    // MARK: - Clear

    public func clear() {
        _context.clearAll()
    }

    /// Clears all the pixels back into a given color.
    public func clear(_ color: Color) {
        saveState()

        _context.setFillStyle(color.asBLRgba32)
        _context.fillRect(BLRect(location: .zero, size: _context.targetSize))

        restoreState()
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
        _setStrokeField(\.brush, .solid(color))
    }

    public func setStroke(_ gradient: Gradient) {
        _setStrokeField(\.brush, .gradient(gradient))
    }

    public func setStrokeWidth(_ width: Double) {
        _stroke.width = width
        _setStrokeField(\.width, width)
    }

    public func setStrokeDash(dashOffset: Double, dashArray: [Double]) {
        _stroke.dashOffset = dashOffset
        _stroke.dashArray = dashArray
        _stroke.setStyle(in: _context)
    }

    // MARK: - Fill

    public func fill(_ rect: UIRectangle) {
        _context.fillRect(rect.asBLRect)
    }

    public func fill(_ roundRect: UIRoundRectangle) {
        _context.fillRoundRect(roundRect.asBLRoundRect)
    }

    public func fill(_ circle: UICircle) {
        _context.fillCircle(circle.asBLCircle)
    }

    public func fill(_ ellipse: UIEllipse) {
        _context.fillEllipse(ellipse.asBLEllipse)
    }

    public func fill(_ polygon: UIPolygon) {
        _context.fillPolygon(polygon.vertices.map(\.asBLPoint))
    }

    public func fill(_ triangle: UITriangle) {
        _context.fillTriangle(triangle.asBLTriangle)
    }

    public func fill(_ bezier: UIBezier) {
        let path = bezier.drawOperations().toBLPath()

        _context.fillPath(path)
    }

    public func fill(chord: UIArc) {
        _context.fillChord(chord.asBLArc)
    }

    public func fill(pie: UIArc) {
        _context.fillPie(pie.asBLArc)
    }

    // MARK: - Stroke

    public func stroke(_ line: UILine) {
        _context.strokeLine(line.asBLLine)
    }

    public func stroke(_ rect: UIRectangle) {
        _context.strokeRect(rect.asBLRect)
    }

    public func stroke(_ roundRect: UIRoundRectangle) {
        _context.strokeRoundRect(roundRect.asBLRoundRect)
    }

    public func stroke(_ circle: UICircle) {
        _context.strokeCircle(circle.asBLCircle)
    }

    public func stroke(_ ellipse: UIEllipse) {
        _context.strokeEllipse(ellipse.asBLEllipse)
    }

    public func stroke(_ polygon: UIPolygon) {
        _context.strokePolygon(polygon.vertices.map(\.asBLPoint))
    }

    public func stroke(_ triangle: UITriangle) {
        _context.strokeTriangle(triangle.asBLTriangle)
    }

    public func strokeLine(start: UIVector, end: UIVector) {
        _context.strokeLine(p0: start.asBLPoint, p1: end.asBLPoint)
    }

    public func stroke(polyline: [UIVector]) {
        _context.strokePolyline(polyline.map(\.asBLPoint))
    }

    public func stroke(_ arc: UIArc) {
        _context.strokeArc(arc.asBLArc)
    }

    public func stroke(_ bezier: UIBezier) {
        let path = bezier.drawOperations().toBLPath()

        _context.strokePath(path)
    }

    public func stroke(chord: UIArc) {
        _context.strokeChord(chord.asBLArc)
    }

    public func stroke(pie: UIArc) {
        _context.strokePie(pie.asBLArc)
    }

    // MARK: - Bitmap

    public func drawImageScaled(_ image: Image, area: UIRectangle) {
        let image = blImage(from: image)

        _context.blitScaledImage(image, rectangle: area.asBLRect)
    }

    public func drawImage(_ image: Image, at point: UIVector) {
        let image = blImage(from: image)

        _context.blitImage(image, at: point.asBLPoint)
    }

    // MARK: - Text

    public func drawTextLayout(_ layout: TextLayoutType, at point: UIVector) {
        let renderer = TextLayoutRenderer(textLayout: layout)
        renderer.render(in: _context, location: point.asBLPoint)
    }

    public func strokeTextLayout(_ layout: TextLayoutType, at point: UIVector) {
        let renderer = TextLayoutRenderer(textLayout: layout)
        renderer.strokeText(in: _context, location: point.asBLPoint)
    }

    public func fillTextLayout(_ layout: TextLayoutType, at point: UIVector) {
        let renderer = TextLayoutRenderer(textLayout: layout)
        renderer.fillText(in: _context, location: point.asBLPoint)
    }

    // MARK: - Transform

    public func transform(_ matrix: UIMatrix) {
        _context.transform(matrix.asBLMatrix2D)
    }

    public func resetTransform() {
        _context.resetMatrix()
    }

    public func translate(x: Double, y: Double) {
        _context.translate(x: x, y: y)
    }

    public func translate(by vec: UIVector) {
        _context.translate(x: vec.x, y: vec.y)
    }

    public func scale(x: Double, y: Double) {
        _context.scale(x: x, y: y)
    }

    public func scale(by factor: UIVector) {
        _context.scale(x: factor.x, y: factor.y)
    }

    public func rotate(by angle: Double) {
        _context.rotate(angle: angle)
    }

    public func rotate(by angle: Double, around center: UIVector) {
        _context.rotate(angle: angle, x: center.x, y: center.y)
    }

    // MARK: - Clipping

    public func clip(_ rect: UIRectangle) {
        _context.clipToRect(rect.asBLRect)
    }

    public func restoreClipping() {
        _context.restoreClipping()
    }

    // MARK: - Global alpha

    public func setGlobalAlpha(_ alpha: Double) {
        _context.globalAlpha = alpha
    }

    // MARK: - State

    @discardableResult
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
}

struct BLContextStateToken: RendererStateToken {
    var cookie: BLContextCookie
}
