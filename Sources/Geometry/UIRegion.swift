/// A mutable structure that represents an area created by joining rectangles.
public class UIRegion {
    private var _rectangles: [UIRectangle]
    private var _needsDissect: Bool

    public var isEmpty: Bool {
        _rectangles.isEmpty || _rectangles.allSatisfy({ $0.size == .zero })
    }

    public init() {
        _rectangles = []
        _needsDissect = false
    }

    public init(_ rectangles: [UIRectangle], _ areDissected: Bool) {
        self._rectangles = rectangles
        self._needsDissect = !areDissected
    }

    /// Returns a series of `UIRectangle` instances that approximate the redraw
    /// region of this `UIRegion`, truncated to be within the given
    /// rectangle area.
    public func rectanglesUnder(area: UIRectangle) -> [UIRectangle] {
        if _needsDissect {
            _dissect()
        }

        let clipped = _rectangles.compactMap { r in r.intersection(area) }

        return mergeRectangles(clipped)
    }
    
    /// Returns `true` if a given rectangle intersects this region.
    public func intersects(_ rectangle: UIRectangle) -> Bool {
        return _rectangles.contains(where: { r in r.intersects(rectangle) })
    }
    
    /// Returns `true` if a given point is contained in this region.
    public func contains(point: UIPoint) -> Bool {
        return _rectangles.contains(where: { r in r.contains(point) })
    }

    public func addRectangle(_ rectangle: UIRectangle) {
        if isEmpty {
            _rectangles.append(rectangle)
            return
        }

        // If there are any rectangles available, check if we're not contained within other rectangles
        if _rectangles.contains(where: { rect in rect.contains(rectangle) }) {
            return
        }

        // If no intersection is found, just add the rectangle right away
        if _rectangles.allSatisfy({ rect in !rect.intersects(rectangle) }) {
            _rectangles.append(rectangle)
            return
        }

        _needsDissect = true

        _rectangles.append(rectangle)
    }

    /// Adds the regions of another region to this region instance.
    public func addRegion(_ region: UIRegion) {
        for rect in region._rectangles {
            addRectangle(rect)
        }
    }

    /*
    public func IsVisibleInClippingRegion(UIRectangle aabb, ISpatialReference reference) -> Bool {
        var transformed = reference.ConvertTo(aabb, null)
        return _rectangles.contains(where: r in r.IntersectsWith((UIRectangle) transformed))
    }

    public func IsVisibleInClippingRegion(Vector point, ISpatialReference reference) -> Bool {
        var transformed = reference.ConvertTo(point, null)
        return _rectangles.contains(where: { r in r.contains(transformed) })
    }

    /// Adds the regions of another clipping region to this clipping region instance.
    public func AddClippingRegion([NotNull] UIRegion region) {
        _rectangles.append(contentsOf: region._rectangles)
        _needsDissect = true
    }

    /// Applies a clip to the rectangles on this `UIRegion` so they are all contained within
    /// a given region.
    public func ApplyClip(UIRectangle region, [CanBeNull] ISpatialReference reference) {
        ApplyClip((UIRectangle)region, reference)
    }

    /// Applies a clip to the rectangles on this `UIRegion` so they are all contained within
    /// a given region.
    public func ApplyClip(UIRectangle region, ISpatialReference reference) {
        var clipRegion = region
        if (reference != null)
        {
            clipRegion = (UIRectangle)reference.ConvertTo(region, null)
        }

        for (int i = _rectangles.Count - 1 i >= 0 i--)
        {
            var rect = _rectangles[i]
            rect = UIRectangle.Intersect(rect, clipRegion)

            if (rect.isEmpty)
            {
                _rectangles.RemoveAt(i)
            }
            else
            {
                _rectangles[i] = rect
            }
        }
    }
    */

    public func SetRectangle(_ rectangle: UIRectangle) {
        clear()
        addRectangle(rectangle)
    }

    public func clear() {
        _rectangles.removeAll()
    }

    private func _dissect() {
        _rectangles = dissect(_rectangles)
        _needsDissect = false
    }
}

/// Performs dissection of two or more rectangles into an array of rectangles
/// that occupy the same area, and do not intersect.
/// 
/// If the rectangles do not intersect, the same input rectangles are returned
/// instead.
private func dissect(_ rects: [UIRectangle]) -> [UIRectangle] {
    let inputSet = _pruneEnclosedRectangles(rects)
    if inputSet.isEmpty {
        return []
    }
    if inputSet.count == 1 {
        return inputSet
    }

    let totalSize = UIRectangle.union(inputSet)

    // For faster querying of contained regions
    let quadTree = QuadTree<UIRectangle>(totalSize, 10, 5)
    for rect in inputSet {
        quadTree.AddNode(QuadTreeElement<UIRectangle>(rect, rect))
    }

    var output: [UIRectangle] = []

    let hEdges = HorizontalEdge.sortedEdges(from: inputSet)
    let vEdges = VerticalEdge.sortedEdges(from: inputSet)

    for y in 0..<(vEdges.count - 1) {
        let top = vEdges[y]
        let bottom = vEdges[y + 1]

        for x in 0..<(hEdges.count - 1) {
            let left = hEdges[x]
            let right = hEdges[x + 1]

            // Form a rectangle
            let rect = UIRectangle(left: left.x, top: top.y, right: right.x, bottom: bottom.y)

            if quadTree.QueryAabbAny(predicate: { $0.Value.contains(rect) }, searchR: rect) {
                output.append(rect)
            }
        }
    }
    
    output = mergeRectangles(output)

    return output
}

/// From a given list of rectangles, returns a new list where rectangles with shared edges
/// (two shared vertices on either the top, left, right, or bottom sides are the same) are
/// joined such that they form a single rectangle with the same area as the original rectangles.
private func mergeRectangles(_ rects: [UIRectangle]) -> [UIRectangle] {
    guard rects.count > 1 else {
        return rects
    }

    let epsilon: Double = 0.000001

    let totalSize = UIRectangle.union(rects)

    let quadTree = QuadTree<UIRectangle>(totalSize, 10, 10)

    for rect in rects {
        // Verify any existing rect on quad tree before adding
        var targetRect = rect

        var found: QuadTreeElement<UIRectangle>? = nil
        quadTree.QueryAabb(predicate: { element in
            let other = element.Value

            // Check top and bottom
            if (abs(rect.top - other.bottom) < epsilon || abs(rect.bottom - other.top) < epsilon) {
                if (abs(rect.left - other.left) < epsilon && abs(rect.right - other.right) < epsilon) {
                    targetRect = rect.union(element.Value)
                    found = element
                    return false
                }
            }

            // Check left and right
            if (abs(rect.left - other.right) < epsilon || abs(rect.right - other.left) < epsilon)
            {
                if (abs(rect.top - other.top) < epsilon && abs(rect.bottom - other.bottom) < epsilon)
                {
                    targetRect = rect.union(element.Value)
                    found = element
                    return false
                }
            }

            return true
        }, searchR: rect)

        if let found = found {
            quadTree.RemoveNode(found)
        }

        quadTree.AddNode(QuadTreeElement<UIRectangle>(targetRect, targetRect))
    }

    var elements: [QuadTreeElement<UIRectangle>] = []
    quadTree.GetAllNodesR(&elements)

    return elements.map(\.Value)
}

/// Remove rectangles completely contained within other rectangles from the
/// input set and returns the result a list of rectangles.
private func _pruneEnclosedRectangles(_ rects: [UIRectangle]) -> [UIRectangle] {
    var output: [UIRectangle] = []

    for rect in rects where !output.contains(where: { $0.contains(rect) }) {
        output.append(rect)
    }

    return output
}
private struct HorizontalEdge: Hashable, Comparable {
    var x: Double

    static func sortedEdges<S: Sequence>(from rectangles: S) -> [Self] where S.Element == UIRectangle {
        var edges: [Self] = []

        for rect in rectangles {
            edges.append(rect.edges.left)
            edges.append(rect.edges.right)
        }

        return edges.sorted()
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.x < rhs.x
    }
}

private struct VerticalEdge: Hashable, Comparable {
    var y: Double

    static func sortedEdges<S: Sequence>(from rectangles: S) -> [Self] where S.Element == UIRectangle {
        var edges: [Self] = []

        for rect in rectangles {
            edges.append(rect.edges.top)
            edges.append(rect.edges.bottom)
        }

        return edges.sorted()
    }
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.y < rhs.y
    }
}

private extension UIRectangle {
    var edges: (left: HorizontalEdge, top: VerticalEdge, right: HorizontalEdge, bottom: VerticalEdge) {
        (.init(x: left), .init(y: top), .init(x: right), .init(y: bottom))
    }
}
