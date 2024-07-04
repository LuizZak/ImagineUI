import SwiftBezier

extension UIPoint: ConstructibleBezier2PointType {
    public func lerp(to end: UIPoint, factor: Double) -> UIPoint {
        Self.lerp(self, end, factor: factor)
    }

    public func transposed(along line: LinearBezier2<Self>) -> Self {
        (line.p0 - self).rotated(by: -(line.p0 - line.p1).angle())
    }

    public func leftRotated() -> UIPoint {
        Self(x: -y, y: x)
    }

    public func rightRotated() -> UIPoint {
        Self(x: y, y: -x)
    }
}
