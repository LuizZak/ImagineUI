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
}
