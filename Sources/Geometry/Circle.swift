public typealias Circle = CircleT<Double>

/// Represents a circle with a center point and radius
public struct CircleT<T: VectorScalar>: Equatable, Codable {
    public var center: VectorT<T>
    public var radius: T
    
    public init(center: VectorT<T>, radius: T) {
        self.center = center
        self.radius = radius
    }
    
    @inlinable
    public func expanded(by value: T) -> CircleT {
        return CircleT(center: center, radius: radius + value)
    }
    
    @inlinable
    public func contains(x: T, y: T) -> Bool {
        let dx = x - center.x
        let dy = y - center.y
        
        return dx * dx + dy * dy < radius * radius
    }
    
    @inlinable
    public func contains(_ point: VectorT<T>) -> Bool {
        return contains(x: point.x, y: point.y)
    }
}
