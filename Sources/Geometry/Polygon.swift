public typealias Polygon = PolygonT<Double>

/// Represents a polygon as a series of connected vertices
public struct PolygonT<T: VectorScalar> {
    public var vertices: [VectorT<T>]
    
    public init() {
        vertices = []
    }
    
    public init(vertices: [VectorT<T>]) {
        self.vertices = vertices
    }
    
    /// Adds a new point at the end of this polygon's vertices list`
    public mutating func addVertex(_ v: VectorT<T>) {
        vertices.append(v)
    }
    
    /// Adds a new point at the end of this polygon's vertices list`
    public mutating func addVertex(x: T, y: T) {
        vertices.append(VectorT(x: x, y: y))
    }
}
