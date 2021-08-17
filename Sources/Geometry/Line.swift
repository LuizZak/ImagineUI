/// Describes a line as a pair of double-precision, floating-point start and end
/// vectors
public typealias Line = LineT<Double>

/// Describes a line as a pair of start and end positions
public struct LineT<Scalar: VectorScalar>: Equatable, Codable {
    public var start: VectorT<Scalar>
    public var end: VectorT<Scalar>
    
    @inlinable
    public init(start: VectorT<Scalar>, end: VectorT<Scalar>) {
        self.start = start
        self.end = end
    }
    
    @inlinable
    public init(x1: Scalar, y1: Scalar, x2: Scalar, y2: Scalar) {
        start = VectorT(x: x1, y: y1)
        end = VectorT(x: x2, y: y2)
    }
}

extension LineT where Scalar == Float {
    /// Returns the angle of this line, in radians
    @inlinable
    public var angle: Scalar {
        return (end - start).angle
    }
    
    /// Returns the magnitude of this line
    @inlinable
    public var magnitude: Scalar {
        return (end - start).magnitude
    }
}

extension LineT where Scalar == Double {
    /// Returns the angle of this line, in radians
    @inlinable
    public var angle: Scalar {
        return (end - start).angle
    }
    
    /// Returns the magnitude of this line
    @inlinable
    public var magnitude: Scalar {
        return (end - start).magnitude
    }
}
