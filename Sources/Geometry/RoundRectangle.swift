/// Represents a rounded rectangle with double-point bounds and X and Y radius
public typealias RoundRectangle = RoundRectangleT<Double>

/// Represents a rounded rectangle with bounds and X and Y radius
public struct RoundRectangleT<T: VectorScalar>: Equatable, Codable {
    public var bounds: RectangleT<T>
    public var radius: VectorT<T>
    
    public init(bounds: RectangleT<T>, radius: VectorT<T>) {
        self.bounds = bounds
        self.radius = radius
    }
    
    public init(bounds: RectangleT<T>, radiusX: T, radiusY: T) {
        self.bounds = bounds
        self.radius = VectorT<T>(x: radiusX, y: radiusY)
    }
}
