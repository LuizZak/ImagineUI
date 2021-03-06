public protocol RootViewRedrawInvalidationDelegate: class {
    func rootView(_ rootView: RootView, invalidateRect rect: Rectangle)
}


/// A view which serves as the root of a view hierarchy.
public class RootView: ControlView {
    private var _constraintCache = LayoutConstraintSolverCache()
    
    public weak var invalidationDelegate: RootViewRedrawInvalidationDelegate?
    
    override func invalidate(bounds: Rectangle, spatialReference: SpatialReferenceType) {
        let rect = spatialReference.convert(bounds: bounds, to: nil)
        invalidationDelegate?.rootView(self, invalidateRect: rect)
    }
    
    internal override func performConstraintsLayout() {
        let solver = LayoutConstraintSolver()
        solver.solve(viewHierarchy: self, cache: _constraintCache)
    }
}
