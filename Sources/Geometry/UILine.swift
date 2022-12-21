public struct UILine: Hashable, Codable {
    public typealias Scalar = UIPoint.Scalar

    public static let zero: Self = .init()

    public var start: UIPoint
    public var end: UIPoint

    public init() {
        self.start = .zero
        self.end = .zero
    }

    public init(start: UIPoint, end: UIPoint) {
        self.start = start
        self.end = end
    }

    @_transparent
    public init(x1: Scalar, y1: Scalar, x2: Scalar, y2: Scalar) {
        start = .init(x: x1, y: y1)
        end = .init(x: x2, y: y2)
    }

    @_transparent
    public func length() -> Scalar {
        start.distance(to: end)
    }

    @_transparent
    public func lengthSquared() -> Scalar {
        start.distanceSquared(to: end)
    }

    @inlinable
    public func distance(to point: UIPoint) -> Double {
        distanceSquared(to: point).squareRoot()
    }

    @inlinable
    public func distanceSquared(to point: UIPoint) -> Double {
        let projected = project(point)

        return projected.distanceSquared(to: point)
    }

    @inlinable
    func project(_ point: UIPoint) -> UIPoint {
        let relEnd = end - start
        let relVec = point - start
        
        let proj = relVec.dot(relEnd) / relEnd.lengthSquared()
        
        return start + relEnd * proj
    }
}

public extension UILine {
    @_transparent
    func offsetBy(x: Scalar, y: Scalar) -> Self {
        offsetBy(.init(x: x, y: y))
    }

    @_transparent
    func offsetBy(_ vector: UIVector) -> Self {
        .init(start: start + vector, end: end + vector)
    }
}
