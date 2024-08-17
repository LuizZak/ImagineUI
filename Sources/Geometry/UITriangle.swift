/// A triangle consisting of three points.
public struct UITriangle: Hashable, Codable {
    private static let equilateralHeight = 0.866025404
    private static let equilateralOffset = 0.14433756733333333

    /// An upright equilateral triangle where each side is unit-length.
    ///
    /// The centroid of the triangle is at (0, 0).
    ///
    /// The first point is the top-most center point of the triangle.
    public static let unitEquilateral = UITriangle(
        x0: 0,
        y0: -equilateralHeight / 2 - equilateralOffset,
        x1: 0.5,
        y1: equilateralHeight / 2 - equilateralOffset,
        x2: -0.5,
        y2: equilateralHeight / 2 - equilateralOffset
    )

    public var p0: UIPoint
    public var p1: UIPoint
    public var p2: UIPoint

    public var x0: Double {
        p0.x
    }
    public var y0: Double {
        p0.y
    }
    public var x1: Double {
        p1.x
    }
    public var y1: Double {
        p1.y
    }
    public var x2: Double {
        p2.x
    }
    public var y2: Double {
        p2.y
    }

    /// Computes the centroid of this triangle
    @inlinable
    public var centroid: UIPoint {
        return (p0 + p1 + p2) / 3
    }

    public init(x0: Double, y0: Double, x1: Double, y1: Double, x2: Double, y2: Double) {
        self.init(
            p0: UIPoint(x: x0, y: y0),
            p1: UIPoint(x: x1, y: y1),
            p2: UIPoint(x: x2, y: y2)
        )
    }

    public init(p0: UIPoint, p1: UIPoint, p2: UIPoint) {
        self.p0 = p0
        self.p1 = p1
        self.p2 = p2
    }

    @inlinable
    public func contains(x: Double, y: Double) -> Bool {
        func sign(_ p1x: Double, _ p1y: Double, _ p2x: Double,
                  _ p2y: Double, _ p3x: Double, _ p3y: Double) -> Double {

            return (p1x - p3x) * (p2y - p3y) - (p2x - p3x) * (p1y - p3y)
        }

        let d1 = sign(x, y, x0, y0, x1, y1)
        let d2 = sign(x, y, x1, y1, x2, y2)
        let d3 = sign(x, y, x2, y2, x0, y0)

        let has_neg = (d1 < 0) || (d2 < 0) || (d3 < 0)
        let has_pos = (d1 > 0) || (d2 > 0) || (d3 > 0)

        return !(has_neg && has_pos)
    }

    @inlinable
    public func contains(_ point: UIPoint) -> Bool {
        return contains(x: point.x, y: point.y)
    }

    /// Returns a new triangle represented by the coordinates of this triangle,
    /// scaled by a given factor around the centroid.
    ///
    /// The centroid of the resulting triangle matches the centroid of the original
    /// triangle.
    @inlinable
    public func scaledBy(x: Double, y: Double) -> UITriangle {
        return scaledBy(UIVector(x: x, y: y))
    }

    /// Returns a new triangle represented by the coordinates of this triangle,
    /// scaled by a given factor around the centroid.
    ///
    /// The centroid of the resulting triangle matches the centroid of the original
    /// triangle.
    @inlinable
    public func scaledBy(_ scale: UIVector) -> UITriangle {
        let center = centroid

        return UITriangle(
            p0: center + (p0 - center) * scale,
            p1: center + (p1 - center) * scale,
            p2: center + (p2 - center) * scale
        )
    }

    /// Returns a new copy of this triangle with the vertices offset by a given
    /// pair of coordinates.
    @inlinable
    public func offsetBy(x: Double, y: Double) -> UITriangle {
        return UITriangle(
            x0: x0 + x,
            y0: y0 + y,
            x1: x1 + x,
            y1: y1 + y,
            x2: x2 + x,
            y2: y2 + y
        )
    }

    /// Returns a new copy of this triangle with the vertices offset by a given
    /// point.
    @inlinable
    public func offsetBy(_ vector: UIVector) -> UITriangle {
        return offsetBy(x: vector.x, y: vector.y)
    }

    /// Returns a new copy of this triangle with the vertices rotated along the
    /// centroid by a given radian amount
    @inlinable
    public func rotated(by angleInRadians: Double) -> UITriangle {
        return rotated(by: angleInRadians, around: centroid)
    }

    /// Returns a new copy of this triangle with the vertices rotated along the
    /// given point by a given radian amount
    @inlinable
    public func rotated(by angleInRadians: Double, around center: UIPoint) -> UITriangle {
        let newP0 = p0.rotated(by: angleInRadians, around: center)
        let newP1 = p1.rotated(by: angleInRadians, around: center)
        let newP2 = p2.rotated(by: angleInRadians, around: center)

        return UITriangle(p0: newP0, p1: newP1, p2: newP2)
    }

    /// Returns a new copy of this triangle with the vertices transformed around
    /// by a given matrix
    public func transformed(by matrix: UIMatrix) -> UITriangle {
        return UITriangle(
            p0: matrix.transform(p0),
            p1: matrix.transform(p1),
            p2: matrix.transform(p2)
        )
    }
}
