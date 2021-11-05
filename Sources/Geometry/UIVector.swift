import Foundation

public typealias UIVector = UIPoint

public extension UIVector {
    @_transparent
    func dot(_ other: Self) -> Scalar {
        x * other.x + y * other.y
    }

    @_transparent
    func length() -> Scalar {
        dot(self)
    }

    @_transparent
    func normalized() -> Self {
        let l = length()
        if l == 0 {
            return .zero
        }

        return self / l
    }

    @inlinable
    func rotated(by angleInRadians: Double) -> Self {
        let c = cos(angleInRadians)
        let s = sin(angleInRadians)

        return Self(x: (c * x) - (s * y), y: (s * x) + (c * y))
    }

    @inlinable
    func rotated(by angleInRadians: Double, around center: UIPoint) -> Self {
        return (self - center).rotated(by: angleInRadians) + center
    }

    @_transparent
    static func * (lhs: Self, rhs: UIMatrix) -> Self {
        rhs.transform(lhs)
    }

    @_transparent
    static func *= (lhs: inout Self, rhs: UIMatrix) {
        lhs = lhs * rhs
    }
}
