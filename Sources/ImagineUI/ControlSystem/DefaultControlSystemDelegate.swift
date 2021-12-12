import Geometry

public protocol DefaultControlSystemDelegate: AnyObject {
    func bringRootViewToFront(_ rootView: RootView)
    func controlViewUnder(point: UIVector, enabledOnly: Bool) -> ControlView?
    func setMouseCursor(_ cursor: MouseCursorKind)
    func setMouseHiddenUntilMouseMoves()
    func firstResponderChanged(_ newFirstResponder: KeyboardEventHandler?)

    /// Requests that a tooltip be shown on screen for a given view.
    func showTooltip(_ tooltip: Tooltip, view: View, location: PreferredTooltipLocation)

    /// Requests that the tooltip previously shown be hidden from the screen.
    func hideTooltip()

    /// Updates the position of the mouse cursor for tooltips being displayed.
    func updateTooltipCursorLocation(_ location: UIPoint)
}
