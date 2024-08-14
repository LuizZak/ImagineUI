import Geometry

/// A rectangular area in a view that can interact with the layout constraint
/// system.
public final class LayoutGuide {
    /// Used to map active constraints affecting anchors within this view.
    internal var _constraintsPerAnchor: [AnchorKind: [LayoutConstraint]] = [:]

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

    public func removeFromSuperview() {
        guard let superview = owningView else {
            return
        }

        if let index = superview.layoutGuides.firstIndex(where: { $0 === self }) {
            superview.layoutGuides.remove(at: index)

            for constraint in constraints {
                constraint.removeConstraint()
            }
        } else {
            assertionFailure("Layout guide with owningView is not referenced in its layout guide collection: View: \(superview) LayoutGuide: \(self)")
        }

        owningView = nil
    }
}

extension LayoutGuide: LayoutVariablesContainer {
    var parent: LayoutVariablesContainer? {
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
        guard let list = _constraintsPerAnchor[anchorKind] else {
            return false
        }

        return !list.isEmpty
    }

    func constraintsOnAnchorKind(_ anchorKind: AnchorKind) -> [LayoutConstraint] {
        return _constraintsPerAnchor[anchorKind, default: []]
    }

    func setAreaSkippingLayout(_ area: UIRectangle) {
        self.area = area
    }

    func suspendLayout() {
        viewInHierarchy?.suspendLayout()
    }

    func resumeLayout(setNeedsLayout: Bool) {
        viewInHierarchy?.resumeLayout(setNeedsLayout: setNeedsLayout)
    }

    func withSuspendedLayout<T>(setNeedsLayout: Bool, _ block: () throws -> T) rethrows -> T {
        if let viewInHierarchy {
            try viewInHierarchy.withSuspendedLayout(setNeedsLayout: setNeedsLayout, block)
        } else {
            try block()
        }
    }

    func didAddConstraint(_ constraint: LayoutConstraint) {
        if constraint.firstCast._owner === self {
            self._constraintsPerAnchor[constraint.firstCast.kind, default: []].append(constraint)
        }
        if let secondCast = constraint.secondCast, secondCast._owner === self {
            self._constraintsPerAnchor[secondCast.kind, default: []].append(constraint)
        }
    }

    func didRemoveConstraint(_ constraint: LayoutConstraint) {
        if constraint.firstCast._owner === self {
            self._constraintsPerAnchor[constraint.firstCast.kind, default: []].removeAll(where: { $0 == constraint })
        }
        if let secondCast = constraint.secondCast, secondCast._owner === self {
            self._constraintsPerAnchor[secondCast.kind, default: []].removeAll(where: { $0 == constraint })
        }
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
