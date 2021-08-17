import simd

public extension VectorT where T == Double {
    /// Returns the angle in radians of this Vector relative to the origin (0, 0).
    @inlinable
    var angle: Double {
        return atan2(y, x)
    }
    
    /// Returns the squared length of this Vector
    @inlinable
    var length: Double {
        return length_squared(theVector)
    }
    
    /// Returns the magnitude (or square root of the squared length) of this
    /// Vector
    @inlinable
    var magnitude: Double {
        return simd.length(theVector)
    }
    
    /// Inits a Vector with two integer components
    @inlinable
    init(x: Int, y: Int) {
        theVector = NativeVectorType(Double(x), Double(y))
    }
    
    /// Inits a Vector with two float components
    @inlinable
    init(x: Float, y: Float) {
        theVector = NativeVectorType(Double(x), Double(y))
    }
    
    /// Returns the distance between this Vector and another Vector
    @inlinable
    func distance(to vec: VectorT) -> Double {
        return simd.distance(self.theVector, vec.theVector)
    }
    
    /// Returns the distance squared between this Vector and another Vector
    @inlinable
    func distanceSquared(to vec: VectorT) -> Double {
        return distance_squared(self.theVector, vec.theVector)
    }
    
    // Normalizes this Vector instance.
    // This alters the current vector instance
    @inlinable
    mutating func normalize() -> VectorT {
        self = normalized()
        return self
    }
    
    /// Returns a normalized version of this Vector
    @inlinable
    func normalized() -> VectorT {
        return VectorT(simd.normalize(theVector))
    }
    
    /// Calculates the dot product between this and another provided Vector
    @inlinable
    func dot(_ other: VectorT) -> Double {
        return simd.dot(theVector, other.theVector)
    }
    
    /// Calculates the cross product between this and another provided Vector.
    /// The resulting scalar would match the 'z' axis of the cross product
    /// between 3d vectors matching the x and y coordinates of the operands, with
    /// the 'z' coordinate being 0.
    @inlinable
    func cross(_ other: VectorT) -> Double {
        return simd.cross(theVector, other.theVector).z
    }
}

// MARK: - Rotation
extension VectorT where T == Double {
    /// Returns a rotated version of this vector, rotated around by a given
    /// angle in radians
    @inlinable
    public func rotated(by angleInRadians: Double) -> VectorT {
        return VectorT.rotate(self, by: angleInRadians)
    }
    
    /// Rotates this vector around by a given angle in radians
    @inlinable
    public mutating func rotate(by angleInRadians: Double) -> VectorT {
        self = rotated(by: angleInRadians)
        return self
    }
    
    /// Rotates a given vector by an angle in radians
    @inlinable
    public static func rotate(_ vec: VectorT, by angleInRadians: Double) -> VectorT {
        
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
        
        return VectorT(x: (c * vec.x) - (s * vec.y), y: (c * vec.y) + (s * vec.x))
    }
}

// MARK: Matrix-transformation
extension VectorT where T == Double {
    /// The 3x3 matrix type that can be used to apply transformations by
    /// multiplying on this Vector
    public typealias NativeMatrixType = double3x3
    
    /// Creates a matrix that when multiplied with a Vector object applies the
    /// given set of transformations.
    ///
    /// If all default values are set, an identity matrix is created, which does
    /// not alter a Vector's coordinates once applied.
    ///
    /// The order of operations are: scaling -> rotation -> translation
    @inlinable
    static public func matrix(scalingBy scale: VectorT = .unit,
                              rotatingBy angle: Double = 0,
                              translatingBy translate: VectorT = .zero) -> VectorT.NativeMatrixType {
        
        var matrix = VectorT.NativeMatrixType(1)
        
        // Prepare matrices
        
        // Scaling:
        //
        // | sx 0  0 |
        // | 0  sy 0 |
        // | 0  0  1 |
        //
        
        let cScale =
            VectorT.NativeMatrixType(columns:
                (VectorT.HomogenousVectorType(scale.theVector.x, 0, 0),
                 VectorT.HomogenousVectorType(0, scale.theVector.y, 0),
                 VectorT.HomogenousVectorType(0, 0, 1)))
        
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
                VectorT.NativeMatrixType(columns:
                    (VectorT.HomogenousVectorType(c, s, 0),
                     VectorT.HomogenousVectorType(-s, c, 0),
                     VectorT.HomogenousVectorType(0, 0, 1)))
            
            matrix *= cRotation
        }
        
        // Translation:
        //
        // | 0  0  dx |
        // | 0  0  dy |
        // | 0  0  1  |
        //
        
        let cTranslation =
            VectorT.NativeMatrixType(columns:
                (VectorT.HomogenousVectorType(1, 0, translate.theVector.x),
                 VectorT.HomogenousVectorType(0, 1, translate.theVector.y),
                 VectorT.HomogenousVectorType(0, 0, 1)))
        
        matrix *= cTranslation
        
        return matrix
    }
    
    // Matrix multiplication
    @inlinable
    static public func *(lhs: VectorT, rhs: VectorT.NativeMatrixType) -> VectorT {
        let homog = VectorT.HomogenousVectorType(lhs.theVector.x, lhs.theVector.y, 1)
        
        let transformed = homog * rhs
        
        return VectorT(x: transformed.x, y: transformed.y)
    }

    @inlinable
    static public func *(lhs: VectorT, rhs: Matrix2D) -> VectorT {
        return Matrix2D.transformPoint(matrix: rhs, point: lhs)
    }

    @inlinable
    static public func *(lhs: Matrix2D, rhs: VectorT) -> VectorT {
        return Matrix2D.transformPoint(matrix: lhs, point: rhs)
    }
    
    @inlinable
    static public func *=(lhs: inout VectorT, rhs: Matrix2D) {
        lhs = Matrix2D.transformPoint(matrix: rhs, point: lhs)
    }
}

// MARK: - Operators
public extension VectorT where T == Double {
    /// Calculates the dot product between two provided coordinates.
    /// See `Vector.dot`
    @inlinable
    static func • (lhs: VectorT, rhs: VectorT) -> Double {
        return lhs.dot(rhs)
    }
    
    /// Calculates the dot product between two provided coordinates
    /// See `Vector.cross`
    @inlinable
    static func =/ (lhs: VectorT, rhs: VectorT) -> Double {
        return lhs.cross(rhs)
    }
    
    @inlinable
    static func + (lhs: VectorT, rhs: VectorT) -> VectorT {
        return VectorT(lhs.theVector + rhs.theVector)
    }
    
    @inlinable
    static func - (lhs: VectorT, rhs: VectorT) -> VectorT {
        return VectorT(lhs.theVector - rhs.theVector)
    }
    
    @inlinable
    static func * (lhs: VectorT, rhs: VectorT) -> VectorT {
        return VectorT(lhs.theVector * rhs.theVector)
    }
    
    @inlinable
    static func / (lhs: VectorT, rhs: VectorT) -> VectorT {
        return VectorT(lhs.theVector / rhs.theVector)
    }
    
    @inlinable
    static func + (lhs: VectorT, rhs: T) -> VectorT {
        return VectorT(lhs.theVector + rhs)
    }
    
    @inlinable
    static func - (lhs: VectorT, rhs: T) -> VectorT {
        return VectorT(lhs.theVector - rhs)
    }
    
    @inlinable
    static func * (lhs: VectorT, rhs: T) -> VectorT {
        return VectorT(lhs.theVector * rhs)
    }
    
    @inlinable
    static func / (lhs: VectorT, rhs: T) -> VectorT {
        return VectorT(lhs.theVector / rhs)
    }
    
    @inlinable
    static func += (lhs: inout VectorT, rhs: VectorT) {
        lhs.theVector += rhs.theVector
    }
    @inlinable
    static func -= (lhs: inout VectorT, rhs: VectorT) {
        lhs.theVector -= rhs.theVector
    }
    @inlinable
    static func *= (lhs: inout VectorT, rhs: VectorT) {
        lhs.theVector *= rhs.theVector
    }
    @inlinable
    static func /= (lhs: inout VectorT, rhs: VectorT) {
        lhs.theVector /= rhs.theVector
    }
}

/// Returns a Vector that represents the minimum coordinates between two
/// Vector objects
@inlinable
public func min(_ a: VectorT<Double>, _ b: VectorT<Double>) -> VectorT<Double> {
    return VectorT(min(a.theVector, b.theVector))
}

/// Returns a Vector that represents the maximum coordinates between two
/// Vector objects
@inlinable
public func max(_ a: VectorT<Double>, _ b: VectorT<Double>) -> VectorT<Double> {
    return VectorT(max(a.theVector, b.theVector))
}

/// Returns whether rotating from A to B is counter-clockwise
@inlinable
public func vectorsAreCCW(_ A: VectorT<Double>, B: VectorT<Double>) -> Bool {
    return (B • A.perpendicular()) >= 0.0
}
