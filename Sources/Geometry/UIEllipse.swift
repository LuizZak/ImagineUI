import Foundation

public struct UIEllipse: Hashable, Codable {
    /// The arc type for an ellipse.
    public typealias Arc = UIEllipseArc

    public typealias Scalar = UIPoint.Scalar

    public static let zero: Self = .init()

    public var center: UIPoint
    public var radius: UIVector

    public var radiusX: Scalar {
        @_transparent
        get { radius.x }
        @_transparent
        set { radius.x = newValue }
    }

    public var radiusY: Scalar {
        @_transparent
        get { radius.y }
        @_transparent
        set { radius.y = newValue }
    }

    public init() {
        center = .zero
        radius = .zero
    }

    public init(center: UIPoint, radius: UIVector) {
        self.center = center
        self.radius = radius
    }

    public init(center: UIPoint, radiusX: Scalar, radiusY: Scalar) {
        self.init(center: center, radius: .init(x: radiusX, y: radiusY))
    }
}

public extension UIEllipse {
    @_transparent
    var bounds: UIRectangle {
        .init(location: center - radius, size: radius.asUISize * 2)
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
    func scaledBy(x: Scalar, y: Scalar) -> Self {
        scaledBy(.init(x: x, y: y))
    }

    @_transparent
    func scaledBy(_ factor: UIVector) -> Self {
        var copy = self
        copy.radius *= factor
        return copy
    }

    /// Creates an arc within this ellipse based on the given start and sweep
    /// angles, both in radians.
    @_transparent
    @inlinable
    func arc(start startAngleInRadians: Double, sweep sweepAngleInRadians: Double) -> Arc {
        .init(
            center: center,
            radius: radius,
            startAngle: startAngleInRadians,
            sweepAngle: sweepAngleInRadians
        )
    }

    /// Returns a point on this ellipse on a given angle in radians.
    @_transparent
    @inlinable
    func pointOnAngle(_ angleInRadians: Scalar) -> UIPoint {
        let c = cos(angleInRadians)
        let s = sin(angleInRadians)

        let point = UIPoint(x: c, y: s) * radius

        return center + point
    }
}
