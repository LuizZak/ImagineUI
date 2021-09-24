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

    static func * (lhs: Self, rhs: UIMatrix) -> Self {
        rhs.transform(lhs)
    }

    static func *= (lhs: inout Self, rhs: UIMatrix) {
        lhs = lhs * rhs
    }
}
