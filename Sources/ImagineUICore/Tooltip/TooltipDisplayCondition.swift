import Foundation

/// Represents the conditions at which a tooltip from a `TooltipProvider` should
/// be displayed.
public enum TooltipDisplayCondition {
    /// The tooltip should be displayed if `TooltipProvider.viewForTooltip` is
    /// partially occluded on screen.
    case viewPartiallyOccluded

    /// The tooltip should always be displayed when the mouse hovers over the
    /// associated control.
    case always
}
