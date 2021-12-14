import Geometry

public protocol DefaultControlSystemDelegate: AnyObject {
    func bringRootViewToFront(_ rootView: RootView)
    func controlViewUnder(point: UIVector, controlKinds: ControlKinds) -> ControlView?
    func setMouseCursor(_ cursor: MouseCursorKind)
    func setMouseHiddenUntilMouseMoves()
    func firstResponderChanged(_ newFirstResponder: KeyboardEventHandler?)

    /// Requests a tooltip manager from the delegate.
    func tooltipsManager() -> TooltipsManagerType?
}
