/// Represents an ellipse as a center with X and Y radii
public struct Ellipse: Equatable, Codable {
    public var center: Vector2
    public var radiusX: Double
    public var radiusY: Double
    
    public init(center: Vector2, radiusX: Double, radiusY: Double) {
        self.center = center
        self.radiusX = radiusX
        self.radiusY = radiusY
    }
}
