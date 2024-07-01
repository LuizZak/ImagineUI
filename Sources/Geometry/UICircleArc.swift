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

    /// Gets the length of this arc.
    @_transparent
    @inlinable
    func length() -> Double {
        sweepAngle * radius * 2
    }

    /// Returns `true` if this arc, when considered as a pie slice, contains a
    /// given point.
    func containsAsPie(_ point: UIPoint) -> Bool {
        if point == center {
            return true
        }

        let angle = normalized(angle: (point - center).angle())
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

        return center.distanceSquared(to: point) <= radius * radius
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
