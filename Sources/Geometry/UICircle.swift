public struct UICircle: Hashable, Codable {
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
    func arc(start startAngleInRadians: Double, sweep sweepAngleInRadians: Double) -> UIArc {
        .init(
            center: center,
            radius: radius,
            startAngle: startAngleInRadians,
            sweepAngle: sweepAngleInRadians
        )
    }
}
