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
}

extension LayoutGuide: Equatable {
    public static func == (lhs: LayoutGuide, rhs: LayoutGuide) -> Bool {
        return lhs === rhs
    }
}

extension LayoutGuide: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
