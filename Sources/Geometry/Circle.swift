/// Represents a circle with a center point and radius
public struct Circle: Equatable, Codable {
    public var center: Vector2
    public var radius: Double
    
    public init(center: Vector2, radius: Double) {
        self.center = center
        self.radius = radius
    }
    
    @inlinable
    public func expanded(by value: Double) -> Circle {
        return Circle(center: center, radius: radius + value)
    }
    
    @inlinable
    public func contains(x: Double, y: Double) -> Bool {
        let dx = x - center.x
        let dy = y - center.y
        
        return dx * dx + dy * dy < radius * radius
    }
    
    @inlinable
    public func contains(_ point: Vector2) -> Bool {
        return contains(x: point.x, y: point.y)
    }
}
