import Geometry

/// A view which serves as the root of a view hierarchy.
open class RootView: ControlView {
    private var _constraintCache = LayoutConstraintSolverCache()
    private weak var _invalidationDelegate: RootViewRedrawInvalidationDelegate?

    public var invalidationDelegate: RootViewRedrawInvalidationDelegate? {
        get {
            if _invalidationDelegate == nil, let superview = superview as? RootView {
                return superview.invalidationDelegate
            }

            return _invalidationDelegate
        }
        set {
            _invalidationDelegate = newValue
        }
    }

    public var rootControlSystem: ControlSystem?

    public override var controlSystem: ControlSystem? {
        if rootControlSystem == nil, let controlSystem = superview?.controlSystem {
            return controlSystem
        }
        
        return rootControlSystem
    }

    public override func setNeedsLayout() {
        super.setNeedsLayout()
        
        guard !_isSizingLayout else { return }
        guard !isLayoutSuspended else { return }
        
        invalidationDelegate?.rootViewInvalidatedLayout(self)
    }

    override func invalidate(bounds: UIRectangle, spatialReference: SpatialReferenceType) {
        guard !_isSizingLayout else { return }
        
        let rect = spatialReference.convert(bounds: bounds, to: nil)
        invalidationDelegate?.rootView(self, invalidateRect: rect)
    }

    internal override func performConstraintsLayout(cached: Bool) {
        let solver = LayoutConstraintSolver()
        solver.solve(viewHierarchy: self, cache: cached ? _constraintCache : nil)
    }
}
