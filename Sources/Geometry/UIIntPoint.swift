import Foundation

/// A 2D point with integer coordinates
public struct UIIntPoint: Hashable, Codable {
    public typealias Scalar = Int

    public static let zero: Self = .init()
    public static let one: Self = .init(x: 1, y: 1)

    public var x: Scalar
    public var y: Scalar

    @_transparent
    public var asUIIntSize: UIIntSize {
        .init(self)
    }

    @_transparent
    public init() {
        self.x = 0
        self.y = 0
    }

    @_transparent
    public init(x: Scalar, y: Scalar) {
        self.x = x
        self.y = y
    }

    @_transparent
    public init(repeating value: Scalar) {
        self.init(x: value, y: value)
    }

    @_transparent
    public init(_ size: UIIntSize) {
        self.init(x: size.width, y: size.height)
    }

    @_transparent
    public func distanceSquared(to other: Self) -> Scalar {
        let dx = x - other.x
        let dy = y - other.y

        return dx * dx + dy * dy
    }

    @_transparent
    public func distance(to other: Self) -> Double {
        return Double(distanceSquared(to: other)).squareRoot()
    }
}

// MARK: Addition

public extension UIIntPoint {
    @_transparent
    static func + (lhs: Self, rhs: Self) -> Self {
        .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    @_transparent
    static func - (lhs: Self, rhs: Self) -> Self {
        .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    @_transparent
    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    @_transparent
    static func -= (lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }

    @_transparent
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
    @_transparent
    static func + (lhs: Self, rhs: Scalar) -> Self {
        lhs + Self(repeating: rhs)
    }

    @_transparent
    static func - (lhs: Self, rhs: Scalar) -> Self {
        lhs - Self(repeating: rhs)
    }

    @_transparent
    static func + (lhs: Scalar, rhs: Self) -> Self {
        Self(repeating: lhs) + rhs
    }

    @_transparent
    static func - (lhs: Scalar, rhs: Self) -> Self {
        Self(repeating: lhs) - rhs
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

public extension UIIntPoint {
    @_transparent
    static func * (lhs: Self, rhs: Self) -> Self {
        .init(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }

    @_transparent
    static func / (lhs: Self, rhs: Self) -> Self {
        .init(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
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

public extension UIIntPoint {
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

public extension UIIntPoint {
    @_transparent
    static func pointwiseMin(_ lhs: Self, _ rhs: Self) -> Self {
        .init(x: min(lhs.x, rhs.x), y: min(lhs.y, rhs.y))
    }

    @_transparent
    static func pointwiseMax(_ lhs: Self, _ rhs: Self) -> Self {
        .init(x: max(lhs.x, rhs.x), y: max(lhs.y, rhs.y))
    }

    @_transparent
    static func > (lhs: Self, rhs: Self) -> Bool {
        lhs.x > rhs.x && lhs.y > rhs.y
    }

    @_transparent
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.x < rhs.x && lhs.y < rhs.y
    }

    @_transparent
    static func >= (lhs: Self, rhs: Self) -> Bool {
        lhs.x >= rhs.x && lhs.y >= rhs.y
    }

    @_transparent
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

// MARK: Comparison - Scalars

public extension UIIntPoint {
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
public func min(_ lhs: UIIntPoint, _ rhs: UIIntPoint) -> UIIntPoint {
    .pointwiseMin(lhs, rhs)
}

@_transparent
public func max(_ lhs: UIIntPoint, _ rhs: UIIntPoint) -> UIIntPoint {
    .pointwiseMax(lhs, rhs)
}
