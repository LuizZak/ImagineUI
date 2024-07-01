import Foundation

/// A 2D point with double-precision floating point coordinates
public struct UIPoint: Hashable, Codable {
    public typealias Scalar = Double

    public static let zero: Self = .init()
    public static let one: Self = .init(x: 1, y: 1)

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
    public init<Integer: BinaryInteger>(repeating value: Integer) {
        self.init(repeating: Scalar(value))
    }

    @_transparent
    public init(_ point: UIIntPoint) {
        self.init(x: Scalar(point.x), y: Scalar(point.y))
    }

    @_transparent
    public init(_ size: UISize) {
        self.init(x: size.width, y: size.height)
    }

    @_transparent
    public init(_ size: UIIntSize) {
        self.init(x: Double(size.width), y: Double(size.height))
    }

    @_transparent
    public func distanceSquared(to other: Self) -> Scalar {
        (self - other).lengthSquared()
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
    public func angle(to other: Self) -> Scalar {
        (other - self).angle()
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

    @_transparent
    public func absolute() -> Self {
        Self(x: x.magnitude, y: y.magnitude)
    }

    @inlinable
    public func scaledBy(_ factor: UIVector, around center: Self) -> Self {
        (self - center) * factor + center
    }

    /// Performs a linear interpolation between `start` and `end` using a ratio
    /// of `factor`.
    @inlinable
    public static func lerp(_ start: UIPoint, _ end: UIPoint, factor: Double) -> UIPoint {
        return start * (1 - factor) + end * factor
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

// MARK: Addition - Binary integers

public extension UIPoint {
    @_transparent
    static func + <Integer: BinaryInteger>(lhs: Self, rhs: Integer) -> Self {
        lhs + Self(repeating: .init(rhs))
    }

    @_transparent
    static func - <Integer: BinaryInteger>(lhs: Self, rhs: Integer) -> Self {
        lhs - Self(repeating: rhs)
    }

    @_transparent
    static func + <Integer: BinaryInteger>(lhs: Integer, rhs: Self) -> Self {
        Self(repeating: lhs) + rhs
    }

    @_transparent
    static func - <Integer: BinaryInteger>(lhs: Integer, rhs: Self) -> Self {
        Self(repeating: lhs) - rhs
    }

    @_transparent
    static func += <Integer: BinaryInteger>(lhs: inout Self, rhs: Integer) {
        lhs = lhs + Self(repeating: rhs)
    }

    @_transparent
    static func -= <Integer: BinaryInteger>(lhs: inout Self, rhs: Integer) {
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
    static func * (lhs: Scalar, rhs: Self) -> Self {
        Self(repeating: lhs) * rhs
    }

    @_transparent
    static func / (lhs: Scalar, rhs: Self) -> Self {
        Self(repeating: lhs) / rhs
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

// MARK: Multiplication - Binary integers

public extension UIPoint {
    @_transparent
    static func * <Integer: BinaryInteger>(lhs: Self, rhs: Integer) -> Self {
        lhs * Self(repeating: rhs)
    }

    @_transparent
    static func / <Integer: BinaryInteger>(lhs: Self, rhs: Integer) -> Self {
        lhs / Self(repeating: rhs)
    }

    @_transparent
    static func * <Integer: BinaryInteger>(lhs: Integer, rhs: Self) -> Self {
        Self(repeating: lhs) * rhs
    }

    @_transparent
    static func / <Integer: BinaryInteger>(lhs: Integer, rhs: Self) -> Self {
        Self(repeating: lhs) / rhs
    }

    @_transparent
    static func *= <Integer: BinaryInteger>(lhs: inout Self, rhs: Integer) {
        lhs = lhs * Self(repeating: rhs)
    }

    @_transparent
    static func /= <Integer: BinaryInteger>(lhs: inout Self, rhs: Integer) {
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
        lhs.x >= rhs.x && lhs.y >= rhs.y
    }

    @_transparent
    static func <= (lhs: Self, rhs: Self) -> Bool {
        lhs.x <= rhs.x && lhs.y <= rhs.y
    }
}

// MARK: Comparison - UISize

public extension UIPoint {
    @_transparent
    static func > (lhs: Self, rhs: UISize) -> Bool {
        lhs > rhs.asUIPoint
    }

    @_transparent
    static func < (lhs: Self, rhs: UISize) -> Bool {
        lhs < rhs.asUIPoint
    }

    @_transparent
    static func >= (lhs: Self, rhs: UISize) -> Bool {
        lhs >= rhs.asUIPoint
    }

    @_transparent
    static func <= (lhs: Self, rhs: UISize) -> Bool {
        lhs <= rhs.asUIPoint
    }
}

// MARK: Comparison - Scalars

public extension UIPoint {
    @_transparent
    static func == (lhs: Self, rhs: Scalar) -> Bool {
        lhs == .init(repeating: rhs)
    }

    @_transparent
    static func != (lhs: Self, rhs: Scalar) -> Bool {
        lhs != .init(repeating: rhs)
    }
}

// MARK: Comparison - Binary integers

public extension UIPoint {
    @_transparent
    static func == <Integer: BinaryInteger>(lhs: Self, rhs: Integer) -> Bool {
        lhs == .init(repeating: rhs)
    }

    @_transparent
    static func != <Integer: BinaryInteger>(lhs: Self, rhs: Integer) -> Bool {
        lhs != .init(repeating: rhs)
    }
}

@_transparent
public func min(_ lhs: UIPoint, _ rhs: UIPoint) -> UIPoint {
    .pointwiseMin(lhs, rhs)
}
@_transparent
public func min(_ v1: UIPoint, _ v2: UIPoint, _ v3: UIPoint) -> UIPoint {
    min(min(v1, v2), v3)
}
@_transparent
public func min(_ v1: UIPoint, _ v2: UIPoint, _ v3: UIPoint, _ v4: UIPoint) -> UIPoint {
    min(min(v1, v2, v3), v4)
}

@_transparent
public func max(_ lhs: UIPoint, _ rhs: UIPoint) -> UIPoint {
    .pointwiseMax(lhs, rhs)
}
@_transparent
public func max(_ v1: UIPoint, _ v2: UIPoint, _ v3: UIPoint) -> UIPoint {
    max(max(v1, v2), v3)
}
@_transparent
public func max(_ v1: UIPoint, _ v2: UIPoint, _ v3: UIPoint, _ v4: UIPoint) -> UIPoint {
    max(max(v1, v2, v3), v4)
}
