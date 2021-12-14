/// Specifies the preferred location to place a tooltip relative to a view.
public enum PreferredTooltipLocation {
    /// Defined by the underlying system.
    case systemDefined

    /// Tooltip is displayed anchored to the right side of the view.
    case right

    /// Tooltip is displayed anchored to the left side of the view.
    case left

    /// Tooltip is displayed anchored to the top of the view.
    case top

    /// Tooltip is displayed anchored to the bottom of the view.
    case bottom

    /// Tooltip is displayed atop the view specified by a `TooltipProvider`.
    case inPlace

    /// Tooltip is displayed besides the mouse at the time the tooltip is first
    /// displayed.
    ///
    /// The tooltip's location can remain fixed afterwards.
    case nextToMouse

    /// The tooltip should follow the mouse cursor as it moves around the screen.
    case followingMouse
}
