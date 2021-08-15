/// Represents a polygon as a series of connected vertices
public struct Polygon {
    public var vertices: [Vector2]
    
    public init() {
        vertices = []
    }
    
    public init(vertices: [Vector2]) {
        self.vertices = vertices
    }
    
    /// Adds a new point at the end of this polygon's vertices list`
    public mutating func addVertex(_ v: Vector2) {
        vertices.append(v)
    }
    
    /// Adds a new point at the end of this polygon's vertices list`
    public mutating func addVertex(x: Double, y: Double) {
        vertices.append(Vector2(x: x, y: y))
    }
}
