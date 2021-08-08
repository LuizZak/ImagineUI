@_exported import Geometry

/// Protocol for abstract renderers
public protocol Renderer {
    
    // MARK: - Fill/Stroke Settings
    
    /// Sets the fill style of subsequent fill operations to match a given fill style brush.
    func setFill(_ style: FillStyle)
    
    /// Sets the stroke style of subsequent stroke operations to match a given stroke style brush.
    /// Width is set to the style's width parameter.
    func setStroke(_ style: StrokeStyle)
    
    /// Sets the width of the current stroke brush.
    func setStrokeWidth(_ width: Double)
    
    // MARK: - Fill Operations
    
    /// Fills a given rectangle with the current fill style
    func fill(_ rect: Rectangle)
    
    /// Fills a given rounded rectangle with the current fill style
    func fill(_ roundRect: RoundRectangle)
    
    /// Fills a given circle with the current fill style
    func fill(_ circle: Circle)
    
    /// Fills a given ellipse with the current fill style
    func fill(_ ellipse: Ellipse)
    
    // MARK: - Stroke Operations
    
    /// Strokes a given line with the current stroke style
    func stroke(_ line: Line)
    
    /// Strokes a given rectangle with the current stroke style
    func stroke(_ rect: Rectangle)
    
    /// Strokes a given rounded rectangle with the current stroke style
    func stroke(_ roundRect: RoundRectangle)
    
    /// Strokes a given circle with the current stroke style
    func stroke(_ circle: Circle)
    
    /// Strokes a given ellipse with the current stroke style
    func stroke(_ ellipse: Ellipse)
}
