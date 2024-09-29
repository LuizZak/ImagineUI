public struct UIRoundRectangle: Hashable, Codable, Sendable {
    public typealias Scalar = UIRectangle.Scalar

    public static let zero: Self = .init()

    public var rectangle: UIRectangle
    public var radius: UIVector

    public var radiusX: Scalar {
        @_transparent
        get { radius.x }
        @_transparent
        set { radius.x = newValue }
    }

    public var radiusY: Scalar {
        @_transparent
        get { radius.y }
        @_transparent
        set { radius.y = newValue }
    }

    public init() {
        rectangle = .zero
        radius = .zero
    }

    @_transparent
    public init(rectangle: UIRectangle, radius: UIVector) {
        self.rectangle = rectangle
        self.radius = radius
    }

    public init(rectangle: UIRectangle, radiusX: Scalar, radiusY: Scalar) {
        self.init(rectangle: rectangle, radius: .init(x: radiusX, y: radiusY))
    }

    public init(location: UIPoint, size: UISize, radiusX: Scalar, radiusY: Scalar) {
        self.init(
            rectangle: .init(location: location, size: size),
            radius: .init(x: radiusX, y: radiusY)
        )
    }

    public init(x: Scalar, y: Scalar, width: Scalar, height: Scalar, radiusX: Scalar, radiusY: Scalar) {
        self.init(
            rectangle: .init(x: x, y: y, width: width, height: height),
            radius: .init(x: radiusX, y: radiusY)
        )
    }

    public init(left: Scalar, top: Scalar, right: Scalar, bottom: Scalar, radiusX: Scalar, radiusY: Scalar) {
        self.init(
            rectangle: .init(left: left, top: top, right: right, bottom: bottom),
            radius: .init(x: radiusX, y: radiusY)
        )
    }
}

public extension UIRoundRectangle {
    var location: UIPoint {
        @inlinable
        get { rectangle.location }
        @inlinable
        set { rectangle.location = newValue }
    }

    var size: UISize {
        @inlinable
        get { rectangle.size }
        @inlinable
        set { rectangle.size = newValue }
    }

    @inlinable
    var center: UIPoint {
        rectangle.center
    }

    @inlinable
    var centerX: Scalar {
        rectangle.centerX
    }

    @inlinable
    var centerY: Scalar {
        rectangle.centerY
    }

    @inlinable
    var width: Scalar {
        rectangle.width
    }

    @inlinable
    var height: Scalar {
        rectangle.height
    }

    var left: Scalar {
        get { rectangle.left }
        set { rectangle.left = newValue }
    }

    var top: Scalar {
        get { rectangle.top }
        set { rectangle.top = newValue }
    }

    var right: Scalar {
        get { rectangle.right }
        set { rectangle.right = newValue }
    }

    var bottom: Scalar {
        get { rectangle.bottom }
        set { rectangle.bottom = newValue }
    }

    var minimum: UIPoint {
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

    var maximum: UIPoint {
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
    var area: Scalar {
        width * height
    }

    /// Gets the top-left-most coordinate of this round rectangle.
    ///
    /// Note that this does not take in consideration the rounded corner itself,
    /// only the rectangle's maximal area.
    @_transparent
    var topLeft: UIPoint {
        .init(x: left, y: top)
    }

    /// Gets the top-right-most coordinate of this round rectangle.
    ///
    /// Note that this does not take in consideration the rounded corner itself,
    /// only the rectangle's maximal area.
    @_transparent
    var topRight: UIPoint {
        .init(x: right, y: top)
    }

    /// Gets the bottom-left-most coordinate of this round rectangle.
    ///
    /// Note that this does not take in consideration the rounded corner itself,
    /// only the rectangle's maximal area.
    @_transparent
    var bottomLeft: UIPoint {
        .init(x: left, y: bottom)
    }

    /// Gets the bottom-right-most coordinate of this round rectangle.
    ///
    /// Note that this does not take in consideration the rounded corner itself,
    /// only the rectangle's maximal area.
    @_transparent
    var bottomRight: UIPoint {
        .init(x: right, y: bottom)
    }
}

public extension UIRoundRectangle {
    /// Returns the rectangle whose bounds cover the non-rounded regions of this
    /// round rectangle.
    ///
    /// The rounded corners of this round rectangle are centered around each
    /// corner of this rectangle.
    func innerRectangle() -> UIRectangle {
        rectangle.insetBy(radius * 2)
    }

    @inlinable
    func contains(_ point: UIPoint) -> Bool {
        guard rectangle.contains(point) else {
            return false
        }

        let scale = radius.normalized()
        let invScale = 1 / scale
        var radiusSquared = radiusX * radiusX
        var point = point
        var inner = innerRectangle()

        // If the rounded rectangle has non-circular rounds, circularize the
        // problem before querying the circularized case
        if radiusX != radiusY {
            point = point.scaledBy(invScale, around: rectangle.topLeft)
            inner.location = inner.location.scaledBy(invScale, around: rectangle.topLeft)
            inner.size *= invScale.asUISize
            radiusSquared = self.radius.scaledBy(invScale, around: .zero).x
            radiusSquared *= radiusSquared
        }

        let clamped = inner.clamp(point)
        let clampedDistanceSquared = clamped.distanceSquared(to: point)

        return clampedDistanceSquared <= radiusSquared
    }
}

// MARK: Edge / Center Moving

public extension UIRoundRectangle {
    /// Returns a new rectangle with the same size as the current instance,
    /// where the center of the boundaries lay on `center`.
    @_transparent
    func movingCenter(to center: UIPoint) -> Self {
        Self(location: center - size.asUIPoint / 2, size: size, radiusX: radiusX, radiusY: radiusY)
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

    /// Returns a new Round Rectangle with the same left, right, and height as the
    /// current instance, where the `top` lays on `value`.
    ///
    /// The final rectangle is only translated, and not resized.
    @_transparent
    func movingTop(to value: Scalar) -> Self {
        Self(x: left, y: value, width: width, height: height, radiusX: radiusX, radiusY: radiusY)
    }

    /// Returns a new Round Rectangle with the same top, bottom, and width as the
    /// current instance, where the `left` lays on `value`.
    ///
    /// The final rectangle is only translated, and not resized.
    @_transparent
    func movingLeft(to value: Scalar) -> Self {
        Self(x: value, y: top, width: width, height: height, radiusX: radiusX, radiusY: radiusY)
    }
    /// Returns a new Round Rectangle with the same top, bottom, and width as the
    /// current instance, where the `right` lays on `value`.
    ///
    /// The final rectangle is only translated, and not resized.
    @inlinable
    func movingRight(to value: Scalar) -> Self {
        Self(left: value - width, top: top, right: value, bottom: bottom, radiusX: radiusX, radiusY: radiusY)
    }

    /// Returns a new Round Rectangle with the same left, right, and height as the
    /// current instance, where the `bottom` lays on `value`.
    ///
    /// The final rectangle is only translated, and not resized.
    @inlinable
    func movingBottom(to value: Scalar) -> Self {
        Self(left: left, top: value - height, right: right, bottom: value, radiusX: radiusX, radiusY: radiusY)
    }

    /// Returns a new Round Rectangle with the same top, bottom, and right as the
    /// current instance, where the `left` lays on `value`.
    ///
    /// Can be used to move the left edge of the rectangle while keeping the top,
    /// right, and bottom fixed in their current position by changing the width
    /// of the rectangle.
    @inlinable
    func stretchingLeft(to value: Scalar) -> Self {
        Self(left: value, top: top, right: right, bottom: bottom, radiusX: radiusX, radiusY: radiusY)
    }

    /// Returns a new Round Rectangle with the same left, right, and bottom as the
    /// current instance, where the `top` lays on `value`.
    ///
    /// Can be used to move the top edge of the rectangle while keeping the left,
    /// right, and bottom fixed in their current position by changing the height
    /// of the rectangle.
    @inlinable
    func stretchingTop(to value: Scalar) -> Self {
        Self(left: left, top: value, right: right, bottom: bottom, radiusX: radiusX, radiusY: radiusY)
    }

    /// Returns a new Round Rectangle with the same top, bottom, and left as the
    /// current instance, where the `right` lays on `value`.
    ///
    /// Can be used to move the right edge of the rectangle while keeping the top,
    /// left, and bottom fixed in their current position by changing the width
    /// of the rectangle.
    @inlinable
    func stretchingRight(to value: Scalar) -> Self {
        Self(left: left, top: top, right: value, bottom: bottom, radiusX: radiusX, radiusY: radiusY)
    }

    /// Returns a new Round Rectangle with the same left, right, and top as the
    /// current instance, where the `bottom` lays on `value`.
    ///
    /// Can be used to move the bottom edge of the rectangle while keeping the
    /// top, left, and right fixed in their current position by changing the
    /// height of the rectangle.
    @inlinable
    func stretchingBottom(to value: Scalar) -> Self {
        Self(left: left, top: top, right: right, bottom: value, radiusX: radiusX, radiusY: radiusY)
    }

    /// Insets this Round Rectangle with a given set of edge inset values.
    @inlinable
    func inset(_ inset: UIEdgeInsets) -> Self {
        Self(
            left: left + inset.left,
            top: top + inset.top,
            right: right - inset.right,
            bottom: bottom - inset.bottom,
            radiusX: radiusX,
            radiusY: radiusY
        )
    }
}
