import Geometry

/// 2x2 transformation matrix used by `FontType`. It's similar to `Matrix2D`,
/// however, it doesn't provide a translation part as it's assumed to be zero.
public struct FontMatrix {
    public var m11: Double
    public var m12: Double
    public var m21: Double
    public var m22: Double
    
    public init(m11: Double, m12: Double, m21: Double, m22: Double) {
        self.m11 = m11
        self.m12 = m12
        self.m21 = m21
        self.m22 = m22
    }
    
    public func toMatrix2D() -> UIMatrix {
        return UIMatrix(m11: m11, m12: m12,
                        m21: m21, m22: m22,
                        m31: 0.0, m32: 0.0)
    }
    
    /// Transforms a given polygon by multiplying each coordinate by this matrix.
    @inlinable
    public func transform(_ polygon: [UIVector]) -> [UIVector] {
        return polygon.map(transform(_:))
    }
    
    @inlinable
    public func transform(_ point: UIVector) -> UIVector {
        return UIVector(x: point.x * m11 + point.y * m21,
                        y: point.x * m12 + point.y * m22)
    }
    
    /// Maps the corners of a given rectangle into a newer minimal rectangle
    /// capable of containing all four mapped points.
    @inlinable
    public func transform(_ rect: UIRectangle) -> UIRectangle {
        toMatrix2D().transform(rect)
    }
}
