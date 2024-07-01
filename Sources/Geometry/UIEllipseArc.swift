import Foundation

/// A section of an ellipse represented as a center, radius, start angle, and sweep
/// angle.
public struct UIEllipseArc: Hashable, Codable {
    public typealias Scalar = Double

    public var center: UIPoint

    public var radius: UIVector

    /// Start of the arc, in radians.
    public var startAngle: Scalar

    /// Sweep of the arc, in radians.
    public var sweepAngle: Scalar

    public init(center: UIPoint, radius: UIVector, startAngle: Scalar, sweepAngle: Scalar) {
        self.center = center
        self.radius = radius
        self.startAngle = startAngle
        self.sweepAngle = sweepAngle
    }

    /// Creates a new circular arc.
    public init(center: UIPoint, radius: Scalar, startAngle: Scalar, sweepAngle: Scalar) {
        self.center = center
        self.radius = UIVector(repeating: radius)
        self.startAngle = startAngle
        self.sweepAngle = sweepAngle
    }
}

public extension UIEllipseArc {
    /// Returns an ellipse that encompasses this arc.
    @_transparent
    @inlinable
    var ellipse: UIEllipse {
        .init(center: center, radius: radius)
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

    /// Returns a point on the ellipse represented by this arc on a given angle
    /// in radians.
    @_transparent
    @inlinable
    func pointOnAngle(_ angleInRadians: Scalar) -> UIPoint {
        ellipse.pointOnAngle(angleInRadians)
    }
}
