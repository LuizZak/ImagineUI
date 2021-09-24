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
}

public extension UICircle {
    @_transparent
    func expanded(by scalar: Scalar) -> Self {
        .init(center: center, radius: radius + scalar)
    }
}