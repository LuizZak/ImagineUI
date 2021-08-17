public typealias Line = LineT<Double>

/// Describes a line as a pair of start and end positions
public struct LineT<T: VectorScalar>: Equatable, Codable {
    public var start: VectorT<T>
    public var end: VectorT<T>
    
    @inlinable
    public init(start: VectorT<T>, end: VectorT<T>) {
        self.start = start
        self.end = end
    }
    
    @inlinable
    public init(x1: T, y1: T, x2: T, y2: T) {
        start = VectorT(x: x1, y: y1)
        end = VectorT(x: x2, y: y2)
    }
}

extension LineT where T == Double {
    /// Returns the angle of this line, in radians
    @inlinable
    public var angle: T {
        return (end - start).angle
    }
    
    /// Returns the magnitude of this line
    @inlinable
    public var magnitude: T {
        return (end - start).magnitude
    }
}
