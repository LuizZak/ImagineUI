public protocol CustomTooltipHandlerType: AnyObject {
    /// Requests that a tooltip be shown at a specified location relative to a
    /// specified view.
    func showTooltip(
        _ tooltip: Tooltip,
        view: View,
        location: PreferredTooltipLocation
    )

    /// Requests that a tooltip for a given tooltip provider be shown, optionally
    /// specifying a custom tooltip location.
    func showTooltip(
        for tooltipProvider: TooltipProvider,
        location: PreferredTooltipLocation?
    )

    /// Updates the contents of the currently displayed tooltip.
    /// Does nothing, if 
    func updateTooltip(_ tooltip: Tooltip)

    /// Hides a tooltip that was previously shown with `showTooltip`
    func hideTooltip()

    /// Explicitly requests that the custom lifetime of this tooltip handler be
    /// ended and tooltip management return to the default behaviour.
    func endTooltipLifetime()
}

extension CustomTooltipHandlerType {
    /// Requests that a tooltip for a given tooltip provider be shown.
    public func showTooltip(for tooltipProvider: TooltipProvider) {
        showTooltip(for: tooltipProvider, location: nil)
    }
}
