/// A floating-point rectangle
public typealias Rectangle = RectangleT<Double>

/// Represents a rectangle
public struct RectangleT<T: VectorScalar>: Equatable, Codable {
    /// Returns an empty rectangle
    public static var zero: RectangleT { RectangleT(x: 0, y: 0, width: 0, height: 0) }
    
    /// Minimum point for this rectangle.
    public var minimum: Vector2 {
        get { return topLeft }
        set {
            let diff = newValue - minimum
            
            (x, y) = (newValue.x, newValue.y)
            (width, height) = (width - diff.x, height - diff.y)
        }
    }
    
    /// Maximum point for this rectangle.
    public var maximum: Vector2 {
        get { return bottomRight }
        set {
            width = newValue.x - x
            height = newValue.y - y
        }
    }
    
    /// The top-left location of this rectangle
    public var location: Vector2
    
    /// The size of this rectangle
    public var size: Size
    
    /// Gets the X position of this Rectangle
    @inlinable
    public var x: Double {
        get {
            return location.x
        }
        set {
            location.x = newValue
        }
    }
    
    /// Gets the Y position of this Rectangle
    @inlinable
    public var y: Double {
        get {
            return location.y
        }
        set {
            location.y = newValue
        }
    }
    
    /// Gets the width of this Rectangle.
    ///
    /// When setting this value, `width` must always be `>= 0`
    @inlinable
    public var width: Double {
        get {
            return size.x
        }
        set {
            size.x = newValue
        }
    }
    
    /// Gets the height of this Rectangle
    ///
    /// When setting this value, `height` must always be `>= 0`
    public var height: Double {
        get {
            return size.y
        }
        set {
            size.y = newValue
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
        get {
            return (topLeft + bottomRight) / 2
        }
        set {
            (x, y) = (newValue.x - width / 2, newValue.y - height / 2)
        }
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
    @inlinable
    public var corners: [Vector2] {
        return [topLeft, topRight, bottomRight, bottomLeft]
    }
    
    /// Initializes an empty Rectangle instance
    @inlinable
    public init() {
        location = .zero
        size = .zero
    }
    
    /// Initializes a Rectangle containing the minimum area capable of containing
    /// all supplied points.
    ///
    /// If no points are supplied, an empty Rectangle is created instead.
    @inlinable
    public init(of points: Vector2...) {
        self = RectangleT(points: points)
    }
    
    /// Initializes a Rectangle instance out of the given minimum and maximum
    /// coordinates.
    /// The coordinates are not checked for ordering, and will be directly
    /// assigned to `minimum` and `maximum` properties.
    @inlinable
    public init(min: Vector2, max: Vector2) {
        location = min
        size = max - min
    }
    
    /// Initializes a Rectangle with the coordinates of a rectangle
    @inlinable
    public init(x: Double, y: Double, width: Double, height: Double) {
        location = Vector2(x: x, y: y)
        size = Vector2(x: width, y: height)
    }
    
    /// Initializes a Rectangle with the location + size of a rectangle
    @inlinable
    public init(location: Vector2, size: Size) {
        self.location = location
        self.size = size
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
            location = .zero
            size = .zero
            return
        }
        
        location = first
        size = .zero
        
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
    public mutating func expand<S: Sequence>(toInclude points: S) where S.Element == Vector2 {
        for p in points {
            expand(toInclude: p)
        }
    }
    
    /// Returns whether a given point is contained within this bounding box.
    /// The check is inclusive, so the edges of the bounding box are considered
    /// to contain the point as well.
    @inlinable
    public func contains(x: Double, y: Double) -> Bool {
        return contains(Vector2(x: x, y: y))
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
    public func contains(rectangle: RectangleT) -> Bool {
        return rectangle.minimum >= minimum && rectangle.maximum <= maximum
    }
    
    /// Returns whether this Rectangle intersects the given Rectangle instance.
    /// This check is inclusive, so the edges of the bounding box are considered
    /// to intersect the other bounding box's edges as well.
    @inlinable
    public func intersects(_ box: RectangleT) -> Bool {
        return minimum <= box.maximum && maximum >= box.minimum
    }
    
    /// Returns a Rectangle that matches this Rectangle's size with a new location
    @inlinable
    public func withLocation(_ location: Vector2) -> RectangleT {
        return RectangleT(location: location, size: size)
    }
    
    /// Returns a rectangle that matches this Rectangle's size with a new location
    @inlinable
    public func withLocation(x: Double, y: Double) -> RectangleT {
        return withLocation(Vector2(x: x, y: y))
    }
    
    /// Returns a Rectangle that matches this Rectangle's size with a new location
    @inlinable
    public func withSize(_ size: Vector2) -> RectangleT {
        return RectangleT(location: minimum, size: size)
    }
    
    /// Returns a Rectangle that matches this Rectangle's size with a new location
    @inlinable
    public func withSize(width: Double, height: Double) -> RectangleT {
        return withSize(Vector2(x: width, y: height))
    }
    
    /// Returns a Rectangle with the same position as this Rectangle, with its
    /// width and height multiplied by the coordinates of the given vector
    @inlinable
    public func scaledBy(vector: Vector2) -> RectangleT {
        return scaledBy(x: vector.x, y: vector.y)
    }
    
    /// Returns a Rectangle with the same position as this Rectangle, with its
    /// width and height multiplied by the coordinates of the given vector
    @inlinable
    public func scaledBy(x: Double, y: Double) -> RectangleT {
        return RectangleT(x: x, y: y, width: width * x, height: height * y)
    }
    
    /// Returns a copy of this Rectangle with the minimum and maximum coordinates
    /// offset by a given amount.
    @inlinable
    public func offsetBy(_ vector: Vector2) -> RectangleT {
        return RectangleT(min: minimum + vector, max: maximum + vector)
    }
    
    /// Returns a copy of this Rectangle with the minimum and maximum coordinates
    /// offset by a given amount.
    @inlinable
    public func offsetBy(x: Double, y: Double) -> RectangleT {
        return offsetBy(Vector2(x: x, y: y))
    }
    
    /// Returns a Rectangle which is an inflated version of this Rectangle
    /// (i.e. bounds are larger by `size`, but center remains the same)
    @inlinable
    public func inflatedBy(_ size: Vector2) -> RectangleT {
        if size == .zero {
            return self
        }
        
        return RectangleT(min: minimum - size / 2, max: maximum + size / 2)
    }
    
    /// Returns a Rectangle which is an inflated version of this Rectangle
    /// (i.e. bounds are larger by `size`, but center remains the same)
    @inlinable
    public func inflatedBy(x: Double, y: Double) -> RectangleT {
        return inflatedBy(Vector2(x: x, y: y))
    }
    
    /// Returns a Rectangle which is an inset version of this Rectangle
    /// (i.e. bounds are smaller by `size`, but center remains the same)
    @inlinable
    public func insetBy(_ size: Vector2) -> RectangleT {
        if size == .zero {
            return self
        }
        
        return RectangleT(min: minimum + size / 2, max: maximum - size / 2)
    }
    
    /// Returns a Rectangle which is an inset version of this Rectangle
    /// (i.e. bounds are smaller by `size`, but center remains the same)
    @inlinable
    public func insetBy(x: Double, y: Double) -> RectangleT {
        return insetBy(Vector2(x: x, y: y))
    }
    
    /// Returns a Rectangle which is the minimum Rectangle that can fit this
    /// Rectangle with another given Rectangle.
    @inlinable
    public func formUnion(_ other: RectangleT) -> RectangleT {
        return RectangleT.union(self, other)
    }
    
    /// Returns an `Rectangle` that is the intersection between this and another
    /// `Rectangle` instance.
    ///
    /// Result is an empty Rectangle if the two rectangles do not intersect
    @inlinable
    public func formIntersection(_ other: RectangleT) -> RectangleT {
        return RectangleT.intersect(self, other)
    }
    
    /// Insets this Rectangle with a given set of edge inset values.
    public func inset(_ inset: EdgeInsets) -> RectangleT {
        return RectangleT(left: left + inset.left,
                         top: top + inset.top,
                         right: right - inset.right,
                         bottom: bottom - inset.bottom)
    }
    
    /// Returns a new Rectangle with the same left, right, and height as the current
    /// instance, where the `top` lays on `value`.
    public func movingTop(to value: Double) -> RectangleT {
        return RectangleT(left: left, top: value, right: right, bottom: value + height)
    }
    
    /// Returns a new Rectangle with the same left, right, and height as the current
    /// instance, where the `bottom` lays on `value`.
    public func movingBottom(to value: Double) -> RectangleT {
        return RectangleT(left: left, top: value - height, right: right, bottom: value)
    }
    
    /// Returns a new Rectangle with the same top, bottom, and width as the current
    /// instance, where the `left` lays on `value`.
    public func movingLeft(to value: Double) -> RectangleT {
        return RectangleT(left: value, top: top, right: value + width, bottom: bottom)
    }
    
    /// Returns a new Rectangle with the same top, bottom, and width as the current
    /// instance, where the `right` lays on `value`.
    public func movingRight(to value: Double) -> RectangleT {
        return RectangleT(left: value - width, top: top, right: value, bottom: bottom)
    }
    
    /// Returns a new Rectangle with the same width and height as the current
    /// instance, where the center of the boundaries lay on `center`
    public func movingCenter(to center: Vector2) -> RectangleT {
        return RectangleT(min: center - size / 2, max: center + size / 2)
    }
    
    /// Returns a new Rectangle with the same width and height as the current
    /// instance, where the center of the boundaries lay on the coordinates
    /// composed of `[x, y]`
    public func movingCenter(toX x: Double, y: Double) -> RectangleT {
        return movingCenter(to: Vector2(x: x, y: y))
    }
    
    /// Returns a new Rectangle with the same left, right, and bottom as the current
    /// instance, where the `top` lays on `value`.
    public func stretchingTop(to value: Double) -> RectangleT {
        return RectangleT(left: left, top: value, right: right, bottom: bottom)
    }
    
    /// Returns a new Rectangle with the same left, right, and top as the current
    /// instance, where the `bottom` lays on `value`.
    public func stretchingBottom(to value: Double) -> RectangleT {
        return RectangleT(left: left, top: top, right: right, bottom: value)
    }
    
    /// Returns a new Rectangle with the same top, bottom, and right as the current
    /// instance, where the `left` lays on `value`.
    public func stretchingLeft(to value: Double) -> RectangleT {
        return RectangleT(left: value, top: top, right: right, bottom: bottom)
    }
    
    /// Returns a new Rectangle with the same top, bottom, and left as the current
    /// instance, where the `right` lays on `value`.
    public func stretchingRight(to value: Double) -> RectangleT {
        return RectangleT(left: left, top: top, right: value, bottom: bottom)
    }
    
    /// Returns a Rectangle which is the minimum Rectangle that can fit two
    /// given Rectangles.
    @inlinable
    public static func union(_ left: RectangleT, _ right: RectangleT) -> RectangleT {
        return RectangleT(min: min(left.minimum, right.minimum), max: max(left.maximum, right.maximum))
    }
    
    /// Returns an `Rectangle` that is the intersection between two rectangle
    /// instances.
    ///
    /// Return is `zero`, if they do not intersect.
    @inlinable
    public static func intersect(_ a: RectangleT, _ b: RectangleT) -> RectangleT {
        let x1 = max(a.left, b.left)
        let x2 = min(a.right, b.right)
        let y1 = max(a.top, b.top)
        let y2 = min(a.bottom, b.bottom)
        
        if x2 >= x1 && y2 >= y1 {
            return RectangleT(left: x1, top: y1, right: x2, bottom: y2)
        }
        
        return .zero
    }
}

public extension RectangleT where T == Double {
    /// Applies the given Matrix on all corners of this Rectangle, returning a new
    /// minimal Rectangle capable of containing the transformed points.
    func transformedBounds(_ matrix: Matrix2D) -> RectangleT {
        return matrix.transform(self)
    }
}

extension RectangleT: CustomStringConvertible {
    public var description: String {
        return "\(type(of: self))(x: \(x), y: \(y), width: \(width), height: \(height))"
    }
}

public extension RectangleT {
    /// Returns a `RoundRectangle` which has the same bounds as this rectangle,
    /// with the given radius vector describing the dimensions of the corner arcs
    /// on the X and Y axis.
    func rounded(radius: VectorT<T>) -> RoundRectangleT<T> {
        return RoundRectangleT(bounds: self, radius: radius)
    }
    
    /// Returns a `RoundRectangle` which has the same bounds as this rectangle,
    /// with the given radius value describing the dimensions of the corner arcs
    /// on the X and Y axis.
    func rounded(radius: T) -> RoundRectangleT<T> {
        return RoundRectangleT(bounds: self, radiusX: radius, radiusY: radius)
    }
}
