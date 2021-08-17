/// Describes an ellipse as a double-precision, floating-point center with X and
/// Y radii
public typealias Ellipse = EllipseT<Double>

/// Describes an ellipse as a center with X and Y radii
public struct EllipseT<Scalar: VectorScalar>: Equatable, Codable {
    public var center: VectorT<Scalar>
    public var radiusX: Scalar
    public var radiusY: Scalar
    
    public init(center: VectorT<Scalar>, radiusX: Scalar, radiusY: Scalar) {
        self.center = center
        self.radiusX = radiusX
        self.radiusY = radiusY
    }
}
