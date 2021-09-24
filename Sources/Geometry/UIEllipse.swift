public struct UIEllipse: Hashable, Codable {
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
