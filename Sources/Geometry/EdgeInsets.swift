public typealias EdgeInsets = EdgeInsetsT<Double>

public struct EdgeInsetsT<T: VectorScalar>: Equatable {
    public static var zero: Self { EdgeInsetsT(top: 0, left: 0, bottom: 0, right: 0) }

    public var top: T
    public var left: T
    public var bottom: T
    public var right: T
    
    public init(top: T,
                left: T,
                bottom: T,
                right: T) {
        
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }
    
    public init(_ value: T) {
        top = value
        left = value
        bottom = value
        right = value
    }

    public func inset(rectangle: RectangleT<T>) -> RectangleT<T> {
        return rectangle.inset(self)
    }
}
