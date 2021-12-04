/// A section of an ellipse represented as a center, radius, start angle, and sweep
/// angle.
public struct UIArc: Hashable, Codable {
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
