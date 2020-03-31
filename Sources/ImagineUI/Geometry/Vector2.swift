import simd

/// Represents a 2D vector
public struct Vector2: Equatable, CustomStringConvertible, Codable {
    /// Used to match `Double`'s native type
    public typealias NativeVectorType = SIMD2<Double>
    
    /// The 3x3 matrix type that can be used to apply transformations by
    /// multiplying on this Vector2
    public typealias NativeMatrixType = double3x3
    
    /// This is used during affine transformation
    public typealias HomogenousVectorType = SIMD3<Double>
    
    /// A zeroed-value Vector2
    public static let zero = Vector2(x: 0, y: 0)
    
    /// An unit-valued Vector2
    public static let unit = Vector2(x: 1, y: 1)
    
    /// An unit-valued Vector2.
    /// Aliast for 'unit'.
    public static let one = unit
    
    /// The underlying SIMD vector type
    @usableFromInline
    var theVector: NativeVectorType
    
    /// The Double representation of this vector's x axis
    @inlinable
    public var x: Double {
        get {
            return theVector.x
        }
        set {
            theVector.x = newValue
        }
    }
    
    /// The Double representation of this vector's y axis
    @inlinable
    public var y: Double {
        get {
            return theVector.y
        }
        set {
            theVector.y = newValue
        }
    }
    
    /// Returns the angle in radians of this Vector2
    @inlinable
    public var angle : Double {
        return atan2(y, x)
    }
    
    /// Returns the squared length of this Vector2
    @inlinable
    public var length : Double {
        return length_squared(theVector)
    }
    
    /// Returns the magnitude (or square root of the squared length) of this 
    /// Vector2
    @inlinable
    public var magnitude : Double {
        return simd.length(theVector)
    }
    
    /// Textual representation of this vector's coordinates
    public var description: String {
        return "{ \(self.x) : \(self.y) }"
    }
    
    @inlinable
    init(_ vector: NativeVectorType) {
        theVector = vector
    }
    
    /// Inits a 0-valued Vector2
    @inlinable
    public init() {
        theVector = NativeVectorType(repeating: 0)
    }
    
    /// Inits a vector 2 with two integer components
    @inlinable
    public init(x: Int, y: Int) {
        theVector = NativeVectorType(Double(x), Double(y))
    }
    
    /// Inits a vector 2 with two float components
    @inlinable
    public init(x: Float, y: Float) {
        theVector = NativeVectorType(Double(x), Double(y))
    }
    
    /// Inits a vector 2 with two double-precision floating point components
    @inlinable
    public init(x: Double, y: Double) {
        theVector = NativeVectorType(x, y)
    }
    
    /// Inits a vector 2 with X and Y defined as a given float
    @inlinable
    public init(value: Double) {
        theVector = NativeVectorType(repeating: value)
    }
    
    /// Returns the distance between this Vector2 and another Vector2
    @inlinable
    public func distance(to vec: Vector2) -> Double {
        return simd.distance(self.theVector, vec.theVector)
    }
    
    /// Returns the distance squared between this Vector2 and another Vector2
    @inlinable
    public func distanceSquared(to vec: Vector2) -> Double {
        return distance_squared(self.theVector, vec.theVector)
    }
    
    /// Makes this Vector2 perpendicular to its current position.
    /// This alters the vector instance
    @inlinable
    public mutating func formPerpendicular() -> Vector2 {
        self = perpendicular()
        return self
    }
    
    /// Returns a Vector2 perpendicular to this Vector2
    @inlinable
    public func perpendicular() -> Vector2 {
        return Vector2(x: -y, y: x)
    }
    
    // Normalizes this Vector2 instance.
    // This alters the current vector instance
    @inlinable
    public mutating func normalize() -> Vector2 {
        self = normalized()
        return self
    }
    
    /// Returns a normalized version of this Vector2
    @inlinable
    public func normalized() -> Vector2 {
        return Vector2(simd.normalize(theVector))
    }
    
    /// Returns a vector that represents this vector's point, rotated 90º counter
    /// clockwise
    @inlinable
    public func leftRotated() -> Vector2 {
        return Vector2(x: -y, y: x)
    }
    
    /// Returns a vector that represents this vector's point, rotated 90º clockwise
    @inlinable
    public func rightRotated() -> Vector2 {
        return Vector2(x: y, y: -x)
    }

    /// Performs a linear interpolation between `start` and `end` with a specified
    /// factor.
    ///
    /// Alias for `start.ratio(factor, to: end)`.
    @inlinable
    public static func lerp(start: Vector2, end: Vector2, factor: Double) -> Vector2 {
        return start.ratio(factor, to: end)
    }
}

/// Dot and Cross products
extension Vector2 {
    /// Calculates the dot product between this and another provided Vector2
    @inlinable
    public func dot(_ other: Vector2) -> Double {
        return simd.dot(theVector, other.theVector)
    }
    
    /// Calculates the cross product between this and another provided Vector2.
    /// The resulting scalar would match the 'z' axis of the cross product 
    /// between 3d vectors matching the x and y coordinates of the operands, with
    /// the 'z' coordinate being 0.
    @inlinable
    public func cross(_ other: Vector2) -> Double {
        return simd.cross(theVector, other.theVector).z
    }
}

// MARK: Operators
extension Vector2 {
    ////
    // Comparision operators
    ////
    @inlinable
    static public func ==(lhs: Vector2, rhs: Vector2) -> Bool {
        return lhs.theVector.x == rhs.theVector.x && lhs.theVector.y == rhs.theVector.y
    }
    
    /// Compares two vectors and returns if `lhs` is greater than `rhs`.
    ///
    /// Performs `lhs.x > rhs.x && lhs.y > rhs.y`
    @inlinable
    static public func >(lhs: Vector2, rhs: Vector2) -> Bool {
        return lhs.theVector.x > rhs.theVector.x && lhs.theVector.y > rhs.theVector.y
    }
    
    /// Compares two vectors and returns if `lhs` is greater than or equal to
    /// `rhs`.
    ///
    /// Performs `lhs.x >= rhs.x && lhs.y >= rhs.y`
    @inlinable
    static public func >=(lhs: Vector2, rhs: Vector2) -> Bool {
        return lhs.theVector.x >= rhs.theVector.x && lhs.theVector.y >= rhs.theVector.y
    }
    
    /// Compares two vectors and returns if `lhs` is less than `rhs`.
    ///
    /// Performs `lhs.x < rhs.x && lhs.y < rhs.y`
    @inlinable
    static public func <(lhs: Vector2, rhs: Vector2) -> Bool {
        return lhs.theVector.x < rhs.theVector.x && lhs.theVector.y < rhs.theVector.y
    }
    
    /// Compares two vectors and returns if `lhs` is less than or equal to `rhs`.
    ///
    /// Performs `lhs.x <= rhs.x && lhs.y <= rhs.y`
    @inlinable
    static public func <=(lhs: Vector2, rhs: Vector2) -> Bool {
        return lhs.theVector.x <= rhs.theVector.x && lhs.theVector.y <= rhs.theVector.y
    }
    
    // Unary operators
    @inlinable
    static public prefix func -(lhs: Vector2) -> Vector2 {
        return Vector2(-lhs.theVector)
    }
    
    // DOT operator
    /// Calculates the dot product between two provided coordinates.
    /// See `Vector2.dot`
    @inlinable
    static public func •(lhs: Vector2, rhs: Vector2) -> Double {
        return lhs.dot(rhs)
    }
    
    // CROSS operator
    /// Calculates the dot product between two provided coordinates
    /// See `Vector2.cross`
    @inlinable
    static public func =/(lhs: Vector2, rhs: Vector2) -> Double {
        return lhs.cross(rhs)
    }
    
    ////
    // Basic arithmetic operators
    ////
    @inlinable
    static public func +(lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(lhs.theVector + rhs.theVector)
    }
    
    @inlinable
    static public func -(lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(lhs.theVector - rhs.theVector)
    }
    
    @inlinable
    static public func *(lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(lhs.theVector * rhs.theVector)
    }
    
    @inlinable
    static public func /(lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(lhs.theVector / rhs.theVector)
    }
    
    @inlinable
    static public func %(lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(x: lhs.x.truncatingRemainder(dividingBy: rhs.x),
                       y: lhs.y.truncatingRemainder(dividingBy: rhs.y))
    }
    
    // Double interaction
    @inlinable
    static public func +(lhs: Vector2, rhs: Double) -> Vector2 {
        return Vector2(lhs.theVector + rhs)
    }
    
    @inlinable
    static public func -(lhs: Vector2, rhs: Double) -> Vector2 {
        return Vector2(lhs.theVector - rhs)
    }
    
    @inlinable
    static public func *(lhs: Vector2, rhs: Double) -> Vector2 {
        return Vector2(lhs.theVector * rhs)
    }
    
    @inlinable
    static public func /(lhs: Vector2, rhs: Double) -> Vector2 {
        return Vector2(lhs.theVector / rhs)
    }
    
    @inlinable
    static public func %(lhs: Vector2, rhs: Double) -> Vector2 {
        return Vector2(x: lhs.x.truncatingRemainder(dividingBy: rhs),
                       y: lhs.y.truncatingRemainder(dividingBy: rhs))
    }
    
    @inlinable
    static public func /(lhs: Double, rhs: Vector2) -> Vector2 {
        return Vector2(x: lhs / rhs.x, y: lhs / rhs.y)
    }
    
    ////
    // Compound assignment operators
    ////
    @inlinable
    static public func +=(lhs: inout Vector2, rhs: Vector2) {
        lhs.theVector += rhs.theVector
    }
    @inlinable
    static public func -=(lhs: inout Vector2, rhs: Vector2) {
        lhs.theVector -= rhs.theVector
    }
    @inlinable
    static public func *=(lhs: inout Vector2, rhs: Vector2) {
        lhs.theVector *= rhs.theVector
    }
    @inlinable
    static public func /=(lhs: inout Vector2, rhs: Vector2) {
        lhs.theVector /= rhs.theVector
    }
    
    // Double interaction
    @inlinable
    static public func +=(lhs: inout Vector2, rhs: Double) {
        lhs = lhs + rhs
    }
    @inlinable
    static public func -=(lhs: inout Vector2, rhs: Double) {
        lhs = lhs - rhs
    }
    @inlinable
    static public func *=(lhs: inout Vector2, rhs: Double) {
        lhs = lhs * rhs
    }
    @inlinable
    static public func /=(lhs: inout Vector2, rhs: Double) {
        lhs = lhs / rhs
    }
}

@usableFromInline
let _identityMatrix = Vector2.NativeMatrixType(1)

// MARK: Matrix-transformation
extension Vector2 {
    
    /// Creates a matrix that when multiplied with a Vector2 object applies the
    /// given set of transformations.
    ///
    /// If all default values are set, an identity matrix is created, which does
    /// not alter a Vector2's coordinates once applied.
    ///
    /// The order of operations are: scaling -> rotation -> translation
    @inlinable
    static public func matrix(scalingBy scale: Vector2 = Vector2.unit,
                              rotatingBy angle: Double = 0,
                              translatingBy translate: Vector2 = Vector2.zero) -> Vector2.NativeMatrixType {
        
        var matrix = _identityMatrix
        
        // Prepare matrices
        
        // Scaling:
        //
        // | sx 0  0 |
        // | 0  sy 0 |
        // | 0  0  1 |
        //
        
        let cScale =
            Vector2.NativeMatrixType(columns:
                (Vector2.HomogenousVectorType(scale.theVector.x, 0, 0),
                 Vector2.HomogenousVectorType(0, scale.theVector.y, 0),
                 Vector2.HomogenousVectorType(0, 0, 1)))
        
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
                Vector2.NativeMatrixType(columns:
                    (Vector2.HomogenousVectorType(c, s, 0),
                     Vector2.HomogenousVectorType(-s, c, 0),
                     Vector2.HomogenousVectorType(0, 0, 1)))
            
            matrix *= cRotation
        }
        
        // Translation:
        //
        // | 0  0  dx |
        // | 0  0  dy |
        // | 0  0  1  |
        //
        
        let cTranslation =
            Vector2.NativeMatrixType(columns:
                (Vector2.HomogenousVectorType(1, 0, translate.theVector.x),
                 Vector2.HomogenousVectorType(0, 1, translate.theVector.y),
                 Vector2.HomogenousVectorType(0, 0, 1)))
        
        matrix *= cTranslation
        
        return matrix
    }
    
    // Matrix multiplication
    @inlinable
    static public func *(lhs: Vector2, rhs: Vector2.NativeMatrixType) -> Vector2 {
        let homog = Vector2.HomogenousVectorType(lhs.theVector.x, lhs.theVector.y, 1)
        
        let transformed = homog * rhs
        
        return Vector2(x: transformed.x, y: transformed.y)
    }

    @inlinable
    static public func * (lhs: Vector2, rhs: Matrix2D) -> Vector2 {
        return Matrix2D.transformPoint(matrix: rhs, point: lhs)
    }

    @inlinable
    static public func * (lhs: Matrix2D, rhs: Vector2) -> Vector2 {
        return Matrix2D.transformPoint(matrix: lhs, point: rhs)
    }
    
    @inlinable
    static public func *= (lhs: inout Vector2, rhs: Matrix2D) {
        lhs = Matrix2D.transformPoint(matrix: rhs, point: lhs)
    }
}

// MARK: Rotation
extension Vector2 {
    /// Returns a rotated version of this vector, rotated around by a given 
    /// angle in radians
    @inlinable
    public func rotated(by angleInRadians: Double) -> Vector2 {
        return Vector2.rotate(self, by: angleInRadians)
    }
    
    /// Rotates this vector around by a given angle in radians
    @inlinable
    public mutating func rotate(by angleInRadians: Double) -> Vector2 {
        self = rotated(by: angleInRadians)
        return self
    }
    
    /// Rotates a given vector by an angle in radians
    @inlinable
    public static func rotate(_ vec: Vector2, by angleInRadians: Double) -> Vector2 {
        
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
        
        return Vector2(x: (c * vec.x) - (s * vec.y), y: (c * vec.y) + (s * vec.x))
    }
}

// MARK: Misc math
extension Vector2 {
    
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
    public func ratio(_ ratio: Double, to other: Vector2) -> Vector2 {
        return self + (other - self) * ratio
    }
}

extension Collection where Iterator.Element == Vector2 {
    /// Averages this collection of vectors into one Vector point as the mean
    /// location of each vector.
    ///
    /// Returns a zero Vector, if the collection is empty.
    @inlinable
    public func averageVector() -> Vector2 {
        if isEmpty {
            return .zero
        }
        
        return reduce(into: .zero) { $0 += $1 } / Double(count)
    }
}

/// Returns a Vector2 that represents the minimum coordinates between two 
/// Vector2 objects
@inlinable
public func min(_ a: Vector2, _ b: Vector2) -> Vector2 {
    return Vector2(min(a.theVector, b.theVector))
}

/// Returns a Vector2 that represents the maximum coordinates between two 
/// Vector2 objects
@inlinable
public func max(_ a: Vector2, _ b: Vector2) -> Vector2 {
    return Vector2(max(a.theVector, b.theVector))
}

/// Returns whether rotating from A to B is counter-clockwise
@inlinable
public func vectorsAreCCW(_ A: Vector2, B: Vector2) -> Bool {
    return (B • A.perpendicular()) >= 0.0
}

////////
//// Define the operations to be performed on the Vector2
////////

// This • character is available as 'Option-8' combination on Mac keyboards
infix operator • : MultiplicationPrecedence
infix operator =/ : MultiplicationPrecedence

@inlinable
public func round(_ x: Vector2) -> Vector2 {
    return Vector2(x: round(x.x), y: round(x.y))
}

@inlinable
public func ceil(_ x: Vector2) -> Vector2 {
    return Vector2(ceil(x.theVector))
}

@inlinable
public func floor(_ x: Vector2) -> Vector2 {
    return Vector2(floor(x.theVector))
}

@inlinable
public func abs(_ x: Vector2) -> Vector2 {
    return Vector2(abs(x.theVector))
}

extension Vector2.NativeMatrixType: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        try self.init([
            container.decode(Vector2.HomogenousVectorType.self),
            container.decode(Vector2.HomogenousVectorType.self),
            container.decode(Vector2.HomogenousVectorType.self)
        ])
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        try container.encode(self.columns.0)
        try container.encode(self.columns.1)
        try container.encode(self.columns.2)
    }
}

public typealias Size = Vector2
