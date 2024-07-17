/// Specifies the location that a UI dialog will initially have on screen.
public enum UIDialogInitialLocation {
    /// The view will specify its own location according to its constraints.
    case unspecified

    /// The view should be placed such that its top-left coordinate lies on a given
    /// point, optionally specifying the view that the coordinate relates to.
    case topLeft(UIPoint, relativeTo: SpatialReferenceType? = nil)

    /// The view should be placed centered on screen, according to its initial
    /// `View.size` value.
    case centered
}
