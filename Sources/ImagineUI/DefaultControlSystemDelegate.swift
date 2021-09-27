import Geometry

public protocol DefaultControlSystemDelegate: AnyObject {
    func bringRootViewToFront(_ rootView: RootView)
    func controlViewUnder(point: UIVector, enabledOnly: Bool) -> ControlView?
    func setMouseCursor(_ cursor: MouseCursorKind)
    func setMouseHiddenUntilMouseMoves()
    func firstResponderChanged(_ newFirstResponder: ControlView?)
}
