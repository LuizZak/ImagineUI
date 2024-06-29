import SwiftBezier

/// A Bézier-curve drawing shape object.
public struct UIBezier {
    public typealias UIQuadBezier = CachedBezier<QuadBezier2<UIPoint>>
    public typealias UICubicBezier = CachedBezier<CubicBezier2<UIPoint>>

    private var _cache: _Cache
    fileprivate var _operations: [Operation] = []

    /// Returns `true` if this `UIBezier` contains no draw operations.
    public var isEmpty: Bool {
        _operations.allSatisfy({ !$0.isDrawOperation })
    }

    /// Gets the last vertex on this `UIBezier`, representing the end point of
    /// the last draw operation added.
    ///
    /// Is `nil`, if no operations have been added.
    public var lastVertex: UIPoint? {
        _operations.last?.endPoint
    }

    /// Initializes a new empty `UIBezier` object.
    public init() {
        _cache = _Cache()
    }

    private mutating func ensureUnique() {
        if !isKnownUniquelyReferenced(&_cache) {
            _cache = _Cache()
        }
    }

    /// Returns the minimal `UIRectangle` capable of fitting all drawing operations
    /// for this `UIBezier` instance.
    public func bounds() -> UIRectangle {
        return .union(drawOperations().map(\.bounds))
    }

    /// Returns a list of draw operations contained within this `UIBezier`.
    public func drawOperations() -> [DrawOperation] {
        if let cached = _cache.drawOperations {
            return cached
        }

        let op = Self.makeDrawOperations(_operations)
        _cache.drawOperations = op

        return op
    }

    /// If this `UIBezier` is not empty, returns the distance to the closest draw
    /// operation registered.
    ///
    /// Note that this method inspects each draw operation and then returns the
    /// shortest distance found, and thus does not take into account overlapping
    /// operations that occlude one another.
    ///
    /// If `isEmpty` is `true`, returns `Double.infinity`.
    public func distance(to point: UIPoint) -> Double {
        distanceSquared(to: point).squareRoot()
    }

    /// If this `UIBezier` is not empty, returns the squared distance to the
    /// closest draw operation registered.
    ///
    /// Note that this method inspects each draw operation and then returns the
    /// shortest distance found, and thus does not take into account overlapping
    /// operations that occlude one another.
    ///
    /// If `isEmpty` is `true`, returns `Double.infinity`.
    public func distanceSquared(to point: UIPoint) -> Double {
        var shortest: Double = .infinity

        for op in drawOperations() {
            shortest = min(shortest, op.distanceSquared(to: point))
        }

        return shortest
    }

    private mutating func add(_ operation: Operation) {
        ensureUnique()

        _operations.append(operation)
    }

    private func startVertex() -> UIPoint? {
        drawOperations().first?.startPoint
    }

    // MARK: - Factories

    private static func makeDrawOperations(_ operations: [Operation]) -> [DrawOperation] {
        var cache: [DrawOperation] = []

        var lastPoint: UIPoint = .zero
        for op in operations {
            defer { lastPoint = op.endPoint }

            guard let value = makeCachedOperation(op, start: lastPoint) else {
                continue
            }

            cache.append(value)
        }

        return cache
    }

    private static func makeCachedOperation(_ op: Operation, start: UIPoint) -> DrawOperation? {
        switch op {
        case .moveTo:
            return nil

        case .lineTo(let end):
            return .line(start: start, end: end)

        case .quadTo(let end, let cp1):
            return .quadBezier(makeQuadBezier(start, cp1, end))

        case .cubicTo(let end, let cp1, let cp2):
            return .cubicBezier(makeCubicBezier(start, cp1, cp2, end))
        }
    }

    private static func makeQuadBezier(_ p0: UIPoint, _ p1: UIPoint, _ p2: UIPoint) -> UIQuadBezier {
        return .init(p0: p0, p1: p1, p2: p2)
    }

    private static func makeCubicBezier(_ p0: UIPoint, _ p1: UIPoint, _ p2: UIPoint, _ p3: UIPoint) -> UICubicBezier {
        return .init(p0: p0, p1: p1, p2: p2, p3: p3)
    }

    // MARK: - Auxiliary types

    /// Encapsulates draw operations produced by a `UIBezier` object.
    public enum DrawOperation {
        case line(start: UIPoint, end: UIPoint)
        case quadBezier(UIQuadBezier)
        case cubicBezier(UICubicBezier)

        var startPoint: UIPoint {
            switch self {
            case .line(let start, _):
                return start

            case .quadBezier(let bezier):
                return bezier[0]

            case .cubicBezier(let bezier):
                return bezier[0]
            }
        }

        var endPoint: UIPoint {
            switch self {
            case .line(_, let end):
                return end

            case .quadBezier(let bezier):
                return bezier[2]

            case .cubicBezier(let bezier):
                return bezier[3]
            }
        }

        var bounds: UIRectangle {
            switch self {
            case .line(let start, let end):
                return UIRectangle(
                    minimum: .pointwiseMin(start, end),
                    maximum: .pointwiseMax(start, end)
                )

            case .quadBezier(let bezier):
                let (min, max) = bezier.boundingRegion()

                return UIRectangle(minimum: min, maximum: max)

            case .cubicBezier(let bezier):
                let (min, max) = bezier.boundingRegion()

                return UIRectangle(minimum: min, maximum: max)
            }
        }

        func distanceSquared(to point: UIPoint) -> Double {
            switch self {
            case .line(let start, let end):
                return UILine(start: start, end: end).distanceSquared(to: point)

            case .quadBezier(let bezier):
                let projected = bezier.projectApproximate(
                    to: point,
                    steps: 50,
                    maxIterations: 10,
                    tolerance: 1e-5
                )

                return point.distanceSquared(to: projected.output)

            case .cubicBezier(let bezier):
                let projected = bezier.projectApproximate(
                    to: point,
                    steps: 50,
                    maxIterations: 10,
                    tolerance: 1e-5
                )

                return point.distanceSquared(to: projected.output)
            }
        }

        func distance(to point: UIPoint) -> Double {
            distanceSquared(to: point).squareRoot()
        }
    }

    enum Operation: Hashable {
        case moveTo(UIPoint)
        case lineTo(UIPoint)
        case quadTo(UIPoint, cp1: UIPoint)
        case cubicTo(UIPoint, cp1: UIPoint, cp2: UIPoint)

        var endPoint: UIPoint {
            switch self {
            case .moveTo(let end),
                .lineTo(let end),
                .quadTo(let end, _),
                .cubicTo(let end, _, _):

                return end
            }
        }

        /// Returns `true` if this operation value is a draw operation.
        var isDrawOperation: Bool {
            switch self {
            case .lineTo, .quadTo, .cubicTo:
                return true
            case .moveTo:
                return false
            }
        }

        /// Returns `true` if this operation is a `moveTo` operation.
        var isMove: Bool {
            switch self {
            case .moveTo:
                return true
            case .lineTo, .quadTo, .cubicTo:
                return false
            }
        }
    }

    /// Backing cache for a `UIBezier` object.
    private class _Cache {
        /// The list of draw operations on this cache.
        var drawOperations: [DrawOperation]?

        /// The rectangle area on this cache.
        var bounds: UIRectangle?

        /// Resets the contents of this cache.
        func reset() {
            drawOperations = nil
            bounds = nil
        }
    }
}

// MARK: - Draw operations

extension UIBezier {
    /// Adds a 'move to' operation that moves the current vertex on this `UIBezier`
    /// without issuing a draw command.
    public mutating func move(to point: UIPoint) {
        let op = Operation.moveTo(point)

        // If the last operation is already a `.moveTo()` operation, replace it
        // instead of appending a new one.
        if _operations.last?.isMove == true {
            ensureUnique()
            _operations[_operations.count - 1] = op
        } else {
            add(op)
        }
    }

    /// Adds a 'move to' operation that moves the current vertex on this `UIBezier`
    /// without issuing a draw command.
    public mutating func move(toX x: Double, y: Double) {
        self.move(to: .init(x: x, y: y))
    }

    /// Adds a 'line to' operation that draw a line from the current end vertex
    /// of this `UIBezier` to another point.
    public mutating func line(to point: UIPoint) {
        let op = Operation.lineTo(point)

        add(op)
    }

    /// Adds a 'line to' operation that draw a line from the current end vertex
    /// of this `UIBezier` to another point.
    public mutating func line(toX x: Double, y: Double) {
        self.line(to: .init(x: x, y: y))
    }

    /// Adds a 'quadratic Bézier draw to' operation that draws a quadratic Bézier
    /// curve from the current end vertex of this `UIBezier` to another point,
    /// using `p1` as the second control point of the curve.
    public mutating func quad(to point: UIPoint, p1: UIPoint) {
        let op = Operation.quadTo(point, cp1: p1)

        add(op)
    }

    /// Adds a 'cubic Bézier draw to' operation that draws a cubic Bézier curve
    /// from the current end vertex of this `UIBezier` to another point, using
    /// `p1` and `p2` as the second and third control points of the curve.
    public mutating func cubic(to point: UIPoint, p1: UIPoint, p2: UIPoint) {
        let op = Operation.cubicTo(point, cp1: p1, cp2: p2)

        add(op)
    }

    /// If this `UIBezier` object has draw operations, ensures that the end point
    /// of the last operation matches the starting point of the first operation
    /// by creating a 'line to' operation between them, if none is found.
    ///
    /// If no draw operations are present (i.e. `self.isEmpty` is `true`), no
    /// changes are actually made.
    ///
    /// Sequential calls to `close()` are idempotent.
    public mutating func close() {
        guard !isEmpty else {
            return
        }
        guard let start = startVertex(), let end = lastVertex else {
            return
        }

        if end != start {
            ensureUnique()
            line(to: start)
        }
    }

    /// Resets this `UIBezier` object.
    public mutating func clear() {
        ensureUnique()

        _operations.removeAll()
    }
}
