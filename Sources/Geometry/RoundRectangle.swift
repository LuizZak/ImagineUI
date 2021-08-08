/// Represents a rounded rectangle with bounds and X and Y radius
public struct RoundRectangle: Equatable, Codable {
    public var bounds: Rectangle
    public var radiusX: Double
    public var radiusY: Double
    
    public init(bounds: Rectangle, radiusX: Double, radiusY: Double) {
        self.bounds = bounds
        self.radiusX = radiusX
        self.radiusY = radiusY
    }
}
