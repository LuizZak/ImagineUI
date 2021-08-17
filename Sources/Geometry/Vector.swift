import simd

/// Represents a 2D point with `Double` coordinate domains
public typealias Vector2 = Vector<Double>

/// Represents a 2D point with `Int` coordinate domains
public typealias IntPoint = Vector<Int>

/// Alias for `Vector2`
public typealias Size = Vector2

/// Represents a 2D vector
public struct Vector<T: Comparable & Numeric & SIMDScalar>: Equatable, Codable, CustomStringConvertible {
    public typealias Scalar = T
    
    /// Used to match `T`'s native type
    public typealias NativeVectorType = SIMD2<T>
    
    /// This is used during affine transformation
    public typealias HomogenousVectorType = SIMD3<T>
    
    /// A zeroed-value Vector2
    public static var zero: Vector { Vector(x: .zero, y: .zero) }
    
    /// An unit-valued Vector2
    public static var unit: Vector { Vector(x: 1, y: 1) }
    
    /// An unit-valued Vector2.
    /// Aliast for 'unit'.
    public static var one: Vector { unit }
    
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
        return "{ \(self.x) : \(self.y) }"
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
    
    /// Inits a 0-valued Vector2
    @inlinable
    public init() {
        theVector = NativeVectorType(repeating: T.zero)
    }
}

public extension Vector where T: SignedNumeric {
    /// Makes this Vector perpendicular to its current position.
    /// This alters the vector instance
    @inlinable
    mutating func formPerpendicular() -> Vector {
        self = perpendicular()
        return self
    }
    
    /// Returns a Vector perpendicular to this Vector2
    @inlinable
    func perpendicular() -> Vector {
        return Vector(x: -y, y: x)
    }
    
    /// Returns a vector that represents this vector's point, rotated 90º counter
    /// clockwise
    @inlinable
    func leftRotated() -> Vector {
        return Vector(x: -y, y: x)
    }
    
    /// Returns a vector that represents this vector's point, rotated 90º clockwise
    @inlinable
    func rightRotated() -> Vector {
        return Vector(x: y, y: -x)
    }
    
    // Unary operators
    @inlinable
    static prefix func -(lhs: Vector) -> Vector {
        return Vector(x: -lhs.x, y: -lhs.y)
    }
}

public extension Vector where T: AdditiveArithmetic {
    @inlinable
    static func +(lhs: Vector, rhs: Vector) -> Vector {
        return Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    @inlinable
    static func -(lhs: Vector, rhs: Vector) -> Vector {
        return Vector(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    @inlinable
    static func +(lhs: Vector, rhs: T) -> Vector {
        return Vector(x: lhs.x + rhs, y: lhs.y + rhs)
    }
    
    @inlinable
    static func -(lhs: Vector, rhs: T) -> Vector {
        return Vector(x: lhs.x - rhs, y: lhs.y - rhs)
    }
}

public extension Vector where T: Numeric {
    @inlinable
    static func *(lhs: Vector, rhs: Vector) -> Vector {
        return Vector(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }
    
    @inlinable
    static func *(lhs: Vector, rhs: T) -> Vector {
        return Vector(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    /// Performs a linear interpolation between `start` and `end` with a specified
    /// factor.
    ///
    /// Alias for `start.ratio(factor, to: end)`.
    @inlinable
    static func lerp(start: Vector, end: Vector, factor: T) -> Vector {
        return start.ratio(factor, to: end)
    }
}

public extension Vector where T: FloatingPoint {
    /// Creates a new Vector, with each coordinate rounded to the closest
    /// possible representation.
    ///
    /// If two representable values are equally close, the result is the value
    /// with more trailing zeros in its significand bit pattern.
    ///
    /// - parameter vector: The integer vector to convert to a floating-point value.
    @inlinable
    init<U>(_ vector: Vector<U>) where U: BinaryInteger {
        self.init(x: T.init(vector.x), y: T.init(vector.y))
    }
    
    @inlinable
    static func +(lhs: Vector, rhs: Vector) -> Vector {
        return Vector(lhs.theVector + rhs.theVector)
    }
    
    @inlinable
    static func -(lhs: Vector, rhs: Vector) -> Vector {
        return Vector(lhs.theVector - rhs.theVector)
    }
    
    @inlinable
    static func *(lhs: Vector, rhs: Vector) -> Vector {
        return Vector(lhs.theVector * rhs.theVector)
    }
    
    @inlinable
    static func /(lhs: Vector, rhs: Vector) -> Vector {
        return Vector(lhs.theVector / rhs.theVector)
    }
    
    @inlinable
    static func %(lhs: Vector, rhs: Vector) -> Vector {
        return Vector(x: lhs.x.truncatingRemainder(dividingBy: rhs.x),
                       y: lhs.y.truncatingRemainder(dividingBy: rhs.y))
    }
    
    @inlinable
    static func +(lhs: Vector, rhs: T) -> Vector {
        return Vector(lhs.theVector + rhs)
    }
    
    @inlinable
    static func -(lhs: Vector, rhs: T) -> Vector {
        return Vector(lhs.theVector - rhs)
    }
    
    @inlinable
    static func *(lhs: Vector, rhs: T) -> Vector {
        return Vector(lhs.theVector * rhs)
    }
    
    @inlinable
    static func /(lhs: Vector, rhs: T) -> Vector {
        return Vector(lhs.theVector / rhs)
    }
    
    @inlinable
    static func %(lhs: Vector, rhs: T) -> Vector {
        return Vector(x: lhs.x.truncatingRemainder(dividingBy: rhs),
                       y: lhs.y.truncatingRemainder(dividingBy: rhs))
    }
    
    @inlinable
    static func /(lhs: T, rhs: Vector) -> Vector {
        return Vector(x: lhs / rhs.x, y: lhs / rhs.y)
    }
    
    @inlinable
    static func +=(lhs: inout Vector, rhs: Vector) {
        lhs.theVector += rhs.theVector
    }
    @inlinable
    static func -=(lhs: inout Vector, rhs: Vector) {
        lhs.theVector -= rhs.theVector
    }
    @inlinable
    static func *=(lhs: inout Vector, rhs: Vector) {
        lhs.theVector *= rhs.theVector
    }
    @inlinable
    static func /=(lhs: inout Vector, rhs: Vector) {
        lhs.theVector /= rhs.theVector
    }
    
    @inlinable
    static func +=(lhs: inout Vector, rhs: T) {
        lhs = lhs + rhs
    }
    
    @inlinable
    static func -=(lhs: inout Vector, rhs: T) {
        lhs = lhs - rhs
    }
    
    @inlinable
    static func *=(lhs: inout Vector, rhs: T) {
        lhs = lhs * rhs
    }
    
    @inlinable
    static func /=(lhs: inout Vector, rhs: T) {
        lhs = lhs / rhs
    }
}

/// BinaryInteger - FloatingPoint operations
public extension Vector where T: FloatingPoint {
    @inlinable
    static func + <B: BinaryInteger>(lhs: Vector, rhs: Vector<B>) -> Vector {
        return lhs + Vector(rhs)
    }
    
    @inlinable
    static func - <B: BinaryInteger>(lhs: Vector, rhs: Vector<B>) -> Vector {
        return lhs - Vector(rhs)
    }
    
    @inlinable
    static func * <B: BinaryInteger>(lhs: Vector, rhs: Vector<B>) -> Vector {
        return lhs * Vector(rhs)
    }
    
    @inlinable
    static func / <B: BinaryInteger>(lhs: Vector, rhs: Vector<B>) -> Vector {
        return lhs / Vector(rhs)
    }
    
    @inlinable
    static func + <B: BinaryInteger>(lhs: Vector<B>, rhs: Vector) -> Vector {
        return Vector(lhs) + rhs
    }
    
    @inlinable
    static func - <B: BinaryInteger>(lhs: Vector<B>, rhs: Vector) -> Vector {
        return Vector(lhs) - rhs
    }
    
    @inlinable
    static func * <B: BinaryInteger>(lhs: Vector<B>, rhs: Vector) -> Vector {
        return Vector(lhs) * rhs
    }
    
    @inlinable
    static func / <B: BinaryInteger>(lhs: Vector<B>, rhs: Vector) -> Vector {
        return Vector(lhs) / rhs
    }
    
    @inlinable
    static func += <B: BinaryInteger>(lhs: inout Vector, rhs: Vector<B>) {
        lhs = lhs + Vector(rhs)
    }
    @inlinable
    static func -= <B: BinaryInteger>(lhs: inout Vector, rhs: Vector<B>) {
        lhs = lhs - Vector(rhs)
    }
    @inlinable
    static func *= <B: BinaryInteger>(lhs: inout Vector, rhs: Vector<B>) {
        lhs = lhs * Vector(rhs)
    }
    @inlinable
    static func /= <B: BinaryInteger>(lhs: inout Vector, rhs: Vector<B>) {
        lhs = lhs / Vector(rhs)
    }
}

public extension Vector where T == Double {
    /// Inits a vector 2 with two integer components
    @inlinable
    init(x: Int, y: Int) {
        theVector = NativeVectorType(Double(x), Double(y))
    }
    
    /// Inits a vector 2 with two float components
    @inlinable
    init(x: Float, y: Float) {
        theVector = NativeVectorType(Double(x), Double(y))
    }
    
    /// Inits a vector 2 with X and Y defined as a given float
    @inlinable
    init(value: Double) {
        theVector = NativeVectorType(repeating: value)
    }
    
    /// Returns the distance between this Vector and another Vector
    @inlinable
    func distance(to vec: Vector) -> Double {
        return simd.distance(self.theVector, vec.theVector)
    }
    
    /// Returns the distance squared between this Vector and another Vector
    @inlinable
    func distanceSquared(to vec: Vector) -> Double {
        return distance_squared(self.theVector, vec.theVector)
    }
    
    // Normalizes this Vector instance.
    // This alters the current vector instance
    @inlinable
    mutating func normalize() -> Vector {
        self = normalized()
        return self
    }
    
    /// Returns a normalized version of this Vector
    @inlinable
    func normalized() -> Vector {
        return Vector(simd.normalize(theVector))
    }
    
    /// Calculates the dot product between this and another provided Vector2
    @inlinable
    func dot(_ other: Vector) -> Double {
        return simd.dot(theVector, other.theVector)
    }
    
    /// Calculates the cross product between this and another provided Vector2.
    /// The resulting scalar would match the 'z' axis of the cross product
    /// between 3d vectors matching the x and y coordinates of the operands, with
    /// the 'z' coordinate being 0.
    @inlinable
    func cross(_ other: Vector) -> Double {
        return simd.cross(theVector, other.theVector).z
    }
    
    /// Returns the angle in radians of this Vector2
    @inlinable
    var angle: Double {
        return atan2(y, x)
    }
    
    /// Returns the squared length of this Vector2
    @inlinable
    var length: Double {
        return length_squared(theVector)
    }
    
    /// Returns the magnitude (or square root of the squared length) of this
    /// Vector2
    @inlinable
    var magnitude: Double {
        return simd.length(theVector)
    }
    
    /// Calculates the dot product between two provided coordinates.
    /// See `Vector.dot`
    @inlinable
    static func •(lhs: Vector, rhs: Vector) -> Double {
        return lhs.dot(rhs)
    }
    
    /// Calculates the dot product between two provided coordinates
    /// See `Vector.cross`
    @inlinable
    static func =/(lhs: Vector, rhs: Vector) -> Double {
        return lhs.cross(rhs)
    }
}

public extension Vector where T == Float {
    /// Inits a vector 2 with two integer components
    @inlinable
    init(x: Int, y: Int) {
        theVector = NativeVectorType(Float(x), Float(y))
    }
    
    /// Inits a vector 2 with two double-precision floating point components
    @inlinable
    init(x: Double, y: Double) {
        theVector = NativeVectorType(Float(x), Float(y))
    }
    
    /// Inits a vector 2 with X and Y defined as a given float
    @inlinable
    init(value: Float) {
        theVector = NativeVectorType(repeating: value)
    }
    
    /// Calculates the dot product between this and another provided Vector
    @inlinable
    func dot(_ other: Vector) -> Float {
        return simd.dot(theVector, other.theVector)
    }
    
    /// Returns the distance between this Vector and another Vector
    @inlinable
    func distance(to vec: Vector) -> Float {
        return simd.distance(self.theVector, vec.theVector)
    }
    
    /// Returns the distance squared between this Vector and another Vector
    @inlinable
    func distanceSquared(to vec: Vector) -> Float {
        return distance_squared(self.theVector, vec.theVector)
    }
    
    // Normalizes this Vector instance.
    // This alters the current vector instance
    @inlinable
    mutating func normalize() -> Vector {
        self = normalized()
        return self
    }
    
    /// Returns a normalized version of this Vector
    @inlinable
    func normalized() -> Vector {
        return Vector(simd.normalize(theVector))
    }
    
    /// Calculates the cross product between this and another provided Vector.
    /// The resulting scalar would match the 'z' axis of the cross product
    /// between 3d vectors matching the x and y coordinates of the operands, with
    /// the 'z' coordinate being 0.
    @inlinable
    func cross(_ other: Vector) -> Float {
        return simd.cross(theVector, other.theVector).z
    }
    
    /// Returns the angle in radians of this Vector
    @inlinable
    var angle: Float {
        return atan2f(y, x)
    }
    
    /// Returns the squared length of this Vector
    @inlinable
    var length: Float {
        return length_squared(theVector)
    }
    
    /// Returns the magnitude (or square root of the squared length) of this
    /// Vector
    @inlinable
    var magnitude: Float {
        return simd.length(theVector)
    }
    /// Calculates the dot product between two provided coordinates.
    /// See `Vector.dot`
    @inlinable
    static func •(lhs: Vector, rhs: Vector) -> Float {
        return lhs.dot(rhs)
    }
    
    /// Calculates the dot product between two provided coordinates
    /// See `Vector.cross`
    @inlinable
    static func =/(lhs: Vector, rhs: Vector) -> Float {
        return lhs.cross(rhs)
    }
}

// MARK: Operators
public extension Vector {
    @inlinable
    static func ==(lhs: Vector, rhs: Vector) -> Bool {
        return lhs.theVector == rhs.theVector
    }
    
    /// Compares two vectors and returns if `lhs` is greater than `rhs`.
    ///
    /// Performs `lhs.x > rhs.x && lhs.y > rhs.y`
    @inlinable
    static func >(lhs: Vector, rhs: Vector) -> Bool {
        return lhs.theVector.x > rhs.theVector.x && lhs.theVector.y > rhs.theVector.y
    }
    
    /// Compares two vectors and returns if `lhs` is greater than or equal to
    /// `rhs`.
    ///
    /// Performs `lhs.x >= rhs.x && lhs.y >= rhs.y`
    @inlinable
    static func >=(lhs: Vector, rhs: Vector) -> Bool {
        return lhs.theVector.x >= rhs.theVector.x && lhs.theVector.y >= rhs.theVector.y
    }
    
    /// Compares two vectors and returns if `lhs` is less than `rhs`.
    ///
    /// Performs `lhs.x < rhs.x && lhs.y < rhs.y`
    @inlinable
    static func <(lhs: Vector, rhs: Vector) -> Bool {
        return lhs.theVector.x < rhs.theVector.x && lhs.theVector.y < rhs.theVector.y
    }
    
    /// Compares two vectors and returns if `lhs` is less than or equal to `rhs`.
    ///
    /// Performs `lhs.x <= rhs.x && lhs.y <= rhs.y`
    @inlinable
    static func <=(lhs: Vector, rhs: Vector) -> Bool {
        return lhs.theVector.x <= rhs.theVector.x && lhs.theVector.y <= rhs.theVector.y
    }
}

// MARK: Matrix-transformation
extension Vector where T == Double {
    /// The 3x3 matrix type that can be used to apply transformations by
    /// multiplying on this Vector
    public typealias NativeMatrixType = double3x3
    
    /// Creates a matrix that when multiplied with a Vector2 object applies the
    /// given set of transformations.
    ///
    /// If all default values are set, an identity matrix is created, which does
    /// not alter a Vector2's coordinates once applied.
    ///
    /// The order of operations are: scaling -> rotation -> translation
    @inlinable
    static public func matrix(scalingBy scale: Vector = Vector.unit,
                              rotatingBy angle: T = 0,
                              translatingBy translate: Vector = Vector.zero) -> Vector.NativeMatrixType {
        
        var matrix = Vector.NativeMatrixType(1)
        
        // Prepare matrices
        
        // Scaling:
        //
        // | sx 0  0 |
        // | 0  sy 0 |
        // | 0  0  1 |
        //
        
        let cScale =
            Vector.NativeMatrixType(columns:
                (Vector.HomogenousVectorType(scale.theVector.x, 0, 0),
                 Vector.HomogenousVectorType(0, scale.theVector.y, 0),
                 Vector.HomogenousVectorType(0, 0, 1)))
        
        matrix *= cScale
        
        // Rotation:
        //
        // | cos(a)  sin(a)  0 |
        // | -sin(a) cos(a)  0 |
        // |   0       0     1 |
        
        if angle != 0 {
            let c = cos(-angle)
            let s = sin(-angle)
            
            let cRotation =
                Vector.NativeMatrixType(columns:
                    (Vector.HomogenousVectorType(c, s, 0),
                     Vector.HomogenousVectorType(-s, c, 0),
                     Vector.HomogenousVectorType(0, 0, 1)))
            
            matrix *= cRotation
        }
        
        // Translation:
        //
        // | 0  0  dx |
        // | 0  0  dy |
        // | 0  0  1  |
        //
        
        let cTranslation =
            Vector.NativeMatrixType(columns:
                (Vector.HomogenousVectorType(1, 0, translate.theVector.x),
                 Vector.HomogenousVectorType(0, 1, translate.theVector.y),
                 Vector.HomogenousVectorType(0, 0, 1)))
        
        matrix *= cTranslation
        
        return matrix
    }
    
    // Matrix multiplication
    @inlinable
    static public func *(lhs: Vector, rhs: Vector.NativeMatrixType) -> Vector {
        let homog = Vector.HomogenousVectorType(lhs.theVector.x, lhs.theVector.y, 1)
        
        let transformed = homog * rhs
        
        return Vector(x: transformed.x, y: transformed.y)
    }

    @inlinable
    static public func *(lhs: Vector, rhs: Matrix2D) -> Vector {
        return Matrix2D.transformPoint(matrix: rhs, point: lhs)
    }

    @inlinable
    static public func *(lhs: Matrix2D, rhs: Vector) -> Vector {
        return Matrix2D.transformPoint(matrix: lhs, point: rhs)
    }
    
    @inlinable
    static public func *=(lhs: inout Vector, rhs: Matrix2D) {
        lhs = Matrix2D.transformPoint(matrix: rhs, point: lhs)
    }
}

// MARK: Rotation
extension Vector where T == Float {
    /// Returns a rotated version of this vector, rotated around by a given
    /// angle in radians
    @inlinable
    public func rotated(by angleInRadians: Float) -> Vector {
        return Vector.rotate(self, by: angleInRadians)
    }
    
    /// Rotates this vector around by a given angle in radians
    @inlinable
    public mutating func rotate(by angleInRadians: Float) -> Vector {
        self = rotated(by: angleInRadians)
        return self
    }
    
    /// Rotates a given vector by an angle in radians
    @inlinable
    public static func rotate(_ vec: Vector, by angleInRadians: Float) -> Vector {
        
        // Check if we have a 0º or 180º rotation - these we can figure out
        // using conditionals to speedup common paths.
        let remainder =
            angleInRadians.truncatingRemainder(dividingBy: .pi * 2)
        
        if remainder == 0 {
            return vec
        }
        if remainder == .pi {
            return -vec
        }
        
        let c = cosf(angleInRadians)
        let s = sinf(angleInRadians)
        
        return Vector(x: (c * vec.x) - (s * vec.y), y: (c * vec.y) + (s * vec.x))
    }
}

extension Vector where T == Double {
    /// Returns a rotated version of this vector, rotated around by a given
    /// angle in radians
    @inlinable
    public func rotated(by angleInRadians: Double) -> Vector {
        return Vector.rotate(self, by: angleInRadians)
    }
    
    /// Rotates this vector around by a given angle in radians
    @inlinable
    public mutating func rotate(by angleInRadians: Double) -> Vector {
        self = rotated(by: angleInRadians)
        return self
    }
    
    /// Rotates a given vector by an angle in radians
    @inlinable
    public static func rotate(_ vec: Vector, by angleInRadians: Double) -> Vector {
        
        // Check if we have a 0º or 180º rotation - these we can figure out
        // using conditionals to speedup common paths.
        let remainder =
            angleInRadians.truncatingRemainder(dividingBy: .pi * 2)
        
        if remainder == 0 {
            return vec
        }
        if remainder == .pi {
            return -vec
        }
        
        let c = cos(angleInRadians)
        let s = sin(angleInRadians)
        
        return Vector(x: (c * vec.x) - (s * vec.y), y: (c * vec.y) + (s * vec.x))
    }
}

// MARK: Misc math
public extension Vector where T: Numeric {
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
    func ratio(_ ratio: T, to other: Vector) -> Vector {
        return self + (other - self) * ratio
    }
}

public extension Collection {
    /// Averages this collection of vectors into one Vector point as the mean
    /// location of each vector.
    ///
    /// Returns a zero Vector, if the collection is empty.
    @inlinable
    func averageVector<T: FloatingPoint>() -> Vector<T> where Element == Vector<T> {
        if isEmpty {
            return .zero
        }
        
        return reduce(into: .zero) { $0 += $1 } / T(count)
    }
}

/// Returns a Vector that represents the minimum coordinates between two
/// Vector objects
@inlinable
public func min(_ a: Vector<Double>, _ b: Vector<Double>) -> Vector<Double> {
    return Vector(min(a.theVector, b.theVector))
}

/// Returns a Vector that represents the maximum coordinates between two
/// Vector objects
@inlinable
public func max(_ a: Vector<Double>, _ b: Vector<Double>) -> Vector<Double> {
    return Vector(max(a.theVector, b.theVector))
}

/// Returns a Vector that represents the minimum coordinates between two
/// Vector objects
@inlinable
public func min(_ a: Vector<Float>, _ b: Vector<Float>) -> Vector<Float> {
    return Vector(min(a.theVector, b.theVector))
}

/// Returns a Vector that represents the maximum coordinates between two
/// Vector objects
@inlinable
public func max(_ a: Vector<Float>, _ b: Vector<Float>) -> Vector<Float> {
    return Vector(max(a.theVector, b.theVector))
}

/// Returns a Vector that represents the minimum coordinates between two
/// Vector objects
@inlinable
public func min<T>(_ a: Vector<T>, _ b: Vector<T>) -> Vector<T> {
    return Vector(x: min(a.theVector.x, b.theVector.x), y: min(a.theVector.y, b.theVector.y))
}

/// Returns a Vector that represents the maximum coordinates between two
/// Vector objects
@inlinable
public func max<T>(_ a: Vector<T>, _ b: Vector<T>) -> Vector<T> {
    return Vector(x: max(a.theVector.x, b.theVector.x), y: max(a.theVector.y, b.theVector.y))
}

/// Returns whether rotating from A to B is counter-clockwise
@inlinable
public func vectorsAreCCW(_ A: Vector<Double>, B: Vector<Double>) -> Bool {
    return (B • A.perpendicular()) >= 0.0
}

/// Returns whether rotating from A to B is counter-clockwise
@inlinable
public func vectorsAreCCW(_ A: Vector<Float>, B: Vector<Float>) -> Bool {
    return (B • A.perpendicular()) >= 0.0
}

////////
//// Define the operations to be performed on the Vector2
////////

// This • character is available as 'Option-8' combination on Mac keyboards
infix operator • : MultiplicationPrecedence
infix operator =/ : MultiplicationPrecedence

@inlinable
public func round<T: FloatingPoint>(_ x: Vector<T>) -> Vector<T> {
    return Vector(x: round(x.x), y: round(x.y))
}

@inlinable
public func ceil<T: FloatingPoint>(_ x: Vector<T>) -> Vector<T> {
    return Vector(x.theVector.rounded(.up))
}

@inlinable
public func floor<T: FloatingPoint>(_ x: Vector<T>) -> Vector<T> {
    return Vector(x.theVector.rounded(.down))
}

@inlinable
public func abs<T: SignedNumeric>(_ x: Vector<T>) -> Vector<T> {
    return Vector(x: abs(x.theVector.x), y: abs(x.theVector.y))
}

extension Vector.NativeMatrixType: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        try self.init([
            container.decode(Vector.HomogenousVectorType.self),
            container.decode(Vector.HomogenousVectorType.self),
            container.decode(Vector.HomogenousVectorType.self)
        ])
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        try container.encode(self.columns.0)
        try container.encode(self.columns.1)
        try container.encode(self.columns.2)
    }
}
