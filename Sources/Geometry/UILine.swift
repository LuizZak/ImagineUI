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

    @inlinable
    func intersection(with other: Self) -> UIPoint? {
        let denom = ((other.end.y - other.start.y) * (self.end.x - self.start.x)) - ((other.end.x - other.start.x) * (self.end.y - self.start.y))

        // if denom == 0, lines are parallel - being a bit generous on this one..
        if abs(denom) < .leastNonzeroMagnitude {
            return nil
        }

        let UaTop = ((other.end.x - other.start.x) * (self.start.y - other.start.y)) - ((other.end.y - other.start.y) * (self.start.x - other.start.x))
        let UbTop = ((self.end.x - self.start.x) * (self.start.y - other.start.y)) - ((self.end.y - self.start.y) * (self.start.x - other.start.x))

        let Ua = UaTop / denom
        let Ub = UbTop / denom

        if Ua >= 0 && Ua <= 1 && Ub >= 0 && Ub <= 1 {
            // these lines intersect!
            let hitPt = self.start + ((self.end - self.start) * Ua)

            return hitPt
        }

        return nil
    }
}

public extension UILine {
    /// Returns the center point of this line.
    @inlinable
    var center: UIPoint {
        start * 0.5 + end * 0.5
    }

    /// Returns the result of offsetting this line by a given amount.
    @_transparent
    func offset(byX x: Scalar, y: Scalar) -> Self {
        offset(by: .init(x: x, y: y))
    }

    /// Returns the result of offsetting this line by a given amount.
    @_transparent
    func offset(by vector: UIVector) -> Self {
        .init(start: start + vector, end: end + vector)
    }

    /// Returns the result of scaling this line towards the origin by a given
    /// factor.
    func scaled(byX x: Scalar, y: Scalar) -> Self {
        scaled(by: .init(x: x, y: y))
    }

    /// Returns the result of scaling this line towards the origin by a given
    /// factor.
    func scaled(by factor: UIVector) -> Self {
        Self(start: start * factor, end: end * factor)
    }

    /// Returns the result of scaling this line around the given point by a given
    /// factor.
    func scaled(by factor: UIVector, around center: UIPoint) -> Self {
        Self(
            start: (start - center) * factor + center,
            end: (end - center) * factor + center
        )
    }
}

public extension UILine {
    /// Moves this line such that its center coincides with a given point, while
    /// keeping the length and rotation the same.
    func withCenter(on point: UIPoint) -> Self {
        let center = self.center
        let offset = point - center

        return Self(start: start + offset, end: end + offset)
    }

    /// Rotates the endpoints of this line around the origin by a given angle in
    /// radians.
    func rotatedAroundCenter(by angleInRadians: Double) -> Self {
        return rotated(by: angleInRadians, around: center)
    }

    /// Rotates the endpoints of this line around the given center point by a
    /// given angle in radians.
    func rotated(by angleInRadians: Double, around center: UIPoint) -> Self {
        return Self(
            start: start.rotated(by: angleInRadians, around: center),
            end: end.rotated(by: angleInRadians, around: center)
        )
    }

    /// Returns a polygon that is the transform of the end points of this line
    /// using a given `UIMatrix`.
    func transformed(by matrix: UIMatrix) -> Self {
        .init(start: matrix.transform(start), end: matrix.transform(end))
    }

    /// Transforms the endpoints of this line in place using a given `UIMatrix`.
    mutating func transform(by matrix: UIMatrix) {
        self = transformed(by: matrix)
    }
}
