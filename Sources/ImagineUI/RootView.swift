import Geometry

/// A view which serves as the root of a view hierarchy.
open class RootView: ControlView {
    private var _constraintCache = LayoutConstraintSolverCache()

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

    internal override func performConstraintsLayout(cached: Bool) {
        let solver = LayoutConstraintSolver()
        solver.solve(viewHierarchy: self, cache: cached ? _constraintCache : nil)
    }
}
