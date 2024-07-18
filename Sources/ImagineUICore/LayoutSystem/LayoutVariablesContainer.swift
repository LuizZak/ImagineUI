import Geometry

protocol LayoutVariablesContainer: AnyObject, SpatialReferenceType {
    var layoutVariables: LayoutVariables { get }
    @ImagineActor
    var parent: LayoutVariablesContainer? { get }
    @ImagineActor
    var area: UIRectangle { get }
    @ImagineActor
    var viewInHierarchy: View? { get }

    /// A list of constraints that are affecting this layout container.
    @ImagineActor
    var constraints: [LayoutConstraint] { get set }

    /// Gets a reference for this container's layout anchors.
    @ImagineActor
    var layout: LayoutAnchors { get }

    @ImagineActor
    func viewForFirstBaseline() -> View?
    @ImagineActor
    func setNeedsLayout()
    @ImagineActor
    func boundsForRedrawOnScreen() -> UIRectangle
    @ImagineActor
    func hasConstraintsOnAnchorKind(_ anchorKind: AnchorKind) -> Bool
    @ImagineActor
    func constraintsOnAnchorKind(_ anchorKind: AnchorKind) -> [LayoutConstraint]
    @ImagineActor
    func setAreaSkippingLayout(_ area: UIRectangle)

    // TODO: These methods are used exclusively by `RootView` to cache `hasIndependentInternalLayout`
    // TODO: results ahead of time. Consider using the constraint solver's internal
    // TODO: view visitor to figure out independent layouts during constraint
    // TODO: system construction and feed that information to views during
    // TODO: `performInternalLayout`.

    /// Called to notify this container that a constraint referencing one of its
    /// layout anchors has been created.
    @ImagineActor
    func didAddConstraint(_ constraint: LayoutConstraint)

    /// Called to notify this container that a constraint referencing one of its
    /// layout anchors has been removed.
    @ImagineActor
    func didRemoveConstraint(_ constraint: LayoutConstraint)
}

extension LayoutVariablesContainer {
    func didAddConstraint(_ constraint: LayoutConstraint) {

    }

    func didRemoveConstraint(_ constraint: LayoutConstraint) {

    }
}
