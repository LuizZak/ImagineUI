import Geometry

/// A rectangular area that can interact with the layout constraint system
public class LayoutGuide {
    var layoutVariables: LayoutVariables!
    var constraints: [LayoutConstraint] = []

    var transform: UIMatrix {
        return .translation(x: area.x, y: area.y)
    }

    internal(set) public weak var owningView: View?

    internal(set) public var area: UIRectangle = .zero

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
    func boundsForRedrawOnScreen() -> UIRectangle {
        return absoluteTransform().transform(area.withLocation(.zero))
    }

    func hasConstraintsOnAnchorKind(_ anchorKind: AnchorKind) -> Bool {
        constraints.contains { $0.firstCast.kind == anchorKind || $0.secondCast?.kind == anchorKind }
    }

    func constraintsOnAnchorKind(_ anchorKind: AnchorKind) -> [LayoutConstraint] {
        constraints.filter { $0.firstCast.kind == anchorKind || $0.secondCast?.kind == anchorKind }
    }
}

extension LayoutGuide: SpatialReferenceType {
    public func absoluteTransform() -> UIMatrix {
        var transform = self.transform
        if let superview = owningView {
            transform = UIMatrix.multiply(transform, superview.absoluteTransform())
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
