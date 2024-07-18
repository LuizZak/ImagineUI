import Geometry

public protocol BaseControlSystemDelegate: AnyObject {
    @ImagineActor
    func bringRootViewToFront(_ rootView: RootView)

    @ImagineActor
    func controlViewUnder(point: UIVector, controlKinds: ControlKinds) -> ControlView?
    @ImagineActor
    func controlViewUnder(
        point: UIVector,
        forEventRequest: EventRequest,
        controlKinds: ControlKinds
    ) -> ControlView?

    @ImagineActor
    func setMouseCursor(_ cursor: MouseCursorKind)
    @ImagineActor
    func setMouseHiddenUntilMouseMoves()
    @ImagineActor
    func firstResponderChanged(_ newFirstResponder: KeyboardEventHandler?)

    /// Requests a view to display a dialog on.
    @ImagineActor
    func viewForDialog(_ dialog: UIDialog, location: UIDialogInitialLocation) -> View

    /// Requests a tooltip manager from the delegate.
    func tooltipsManager() -> TooltipsManagerType?
}
