/// A tooltip provider that dynamically updates its tooltips content.
public protocol TooltipProvider {
    /// Gets the current tooltip value.
    var tooltip: Tooltip? { get }

    /// Event called whenever the contents of the tooltip have been updated.
    var tooltipUpdated: EventSource<Tooltip?> { get }

    /// Returns a view in a hierarchy for positioning the tooltip on the screen.
    var viewForTooltip: View { get }

    /// The preferred location for displaying tooltips of this provider.
    var preferredTooltipLocation: PreferredTooltipLocation { get }
}
