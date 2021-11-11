import Geometry

protocol LayoutVariablesContainer: AnyObject, SpatialReferenceType {
    var layoutVariables: LayoutVariables! { get }
    var parent: LayoutVariablesContainer? { get }
    var area: UIRectangle { get set }
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
}
