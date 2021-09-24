public struct UIPolygon: Hashable, Codable {
    public typealias Scalar = UIPoint.Scalar

    public var vertices: [UIPoint]

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
}