public struct UIRoundRectangle: Hashable, Codable {
    public typealias Scalar = UIRectangle.Scalar

    public static let zero: Self = .init()
    
    public var rectangle: UIRectangle
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
        rectangle = .zero
        radius = .zero
    }
    
    @_transparent
    public init(rectangle: UIRectangle, radius: UIVector) {
        self.rectangle = rectangle
        self.radius = radius
    }

    public init(rectangle: UIRectangle, radiusX: Scalar, radiusY: Scalar) {
        self.init(rectangle: rectangle, radius: .init(x: radiusX, y: radiusY))
    }
}
