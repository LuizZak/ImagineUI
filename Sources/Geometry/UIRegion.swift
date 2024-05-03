/// A mutable structure that represents an area composed by rectangles using
/// addition, subtraction, intersection and xor-ing.
public class UIRegion {
    private var _rectangles: [UIRectangle]

    /// Returns `true` if the total area represented by this `UIRegion` is zero.
    public var isEmpty: Bool {
        _rectangles.isEmpty || _rectangles.allSatisfy({ $0.size == .zero })
    }

    /// Initializes an empty region.
    public init() {
        _rectangles = []
    }

    /// Initializes a region with a single rectangle.
    public init(rectangle: UIRectangle) {
        _rectangles = [rectangle]
    }

    /// Initializes a region with a single rectangle.
    public init(rectangle: UIIntRectangle) {
        _rectangles = [UIRectangle(rectangle)]
    }

    /// Initializes a region with a set of rectangles that are added in additive
    /// fashion.
    public init(rectangles: [UIRectangle]) {
        _rectangles = []

        for rect in rectangles {
            _add(rect)
        }
    }

    /// Returns a list of all rectangles in this region.
    public func allRectangles() -> [UIRectangle] {
        return _rectangles
    }

    /// Returns a list of scan rectangles that encompass the area that a given
    /// rectangle overlaps on this UIRegion.
    public func intersectionsFor(area: UIRectangle) -> [UIRectangle] {
        return _rectangles.compactMap { $0.overlap(area) }
    }
    
    /// Returns `true` if a given rectangle intersects this region.
    ///
    /// Rectangle intersection can occur when rectangles share an edge, but do
    /// not need to share a non-zero area with other rectangles.
    public func intersects(_ rectangle: UIRectangle) -> Bool {
        return _rectangles.contains(where: { r in r.intersects(rectangle) })
    }
    
    /// Returns `true` if a given rectangle overlaps this region.
    ///
    /// Rectangle overlapping can only occur when the shared area between two
    /// rectangles is non-zero.
    public func overlaps(_ rectangle: UIRectangle) -> Bool {
        return _rectangles.contains(where: { r in r.overlaps(rectangle) })
    }
    
    /// Returns `true` if a given rectangle is fully contained in this region.
    public func contains(_ rectangle: UIRectangle) -> Bool {
        return _rectangles.contains(where: { r in r.contains(rectangle) })
    }
    
    /// Returns `true` if a given point is contained in this region.
    public func contains(_ point: UIPoint) -> Bool {
        return _rectangles.contains(where: { r in r.contains(point) })
    }

    public func addRectangle(_ rectangle: UIRectangle, operation: Operation = .add) {
        switch operation {
        case .add:
            _add(rectangle)
        case .subtract:
            _subtract(rectangle)
        case .intersect:
            _intersect(rectangle)
        case .xor:
            _xor(rectangle)
        }
    }

    /// Adds the regions of another region to this region instance.
    public func addRegion(_ region: UIRegion, operation: Operation = .add) {
        for rect in region._rectangles {
            addRectangle(rect, operation: operation)
        }
    }

    /// Replaces the entire region with a single rectangle.
    public func reset(_ rectangle: UIRectangle) {
        clear()
        addRectangle(rectangle)
    }

    /// Clears the entire clip region.
    public func clear() {
        _rectangles.removeAll()
    }

    private func _add(_ rectangle: UIRectangle) {
        if isEmpty {
            _rectangles.append(rectangle)
            return
        }

        // If there are any rectangles available, check if the input is not
        // contained within other rectangles
        if _rectangles.contains(where: { rect in rect.contains(rectangle) }) {
            return
        }

        // If, instead, no intersection is found, add the rectangle right away
        // as it does not require dissection against existing rectangles.
        if _rectangles.allSatisfy({ rect in !rect.intersects(rectangle) }) {
            _rectangles.append(rectangle)
            return
        }

        _addOp(rectangle, op: .add)
    }

    private func _subtract(_ rectangle: UIRectangle) {
        guard !isEmpty else {
            return
        }

        _addOp(rectangle, op: .subtract)
    }

    private func _intersect(_ rectangle: UIRectangle) {
        guard !isEmpty else {
            return
        }

        //_rectangles = intersectionsFor(area: rectangle)
        _addOp(rectangle, op: .intersect)
    }

    private func _xor(_ rectangle: UIRectangle) {
        if isEmpty {
            _rectangles.append(rectangle)
            return
        }

        // If, no intersection is found, add the rectangle right away
        // as it does not require dissection against existing rectangles.
        if _rectangles.allSatisfy({ rect in !rect.intersects(rectangle) }) {
            _rectangles.append(rectangle)
            return
        }

        _addOp(rectangle, op: .xor)
    }

    private func _addEdges(from rectangle: UIRectangle, op: Operation) {
        var horizontals = HorizontalEdge.sortedEdges(from: _rectangles)
        var verticals = VerticalEdge.sortedEdges(from: _rectangles)

        switch op {
        case .add, .intersect, .xor:
            horizontals.append(edges: rectangle)
            verticals.append(edges: rectangle)

        case .subtract:
            horizontals.append(edges: rectangle, reversed: true)
            verticals.append(edges: rectangle, reversed: true)
        }

        horizontals.sort()
        verticals.sort()
    }

    private func _addOp(_ rectangle: UIRectangle, op: Operation) {
        // Filter out rectangles that will not be participating in the merge
        // operation meaningfully.

        let firstIntersecting = _rectangles.partition(by: { $0.intersects(rectangle) })
        let nonIntersecting = _rectangles[..<firstIntersecting]
        let intersecting = _rectangles[firstIntersecting...]

        switch op {
        case .add, .subtract, .xor:
            let result = Self._mergeOp(rectangle, rectangles: intersecting, op: op)
            _rectangles = nonIntersecting + result
        
        case .intersect:
            let result = Self._mergeOp(rectangle, rectangles: intersecting, op: op)
            _rectangles = result
        }
    }

    // Used by `_mergeOp(_:rectangles:op:)`
    private enum State {
        case outsideShape
        case inShape(start: VerticalEdge)
    }

    private static func _mergeOp<C: Collection>(
        _ rectangle: UIRectangle,
        rectangles: C,
        op: Operation
    ) -> [UIRectangle] where C.Element == UIRectangle {

        var horizontals = HorizontalEdge.sortedEdges(from: rectangles)
        var verticals = VerticalEdge.sortedEdges(from: rectangles)

        switch op {
        case .add, .intersect, .xor:
            horizontals.append(edges: rectangle)
            verticals.append(edges: rectangle)

        case .subtract:
            horizontals.append(edges: rectangle, reversed: true)
            verticals.append(edges: rectangle, reversed: true)
        }

        horizontals.sort()
        verticals.sort()

        var newRectangles: [UIRectangle] = []
        var previousLine: [UIRectangle] = []
        var currentLine: [UIRectangle] = []

        for i in 0..<(horizontals.count - 1) {
            defer {
                #if DEBUG_UI_REGION

                let format: (UIRectangle) -> String = {
                    ".init(left: \($0.left), top: \($0.top), right: \($0.right), bottom: \($0.bottom))"
                }
                let formatArray: ([UIRectangle]) -> String = {
                    if $0.isEmpty {
                        return "[]"
                    }

                    return "[  \n  " + $0.map(format).joined(separator: ",\n  ") + ",\n]"
                }

                print("result:        ", formatArray(newRectangles))
                print("previous line: ", formatArray(previousLine))
                print("current line:  ", formatArray(currentLine))
                print("---")

                #endif

                // Keep empty line states in case the next range fails to produce
                // a valid list of rectangles (can happen when two rectangles
                // touch vertically, resulting in 0-length vertical runs that are
                // skipped).
                if !currentLine.isEmpty {
                    newRectangles.append(contentsOf: previousLine)
                    previousLine = currentLine
                    currentLine = []
                }
            }

            let top = horizontals[i]
            let bot = horizontals[i + 1]

            // Skip opposite edges that overlap exactly on the same coordinate,
            // as they would essentially be cancelled out anyway and this can
            // save some time computing clippings of vertical edges below
            if top.y == bot.y && top.direction == bot.direction.reversed {
                continue
            }

            /// Current depth into or out of shapes. outside shape: 0,
            /// in shape: >1, initial state: 0
            var depth: Int = 0
            var state: State = .outsideShape

            var xorState: EdgeDirection = .in

            for vi in 0..<verticals.count {
                guard let current = verticals[vi].clipped(top: top.y, bottom: bot.y) else {
                    continue
                }

                var direction = current.direction

                defer {
                    depth += direction.value
                }
                
                // xor: Flip the in and out of the row to effectively cancel out
                // an entrance in the first rectangle with an entrance to the second
                if op == .xor {
                    direction = xorState
                    xorState = xorState.reversed
                }

                switch (state, direction) {
                // Into shape
                case (.outsideShape, .in):
                    if op == .intersect { // Intersections require 2 entrances to count.
                        guard depth == 1 else { break }
                    } else {
                        guard depth == 0 else { break }
                    }

                    state = .inShape(start: current)

                // Leaving shape - create rectangle
                case (.inShape(let start), .out):
                    if op == .intersect { // Intersections require 2 exits to count.
                        guard depth == 2 else { break }
                    } else {
                        guard depth == 1 else { break }
                    }

                    state = .outsideShape

                    var rect = UIRectangle(start, top, current, bot)

                    // Merge and carry over rectangles that connect across lines
                    for prevIndex in 0..<previousLine.count {
                        let prev = previousLine[prevIndex]
                        if prev.left > rect.left {
                            break
                        }

                        // Check if any rectangle of the previous line meets the
                        // current rectangle at the bottom, and if so, merge the
                        // two rectangles into this line, removing the reference
                        // to the rectangle on the previous line.
                        if prev.bottom == rect.top && prev.left == rect.left && prev.right == rect.right {
                            previousLine.remove(at: prevIndex)

                            rect = rect.union(prev)
                            break
                        }
                    }

                    // Attempt to merge rectangles that have equal height and are
                    // side-by-side
                    if let prev = currentLine.last {
                        if prev.right == rect.left && prev.top == rect.top && prev.bottom == rect.bottom {
                            rect = currentLine.removeLast().union(rect)
                        }
                    }

                    if rect.area != 0 {
                        currentLine.append(rect)
                    }
                default:
                    break
                }
            }
        }

        newRectangles.append(contentsOf: previousLine)

        return newRectangles
    }
    
    /// Describes the operation to use when adding elements to a `UIRegion`.
    public enum Operation {
        case add
        case subtract
        case intersect
        case xor
    }
}

private struct HorizontalEdge: Hashable, Comparable {
    var y: Double
    var left: Double
    var right: Double
    var direction: EdgeDirection

    var length: Double {
        right - left
    }

    var reversed: Self {
        var copy = self
        copy.direction = copy.direction.reversed
        return copy
    }

    init(y: Double, left: Double, right: Double, direction: EdgeDirection) {
        self.y = y
        self.left = min(left, right)
        self.right = max(left, right)
        self.direction = direction
    }

    func contains(x: Double) -> Bool {
        left <= x && x >= right
    }

    func clipped(left: Double, right: Double) -> Self? {
        let l = max(self.left, left)
        let r = min(self.right, right)

        if l < r {
            return Self(y: y, left: l, right: r, direction: direction)
        }

        return nil
    }

    func intersects(left: Double, right: Double) -> Bool {
        max(self.left, left) < min(self.right, right)
    }

    static func sortedEdges<S: Sequence>(from rectangles: S) -> [Self] where S.Element == UIRectangle {
        var edges: [Self] = []

        for rect in rectangles {
            edges.append(rect.topEdge)
            edges.append(rect.bottomEdge)
        }

        return edges.sorted()
    }
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.y < rhs.y
    }
}

private struct VerticalEdge: Hashable, Comparable {
    var x: Double
    var top: Double
    var bottom: Double
    var direction: EdgeDirection

    var length: Double {
        bottom - top
    }

    var reversed: Self {
        var copy = self
        copy.direction = copy.direction.reversed
        return copy
    }

    init(x: Double, top: Double, bottom: Double, direction: EdgeDirection) {
        self.x = x
        self.top = min(top, bottom)
        self.bottom = max(top, bottom)
        self.direction = direction
    }

    func contains(y: Double) -> Bool {
        top <= y && y >= bottom
    }

    func clipped(top: Double, bottom: Double) -> Self? {
        let t = max(self.top, top)
        let b = min(self.bottom, bottom)

        if t < b {
            return Self(x: x, top: t, bottom: b, direction: direction)
        }

        return nil
    }

    func intersects(top: Double, bottom: Double) -> Bool {
        max(self.top, top) < min(self.bottom, bottom)
    }

    static func sortedEdges<S: Sequence>(from rectangles: S) -> [Self] where S.Element == UIRectangle {
        var edges: [Self] = []

        for rect in rectangles {
            edges.append(rect.leftEdge)
            edges.append(rect.rightEdge)
        }

        return edges.sorted()
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.x < rhs.x
    }
}

private extension Array {
    mutating func append(edges rect: UIRectangle, reversed: Bool = false) where Element == HorizontalEdge {
        if reversed {
            append(rect.topEdge.reversed)
            append(rect.bottomEdge.reversed)
        } else {
            append(rect.topEdge)
            append(rect.bottomEdge)
        }
    }

    mutating func append(edges rect: UIRectangle, reversed: Bool = false) where Element == VerticalEdge {
        if reversed {
            append(rect.leftEdge.reversed)
            append(rect.rightEdge.reversed)
        } else {
            append(rect.leftEdge)
            append(rect.rightEdge)
        }
    }
}

/// The direction of an edge, or whether crossing the edge from left-to-right or
/// top-to-bottom represents entering or exiting a rectangle.
private enum EdgeDirection {
    case `in`
    case out

    var reversed: Self {
        switch self {
        case .in:
            return .out
        case .out:
            return .in
        }
    }

    var value: Int {
        switch self {
        case .in:
            return 1
        case .out:
            return -1
        }
    }
}

private extension UIRectangle {
    var leftEdge: VerticalEdge {
        .init(x: left, top: top, bottom: bottom, direction: .in)
    }
    var topEdge: HorizontalEdge {
        .init(y: top, left: left, right: right, direction: .in)
    }
    var rightEdge: VerticalEdge {
        .init(x: right, top: top, bottom: bottom, direction: .out)
    }
    var bottomEdge: HorizontalEdge {
        .init(y: bottom, left: left, right: right, direction: .out)
    }

    init(_ left: VerticalEdge, _ top: HorizontalEdge, _ right: VerticalEdge, _ bottom: HorizontalEdge) {
        self.init(left: left.x, top: top.y, right: right.x, bottom: bottom.y)
    }
}
