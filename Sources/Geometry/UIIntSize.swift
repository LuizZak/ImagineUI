/// A 2D size with integer parameters
public struct UIIntSize: Hashable, Codable {
    public typealias Scalar = Int

    public static let zero: Self = .init()

    public var width: Scalar
    public var height: Scalar

    @_transparent
    public var asUIIntPoint: UIIntPoint {
        .init(self)
    }

    @_transparent
    public init() {
        self.width = 0
        self.height = 0
    }

    @_transparent
    public init(width: Scalar, height: Scalar) {
        self.width = width
        self.height = height
    }

    @_transparent
    public init(repeating value: Scalar) {
        self.init(width: value, height: value)
    }

    @_transparent
    public init(_ point: UIIntPoint) {
        self.width = point.x
        self.height = point.y
    }
}

// MARK: Addition

public extension UIIntSize {
    @_transparent
    static func + (lhs: Self, rhs: Self) -> Self {
        .init(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    @_transparent
    static func - (lhs: Self, rhs: Self) -> Self {
        .init(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }

    @_transparent
    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    @_transparent
    static func -= (lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }
}

// MARK: Addition - UIIntPoint

public extension UIIntSize {
    @_transparent
    static func + (lhs: Self, rhs: UIIntPoint) -> Self {
        .init(width: lhs.width + rhs.x, height: lhs.height + rhs.y)
    }

    @_transparent
    static func - (lhs: Self, rhs: UIIntPoint) -> Self {
        .init(width: lhs.width - rhs.x, height: lhs.height - rhs.y)
    }

    @_transparent
    static func += (lhs: inout Self, rhs: UIIntPoint) {
        lhs = lhs + rhs
    }

    @_transparent
    static func -= (lhs: inout Self, rhs: UIIntPoint) {
        lhs = lhs - rhs
    }
}

// MARK: Addition - Scalars

public extension UIIntSize {
    @_transparent
    static func + (lhs: Self, rhs: Scalar) -> Self {
        lhs + Self(repeating: rhs)
    }

    @_transparent
    static func - (lhs: Self, rhs: Scalar) -> Self {
        lhs - Self(repeating: rhs)
    }

    @_transparent
    static func += (lhs: inout Self, rhs: Scalar) {
        lhs = lhs + Self(repeating: rhs)
    }

    @_transparent
    static func -= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs - Self(repeating: rhs)
    }
}

// MARK: Multiplication

public extension UIIntSize {
    @_transparent
    static func * (lhs: Self, rhs: Self) -> Self {
        .init(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
    }

    @_transparent
    static func / (lhs: Self, rhs: Self) -> Self {
        .init(width: lhs.width / rhs.width, height: lhs.height / rhs.height)
    }

    @_transparent
    static func *= (lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }

    @_transparent
    static func /= (lhs: inout Self, rhs: Self) {
        lhs = lhs / rhs
    }
}

// MARK: Multiplication - Scalars

public extension UIIntSize {
    @_transparent
    static func * (lhs: Self, rhs: Scalar) -> Self {
        lhs * Self(repeating: rhs)
    }

    @_transparent
    static func / (lhs: Self, rhs: Scalar) -> Self {
        lhs / Self(repeating: rhs)
    }

    @_transparent
    static func *= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs * Self(repeating: rhs)
    }

    @_transparent
    static func /= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs / Self(repeating: rhs)
    }
}

// MARK: Comparison

public extension UIIntSize {
    @_transparent
    static func pointwiseMin(_ lhs: Self, _ rhs: Self) -> Self {
        .init(width: min(lhs.width, rhs.width), height: min(lhs.height, rhs.height))
    }

    @_transparent
    static func pointwiseMax(_ lhs: Self, _ rhs: Self) -> Self {
        .init(width: max(lhs.width, rhs.width), height: max(lhs.height, rhs.height))
    }

    @_transparent
    static func > (lhs: Self, rhs: Self) -> Bool {
        lhs.width > rhs.width && lhs.height > rhs.height
    }

    @_transparent
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.width < rhs.width && lhs.height < rhs.height
    }

    @_transparent
    static func >= (lhs: Self, rhs: Self) -> Bool {
        lhs.width >= rhs.width && lhs.height >= rhs.height
    }

    @_transparent
    static func <= (lhs: Self, rhs: Self) -> Bool {
        lhs.width <= rhs.width && lhs.height <= rhs.height
    }
}

// MARK: Comparison - Scalars

public extension UIIntSize {
    @_transparent
    static func == (lhs: Self, rhs: Scalar) -> Bool {
        lhs == .init(repeating: rhs)
    }

    @_transparent
    static func != (lhs: Self, rhs: Scalar) -> Bool {
        lhs != .init(repeating: rhs)
    }
}

@_transparent
public func min(_ lhs: UIIntSize, _ rhs: UIIntSize) -> UIIntSize {
    .pointwiseMin(lhs, rhs)
}

@_transparent
public func max(_ lhs: UIIntSize, _ rhs: UIIntSize) -> UIIntSize {
    .pointwiseMax(lhs, rhs)
}
