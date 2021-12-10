import Geometry

/// A view which serves as the root of a view hierarchy.
open class RootView: ControlView {
    private var _constraintCache = LayoutConstraintSolverCache()
    private var _hasIndependentInternalLayout = true

    public weak var invalidationDelegate: RootViewRedrawInvalidationDelegate?
    public var rootControlSystem: ControlSystem?

    public override var controlSystem: ControlSystem? {
        // Propagate parent's control system, if none where specified for this
        // root view.
        if rootControlSystem == nil {
            return superview?.controlSystem
        }
        
        return rootControlSystem
    }

    public override func setNeedsLayout() {
        super.setNeedsLayout()
        
        guard !_isSizingLayout else { return }
        guard !isLayoutSuspended else { return }
        
        invalidationDelegate?.rootViewInvalidatedLayout(self)
    }

    /// Returns `true` iff this root view has no layout constraints attaching it
    /// to a view in a parent hierarchy.
    open override func hasIndependentInternalLayout() -> Bool {
        _hasIndependentInternalLayout
    }

    open override func performInternalLayout() {
        if hasIndependentInternalLayout() {
            performConstraintsLayout(cached: true)
        }
    }

    internal override func performConstraintsLayout(cached: Bool) {
        let solver = LayoutConstraintSolver()
        solver.solve(viewHierarchy: self, cache: cached ? _constraintCache : nil)
    }

    override func invalidate(bounds: UIRectangle, spatialReference: SpatialReferenceType) {
        guard !_isSizingLayout else { return }

        if let invalidationDelegate = invalidationDelegate {
            let rect = spatialReference.convert(bounds: bounds, to: nil)
            invalidationDelegate.rootView(self, invalidateRect: rect)
        } else {
            // Propagate invalidation to parent view, if no invalidation delegate 
            // was specified for this root view.
            superview?.invalidate(bounds: bounds, spatialReference: spatialReference)
        }
    }

    override func didAddConstraint(_ constraint: LayoutConstraint) {
        _cacheIsIndependentLayout()
    }

    override func didRemoveConstraint(_ constraint: LayoutConstraint) {
        _cacheIsIndependentLayout()
    }

    private func _cacheIsIndependentLayout() {
        for constraint in constraints {
            guard let first = constraint.first.owner as? View else {
                continue
            }
            guard let second = constraint.second?.owner as? View else {
                continue
            }

            if View.firstCommonAncestor(between: first, second) !== self {
                _hasIndependentInternalLayout = false
                return
            }
        }

        _hasIndependentInternalLayout = true
    }
}
