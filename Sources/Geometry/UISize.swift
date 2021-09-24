import Foundation

/// A 2D size with double-precision floating point parameters
public struct UISize: Hashable, Codable {
    public typealias Scalar = Double

    public static let zero: Self = .init()

    public var width: Scalar
    public var height: Scalar

    public var asUIPoint: UIPoint {
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

    public init(_ point: UIPoint) {
        self.width = point.x
        self.height = point.y
    }
}

// MARK: Addition

public extension UISize {
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

// MARK: Addition - UIPoint

public extension UISize {
    @_transparent
    static func + (lhs: Self, rhs: UIPoint) -> Self {
        .init(width: lhs.width + rhs.x, height: lhs.height + rhs.y)
    }

    @_transparent
    static func - (lhs: Self, rhs: UIPoint) -> Self {
        .init(width: lhs.width - rhs.x, height: lhs.height - rhs.y)
    }

    @_transparent
    static func += (lhs: inout Self, rhs: UIPoint) {
        lhs = lhs + rhs
    }

    @_transparent
    static func -= (lhs: inout Self, rhs: UIPoint) {
        lhs = lhs - rhs
    }
}

// MARK: Addition - Scalars

public extension UISize {
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

public extension UISize {
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

public extension UISize {
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

public extension UISize {
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
        lhs.width >= rhs.width && lhs.height >= rhs.height
    }

    static func <= (lhs: Self, rhs: Self) -> Bool {
        lhs.width <= rhs.width && lhs.height <= rhs.height
    }
}

public func min(_ lhs: UISize, _ rhs: UISize) -> UISize {
    .pointwiseMin(lhs, rhs)
}

public func max(_ lhs: UISize, _ rhs: UISize) -> UISize {
    .pointwiseMax(lhs, rhs)
}
