import Foundation
import Geometry

/// Base empty control system class that can be overridden with implementation.
@ImagineActor
open class BaseControlSystem: ControlSystemType {
    public weak var delegate: BaseControlSystemDelegate?

    public init() {

    }

    // MARK: - Window management

    public func bringRootViewToFront(_ rootView: RootView) {
        delegate?.bringRootViewToFront(rootView)
    }

    // MARK: - Mouse Events

    open func onMouseLeave() async {

    }

    open func onMouseDown(_ event: MouseEventArgs) async {

    }

    open func onMouseMove(_ event: MouseEventArgs) async {

    }

    open func onMouseUp(_ event: MouseEventArgs) async {

    }

    open func onMouseWheel(_ event: MouseEventArgs) async {

    }

    // MARK: - Keyboard Events

    open func onKeyDown(_ event: KeyEventArgs) async {

    }

    open func onKeyUp(_ event: KeyEventArgs) async {

    }

    open func onKeyPress(_ event: KeyPressEventArgs) async -> Bool {
        return false
    }

    open func onPreviewKeyDown(_ event: PreviewKeyDownEventArgs) async {

    }

    // MARK: - View hierarchy changes

    open func viewRemovedFromHierarchy(_ view: View) {

    }

    // MARK: - First Responder Management

    open func setAsFirstResponder(_ eventHandler: EventHandler?, force: Bool) -> Bool {
        return false
    }

    open func removeAsFirstResponder(_ eventHandler: EventHandler) -> Bool {
        return false
    }

    open func removeAsFirstResponder(anyInHierarchy view: View) -> Bool {
        return false
    }

    open func isFirstResponder(_ eventHandler: EventHandler) -> Bool {
        return false
    }

    // MARK: - Dialog

    open func openDialog(_ view: any UIDialog, location: UIDialogInitialLocation) async -> Bool {
        false
    }

    // MARK: - Tooltip

    open func hideTooltipFor(anyInHierarchy view: View) {

    }

    // MARK: - Mouse Cursor

    open func setMouseCursor(_ cursor: MouseCursorKind) {
        delegate?.setMouseCursor(cursor)
    }

    open func setMouseHiddenUntilMouseMoves() {
        delegate?.setMouseHiddenUntilMouseMoves()
    }
}
