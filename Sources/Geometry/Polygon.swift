/// Describes a polygon as a series of connected double-precision, floating-point
/// vertices
public typealias Polygon = PolygonT<Double>

/// Describes a polygon as a series of connected vertices
public struct PolygonT<Scalar: VectorScalar> {
    public var vertices: [VectorT<Scalar>]
    
    public init() {
        vertices = []
    }
    
    public init(vertices: [VectorT<Scalar>]) {
        self.vertices = vertices
    }
    
    /// Adds a new point at the end of this polygon's vertices list`
    public mutating func addVertex(_ v: VectorT<Scalar>) {
        vertices.append(v)
    }
    
    /// Adds a new point at the end of this polygon's vertices list`
    public mutating func addVertex(x: Scalar, y: Scalar) {
        vertices.append(VectorT(x: x, y: y))
    }
}
