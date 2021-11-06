import Geometry

protocol LayoutVariablesContainer: AnyObject, SpatialReferenceType {
    var layoutVariables: LayoutVariables! { get }
    var parent: SpatialReferenceType? { get }
    var area: UIRectangle { get set }
    var viewInHierarchy: View? { get }
    var constraints: [LayoutConstraint] { get set }
    var layout: LayoutAnchors { get }

    func viewForFirstBaseline() -> View?
    func setNeedsLayout()
    func boundsForRedrawOnScreen() -> UIRectangle
    func hasConstraintsOnAnchorKind(_ anchorKind: AnchorKind) -> Bool
}
