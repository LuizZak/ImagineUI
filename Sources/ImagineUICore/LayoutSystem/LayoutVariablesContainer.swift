import Geometry

protocol LayoutVariablesContainer: AnyObject, SpatialReferenceType {
    var layoutVariables: LayoutVariables! { get }
    var parent: LayoutVariablesContainer? { get }
    var area: UIRectangle { get }
    var viewInHierarchy: View? { get }

    /// A list of constraints that are affecting this layout container.
    var constraints: [LayoutConstraint] { get set }

    /// Gets a reference for this container's layout anchors.
    var layout: LayoutAnchors { get }

    func viewForFirstBaseline() -> View?
    func setNeedsLayout()
    func boundsForRedrawOnScreen() -> UIRectangle
    func hasConstraintsOnAnchorKind(_ anchorKind: AnchorKind) -> Bool
    func constraintsOnAnchorKind(_ anchorKind: AnchorKind) -> [LayoutConstraint]
    func setAreaSkippingLayout(_ area: UIRectangle)

    /// Suspends setNeedsLayout() from affecting this container and its parent
    /// hierarchy.
    ///
    /// Sequential calls to `suspendLayout()` must be balanced with a matching
    /// number of `resumeLayout(setNeedsLayout:)` calls later in order for
    /// layout to resume successfully.
    func suspendLayout()

    /// Resumes layout, optionally dispatching a `setNeedsLayout()` call to the
    /// container at the end.
    ///
    /// Sequential calls to `resumeLayout(setNeedsLayout:)` must be balanced
    /// with a matching number of earlier `suspendLayout()` calls in order for
    /// layout to resume successfully.
    func resumeLayout(setNeedsLayout: Bool)

    /// Performs a given closure while suspending the layout of this container,
    /// optionally dispatching a `setNeedsLayout()` call to the container at the
    /// end.
    ///
    /// Layout is resumed whether or not the closure throws before the end of
    /// the block.
    func withSuspendedLayout<T>(setNeedsLayout: Bool, _ block: () throws -> T) rethrows -> T

    // TODO: These methods are used exclusively by `RootView` to cache `hasIndependentInternalLayout`
    // TODO: results ahead of time. Consider using the constraint solver's internal
    // TODO: view visitor to figure out independent layouts during constraint
    // TODO: system construction and feed that information to views during
    // TODO: `performInternalLayout`.

    /// Called to notify this container that a constraint referencing one of its
    /// layout anchors has been created.
    func didAddConstraint(_ constraint: LayoutConstraint)

    /// Called to notify this container that a constraint referencing one of its
    /// layout anchors has been removed.
    func didRemoveConstraint(_ constraint: LayoutConstraint)
}

extension LayoutVariablesContainer {
    func didAddConstraint(_ constraint: LayoutConstraint) {

    }

    func didRemoveConstraint(_ constraint: LayoutConstraint) {

    }
}
