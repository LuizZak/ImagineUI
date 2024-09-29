/// A representation of an angle, clamped to always be between 0 - 2pi, or
/// 0 - 360 degrees.
public struct UIAngle: Hashable, Comparable, Sendable {
    /// Gets the angle for the mathematical constant pi (π), approximately equal
    /// to 3.14159.
    public static let pi: Self = Self(radians: .pi)

    /// Gets the radians representation of this angle.
    public let radians: Double

    /// Gets the degrees representation of this angle.
    public var degrees: Double {
        radians * (180.0 / .pi)
    }

    @inlinable
    public init(degrees: Double) {
        self.init(radians: degrees * (.pi / 180))
    }

    @inlinable
    public init(radians: Double) {
        self.init(uncheckedRadians: Self.normalized(radians))
    }

    @usableFromInline
    internal init(uncheckedRadians: Double) {
        self.radians = uncheckedRadians
    }

    /// Returns `true` if `lhs.radians < rhs.radians`.
    @inlinable
    public static func < (lhs: UIAngle, rhs: UIAngle) -> Bool {
        lhs.radians < rhs.radians
    }

    @usableFromInline
    static func normalized(_ angleInRadians: Double) -> Double {
        var radians = angleInRadians
        radians.formTruncatingRemainder(dividingBy: .pi * 2)

        while radians < 0 {
            radians += .pi * 2
        }

        return radians
    }
}

extension UIAngle: ExpressibleByFloatLiteral {
    /// Initializes a new radians angle from a float literal.
    public init(floatLiteral value: FloatLiteralType) {
        self.init(radians: value)
    }
}

extension UIAngle: AdditiveArithmetic {
    public static var zero: Self {
        .init(uncheckedRadians: 0)
    }

    @inlinable
    public static func + (lhs: Self, rhs: Self) -> Self {
        op(lhs, rhs, +)
    }

    @inlinable
    public static func - (lhs: Self, rhs: Self) -> Self {
        op(lhs, rhs, -)
    }

    @inlinable
    static func op(_ lhs: Self, _ rhs: Self, _ op: (Double, Double) -> Double) -> Self {
        Self(radians: op(lhs.radians, rhs.radians))
    }

    @inlinable
    static func op(_ lhs: Self, _ rhs: Double, _ op: (Double, Double) -> Double) -> Self {
        Self(radians: op(lhs.radians, rhs))
    }

    @inlinable
    static func op(_ lhs: Double, _ rhs: Self, _ op: (Double, Double) -> Double) -> Self {
        Self(radians: op(lhs, rhs.radians))
    }
}

extension UIAngle: Numeric {
    public typealias Magnitude = Self

    public var magnitude: Magnitude {
        self
    }

    public init(integerLiteral value: Int) {
        self.init(radians: Double(value))
    }

    public init?<T>(exactly source: T) where T : BinaryInteger {
        guard let value = Double(exactly: source) else {
            return nil
        }

        self.init(radians: value)

        if radians != value {
            return nil
        }
    }

    @inlinable
    public static func * (lhs: Self, rhs: Self) -> Self {
        Self.op(lhs, rhs, *)
    }

    @inlinable
    public static func / (lhs: Self, rhs: Self) -> Self {
        Self.op(lhs, rhs, /)
    }

    @inlinable
    public static func *= (lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }
    @inlinable
    public static func /= (lhs: inout Self, rhs: Self) {
        lhs = lhs / rhs
    }
}

extension UIAngle: SignedNumeric {
    public mutating func negate() {
        self = Self.init(radians: .pi * 2 - radians)
    }
}
