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
}
