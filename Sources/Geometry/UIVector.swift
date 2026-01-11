import Foundation

public typealias UIVector = UIPoint

public extension UIVector {
    @inlinable
    func lerp(to end: UIPoint, factor: Double) -> UIPoint {
        Self.lerp(self, end, factor: factor)
    }

    @_transparent
    func dot(_ other: Self) -> Scalar {
        x * other.x + y * other.y
    }

    @_transparent
    func length() -> Scalar {
        lengthSquared().squareRoot()
    }

    @_transparent
    func lengthSquared() -> Scalar {
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

extension UIVector {
    @_transparent
    public mutating func formPerpendicular() {
        self = perpendicular()
    }

    @_transparent
    public func perpendicular() -> Self {
        Self(x: -y, y: x)
    }

    @_transparent
    public func leftRotated() -> Self {
        Self(x: -y, y: x)
    }

    @_transparent
    public mutating func formLeftRotated() {
        self = leftRotated()
    }

    @_transparent
    public func rightRotated() -> Self {
        Self(x: y, y: -x)
    }

    @_transparent
    public mutating func formRightRotated() {
        self = rightRotated()
    }
}
