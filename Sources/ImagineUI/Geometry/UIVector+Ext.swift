import Geometry

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
