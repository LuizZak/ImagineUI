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
            _cache = _cache.copy()
        }
    }

    /// Returns the absolute length of the lines drawn by this bezier instance.
    ///
    /// Counts only drawable operations, so move operations are ignored.
    public func length() -> Double {
        if let cached = _cache.length {
            return cached
        }

        let result = drawOperations().reduce(0) { $0 + $1.length }
        _cache.length = result

        return result
    }

    /// Returns the computed point of the draw operations, or the 'pen position',
    /// at a given offset from the start of the draw operations.
    ///
    /// If this bezier is empty, the result is `.zero`, and if the value is
    /// outside the range (0 - `self.length()`), the result is clamped to between
    /// the start and end draw vertices.
    ///
    /// - parameter offset: A value between (0 - `self.length()`) that describes
    ///     the absolute offset along this bezier's length.
    public func pointAtOffset(_ offset: Double) -> UIPoint {
        guard !isEmpty else {
            return .zero
        }

        if offset < 0 {
            return drawOperations().first?.startPoint ?? .zero
        }
        if offset > length() {
            return drawOperations().last?.endPoint ?? .zero
        }

        var remaining = offset
        for op in drawOperations() {
            if remaining < op.length {
                return op.compute(at: remaining / op.length)
            }

            remaining -= op.length
        }

        return drawOperations().last?.endPoint ?? .zero
    }

    /// Returns the minimal `UIRectangle` capable of fitting all drawing operations
    /// for this `UIBezier` instance.
    public func bounds() -> UIRectangle {
        return .union(drawOperations().map(\.bounds))
    }

    /// Returns the internal list of operations queued up within this `UIBezier`.
    public func operations() -> [Operation] {
        return _operations
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

    /// Assuming that this `UIBezier` represents an enclosed area, returns `true`
    /// if the given point is contained within the area specified by this `UIBezier`
    /// instance.
    public func contains(_ point: UIPoint) -> Bool {
        let outerPoint = UIPoint(x: self.bounds().right + 1, y: point.y)
        let line = UILine(start: point, end: outerPoint)

        return intersect(line).count % 2 == 1
    }

    func intersect(_ line: UILine) -> [UIPoint] {
        let ops = drawOperations()

        var result: [UIPoint] = []
        let bezierLine = LinearBezier<UIPoint>(p0: line.start, p1: line.end)

        for op in ops {
            switch op {
            case .line(let start, let end):
                let opLine = UILine(start: start, end: end)
                if let point = opLine.intersection(with: line) {
                    result.append(point)
                }

            case .arc(let arc):
                switch arc.intersection(with: line) {
                case (let a?, let b?):
                    return [a, b]

                case (let a?, nil):
                    return [a]

                case (nil, let b?):
                    return [b]

                case (nil, nil):
                    return []
                }

            case .quadBezier(let bezier):
                let (t0, t1) = bezier.bezier.intersection(with: bezierLine)
                if let t0 { result.append(bezier.compute(at: t0)) }
                if let t1 { result.append(bezier.compute(at: t1)) }

            case .cubicBezier(let bezier):
                let (t0, t1, t2, t3) = bezier.bezier.intersection(with: bezierLine)
                if let t0 { result.append(bezier.compute(at: t0)) }
                if let t1 { result.append(bezier.compute(at: t1)) }
                if let t2 { result.append(bezier.compute(at: t2)) }
                if let t3 { result.append(bezier.compute(at: t3)) }
            }
        }

        return result
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

        case .arc(let end, let sweepAngle):
            return .arc(makeArc(start, end, sweepAngle))

        case .lineTo(let end):
            return .line(start: start, end: end)

        case .quadTo(let end, let cp1):
            return .quadBezier(makeQuadBezier(start, cp1, end))

        case .cubicTo(let end, let cp1, let cp2):
            return .cubicBezier(makeCubicBezier(start, cp1, cp2, end))
        }
    }

    private static func makeArc(_ p0: UIPoint, _ p1: UIPoint, _ sweepAngle: Double) -> UICircleArc {
        UICircleArc(startPoint: p0, endPoint: p1, sweepAngle: sweepAngle)
    }

    private static func makeQuadBezier(_ p0: UIPoint, _ p1: UIPoint, _ p2: UIPoint) -> UIQuadBezier {
        return .init(p0: p0, p1: p1, p2: p2)
    }

    private static func makeCubicBezier(_ p0: UIPoint, _ p1: UIPoint, _ p2: UIPoint, _ p3: UIPoint) -> UICubicBezier {
        return .init(p0: p0, p1: p1, p2: p2, p3: p3)
    }

    // MARK: - Auxiliary types

    /// Encapsulates draw operations produced by a `UIBezier` object, and always
    /// represents a stroke operation.
    public enum DrawOperation {
        case line(start: UIPoint, end: UIPoint)
        case arc(UICircleArc)
        case quadBezier(UIQuadBezier)
        case cubicBezier(UICubicBezier)

        var startPoint: UIPoint {
            switch self {
            case .line(let start, _):
                return start

            case .arc(let arc):
                return arc.startPoint

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

            case .arc(let arc):
                return arc.endPoint

            case .quadBezier(let bezier):
                return bezier[2]

            case .cubicBezier(let bezier):
                return bezier[3]
            }
        }

        var length: Double {
            switch self {
            case .line(let start, let end):
                return start.distance(to: end)

            case .arc(let arc):
                return arc.length()

            case .quadBezier(let bezier):
                let series = bezier.computeSeries(steps: 100)

                return zip(series, series.dropFirst()).reduce(0.0) { (total, next) in
                    next.0.distance(to: next.1)
                }

            case .cubicBezier(let bezier):
                let series = bezier.computeSeries(steps: 100)

                return zip(series, series.dropFirst()).reduce(0.0) { (total, next) in
                    next.0.distance(to: next.1)
                }
            }
        }

        var bounds: UIRectangle {
            switch self {
            case .line(let start, let end):
                return UIRectangle(
                    minimum: .pointwiseMin(start, end),
                    maximum: .pointwiseMax(start, end)
                )

            case .arc(let arc):
                return arc.bounds()

            case .quadBezier(let bezier):
                let (min, max) = bezier.boundingRegion()

                return UIRectangle(minimum: min, maximum: max)

            case .cubicBezier(let bezier):
                let (min, max) = bezier.boundingRegion()

                return UIRectangle(minimum: min, maximum: max)
            }
        }

        func compute(at factor: Double) -> UIPoint {
            switch self {
            case .line(let start, let end):
                return start.lerp(to: end, factor: factor)

            case .arc(let arc):
                return arc.pointOnAngle(arc.startAngle + arc.sweepAngle * factor)

            case .cubicBezier(let bezier):
                return bezier.compute(at: factor)

            case .quadBezier(let bezier):
                return bezier.compute(at: factor)
            }
        }

        func distanceSquared(to point: UIPoint) -> Double {
            switch self {
            case .line(let start, let end):
                return UILine(start: start, end: end).distanceSquared(to: point)

            case .arc(let arc):
                return arc.distanceSquared(to: point)

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

    /// An internal path operation that may or may not produce a stroke.
    public enum Operation: Hashable {
        case moveTo(UIPoint)
        case lineTo(UIPoint)
        case quadTo(UIPoint, cp1: UIPoint)
        case cubicTo(UIPoint, cp1: UIPoint, cp2: UIPoint)
        case arc(UIPoint, sweepAngle: Double)

        public var endPoint: UIPoint {
            switch self {
            case .moveTo(let end),
                .lineTo(let end),
                .quadTo(let end, _),
                .cubicTo(let end, _, _),
                .arc(let end, _):

                return end
            }
        }

        /// Returns `true` if this operation value is a draw operation.
        public var isDrawOperation: Bool {
            switch self {
            case .lineTo, .quadTo, .cubicTo, .arc:
                return true
            case .moveTo:
                return false
            }
        }

        /// Returns `true` if this operation is a `moveTo` operation.
        public var isMove: Bool {
            switch self {
            case .moveTo:
                return true
            case .lineTo, .quadTo, .cubicTo, .arc:
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

        /// The length on this cache.
        var length: Double?

        init(
            drawOperations: [UIBezier.DrawOperation]? = nil,
            bounds: UIRectangle? = nil,
            length: Double? = nil
        ) {
            self.drawOperations = drawOperations
            self.bounds = bounds
            self.length = length
        }

        func copy() -> _Cache {
            return _Cache(
                drawOperations: drawOperations,
                bounds: bounds,
                length: length
            )
        }

        /// Resets the contents of this cache.
        func reset() {
            drawOperations = nil
            bounds = nil
            length = nil
        }
    }
}

// MARK: - Draw operations

extension UIBezier {
    /// Adds a 'move to' operation that moves the current vertex on this `UIBezier`
    /// without issuing a draw command.
    public mutating func move(to point: UIPoint) {
        ensureUnique()

        let op = Operation.moveTo(point)

        // If the last operation is already a `.moveTo()` operation, replace it
        // instead of appending a new one.
        if _operations.last?.isMove == true {
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

    /// Adds an 'arc' operation that draws a circular arc starting from the
    /// current end vertex of this `UIBezier`, before sweeping towards another
    /// end point.
    public mutating func arc(to point: UIPoint, sweepAngle: Double) {
        let op = Operation.arc(point, sweepAngle: sweepAngle)

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
        ensureUnique()

        guard !isEmpty else {
            return
        }
        guard let start = startVertex(), let end = lastVertex else {
            return
        }

        if end != start {
            line(to: start)
        }
    }

    /// Resets this `UIBezier` object.
    public mutating func clear() {
        ensureUnique()

        _operations.removeAll()
    }
}
