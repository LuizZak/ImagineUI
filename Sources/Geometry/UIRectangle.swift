/// A 2D rectangle with double-precision floating-point coordinates and size
public struct UIRectangle: Hashable, Codable {
    public typealias Scalar = Double

    public static let zero: Self = .init()

    public var location: UIPoint
    public var size: UISize

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
    public var center: UIPoint {
        @_transparent
        get { location + size.asUIPoint / 2 }
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

    public var left: Scalar {
        @_transparent
        get {
            x
        }
        @_transparent
        set {
            x = newValue
        }
    }
    public var top: Scalar {
        @_transparent
        get {
            y
        }
        @_transparent
        set {
            y = newValue
        }
    }
    public var right: Scalar {
        @_transparent
        get {
            left + width
        }
        @_transparent
        set {
            width = newValue - left
        }
    }
    public var bottom: Scalar {
        @_transparent
        get {
            top + height
        }
        @_transparent
        set {
            height = newValue - top
        }
    }

    public var minimum: UIPoint {
        @_transparent
        get {
            location
        }
        @_transparent
        set {
            let diff = newValue - minimum

            location = newValue
            size -= diff.asUISize
        }
    }

    public var maximum: UIPoint {
        @_transparent
        get {
            location + size.asUIPoint
        }
        @_transparent
        set {
            size = (newValue - location).asUISize
        }
    }

    @_transparent
    public var area: Scalar {
        width * height
    }

    @_transparent
    public var topLeft: UIPoint {
        .init(x: left, y: top)
    }

    @_transparent
    public var topRight: UIPoint {
        .init(x: right, y: top)
    }

    @_transparent
    public var bottomLeft: UIPoint {
        .init(x: left, y: bottom)
    }

    @_transparent
    public var bottomRight: UIPoint {
        .init(x: right, y: bottom)
    }

    public init() {
        location = .zero
        size = .zero
    }

    @_transparent
    public init(location: UIPoint, size: UISize) {
        self.location = location
        self.size = size
    }

    @_transparent
    public init(minimum: UIPoint, maximum: UIPoint) {
        self.init(location: minimum, size: (maximum - minimum).asUISize)
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
    public func withLocation(_ point: UIPoint) -> Self {
        .init(location: point, size: size)
    }

    @_transparent
    public func withSize(_ size: UISize) -> Self {
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

    @_transparent
    public func makeRoundedRectangle(radius: Scalar) -> UIRoundRectangle {
        makeRoundedRectangle(radius: .init(repeating: radius))
    }

    @_transparent
    public func makeRoundedRectangle(radius: UIVector) -> UIRoundRectangle {
        .init(rectangle: self, radius: radius)
    }
}

// MARK: Offset / Resize / Expansion

public extension UIRectangle {
    @_transparent
    func offsetBy(x: Scalar, y: Scalar) -> Self {
        offsetBy(.init(x: x, y: y))
    }

    @_transparent
    func offsetBy(_ vector: UIVector) -> Self {
        .init(location: location + vector, size: size)
    }

    @_transparent
    func inflatedBy(_ size: UIVector) -> Self {
        Self(location: location - size / 2, size: self.size + size.asUISize)
    }

    @_transparent
    func insetBy(_ size: UIVector) -> Self {
        Self(location: location + size / 2, size: self.size - size.asUISize)
    }

    @_transparent
    func inflatedBy(x: Scalar, y: Scalar) -> Self {
        inflatedBy(.init(x: x, y: y))
    }

    @_transparent
    func insetBy(x: Scalar, y: Scalar) -> Self {
        insetBy(.init(x: x, y: y))
    }

    @_transparent
    func inflatedBy(_ value: Scalar) -> Self {
        inflatedBy(.init(repeating: value))
    }

    @_transparent
    func insetBy(_ value: Scalar) -> Self {
        insetBy(.init(repeating: value))
    }

    /// Returns a rectangle where each coordinate is rounded such that the rectangle
    /// with the maximal possible bounds is returned.
    @_transparent
    func roundedToLargest() -> Self {
        .init(location: location.rounded(.down), size: size.rounded(.up))
    }

    @_transparent
    mutating func expand(toInclude point: UIPoint) {
        minimum = UIPoint.pointwiseMin(minimum, point)
        maximum = UIPoint.pointwiseMax(maximum, point)
    }

    @inlinable
    mutating func expand<S: Sequence>(toInclude points: S) where S.Element == UIPoint {
        for p in points {
            expand(toInclude: p)
        }
    }

    init<S: Sequence>(boundsFor points: S) where S.Element == UIPoint {
        var iterator = points.makeIterator()
        guard let first = iterator.next() else {
            self.init()
            return
        }

        self.init(minimum: first, maximum: first)

        while let next = iterator.next() {
            expand(toInclude: next)
        }
    }
}

// MARK: Edge / Center Moving

public extension UIRectangle {
    /// Returns a new rectangle with the same size as the current instance,
    /// where the center of the boundaries lay on `center`.
    @_transparent
    func movingCenter(to center: UIPoint) -> Self {
        Self(location: center - size.asUIPoint / 2, size: size)
    }

    /// Convenience for `self.movingCenter(to: UIPoint(x: x, y: y))`.
    @_transparent
    func movingCenter(toX x: Scalar, y: Scalar) -> Self {
        movingCenter(to: .init(x: x, y: y))
    }

    /// Returns a new rectangle with the same size as the current instance,
    /// where the center X of the boundaries lay on `center`.
    ///
    /// The final rectangle is only translated, and not resized.
    @_transparent
    func movingCenterX(to centerX: Scalar) -> Self {
        movingCenter(to: .init(x: centerX, y: center.y))
    }

    /// Returns a new rectangle with the same size as the current instance,
    /// where the center Y of the boundaries lay on `center`.
    ///
    /// The final rectangle is only translated, and not resized.
    @_transparent
    func movingCenterY(to centerY: Scalar) -> Self {
        movingCenter(to: .init(x: center.x, y: centerY))
    }

    /// Returns a new Rectangle with the same left, right, and height as the current
    /// instance, where the `top` lays on `value`.
    ///
    /// The final rectangle is only translated, and not resized.
    @_transparent
    func movingTop(to value: Scalar) -> Self {
        Self(x: left, y: value, width: width, height: height)
    }

    /// Returns a new Rectangle with the same top, bottom, and width as the current
    /// instance, where the `left` lays on `value`.
    ///
    /// The final rectangle is only translated, and not resized.
    @_transparent
    func movingLeft(to value: Scalar) -> Self {
        Self(x: value, y: top, width: width, height: height)
    }
    /// Returns a new Rectangle with the same top, bottom, and width as the current
    /// instance, where the `right` lays on `value`.
    ///
    /// The final rectangle is only translated, and not resized.
    @inlinable
    func movingRight(to value: Scalar) -> Self {
        Self(left: value - width, top: top, right: value, bottom: bottom)
    }

    /// Returns a new Rectangle with the same left, right, and height as the current
    /// instance, where the `bottom` lays on `value`.
    ///
    /// The final rectangle is only translated, and not resized.
    @inlinable
    func movingBottom(to value: Scalar) -> Self {
        Self(left: left, top: value - height, right: right, bottom: value)
    }

    /// Returns a new Rectangle with the same top, bottom, and right as the current
    /// instance, where the `left` lays on `value`.
    ///
    /// Can be used to move the left edge of the rectangle while keeping the top,
    /// right, and bottom fixed in their current position by changing the width
    /// of the rectangle.
    @inlinable
    func stretchingLeft(to value: Scalar) -> Self {
        Self(left: value, top: top, right: right, bottom: bottom)
    }

    /// Returns a new Rectangle with the same left, right, and bottom as the current
    /// instance, where the `top` lays on `value`.
    ///
    /// Can be used to move the top edge of the rectangle while keeping the left,
    /// right, and bottom fixed in their current position by changing the height
    /// of the rectangle.
    @inlinable
    func stretchingTop(to value: Scalar) -> Self {
        Self(left: left, top: value, right: right, bottom: bottom)
    }

    /// Returns a new Rectangle with the same top, bottom, and left as the current
    /// instance, where the `right` lays on `value`.
    ///
    /// Can be used to move the right edge of the rectangle while keeping the top,
    /// left, and bottom fixed in their current position by changing the width
    /// of the rectangle.
    @inlinable
    func stretchingRight(to value: Scalar) -> Self {
        Self(left: left, top: top, right: value, bottom: bottom)
    }

    /// Returns a new Rectangle with the same left, right, and top as the current
    /// instance, where the `bottom` lays on `value`.
    ///
    /// Can be used to move the bottom edge of the rectangle while keeping the
    /// top, left, and right fixed in their current position by changing the
    /// height of the rectangle.
    @inlinable
    func stretchingBottom(to value: Scalar) -> Self {
        Self(left: left, top: top, right: right, bottom: value)
    }

    /// Insets this Rectangle with a given set of edge inset values.
    @inlinable
    func inset(_ inset: UIEdgeInsets) -> Self {
        Self(left: left + inset.left,
             top: top + inset.top,
             right: right - inset.right,
             bottom: bottom - inset.bottom)
    }
}

// MARK: Containment Checks

public extension UIRectangle {
    @_transparent
    func contains(x: Scalar, y: Scalar) -> Bool {
        contains(.init(x: x, y: y))
    }

    @_transparent
    func clamp(_ point: UIPoint) -> UIPoint {
        UIPoint.pointwiseMax(minimum, UIPoint.pointwiseMin(maximum, point))
    }

    @_transparent
    func contains(_ point: UIPoint) -> Bool {
        point >= minimum && point <= maximum
    }

    /// Returns `true` if a given rectangle's area can be fully contained within
    /// this rectangle.
    ///
    /// Check is inclusive, so rectangle edges that match exactly are considered
    /// contained.
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

public extension UIRectangle {
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
        Self(minimum: UIPoint.pointwiseMin(left.minimum, right.minimum),
             maximum: UIPoint.pointwiseMax(left.maximum, right.maximum))
    }

    @_transparent
    static func union(_ first: Self, _ second: Self, _ remaining: Self...) -> Self {
        var result = first.union(second)

        for rect in remaining {
            result = result.union(rect)
        }

        return result
    }

    /// Returns the union of a sequence of rectangles.
    /// If the sequence is empty, `UIRectangle.zero` is returned.
    @_transparent
    static func union<S: Sequence>(_ rectangles: S) -> Self where S.Element == UIRectangle {
        var iterator = rectangles.makeIterator()

        var result: UIRectangle = iterator.next() ?? .zero

        while let next = iterator.next() {
            result = union(result, next)
        }

        return result
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

    @_transparent
    func transformedBounds(_ matrix: UIMatrix) -> Self {
        matrix.transform(self)
    }
}
