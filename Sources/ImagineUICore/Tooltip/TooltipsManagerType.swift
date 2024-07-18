/// Protocol for tooltip managers.
@ImagineActor
public protocol TooltipsManagerType {
    /// Returns whether a tooltip is currently visible on screen.
    var isTooltipVisible: Bool { get }

    /// Returns `true` if an active `CustomTooltipHandlerType` is currently
    /// using this tooltips manager service.
    ///
    /// If `true`, calls to tooltip management methods are ignored until the
    /// custom tooltip handler revokes its exclusive access or it's ARC lifetime
    /// ends.
    var hasCustomTooltipActive: Bool { get }

    /// Returns whether a given view is a tooltip view, or contained within a
    /// tooltip view's hierarchy.
    func isInTooltipView(_ view: View) -> Bool

    /// Hides the currently displayed tooltip.
    func hideTooltip()

    /// Shows a provided tooltip.
    func showTooltip(_ tooltip: Tooltip, view: View, location: PreferredTooltipLocation)

    /// Updates the contents of the currently displayed tooltip.
    func updateTooltip(_ tooltip: Tooltip)

    /// Starts a custom tooltip display mode where the caller has exclusive
    /// access to the tooltip control until it is either revoked or the lifetime
    /// of the returned `CustomTooltipHandlerType` reaches its end.
    ///
    /// Method returns `nil` if another custom tooltip handler is already active.
    func beginCustomTooltipLifetime() -> CustomTooltipHandlerType?
}
