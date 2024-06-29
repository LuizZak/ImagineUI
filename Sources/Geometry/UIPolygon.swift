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

    public mutating func insertVertex(_ vertex: UIPoint, at index: Int) {
        vertices.insert(vertex, at: index)
    }

    public mutating func insertVertex(x: Scalar, y: Scalar, at index: Int) {
        insertVertex(.init(x: x, y: y), at: index)
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

    /// Computes the minimum bounding box for this polygon.
    ///
    /// If the polygon is empty, `UIRectangle.empty` is returned, instead.
    public func bounds() -> UIRectangle {
        UIRectangle(boundsFor: vertices)
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
