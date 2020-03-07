/// Represents an axis-aligned bounding box
public struct Rectangle: Equatable, Codable {
    /// Returns an empty rectangle
    public static let zero = Rectangle(x: 0, y: 0, width: 0, height: 0)
    
    /// Minimum point for this rectangle.
    public var minimum: Vector2 {
        get { return Vector2(x: x, y: y) }
        set {
            let diff = newValue - minimum
            
            (x, y) = (newValue.x, newValue.y)
            (width, height) = (width - diff.x, height - diff.y)
        }
    }
    
    /// Maximum point for this rectangle.
    public var maximum: Vector2 {
        get { return Vector2(x: right, y: bottom) }
        set {
            width = newValue.x - x
            height = newValue.y - y
        }
    }
    
    /// Gets the X position of this Rectangle
    public var x: Double
    /// Gets the Y position of this Rectangle
    public var y: Double
    
    /// Gets the width of this Rectangle.
    ///
    /// When setting this value, `width` must always be `>= 0`
    public var width: Double
    
    /// Gets the height of this Rectangle
    ///
    /// When setting this value, `height` must always be `>= 0`
    public var height: Double

    public var size: Vector2 {
        get {
            return Vector2(x: width, y: height)
        }
        set {
            maximum = minimum + newValue
        }
    }
    
    /// Gets the middle X position of this Rectangle
    @inlinable
    public var midX: Double {
        return (left + right) / 2
    }
    /// Gets the middle Y position of this Rectangle
    @inlinable
    public var midY: Double {
        return (top + bottom) / 2
    }

    @inlinable
    public var center: Vector2 {
        return (topLeft + bottomRight) / 2
    }

    /// Returns true iff this Rectangle's area is empty (i.e. `width == 0 && height == 0`).
    public var isEmpty: Bool {
        return width == 0 && height == 0
    }

    /// The y coordinate of the top corner of this rectangle.
    ///
    /// Alias for `y`
    @inlinable
    public var top: Double { y }

    /// The x coordinate of the left corner of this rectangle.
    ///
    /// Alias for `x`
    @inlinable
    public var left: Double { x }

    /// The x coordinate of the right corner of this rectangle.
    ///
    /// Alias for `x + width`
    @inlinable
    public var right: Double { x + width }

    /// The y coordinate of the bottom corner of this rectangle.
    ///
    /// Alias for `y + height`
    @inlinable
    public var bottom: Double { y + height }
    
    @inlinable
    public var topLeft: Vector2 {
        return Vector2(x: left, y: top)
    }

    @inlinable
    public var topRight: Vector2 {
        return Vector2(x: right, y: top)
    }

    @inlinable
    public var bottomLeft: Vector2 {
        return Vector2(x: left, y: bottom)
    }

    @inlinable
    public var bottomRight: Vector2 {
        return Vector2(x: right, y: bottom)
    }
    
    /// Returns an array of vectors that represent this `Rectangle`'s corners in
    /// clockwise order, starting from the top-left corner.
    ///
    /// Always contains 4 elements.
    public var corners: [Vector2] {
        return [topLeft, topRight, bottomRight, bottomLeft]
    }
    
    /// Initializes an empty Rectangle instance
    @inlinable
    public init() {
        x = 0
        y = 0
        width = 0
        height = 0
    }
    
    /// Initializes a Rectangle containing the minimum area capable of containing
    /// all supplied points.
    ///
    /// If no points are supplied, an empty Rectangle is created instead.
    @inlinable
    public init(of points: Vector2...) {
        self = Rectangle(points: points)
    }
    
    /// Initializes a Rectangle instance out of the given minimum and maximum
    /// coordinates.
    /// The coordinates are not checked for ordering, and will be directly
    /// assigned to `minimum` and `maximum` properties.
    @inlinable
    public init(min: Vector2, max: Vector2) {
        (x, y) = (min.x, min.y)
        width = max.x - min.x
        height = max.y - min.y
    }

    /// Initializes a Rectangle with the coordinates of a rectangle
    @inlinable
    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    /// Initializes a Rectangle with the location + size of a rectangle
    @inlinable
    public init(location: Vector2, size: Vector2) {
        self.init(min: location, max: location + size)
    }

    /// Initializes a Rectangle with the corners of a rectangle
    @inlinable
    public init(left: Double, top: Double, right: Double, bottom: Double) {
        self.init(x: left, y: top, width: right - left, height: bottom - top)
    }

    /// Initializes a Rectangle with the coordinates of a rectangle
    @inlinable
    public init(x: Int, y: Int, width: Int, height: Int) {
        self.init(x: Double(x), y: Double(y), width: Double(width), height: Double(height))
    }
    
    /// Initializes a Rectangle out of a set of points, expanding to the
    /// smallest bounding box capable of fitting each point.
    public init<C: Collection>(points: C) where C.Element == Vector2 {
        guard let first = points.first else {
            x = 0
            y = 0
            width = 0
            height = 0
            return
        }
        
        x = first.x
        y = first.y
        width = 0
        height = 0
        
        expand(toInclude: points)
    }
    
    /// Expands the bounding box of this Rectangle to include the given point.
    public mutating func expand(toInclude point: Vector2) {
        minimum = min(minimum, point)
        maximum = max(maximum, point)
    }
    
    /// Expands the bounding box of this Rectangle to include the given set of
    /// points.
    ///
    /// Same as calling `expand(toInclude:Vector2)` over each point.
    /// If the array is empty, nothing is done.
    public mutating func expand<C: Collection>(toInclude points: C) where C.Element == Vector2 {
        for p in points {
            minimum = min(minimum, p)
            maximum = max(maximum, p)
        }
    }
    
    /// Returns whether a given point is contained within this bounding box.
    /// The check is inclusive, so the edges of the bounding box are considered
    /// to contain the point as well.
    @inlinable
    public func contains(_ point: Vector2) -> Bool {
        return point >= minimum && point <= maximum
    }

    /// Returns whether a given Rectangle rests completely inside the boundaries
    /// of this Rectangle.
    @inlinable
    public func contains(rectangle: Rectangle) -> Bool {
        return rectangle.minimum >= minimum && rectangle.maximum <= maximum
    }
    
    /// Returns whether this Rectangle intersects the given Rectangle instance.
    /// This check is inclusive, so the edges of the bounding box are considered
    /// to intersect the other bounding box's edges as well.
    @inlinable
    public func intersects(_ box: Rectangle) -> Bool {
        return minimum <= box.maximum && maximum >= box.minimum
    }

    /// Returns a Rectangle that matches this Rectangle's size with a new location
    @inlinable
    public func withLocation(_ location: Vector2) -> Rectangle {
        return Rectangle(location: location, size: size)
    }

    /// Returns a rectangle that matches this Rectangle's size with a new location
    @inlinable
    public func withLocation(x: Double, y: Double) -> Rectangle {
        return withLocation(Vector2(x: x, y: y))
    }

    /// Returns a Rectangle that matches this Rectangle's size with a new location
    @inlinable
    public func withSize(_ size: Vector2) -> Rectangle {
        return Rectangle(location: minimum, size: size)
    }

    /// Returns a Rectangle that matches this Rectangle's size with a new location
    @inlinable
    public func withSize(width: Double, height: Double) -> Rectangle {
        return withSize(Vector2(x: width, y: height))
    }

    /// Returns a Rectangle with the same position as this Rectangle, with its
    /// width and height multiplied by the coordinates of the given vector
    @inlinable
    public func scaledBy(vector: Vector2) -> Rectangle {
        return scaledBy(x: vector.x, y: vector.y)
    }

    /// Returns a Rectangle with the same position as this Rectangle, with its
    /// width and height multiplied by the coordinates of the given vector
    @inlinable
    public func scaledBy(x: Double, y: Double) -> Rectangle {
        return Rectangle(x: x, y: y, width: width * x, height: height * y)
    }

    /// Returns a copy of this Rectangle with the minimum and maximum coordinates
    /// offset by a given amount.
    @inlinable
    public func offsetBy(_ vector: Vector2) -> Rectangle {
        return Rectangle(min: minimum + vector, max: maximum + vector)
    }

    /// Returns a copy of this Rectangle with the minimum and maximum coordinates
    /// offset by a given amount.
    @inlinable
    public func offsetBy(x: Double, y: Double) -> Rectangle {
        return offsetBy(Vector2(x: x, y: y))
    }

    /// Returns a Rectangle which is an inflated version of this Rectangle
    /// (i.e. bounds are larger by `size`, but center remains the same)
    @inlinable
    public func inflatedBy(_ size: Vector2) -> Rectangle {
        if size == .zero {
            return self
        }
        
        return Rectangle(min: minimum - size / 2, max: maximum + size / 2)
    }

    /// Returns a Rectangle which is an inflated version of this Rectangle
    /// (i.e. bounds are larger by `size`, but center remains the same)
    @inlinable
    public func inflatedBy(x: Double, y: Double) -> Rectangle {
        return inflatedBy(Vector2(x: x, y: y))
    }

    /// Returns a Rectangle which is an inset version of this Rectangle
    /// (i.e. bounds are smaller by `size`, but center remains the same)
    @inlinable
    public func insetBy(_ size: Vector2) -> Rectangle {
        if size == .zero {
            return self
        }
        
        return Rectangle(min: minimum + size / 2, max: maximum - size / 2)
    }

    /// Returns a Rectangle which is an inset version of this Rectangle
    /// (i.e. bounds are smaller by `size`, but center remains the same)
    @inlinable
    public func insetBy(x: Double, y: Double) -> Rectangle {
        return insetBy(Vector2(x: x, y: y))
    }

    /// Returns a Rectangle which is the minimum Rectangle that can fit this
    /// Rectangle with another given Rectangle.
    @inlinable
    public func formUnion(_ other: Rectangle) -> Rectangle {
        return Rectangle.union(self, other)
    }

    /// Returns an `Rectangle` that is the intersection between this and another
    /// `Rectangle` instance.
    ///
    /// Result is an empty Rectangle if the two rectangles do not intersect
    @inlinable
    public func formIntersection(_ other: Rectangle) -> Rectangle {
        return Rectangle.intersect(self, other)
    }

    /// Applies the given Matrix on all corners of this Rectangle, returning a new
    /// minimal Rectangle capable of containing the transformed points.
    public func transformedBounds(_ matrix: Matrix2D) -> Rectangle {
        return matrix.transform(self)
    }

    /// Insets this Rectangle with a given set of edge inset values.
    public func inset(_ inset: EdgeInsets) -> Rectangle {
        return Rectangle(left: left + inset.left,
                         top: top + inset.top,
                         right: right - inset.right,
                         bottom: bottom - inset.bottom)
    }

    /// Returns a new Rectangle with the same left, right, and height as the current
    /// instance, where the `top` lays on `value`.
    public func movingTop(to value: Double) -> Rectangle {
        return Rectangle(left: left, top: value, right: right, bottom: value + height)
    }

    /// Returns a new Rectangle with the same left, right, and height as the current
    /// instance, where the `bottom` lays on `value`.
    public func movingBottom(to value: Double) -> Rectangle {
        return Rectangle(left: left, top: value - height, right: right, bottom: value)
    }

    /// Returns a new Rectangle with the same top, bottom, and width as the current
    /// instance, where the `left` lays on `value`.
    public func movingLeft(to value: Double) -> Rectangle {
        return Rectangle(left: value, top: top, right: value + width, bottom: bottom)
    }

    /// Returns a new Rectangle with the same top, bottom, and width as the current
    /// instance, where the `right` lays on `value`.
    public func movingRight(to value: Double) -> Rectangle {
        return Rectangle(left: value - width, top: top, right: value, bottom: bottom)
    }

    /// Returns a new Rectangle with the same width and height as the current
    /// instance, where the center of the boundaries lay on `center`
    public func movingCenter(to center: Vector2) -> Rectangle {
        return Rectangle(min: center - size / 2, max: center + size / 2)
    }

    /// Returns a new Rectangle with the same width and height as the current
    /// instance, where the center of the boundaries lay on the coordinates
    /// composed of `[x, y]`
    public func movingCenter(toX x: Double, y: Double) -> Rectangle {
        return movingCenter(to: Vector2(x: x, y: y))
    }

    /// Returns a Rectangle which is the minimum Rectangle that can fit two
    /// given Rectangles.
    @inlinable
    public static func union(_ left: Rectangle, _ right: Rectangle) -> Rectangle {
        return Rectangle(min: min(left.minimum, right.minimum), max: max(left.maximum, right.maximum))
    }

    /// Returns an `Rectangle` that is the intersection between two rectangle
    /// instances.
    ///
    /// Return is `zero`, if they do not intersect.
    @inlinable
    public static func intersect(_ a: Rectangle, _ b: Rectangle) -> Rectangle {
        let x1 = max(a.left, b.left)
        let x2 = min(a.right, b.right)
        let y1 = max(a.top, b.top)
        let y2 = min(a.bottom, b.bottom)

        if x2 >= x1 && y2 >= y1 {
            return Rectangle(left: x1, top: y1, right: x2, bottom: y2)
        }

        return .zero
    }
}

extension Rectangle: CustomStringConvertible {
    public var description: String {
        return "Rectangle(x: \(x), y: \(y), width: \(width), height: \(height))"
    }
}
