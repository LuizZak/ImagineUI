import Foundation

/// A section of a circle represented as a center, radius, start angle, and sweep
/// angle.
public struct UICircleArc: Hashable, Codable {
    public typealias Scalar = Double

    public var center: UIPoint

    public var radius: Double

    /// Start of the arc, in radians.
    public var startAngle: Scalar

    /// Sweep of the arc, in radians.
    public var sweepAngle: Scalar

    /// Creates a new circular arc.
    public init(center: UIPoint, radius: Double, startAngle: Scalar, sweepAngle: Scalar) {
        self.center = center
        self.radius = radius
        self.startAngle = startAngle
        self.sweepAngle = sweepAngle
    }

    /// Creates a new circular arc that fills the space between `startPoint` and
    /// `endPoint`, with a sweep angle of `sweepAngle`.
    public init(startPoint: UIPoint, endPoint: UIPoint, sweepAngle: Scalar) {
        let mid = (endPoint + startPoint) / 2
        let gapDistance = endPoint.distance(to: startPoint)
        let arcNormal = (endPoint - startPoint).normalized().rightRotated()

        let center: UIPoint =
            mid - arcNormal * 0.5 * gapDistance / tan(sweepAngle / 2)

        self.init(
            center: center,
            radius: startPoint.distance(to: center),
            startAngle: center.angle(to: startPoint),
            sweepAngle: sweepAngle
        )
    }
}

public extension UICircleArc {
    /// Returns a circle that encompasses this arc.
    @_transparent
    @inlinable
    var circle: UICircle {
        .init(center: center, radius: radius)
    }

    /// Returns an ellipse that encompasses this arc.
    @_transparent
    @inlinable
    var ellipse: UIEllipse {
        .init(center: center, radiusX: radius, radiusY: radius)
    }

    /// Returns an ellipse arc that encompasses this arc.
    @_transparent
    @inlinable
    var ellipseArc: UIEllipseArc {
        .init(center: center, radius: radius, startAngle: startAngle, sweepAngle: sweepAngle)
    }

    /// Computes the starting point of this arc based on its center + radius +
    /// startAngle.
    @_transparent
    @inlinable
    var startPoint: UIPoint {
        pointOnAngle(startAngle)
    }

    /// Computes the starting point of this arc based on its center + radius +
    /// startAngle + sweepAngle.
    @_transparent
    @inlinable
    var endPoint: UIPoint {
        pointOnAngle(startAngle + sweepAngle)
    }

    /// Returns a point on the circle represented by this arc on a given angle
    /// in radians.
    @_transparent
    @inlinable
    func pointOnAngle(_ angleInRadians: Scalar) -> UIPoint {
        circle.pointOnAngle(angleInRadians)
    }

    /// Gets the positive length of this arc.
    @inlinable
    func length() -> Double {
        sweepAngle.magnitude * radius
    }

    /// Returns `true` if this arc contains a given angle within its sweep.
    func containsAngle(_ angle: Scalar) -> Bool {
        let angle = normalized(angle: angle)
        var start = normalized(angle: startAngle)
        var stop = normalized(angle: startAngle + sweepAngle)
        if sweepAngle < 0 {
            swap(&start, &stop)
        }

        if start < stop {
            guard angle >= start && angle <= stop else {
                return false
            }
        } else {
            guard angle >= start || angle <= stop else {
                return false
            }
        }

        return true
    }

    /// Returns `true` if this arc, when considered as a pie slice, contains a
    /// given point.
    func containsAsPie(_ point: UIPoint) -> Bool {
        if point == center {
            return true
        }

        let angle = (point - center).angle()
        guard containsAngle(angle) else {
            return false
        }

        return center.distanceSquared(to: point) <= radius * radius
    }
}

internal extension UICircleArc {
    /// Returns the minimal bounding box capable of fully containing this arc.
    func bounds() -> UIRectangle {
        let points = quadrants() + [startPoint, endPoint]

        return UIRectangle(boundsFor: points)
    }

    /// Returns the coordinates of the occupied quadrants that this arc sweeps
    /// through.
    ///
    /// The resulting array is up to four elements long, with each element
    /// representing an axis, from the arc's center point, in the +/- x and +/- y
    /// direction, if the arc's sweep includes that point.
    func quadrants() -> [UIPoint] {
        let quadrantAngles: [Scalar] = [
            0, .pi / 2, .pi, .pi * 3 / 2
        ]
        var result: [UIPoint] = []

        let sweep = UIAngleSweep(start: startAngle, sweep: sweepAngle)
        for quadrant in quadrantAngles {
            if sweep.contains(quadrant) {
                result.append(pointOnAngle(quadrant))
            }
        }

        return result
    }

    /// Returns the squared distance to the closest point within this arc to the
    /// given point.
    func distanceSquared(to point: UIPoint) -> Scalar {
        let angle = UIAngle(radians: (point - center).angle()).radians
        let sweep = UIAngleSweep(start: .init(radians: startAngle), sweep: sweepAngle)

        // Full circle
        guard sweepAngle.magnitude < .pi * 2 else {
            let pointOnArc = circle.projectOnPerimeter(point)
            let distance = pointOnArc.distance(to: point)

            return distance
        }

        let clamped = sweep.clamped(.init(radians: angle))

        let pointOnArc = pointOnAngle(clamped.radians)
        let distance = pointOnArc.distance(to: point)

        return distance
    }

    /// Returns the up to two intersection points between this arc and a given
    /// line.
    func intersection(with line: UILine) -> (UIPoint?, UIPoint?) {
        var (pointA, pointB) = circle.intersection(with: line)

        if let p = pointA, !containsAngle((p - center).angle()) {
            pointA = nil
        }
        if let p = pointB, !containsAngle((p - center).angle()) {
            pointB = nil
        }

        return (pointA, pointB)
    }
}

private func normalized(angle: Double) -> Double {
    var angle = angle
    while angle > .pi * 2 {
        angle -= .pi * 2
    }
    while angle < 0 {
        angle += .pi * 2
    }
    return angle
}
