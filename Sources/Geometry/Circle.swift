/// Represents a circle with a center point and radius
public struct Circle: Equatable, Codable {
    public var center: Vector2
    public var radius: Double
    
    public init(center: Vector2, radius: Double) {
        self.center = center
        self.radius = radius
    }
}
