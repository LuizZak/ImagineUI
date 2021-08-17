/// Represents an ellipse as a double-point center with X and Y radii
public typealias Ellipse = EllipseT<Double>

/// Represents an ellipse as a center with X and Y radii
public struct EllipseT<T: VectorScalar>: Equatable, Codable {
    public var center: VectorT<T>
    public var radiusX: T
    public var radiusY: T
    
    public init(center: VectorT<T>, radiusX: T, radiusY: T) {
        self.center = center
        self.radiusX = radiusX
        self.radiusY = radiusY
    }
}
