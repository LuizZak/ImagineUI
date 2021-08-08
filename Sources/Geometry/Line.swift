/// Describes a line as a pair of start and end positions
public struct Line: Equatable, Codable {
    public var start: Vector2
    public var end: Vector2
    
    /// Returns the angle of this line, in radians
    @inlinable
    public var angle: Double {
        return (end - start).angle
    }
    
    /// Returns the magnitude of this line
    @inlinable
    public var magnitude: Double {
        return (end - start).magnitude
    }
    
    @inlinable
    public init(start: Vector2, end: Vector2) {
        self.start = start
        self.end = end
    }
    
    @inlinable
    public init(x1: Double, y1: Double, x2: Double, y2: Double) {
        start = Vector2(x: x1, y: y1)
        end = Vector2(x: x2, y: y2)
    }
}
