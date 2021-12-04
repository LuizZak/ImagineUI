public struct UIPolygon: Hashable, Codable {
    public typealias Scalar = UIPoint.Scalar

    public var vertices: [UIPoint]

    public var center: UIPoint {
        if vertices.isEmpty {
            return .zero
        }

        return vertices.reduce(.zero, +) / Double(vertices.count)
    }

    public init() {
        self.vertices = []
    }

    public init(vertices: [UIPoint]) {
        self.vertices = vertices
    }

    public mutating func addVertex(_ vertex: UIPoint) {
        vertices.append(vertex)
    }

    public mutating func addVertex(x: Scalar, y: Scalar) {
        addVertex(.init(x: x, y: y))
    }

    /// Adds a new vertex at the end of the vertices list that has the same location
    /// as the initial vertex.
    ///
    /// If this polygon has no vertices, nothing is done.
    public mutating func close() {
        guard let first = vertices.first else {
            return
        }

        addVertex(first)
    }

    public func withCenter(on point: UIPoint) -> UIPolygon {
        let center = self.center
        let offset = point - center

        return UIPolygon(vertices: vertices.map { vert in
            vert + offset
        })
    }

    public func rotatedAroundCenter(by angleInRadians: Double) -> UIPolygon {
        return rotated(by: angleInRadians, around: center)
    }

    public func rotated(by angleInRadians: Double, around center: UIPoint) -> UIPolygon {
        return UIPolygon(vertices: vertices.map { vert in
            vert.rotated(by: angleInRadians, around: center)
        })
    }

    /// Returns a polygon that is the transform of the vertices of this polygon
    /// using a given `UIMatrix`.
    public func transformed(by matrix: UIMatrix) -> UIPolygon {
        .init(vertices: matrix.transform(points: vertices))
    }

    /// Transforms the vertices of this polygon in place using a given `UIMatrix`.
    public mutating func transform(by matrix: UIMatrix) {
        self = transformed(by: matrix)
    }
}
