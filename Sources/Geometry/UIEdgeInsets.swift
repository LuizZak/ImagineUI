public struct UIEdgeInsets: Hashable, Codable {
    public typealias Scalar = Double

    public static let zero: Self = .init()

    public var left: Scalar
    public var top: Scalar
    public var right: Scalar
    public var bottom: Scalar

    public var topLeft: UIVector {
        .init(x: left, y: top)
    }
    public var topRight: UIVector {
        .init(x: right, y: top)
    }
    public var bottomLeft: UIVector {
        .init(x: left, y: bottom)
    }
    public var bottomRight: UIVector {
        .init(x: right, y: bottom)
    }

    @_transparent
    public init(left: Scalar = 0.0, top: Scalar = 0.0, right: Scalar = 0.0, bottom: Scalar = 0.0) {
        self.left = left
        self.top = top
        self.right = right
        self.bottom = bottom
    }

    @_transparent
    public init(_ value: Scalar) {
        left = value
        top = value
        right = value
        bottom = value
    }

    @_transparent
    public func inset(rectangle: UIRectangle) -> UIRectangle {
        rectangle.inset(self)
    }
}

extension UIEdgeInsets: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self.init(value)
    }
}

extension UIEdgeInsets: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(Double(value))
    }
}

public extension UIEdgeInsets {
    @_transparent
    static prefix func - (value: Self) -> Self {
        Self(left: -value.left, top: -value.top, right: -value.right, bottom: -value.bottom)
    }
}
