import Foundation

public struct UICircle: Hashable, Codable {
    /// The arc type for a circle.
    public typealias Arc = UICircleArc

    public typealias Scalar = Double

    public static let zero: Self = .init()

    public var center: UIPoint
    public var radius: Scalar

    public init() {
        center = .zero
        radius = .zero
    }

    @_transparent
    public init(center: UIPoint, radius: Scalar) {
        self.center = center
        self.radius = radius
    }

    @_transparent
    public init(x: Scalar, y: Scalar, radius: Scalar) {
        self.center = .init(x: x, y: y)
        self.radius = radius
    }
}

public extension UICircle {
    @_transparent
    var asUIEllipse: UIEllipse {
        .init(center: center, radius: UIVector(repeating: radius))
    }

    @_transparent
    var bounds: UIRectangle {
        .init(location: center - radius, size: UISize(repeating: radius * 2))
    }

    @_transparent
    func offsetBy(x: Scalar, y: Scalar) -> Self {
        offsetBy(.init(x: x, y: y))
    }

    @_transparent
    func offsetBy(_ point: UIVector) -> Self {
        var copy = self
        copy.center += point
        return copy
    }

    @_transparent
    func expanded(by scalar: Scalar) -> Self {
        .init(center: center, radius: radius + scalar)
    }

    @_transparent
    func scaled(by scalar: Scalar) -> Self {
        .init(center: center, radius: radius * scalar)
    }

    /// Creates an arc within this circle based on the given start and sweep
    /// angles, both in radians.
    @_transparent
    func arc(start startAngleInRadians: Double, sweep sweepAngleInRadians: Double) -> Arc {
        .init(
            center: center,
            radius: radius,
            startAngle: startAngleInRadians,
            sweepAngle: sweepAngleInRadians
        )
    }

    /// Creates an ellipse arc within this circle based on the given start and
    /// sweep angles, both in radians.
    @_transparent
    func ellipseArc(start startAngleInRadians: Double, sweep sweepAngleInRadians: Double) -> UIEllipse.Arc {
        .init(
            center: center,
            radius: radius,
            startAngle: startAngleInRadians,
            sweepAngle: sweepAngleInRadians
        )
    }

    /// Returns a point on this circle's perimeter on a given angle in radians.
    @_transparent
    func pointOnAngle(_ angleInRadians: Scalar) -> UIPoint {
        asUIEllipse.pointOnAngle(angleInRadians)
    }

    /// Returns a point on this circle's perimeter that is pointing in the same
    /// direction towards the center of the circle as the given point.
    @_transparent
    func projectOnPerimeter(_ point: UIPoint) -> UIPoint {
        if point == center {
            return center + .one.normalized() * radius
        }

        return center + (point - center).normalized() * radius
    }

    /// Returns `true` if this circle contains a given point.
    ///
    /// Points on the edge of the circle are considered to be within the circle
    /// by this method.
    @_transparent
    func contains(_ point: UIPoint) -> Bool {
        point.distanceSquared(to: center) <= radius * radius
    }
}
