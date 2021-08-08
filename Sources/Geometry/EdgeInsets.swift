public struct EdgeInsets: Equatable {
    public static let zero = EdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    public var top: Double
    public var left: Double
    public var bottom: Double
    public var right: Double
    
    public init(top: Double,
                left: Double,
                bottom: Double,
                right: Double) {
        
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }
    
    public init(_ value: Double) {
        top = value
        left = value
        bottom = value
        right = value
    }

    public func inset(rectangle: Rectangle) -> Rectangle {
        return rectangle.inset(self)
    }
}
