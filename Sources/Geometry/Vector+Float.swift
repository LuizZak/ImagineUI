import simd

public extension VectorT where Scalar == Float {
    /// Returns the angle in radians of this Vector relative to the origin (0, 0).
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
    
    /// Inits a Vector with two integer components
    @inlinable
    init(x: Int, y: Int) {
        theVector = NativeVectorType(Float(x), Float(y))
    }
    
    /// Inits a Vector with two double-precision float components
    @inlinable
    init(x: Double, y: Double) {
        theVector = NativeVectorType(Float(x), Float(y))
    }
    
    /// Returns the distance between this Vector and another Vector
    @inlinable
    func distance(to vec: VectorT) -> Float {
        return simd.distance(self.theVector, vec.theVector)
    }
    
    /// Returns the distance squared between this Vector and another Vector
    @inlinable
    func distanceSquared(to vec: VectorT) -> Float {
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
    func dot(_ other: VectorT) -> Float {
        return simd.dot(theVector, other.theVector)
    }
    
    /// Calculates the cross product between this and another provided Vector.
    /// The resulting scalar would match the 'z' axis of the cross product
    /// between 3d vectors matching the x and y coordinates of the operands, with
    /// the 'z' coordinate being 0.
    @inlinable
    func cross(_ other: VectorT) -> Float {
        return simd.cross(theVector, other.theVector).z
    }
    
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
    func ratio(_ ratio: Scalar, to other: VectorT) -> VectorT {
        return VectorT(mix(self.theVector, other.theVector, t: ratio))
    }
}

// MARK: - Rotation
extension VectorT where Scalar == Float {
    /// Returns a rotated version of this vector, rotated around by a given
    /// angle in radians
    @inlinable
    public func rotated(by angleInRadians: Float) -> VectorT {
        return VectorT.rotate(self, by: angleInRadians)
    }
    
    /// Rotates this vector around by a given angle in radians
    @inlinable
    public mutating func rotate(by angleInRadians: Float) -> VectorT {
        self = rotated(by: angleInRadians)
        return self
    }
    
    /// Rotates a given vector by an angle in radians
    @inlinable
    public static func rotate(_ vec: VectorT, by angleInRadians: Float) -> VectorT {
        
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
        
        return VectorT(x: (c * vec.x) - (s * vec.y), y: (c * vec.y) + (s * vec.x))
    }
}

// MARK: - Operators
public extension VectorT where Scalar == Float {
    /// Calculates the dot product between two provided coordinates.
    /// See `Vector.dot`
    @inlinable
    static func • (lhs: VectorT, rhs: VectorT) -> Float {
        return lhs.dot(rhs)
    }
    
    /// Calculates the dot product between two provided coordinates
    /// See `Vector.cross`
    @inlinable
    static func =/ (lhs: VectorT, rhs: VectorT) -> Float {
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
    static func + (lhs: VectorT, rhs: Scalar) -> VectorT {
        return VectorT(lhs.theVector + rhs)
    }
    
    @inlinable
    static func - (lhs: VectorT, rhs: Scalar) -> VectorT {
        return VectorT(lhs.theVector - rhs)
    }
    
    @inlinable
    static func * (lhs: VectorT, rhs: Scalar) -> VectorT {
        return VectorT(lhs.theVector * rhs)
    }
    
    @inlinable
    static func / (lhs: VectorT, rhs: Scalar) -> VectorT {
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
public func min(_ a: VectorT<Float>, _ b: VectorT<Float>) -> VectorT<Float> {
    return VectorT(min(a.theVector, b.theVector))
}

/// Returns a Vector that represents the maximum coordinates between two
/// Vector objects
@inlinable
public func max(_ a: VectorT<Float>, _ b: VectorT<Float>) -> VectorT<Float> {
    return VectorT(max(a.theVector, b.theVector))
}

/// Returns whether rotating from A to B is counter-clockwise
@inlinable
public func vectorsAreCCW(_ A: VectorT<Float>, B: VectorT<Float>) -> Bool {
    return (B • A.perpendicular()) >= 0.0
}
