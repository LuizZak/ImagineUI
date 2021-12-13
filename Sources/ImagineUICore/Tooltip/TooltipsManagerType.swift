/// Protocol for tooltip managers.
public protocol TooltipsManagerType {
    /// Returns whether a tooltip is currently visible on screen.
    var isTooltipVisible: Bool { get }

    /// Returns whether a given view is a tooltip view, or contained within a
    /// tooltip view's hierarchy.
    func isInTooltipView(_ view: View) -> Bool

    /// Hides the currently displayed tooltip.
    func hideTooltip()

    /// Shows a provided tooltip.
    func showTooltip(_ tooltip: Tooltip, view: View, location: PreferredTooltipLocation)

    /// Updates the contents of the currently displayed tooltip.
    func updateTooltip(_ tooltip: Tooltip)
}
