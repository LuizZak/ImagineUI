/// Represents a rounded rectangle with bounds and X and Y radius
public struct RoundRectangle: Equatable, Codable {
    public var bounds: Rectangle
    public var radius: Vector2
    
    public init(bounds: Rectangle, radius: Vector2) {
        self.bounds = bounds
        self.radius = radius
    }
    
    public init(bounds: Rectangle, radiusX: Double, radiusY: Double) {
        self.bounds = bounds
        self.radius = Vector2(x: radiusX, y: radiusY)
    }
}
