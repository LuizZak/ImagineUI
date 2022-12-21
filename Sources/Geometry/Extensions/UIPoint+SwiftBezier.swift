import SwiftBezier

extension UIPoint: Bezier2PointType {
    public func lerp(to end: UIPoint, factor: Double) -> UIPoint {
        Self.lerp(self, end, factor: factor)
    }
}
