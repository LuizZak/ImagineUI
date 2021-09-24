import Foundation

/// A 2D point with integer coordinates
public struct UIIntPoint: Hashable, Codable {
    public typealias Scalar = Int

    public static let zero: Self = .init()

    public var x: Scalar
    public var y: Scalar
    
    @_transparent
    public var asUIIntSize: UIIntSize {
        .init(self)
    }

    public init() {
        self.x = 0
        self.y = 0
    }

    public init(x: Scalar, y: Scalar) {
        self.x = x
        self.y = y
    }

    public init(repeating value: Scalar) {
        self.init(x: value, y: value)
    }

    @_transparent
    public init(_ size: UIIntSize) {
        self.init(x: size.width, y: size.height)
    }

    public func distanceSquared(to other: Self) -> Scalar {
        let dx = x - other.x
        let dy = y - other.y

        return dx * dx + dy * dy
    }
}

// MARK: Addition

public extension UIIntPoint {
    static func + (lhs: Self, rhs: Self) -> Self {
        .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func - (lhs: Self, rhs: Self) -> Self {
        .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    static func -= (lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }

    static prefix func - (lhs: Self) -> Self {
        .zero - lhs
    }
}

// MARK: Addition - UIIntSize

public extension UIIntPoint {
    @_transparent
    static func + (lhs: Self, rhs: UIIntSize) -> Self {
        .init(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }

    @_transparent
    static func - (lhs: Self, rhs: UIIntSize) -> Self {
        .init(x: lhs.x - rhs.width, y: lhs.y - rhs.height)
    }

    @_transparent
    static func += (lhs: inout Self, rhs: UIIntSize) {
        lhs = lhs + rhs
    }

    @_transparent
    static func -= (lhs: inout Self, rhs: UIIntSize) {
        lhs = lhs - rhs
    }
}

// MARK: Addition - Scalars

public extension UIIntPoint {
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

public extension UIIntPoint {
    static func * (lhs: Self, rhs: Self) -> Self {
        .init(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }

    static func / (lhs: Self, rhs: Self) -> Self {
        .init(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
    }

    static func *= (lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }

    static func /= (lhs: inout Self, rhs: Self) {
        lhs = lhs / rhs
    }
}

// MARK: Multiplication - Scalars

public extension UIIntPoint {
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

public extension UIIntPoint {
    static func pointwiseMin(_ lhs: Self, _ rhs: Self) -> Self {
        .init(x: min(lhs.x, rhs.x), y: min(lhs.y, rhs.y))
    }

    static func pointwiseMax(_ lhs: Self, _ rhs: Self) -> Self {
        .init(x: max(lhs.x, rhs.x), y: max(lhs.y, rhs.y))
    }

    static func > (lhs: Self, rhs: Self) -> Bool {
        lhs.x > rhs.x && lhs.y > rhs.y
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.x < rhs.x && lhs.y < rhs.y
    }

    static func >= (lhs: Self, rhs: Self) -> Bool {
        lhs.x >= rhs.x && lhs.y >= rhs.y
    }

    static func <= (lhs: Self, rhs: Self) -> Bool {
        lhs.x <= rhs.x && lhs.y <= rhs.y
    }
}

// MARK: Comparison - UIIntSize

public extension UIIntPoint {
    @_transparent
    static func > (lhs: Self, rhs: UIIntSize) -> Bool {
        lhs > rhs.asUIIntPoint
    }

    @_transparent
    static func < (lhs: Self, rhs: UIIntSize) -> Bool {
        lhs < rhs.asUIIntPoint
    }

    @_transparent
    static func >= (lhs: Self, rhs: UIIntSize) -> Bool {
        lhs >= rhs.asUIIntPoint
    }

    @_transparent
    static func <= (lhs: Self, rhs: UIIntSize) -> Bool {
        lhs <= rhs.asUIIntPoint
    }
}

public func min(_ lhs: UIIntPoint, _ rhs: UIIntPoint) -> UIIntPoint {
    .pointwiseMin(lhs, rhs)
}

public func max(_ lhs: UIIntPoint, _ rhs: UIIntPoint) -> UIIntPoint {
    .pointwiseMax(lhs, rhs)
}
