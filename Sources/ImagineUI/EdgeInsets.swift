import SwiftBlend2D

public struct EdgeInsets: Equatable {
    public static let empty = EdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

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

    public func inset(rectangle: Rectangle) -> Rectangle {
        return rectangle.inset(self)
    }
    
    public func inset(rectangle: BLRect) -> BLRect {
        return BLRect(x: rectangle.x + left,
                      y: rectangle.y + top,
                      w: rectangle.w - left - right,
                      h: rectangle.h - top - bottom)
    }
}
