/// A rectangular area that can interact with the layout constraint system
public class LayoutGuide {
    var layoutVariables: LayoutVariables!
    var constraints: [LayoutConstraint] = []
    
    var transform: Matrix2D {
        return .translation(x: area.x, y: area.y)
    }
    
    internal(set) public weak var owningView: View?
    
    internal(set) public var area: Rectangle = .zero
    
    public init() {
        layoutVariables = LayoutVariables(container: self)
    }
}

extension LayoutGuide: LayoutVariablesContainer {
    var parent: SpatialReferenceType? {
        return owningView
    }
    var viewInHierarchy: View? {
        return owningView
    }
    
    func viewForFirstBaseline() -> View? {
        return nil
    }
    
    func setNeedsLayout() {
        owningView?.setNeedsLayout()
    }
    
    /// Returns the bounds for redrawing on the screen's coordinate system
    func boundsForRedrawOnScreen() -> Rectangle {
        return absoluteTransform().transform(area.withLocation(.zero))
    }
}

extension LayoutGuide: SpatialReferenceType {
    public func absoluteTransform() -> Matrix2D {
        var transform = self.transform
        if let superview = owningView {
            transform = transform * superview.absoluteTransform()
        }
        return transform
    }
    
    public func convert(point: Vector2, to other: SpatialReferenceType?) -> Vector2 {
        var point = point
        point *= absoluteTransform()
        if let other = other {
            point *= other.absoluteTransform().inverted()
        }
        return point
    }

    public func convert(point: Vector2, from other: SpatialReferenceType?) -> Vector2 {
        var point = point
        if let other = other {
            point *= other.absoluteTransform()
        }
        point *= absoluteTransform().inverted()

        return point
    }

    public func convert(bounds: Rectangle, to other: SpatialReferenceType?) -> Rectangle {
        var bounds = bounds
        bounds = absoluteTransform().transform(bounds)
        if let other = other {
            bounds = other.absoluteTransform().inverted().transform(bounds)
        }
        return bounds
    }

    public func convert(bounds: Rectangle, from other: SpatialReferenceType?) -> Rectangle {
        var bounds = bounds
        if let other = other {
            bounds = other.absoluteTransform().transform(bounds)
        }
        bounds = absoluteTransform().inverted().transform(bounds)
        return bounds
    }
}
