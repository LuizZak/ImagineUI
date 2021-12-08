import Geometry
import Text

/// Protocol for abstract renderers
public protocol Renderer {
    /// Gets the context for this renderer
    var context: RenderContext { get }

    // MARK: - Clear

    /// Clears all the pixels back into a transparent black (#000000) color.
    func clear()

    /// Clears all the pixels back into a given color.
    func clear(_ color: Color)

    // MARK: - Fill/Stroke Settings

    /// Sets the fill style of subsequent fill operations to match a given fill style brush.
    func setFill(_ style: FillStyle)

    /// Convenience for `setFill(FillStyle(brush: .solid(color)))`
    func setFill(_ color: Color)

    /// Convenience for `setFill(FillStyle(brush: .gradient(gradient)))`
    func setFill(_ gradient: Gradient)

    /// Sets the stroke style of subsequent stroke operations to match a given stroke style brush.
    /// Width is set to the style's width parameter.
    func setStroke(_ style: StrokeStyle)

    /// Convenience for `setStroke(StrokeStyle(brush: .solid(color)))`
    func setStroke(_ color: Color)

    /// Convenience for `setStroke(StrokeStyle(brush: .gradient(gradient)))`
    func setStroke(_ gradient: Gradient)

    /// Sets the width of the current stroke brush.
    func setStrokeWidth(_ width: Double)

    /// Sets the stroke dash for the current stroke brush.
    func setStrokeDash(dashOffset: Double, dashArray: [Double])

    // MARK: - Fill Operations

    /// Fills a given rectangle with the current fill style
    func fill(_ rect: UIRectangle)

    /// Fills a given rounded rectangle with the current fill style
    func fill(_ roundRect: UIRoundRectangle)

    /// Fills a given circle with the current fill style
    func fill(_ circle: UICircle)

    /// Fills a given ellipse with the current fill style
    func fill(_ ellipse: UIEllipse)

    /// Fills a given polygon with the current fill style
    func fill(_ polygon: UIPolygon)

    /// Fills a given triangle with the current fill style
    func fill(_ triangle: UITriangle)

    /// Fills a given arc as a chord with the current fill style
    func fill(chord: UIArc)

    /// Fills a given arc as a pie with the current fill style
    func fill(pie: UIArc)

    // MARK: - Stroke Operations

    /// Strokes a given line with the current stroke style
    func stroke(_ line: UILine)

    /// Strokes a given rectangle with the current stroke style
    func stroke(_ rect: UIRectangle)

    /// Strokes a given rounded rectangle with the current stroke style
    func stroke(_ roundRect: UIRoundRectangle)

    /// Strokes a given circle with the current stroke style
    func stroke(_ circle: UICircle)

    /// Strokes a given ellipse with the current stroke style
    func stroke(_ ellipse: UIEllipse)

    /// Strokes a given polygon with the current stroke style
    func stroke(_ polygon: UIPolygon)

    /// Strokes a given triangle with the current stroke style
    func stroke(_ triangle: UITriangle)

    /// Strokes a given arc with the current stroke style
    func stroke(_ arc: UIArc)

    /// Strokes a given arc as a chord with the current stroke style
    func stroke(chord: UIArc)

    /// Strokes a given arc as a pie with the current stroke style
    func stroke(pie: UIArc)

    /// Strokes a line formed by the given start and end vectors with the
    /// current stroke style
    func strokeLine(start: UIVector, end: UIVector)

    /// Strokes a list of points as a contiguous line
    func stroke(polyline: [UIVector])

    // MARK: - Bitmap

    /// Draws a given image wth the given bounds, scaling the image as necessary
    func drawImageScaled(_ image: Image, area: UIRectangle)

    /// Draws a given image at a given point
    func drawImage(_ image: Image, at point: UIVector)

    // MARK: - Text

    /// Draws a text layout on a given point
    func drawTextLayout(_ layout: TextLayoutType, at point: UIVector)

    /// Strokes a text layout on a given point
    func strokeTextLayout(_ layout: TextLayoutType, at point: UIVector)

    /// Fills a text layout on a given point
    func fillTextLayout(_ layout: TextLayoutType, at point: UIVector)

    // MARK: - Transformation

    /// Applies the given matrix on top of the current transformation stack for
    /// subsequent draw calls on this renderer
    func transform(_ matrix: UIMatrix)

    /// Resets the transformation back to its identity
    func resetTransform()

    /// Applies a translation transform to the subsequent draw calls on this renderer
    func translate(x: Double, y: Double)

    /// Applies a translation transform to the subsequent draw calls on this renderer
    func translate(by vec: UIVector)

    /// Applies a scale transform to the subsequent draw calls on this renderer
    func scale(x: Double, y: Double)

    /// Applies a scale transform to the subsequent draw calls on this renderer
    func scale(by factor: UIVector)

    /// Applies a rotation transform to the subsequent draw calls on this renderer
    ///
    /// - parameters:
    ///     - angle: The angle to rotate by, in radians
    func rotate(by angle: Double)

    /// Applies a rotation transform around a given center point to the
    /// subsequent draw calls on this renderer
    ///
    /// - parameters:
    ///     - angle: The angle to rotate by, in radians
    ///     - center: The center point of the rotation transform
    func rotate(by angle: Double, around center: UIVector)

    // MARK: - Clipping

    /// Clips the draw region of the renderer to contain the given Rectangle.
    /// Any currently active clip is intersected with the new clipping rectangle.
    func clip(_ rect: UIRectangle)

    /// Restores the clipping of this Renderer back
    func restoreClipping()

    // MARK: - Save/Restore State

    /// Saves the current renderer state and returns a token that when passed to
    /// `restoreState()` results in the same state as when this method was called
    @discardableResult
    func saveState() -> RendererStateToken

    /// Restores renderer state to the state before the last `saveState()` call
    func restoreState()

    /// Restores renderer state to the state represented by the given token
    func restoreState(_ state: RendererStateToken)

    /// Performs a given closure while this renderer saves its internal state,
    /// reverting any change before returning control to the caller.
    ///
    /// Can be nested multiple times, resulting in intermediary states that are
    /// popped in FIFO order.
    func withTemporaryState<T>(_ closure: () throws -> T) rethrows -> T
}

public extension Renderer {
    func withTemporaryState<T>(_ closure: () throws -> T) rethrows -> T {
        let token = saveState()
        defer {
            restoreState(token)
        }

        return try closure()
    }
}

public protocol RendererStateToken {

}

/// Result for invocations of ``Renderer/hitTestClip(_:)``
public enum HitTestResult {
    case `in`
    case partial
    case out
}
