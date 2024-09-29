/// A 2D rectangle with integer coordinates and size
public struct UIIntRectangle: Hashable, Codable, Sendable {
    public typealias Scalar = Int

    public static let zero: Self = .init()

    public var location: UIIntPoint
    public var size: UIIntSize

    public var x: Scalar {
        @_transparent
        get {
            location.x
        }
        @_transparent
        set {
            location.x = newValue
        }
    }
    public var y: Scalar {
        @_transparent
        get {
            location.y
        }
        @_transparent
        set {
            location.y = newValue
        }
    }

    public var width: Scalar {
        @_transparent
        get {
            size.width
        }
        @_transparent
        set {
            size.width = newValue
        }
    }

    public var height: Scalar {
        @_transparent
        get {
            size.height
        }
        @_transparent
        set {
            size.height = newValue
        }
    }

    /// Gets or sets the center point of this rectangle.
    ///
    /// When assigning the center of a rectangle, the size remains unchanged
    /// while the coordinates of the UIPoints change to position the rectangle's
    /// center on the provided coordinates.
    public var center: UIIntPoint {
        @_transparent
        get { location + size.asUIIntPoint / 2 }
        @_transparent
        set { self = self.movingCenter(to: newValue) }
    }

    /// Gets or sets the center X position of this Rectangle.
    public var centerX: Scalar {
        @_transparent
        get {
            center.x
        }
        @_transparent
        set {
            center.x = newValue
        }
    }

    /// Gets or sets the center Y position of this Rectangle.
    public var centerY: Scalar {
        @_transparent
        get {
            center.y
        }
        @_transparent
        set {
            center.y = newValue
        }
    }

    @_transparent public var left: Scalar { x }
    @_transparent public var top: Scalar { y }
    @_transparent public var right: Scalar { left + width }
    @_transparent public var bottom: Scalar { top + height }

    public var minimum: UIIntPoint {
        @_transparent
        get {
            location
        }
        @_transparent
        set {
            let diff = newValue - minimum

            location = newValue
            size -= diff.asUIIntSize
        }
    }

    public var maximum: UIIntPoint {
        @_transparent
        get {
            location + size.asUIIntPoint
        }
        @_transparent
        set {
            size = (newValue - location).asUIIntSize
        }
    }

    @_transparent
    public var topLeft: UIIntPoint {
        .init(x: left, y: top)
    }

    @_transparent
    public var topRight: UIIntPoint {
        .init(x: right, y: top)
    }

    @_transparent
    public var bottomLeft: UIIntPoint {
        .init(x: left, y: bottom)
    }

    @_transparent
    public var bottomRight: UIIntPoint {
        .init(x: right, y: bottom)
    }

    public init() {
        location = .zero
        size = .zero
    }

    @_transparent
    public init(location: UIIntPoint, size: UIIntSize) {
        self.location = location
        self.size = size
    }

    @_transparent
    public init(minimum: UIIntPoint, maximum: UIIntPoint) {
        self.init(location: minimum, size: (maximum - minimum).asUIIntSize)
    }

    @_transparent
    public init(x: Scalar, y: Scalar, width: Scalar, height: Scalar) {
        self.init(location: .init(x: x, y: y),
                  size: .init(width: width, height: height))
    }

    @_transparent
    public init(left: Scalar, top: Scalar, right: Scalar, bottom: Scalar) {
        self.init(minimum: .init(x: left, y: top),
                  maximum: .init(x: right, y: bottom))
    }

    @_transparent
    public func withLocation(_ point: UIIntPoint) -> Self {
        .init(location: point, size: size)
    }

    @_transparent
    public func withSize(_ size: UIIntSize) -> Self {
        .init(location: location, size: size)
    }

    /// Returns a rectangle that matches this rectangle's size with a new
    /// location.
    @_transparent
    public func withLocation(x: Scalar, y: Scalar) -> Self {
        withLocation(.init(x: x, y: y))
    }

    /// Returns a Rectangle that matches this rectangle's size with a new
    /// location.
    @_transparent
    public func withSize(width: Scalar, height: Scalar) -> Self {
        withSize(.init(width: width, height: height))
    }
}

// MARK: Offset / Resize / Expansion

public extension UIIntRectangle {
    @_transparent
    func offsetBy(_ point: UIIntPoint) -> Self {
        .init(location: location + point, size: size)
    }

    @_transparent
    func offsetBy(x: Scalar, y: Scalar) -> Self {
        offsetBy(.init(x: x, y: y))
    }

    @_transparent
    func inflatedBy(_ size: UIIntPoint) -> Self {
        Self(location: location - size / 2, size: self.size + size.asUIIntSize)
    }

    @_transparent
    func inflatedBy(x: Scalar, y: Scalar) -> Self {
        inflatedBy(.init(x: x, y: y))
    }

    @_transparent
    func inflatedBy(_ value: Scalar) -> Self {
        inflatedBy(.init(repeating: value))
    }

    @_transparent
    func insetBy(_ size: UIIntPoint) -> Self {
        Self(location: location + size / 2, size: self.size - size.asUIIntSize)
    }

    @_transparent
    func insetBy(x: Scalar, y: Scalar) -> Self {
        insetBy(.init(x: x, y: y))
    }

    @_transparent
    func insetBy(_ value: Scalar) -> Self {
        insetBy(.init(repeating: value))
    }

    @_transparent
    mutating func expand(toInclude point: UIIntPoint) {
        minimum = UIIntPoint.pointwiseMin(minimum, point)
        maximum = UIIntPoint.pointwiseMax(maximum, point)
    }

    @inlinable
    mutating func expand<S: Sequence>(toInclude points: S) where S.Element == UIIntPoint {
        for p in points {
            expand(toInclude: p)
        }
    }
}

// MARK: Edge / Center Moving

public extension UIIntRectangle {
    /// Returns a new rectangle with the same size as the current instance,
    /// where the center of the boundaries lay on `center`.
    @_transparent
    func movingCenter(to center: UIIntPoint) -> Self {
        Self(location: center - size.asUIIntPoint / 2, size: size)
    }

    @_transparent
    func movingCenter(toX x: Scalar, y: Scalar) -> Self {
        movingCenter(to: .init(x: x, y: y))
    }

    /// Returns a new Rectangle with the same left, right, and height as the current
    /// instance, where the `top` lays on `value`.
    @_transparent
    func movingTop(to value: Scalar) -> Self {
        Self(x: left, y: value, width: width, height: height)
    }

    /// Returns a new Rectangle with the same top, bottom, and width as the current
    /// instance, where the `left` lays on `value`.
    @_transparent
    func movingLeft(to value: Scalar) -> Self {
        Self(x: value, y: top, width: width, height: height)
    }
    /// Returns a new Rectangle with the same top, bottom, and width as the current
    /// instance, where the `right` lays on `value`.
    @inlinable
    func movingRight(to value: Scalar) -> Self {
        Self(left: value - width, top: top, right: value, bottom: bottom)
    }

    /// Returns a new Rectangle with the same left, right, and height as the current
    /// instance, where the `bottom` lays on `value`.
    @inlinable
    func movingBottom(to value: Scalar) -> Self {
        Self(left: left, top: value - height, right: right, bottom: value)
    }

    /// Returns a new Rectangle with the same top, bottom, and right as the current
    /// instance, where the `left` lays on `value`.
    @inlinable
    func stretchingLeft(to value: Scalar) -> Self {
        Self(left: value, top: top, right: right, bottom: bottom)
    }

    /// Returns a new Rectangle with the same left, right, and bottom as the current
    /// instance, where the `top` lays on `value`.
    @inlinable
    func stretchingTop(to value: Scalar) -> Self {
        Self(left: left, top: value, right: right, bottom: bottom)
    }

    /// Returns a new Rectangle with the same top, bottom, and left as the current
    /// instance, where the `right` lays on `value`.
    @inlinable
    func stretchingRight(to value: Scalar) -> Self {
        Self(left: left, top: top, right: value, bottom: bottom)
    }

    /// Returns a new Rectangle with the same left, right, and top as the current
    /// instance, where the `bottom` lays on `value`.
    @inlinable
    func stretchingBottom(to value: Scalar) -> Self {
        Self(left: left, top: top, right: right, bottom: value)
    }
}

// MARK: Containment Checks

public extension UIIntRectangle {
    @_transparent
    func contains(x: Scalar, y: Scalar) -> Bool {
        contains(.init(x: x, y: y))
    }

    @_transparent
    func clamp(_ point: UIIntPoint) -> UIIntPoint {
        UIIntPoint.pointwiseMax(minimum, UIIntPoint.pointwiseMin(maximum, point))
    }

    @_transparent
    func contains(_ point: UIIntPoint) -> Bool {
        point >= minimum && point <= maximum
    }

    @_transparent
    func contains(_ rect: Self) -> Bool {
        rect.minimum >= minimum && rect.maximum <= maximum
    }

    @_transparent
    func intersects(_ other: Self) -> Bool {
        minimum <= other.maximum && maximum >= other.minimum
    }
}

// MARK: Operations

public extension UIIntRectangle {
    @_transparent
    func union(_ other: Self) -> Self {
        Self.union(self, other)
    }

    @inlinable
    func intersection(_ other: Self) -> Self? {
        Self.intersect(self, other)
    }

    @_transparent
    static func union(_ left: Self, _ right: Self) -> Self {
        Self(minimum: UIIntPoint.pointwiseMin(left.minimum, right.minimum),
             maximum: UIIntPoint.pointwiseMax(left.maximum, right.maximum))
    }

    @inlinable
    static func intersect(_ a: Self, _ b: Self) -> Self? {
        let x1 = max(a.left, b.left)
        let x2 = min(a.right, b.right)
        let y1 = max(a.top, b.top)
        let y2 = min(a.bottom, b.bottom)

        if x2 >= x1 && y2 >= y1 {
            return Self(left: x1, top: y1, right: x2, bottom: y2)
        }

        return nil
    }
}
