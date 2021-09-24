import Foundation

/// A 2D point with double-precision floating point coordinates
public struct UIPoint: Hashable, Codable {
    public typealias Scalar = Double

    public static let zero: Self = .init()

    public var x: Scalar
    public var y: Scalar
    
    @_transparent
    public var asUISize: UISize {
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
    public init(_ size: UISize) {
        self.init(x: size.width, y: size.height)
    }

    @_transparent
    public init(_ point: UIIntPoint) {
        self.init(x: Scalar(point.x), y: Scalar(point.y))
    }

    @_transparent
    public func distanceSquared(to other: Self) -> Scalar {
        let dx = x - other.x
        let dy = y - other.y

        return dx * dx + dy * dy
    }

    @_transparent
    public func distance(to other: Self) -> Scalar {
        distanceSquared(to: other).squareRoot()
    }

    @_transparent
    public func angle() -> Scalar {
        atan2(y, x)
    }

    @_transparent
    public func rounded(_ rule: FloatingPointRoundingRule) -> Self {
        .init(x: x.rounded(rule), y: y.rounded(rule))
    }

    @_transparent
    public func rounded() -> Self {
        rounded(.toNearestOrAwayFromZero)
    }

    @_transparent
    public func ceil() -> Self {
        rounded(.up)
    }

    @_transparent
    public func floor() -> Self {
        rounded(.down)
    }
}

// MARK: Addition

public extension UIPoint {
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

// MARK: Addition - UISize

public extension UIPoint {
    @_transparent
    static func + (lhs: Self, rhs: UISize) -> Self {
        .init(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }

    @_transparent
    static func - (lhs: Self, rhs: UISize) -> Self {
        .init(x: lhs.x - rhs.width, y: lhs.y - rhs.height)
    }

    @_transparent
    static func += (lhs: inout Self, rhs: UISize) {
        lhs = lhs + rhs
    }

    @_transparent
    static func -= (lhs: inout Self, rhs: UISize) {
        lhs = lhs - rhs
    }
}

// MARK: Addition - Scalars

public extension UIPoint {
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

public extension UIPoint {
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

public extension UIPoint {
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

public extension UIPoint {
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
        lhs == rhs || lhs > rhs
    }

    @_transparent
    static func <= (lhs: Self, rhs: Self) -> Bool {
        lhs == rhs || lhs < rhs
    }
}

@_transparent
public func min(_ lhs: UIPoint, _ rhs: UIPoint) -> UIPoint {
    .pointwiseMin(lhs, rhs)
}
@_transparent
public func max(_ lhs: UIPoint, _ rhs: UIPoint) -> UIPoint {
    .pointwiseMax(lhs, rhs)
}
