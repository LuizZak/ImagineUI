import SwiftBezier

extension UIPoint: ConstructibleBezier2PointType {
    public func transposed(along line: LinearBezier2<Self>) -> Self {
        (line.p0 - self).rotated(by: -(line.p0 - line.p1).angle())
    }
}
