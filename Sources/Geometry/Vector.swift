import simd

/// Represents a 2D point with `Double` coordinate domains
public typealias Vector2 = VectorT<Double>

/// Represents a 2D point with `Int` coordinate domains
public typealias IntPoint = VectorT<Int>

/// Alias for `Vector2`
public typealias Size = Vector2

/// A typealias for a scalar that can specialize a `VectorT` instance
public typealias VectorScalar = Comparable & Numeric & SIMDScalar

/// Represents a 2D vector
public struct VectorT<T: VectorScalar>: Equatable, Codable, CustomStringConvertible {
    public typealias Scalar = T
    
    /// Used to match `T`'s native type
    public typealias NativeVectorType = SIMD2<T>
    
    /// This is used during affine transformation
    public typealias HomogenousVectorType = SIMD3<T>
    
    /// A zeroed-value Vector
    public static var zero: VectorT { VectorT(x: .zero, y: .zero) }
    
    /// An unit-valued Vector
    public static var unit: VectorT { VectorT(x: 1, y: 1) }
    
    /// An unit-valued Vector.
    /// Aliast for 'unit'.
    public static var one: VectorT { unit }
    
    /// The underlying SIMD vector type
    @usableFromInline
    var theVector: NativeVectorType
    
    @inlinable
    public var x: T {
        get {
            return theVector.x
        }
        set {
            theVector.x = newValue
        }
    }
    
    @inlinable
    public var y: T {
        get {
            return theVector.y
        }
        set {
            theVector.y = newValue
        }
    }
    
    /// Textual representation of this vector's coordinates
    public var description: String {
        return "\(type(of: self))(x: \(self.x), y: \(self.y))"
    }
    
    @inlinable
    init(_ vector: NativeVectorType) {
        theVector = vector
    }
    
    /// Inits a Vector
    @inlinable
    public init(x: T, y: T) {
        theVector = NativeVectorType(x, y)
    }
    
    /// Inits a Vector where both components have the same given value
    @inlinable
    public init(_ xy: T) {
        theVector = NativeVectorType(xy, xy)
    }
    
    /// Inits a 0-valued Vector
    @inlinable
    public init() {
        theVector = NativeVectorType(repeating: T.zero)
    }
}

// MARK: Operators
public extension VectorT {
    @inlinable
    static func == (lhs: VectorT, rhs: VectorT) -> Bool {
        return lhs.theVector == rhs.theVector
    }
    
    /// Compares two vectors and returns if `lhs` is greater than `rhs`.
    ///
    /// Performs `lhs.x > rhs.x && lhs.y > rhs.y`
    @inlinable
    static func > (lhs: VectorT, rhs: VectorT) -> Bool {
        return lhs.theVector.x > rhs.theVector.x && lhs.theVector.y > rhs.theVector.y
    }
    
    /// Compares two vectors and returns if `lhs` is greater than or equal to
    /// `rhs`.
    ///
    /// Performs `lhs.x >= rhs.x && lhs.y >= rhs.y`
    @inlinable
    static func >= (lhs: VectorT, rhs: VectorT) -> Bool {
        return lhs.theVector.x >= rhs.theVector.x && lhs.theVector.y >= rhs.theVector.y
    }
    
    /// Compares two vectors and returns if `lhs` is less than `rhs`.
    ///
    /// Performs `lhs.x < rhs.x && lhs.y < rhs.y`
    @inlinable
    static func < (lhs: VectorT, rhs: VectorT) -> Bool {
        return lhs.theVector.x < rhs.theVector.x && lhs.theVector.y < rhs.theVector.y
    }
    
    /// Compares two vectors and returns if `lhs` is less than or equal to `rhs`.
    ///
    /// Performs `lhs.x <= rhs.x && lhs.y <= rhs.y`
    @inlinable
    static func <= (lhs: VectorT, rhs: VectorT) -> Bool {
        return lhs.theVector.x <= rhs.theVector.x && lhs.theVector.y <= rhs.theVector.y
    }
}

public extension VectorT where T: AdditiveArithmetic {
    @inlinable
    static func + (lhs: VectorT, rhs: VectorT) -> VectorT {
        return VectorT(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    @inlinable
    static func - (lhs: VectorT, rhs: VectorT) -> VectorT {
        return VectorT(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    @inlinable
    static func + (lhs: VectorT, rhs: T) -> VectorT {
        return VectorT(x: lhs.x + rhs, y: lhs.y + rhs)
    }
    
    @inlinable
    static func - (lhs: VectorT, rhs: T) -> VectorT {
        return VectorT(x: lhs.x - rhs, y: lhs.y - rhs)
    }
    
    @inlinable
    static func += (lhs: inout VectorT, rhs: VectorT) {
        lhs = lhs + rhs
    }
    
    @inlinable
    static func -= (lhs: inout VectorT, rhs: VectorT) {
        lhs = lhs - rhs
    }
    
    @inlinable
    static func += (lhs: inout VectorT, rhs: T) {
        lhs = lhs + rhs
    }
    
    @inlinable
    static func -= (lhs: inout VectorT, rhs: T) {
        lhs = lhs - rhs
    }
}

public extension VectorT where T: DivisibleArithmetic {
    @inlinable
    static func / (lhs: VectorT, rhs: VectorT) -> VectorT {
        return VectorT(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
    }
    
    @inlinable
    static func / (lhs: VectorT, rhs: T) -> VectorT {
        return VectorT(x: lhs.x / rhs, y: lhs.y / rhs)
    }
}

public extension VectorT where T: Numeric {
    /// Returns the distance squared between this Vector and another Vector
    @inlinable
    func distanceSquared(to vec: VectorT) -> T {
        let d = self - vec
        
        return d.x * d.x + d.y * d.y
    }
    
    /// Calculates the dot product between this and another provided Vector
    @inlinable
    func dot(_ other: VectorT) -> T {
        return x * other.x + y * other.y
    }
    
    @inlinable
    static func * (lhs: VectorT, rhs: VectorT) -> VectorT {
        return VectorT(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }
    
    @inlinable
    static func * (lhs: VectorT, rhs: T) -> VectorT {
        return VectorT(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    @inlinable
    static func *= (lhs: inout VectorT, rhs: T) {
        lhs = lhs * rhs
    }
}

public extension VectorT where T: SignedNumeric {
    /// Makes this Vector perpendicular to its current position relative to the
    /// origin.
    /// This alters the vector instance
    @inlinable
    mutating func formPerpendicular() -> VectorT {
        self = perpendicular()
        return self
    }
    
    /// Returns a Vector perpendicular to this Vector relative to the origin
    @inlinable
    func perpendicular() -> VectorT {
        return VectorT(x: -y, y: x)
    }
    
    /// Returns a vector that represents this vector's point, rotated 90º counter
    /// clockwise relative to the origin.
    @inlinable
    func leftRotated() -> VectorT {
        return VectorT(x: -y, y: x)
    }
    
    /// Returns a vector that represents this vector's point, rotated 90º clockwise
    /// clockwise relative to the origin.
    @inlinable
    func rightRotated() -> VectorT {
        return VectorT(x: y, y: -x)
    }
    
    /// Negates this Vector
    @inlinable
    static prefix func - (lhs: VectorT) -> VectorT {
        return VectorT(x: -lhs.x, y: -lhs.y)
    }
}

public extension VectorT where T: BinaryInteger {
    @inlinable
    static func / (lhs: VectorT, rhs: VectorT) -> VectorT {
        return VectorT(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
    }
    
    @inlinable
    static func / (lhs: VectorT, rhs: T) -> VectorT {
        return VectorT(x: lhs.x / rhs, y: lhs.y / rhs)
    }
}

public extension VectorT where T: FloatingPoint {
    /// Creates a new Vector, with each coordinate rounded to the closest
    /// possible representation.
    ///
    /// If two representable values are equally close, the result is the value
    /// with more trailing zeros in its significand bit pattern.
    ///
    /// - parameter vector: The integer vector to convert to a floating-point vector.
    @inlinable
    init<U>(_ vector: VectorT<U>) where U: BinaryInteger {
        self.init(x: T.init(vector.x), y: T.init(vector.y))
    }
    
    @inlinable
    static func % (lhs: VectorT, rhs: VectorT) -> VectorT {
        return VectorT(x: lhs.x.truncatingRemainder(dividingBy: rhs.x),
                       y: lhs.y.truncatingRemainder(dividingBy: rhs.y))
    }
    
    @inlinable
    static func % (lhs: VectorT, rhs: T) -> VectorT {
        return VectorT(x: lhs.x.truncatingRemainder(dividingBy: rhs),
                       y: lhs.y.truncatingRemainder(dividingBy: rhs))
    }
    
    @inlinable
    static func / (lhs: VectorT, rhs: VectorT) -> VectorT {
        return VectorT(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
    }
    
    @inlinable
    static func / (lhs: T, rhs: VectorT) -> VectorT {
        return VectorT(x: lhs / rhs.x, y: lhs / rhs.y)
    }
    
    @inlinable
    static func / (lhs: VectorT, rhs: T) -> VectorT {
        return VectorT(x: lhs.x / rhs, y: lhs.y / rhs)
    }
}

/// BinaryInteger - FloatingPoint operations
public extension VectorT where T: FloatingPoint {
    @inlinable
    static func + <B: BinaryInteger>(lhs: VectorT, rhs: VectorT<B>) -> VectorT {
        return lhs + VectorT(rhs)
    }
    
    @inlinable
    static func - <B: BinaryInteger>(lhs: VectorT, rhs: VectorT<B>) -> VectorT {
        return lhs - VectorT(rhs)
    }
    
    @inlinable
    static func * <B: BinaryInteger>(lhs: VectorT, rhs: VectorT<B>) -> VectorT {
        return lhs * VectorT(rhs)
    }
    
    @inlinable
    static func / <B: BinaryInteger>(lhs: VectorT, rhs: VectorT<B>) -> VectorT {
        return lhs / VectorT(rhs)
    }
    
    @inlinable
    static func + <B: BinaryInteger>(lhs: VectorT<B>, rhs: VectorT) -> VectorT {
        return VectorT(lhs) + rhs
    }
    
    @inlinable
    static func - <B: BinaryInteger>(lhs: VectorT<B>, rhs: VectorT) -> VectorT {
        return VectorT(lhs) - rhs
    }
    
    @inlinable
    static func * <B: BinaryInteger>(lhs: VectorT<B>, rhs: VectorT) -> VectorT {
        return VectorT(lhs) * rhs
    }
    
    @inlinable
    static func / <B: BinaryInteger>(lhs: VectorT<B>, rhs: VectorT) -> VectorT {
        return VectorT(lhs) / rhs
    }
    
    @inlinable
    static func += <B: BinaryInteger>(lhs: inout VectorT, rhs: VectorT<B>) {
        lhs = lhs + VectorT(rhs)
    }
    @inlinable
    static func -= <B: BinaryInteger>(lhs: inout VectorT, rhs: VectorT<B>) {
        lhs = lhs - VectorT(rhs)
    }
    @inlinable
    static func *= <B: BinaryInteger>(lhs: inout VectorT, rhs: VectorT<B>) {
        lhs = lhs * VectorT(rhs)
    }
    @inlinable
    static func /= <B: BinaryInteger>(lhs: inout VectorT, rhs: VectorT<B>) {
        lhs = lhs / VectorT(rhs)
    }
}

// MARK: Misc math
public extension VectorT where T: Numeric {
    /// Returns the vector that lies within this and another vector's ratio line
    /// projected at a specified ratio along the line created by the vectors.
    ///
    /// A vector on ratio of 0 is the same as this vector's position, and 1 is the
    /// same as the other vector's position.
    ///
    /// Values beyond 0 - 1 range project the point across the limits of the line.
    ///
    /// - Parameters:
    ///   - ratio: A ratio (usually 0 through 1) between this and the second vector.
    ///   - other: The second vector to form the line that will have the point
    /// projected onto.
    /// - Returns: A vector that lies within the line created by the two vectors.
    @inlinable
    func ratio(_ ratio: T, to other: VectorT) -> VectorT {
        return self + (other - self) * ratio
    }
}

public extension Collection {
    /// Averages this collection of vectors into one Vector point as the mean
    /// location of each vector.
    ///
    /// Returns a zero Vector, if the collection is empty.
    @inlinable
    func averageVector<T: FloatingPoint>() -> VectorT<T> where Element == VectorT<T> {
        if isEmpty {
            return .zero
        }
        
        return reduce(into: .zero) { $0 += $1 } / T(count)
    }
}

/// Returns a Vector that represents the minimum coordinates between two
/// Vector objects
@inlinable
public func min<T>(_ a: VectorT<T>, _ b: VectorT<T>) -> VectorT<T> {
    return VectorT(x: min(a.theVector.x, b.theVector.x), y: min(a.theVector.y, b.theVector.y))
}

/// Returns a Vector that represents the maximum coordinates between two
/// Vector objects
@inlinable
public func max<T>(_ a: VectorT<T>, _ b: VectorT<T>) -> VectorT<T> {
    return VectorT(x: max(a.theVector.x, b.theVector.x), y: max(a.theVector.y, b.theVector.y))
}

////////
//// Define the operations to be performed on the Vector
////////

// This • character is available as 'Option-8' combination on Mac keyboards
infix operator • : MultiplicationPrecedence
infix operator =/ : MultiplicationPrecedence

@inlinable
public func round<T: FloatingPoint>(_ x: VectorT<T>) -> VectorT<T> {
    return VectorT(x: round(x.x), y: round(x.y))
}

@inlinable
public func ceil<T: FloatingPoint>(_ x: VectorT<T>) -> VectorT<T> {
    return VectorT(x.theVector.rounded(.up))
}

@inlinable
public func floor<T: FloatingPoint>(_ x: VectorT<T>) -> VectorT<T> {
    return VectorT(x.theVector.rounded(.down))
}

@inlinable
public func abs<T: SignedNumeric>(_ x: VectorT<T>) -> VectorT<T> {
    return VectorT(x: abs(x.theVector.x), y: abs(x.theVector.y))
}

extension VectorT.NativeMatrixType: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        try self.init([
            container.decode(VectorT.HomogenousVectorType.self),
            container.decode(VectorT.HomogenousVectorType.self),
            container.decode(VectorT.HomogenousVectorType.self)
        ])
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        try container.encode(self.columns.0)
        try container.encode(self.columns.1)
        try container.encode(self.columns.2)
    }
}
