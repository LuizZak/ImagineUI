/// A 2D size with integer parameters
public struct UIIntSize: Hashable, Codable {
    public typealias Scalar = Int

    public static let zero: Self = .init()

    public var width: Scalar
    public var height: Scalar

    public var asUIIntPoint: UIIntPoint {
        .init(self)
    }

    public init() {
        self.width = 0
        self.height = 0
    }

    public init(width: Scalar, height: Scalar) {
        self.width = width
        self.height = height
    }

    public init(repeating value: Scalar) {
        self.init(width: value, height: value)
    }

    public init(_ point: UIIntPoint) {
        self.width = point.x
        self.height = point.y
    }
}

// MARK: Addition

public extension UIIntSize {
    static func + (lhs: Self, rhs: Self) -> Self {
        .init(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    static func - (lhs: Self, rhs: Self) -> Self {
        .init(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }

    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

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
    static func + (lhs: Self, rhs: Scalar) -> Self {
        lhs + Self(repeating: rhs)
    }

    static func - (lhs: Self, rhs: Scalar) -> Self {
        lhs - Self(repeating: rhs)
    }

    static func += (lhs: inout Self, rhs: Scalar) {
        lhs = lhs + Self(repeating: rhs)
    }

    static func -= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs - Self(repeating: rhs)
    }
}

// MARK: Multiplication

public extension UIIntSize {
    static func * (lhs: Self, rhs: Self) -> Self {
        .init(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
    }

    static func / (lhs: Self, rhs: Self) -> Self {
        .init(width: lhs.width / rhs.width, height: lhs.height / rhs.height)
    }

    static func *= (lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }

    static func /= (lhs: inout Self, rhs: Self) {
        lhs = lhs / rhs
    }
}

// MARK: Multiplication - Scalars

public extension UIIntSize {
    static func * (lhs: Self, rhs: Scalar) -> Self {
        lhs * Self(repeating: rhs)
    }

    static func / (lhs: Self, rhs: Scalar) -> Self {
        lhs / Self(repeating: rhs)
    }

    static func *= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs * Self(repeating: rhs)
    }

    static func /= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs / Self(repeating: rhs)
    }
}

// MARK: Comparison

public extension UIIntSize {
    static func pointwiseMin(_ lhs: Self, _ rhs: Self) -> Self {
        .init(width: min(lhs.width, rhs.width), height: min(lhs.height, rhs.height))
    }

    static func pointwiseMax(_ lhs: Self, _ rhs: Self) -> Self {
        .init(width: max(lhs.width, rhs.width), height: max(lhs.height, rhs.height))
    }

    static func > (lhs: Self, rhs: Self) -> Bool {
        lhs.width > rhs.width && lhs.height > rhs.height
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.width < rhs.width && lhs.height < rhs.height
    }

    static func >= (lhs: Self, rhs: Self) -> Bool {
        lhs == rhs || lhs > rhs
    }

    static func <= (lhs: Self, rhs: Self) -> Bool {
        lhs == rhs || lhs < rhs
    }
}

public func min(_ lhs: UIIntSize, _ rhs: UIIntSize) -> UIIntSize {
    .pointwiseMin(lhs, rhs)
}

public func max(_ lhs: UIIntSize, _ rhs: UIIntSize) -> UIIntSize {
    .pointwiseMax(lhs, rhs)
}
