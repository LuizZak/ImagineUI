import Foundation
import Geometry

/// Base empty control system class that can be overridden with implementation.
open class BaseControlSystem: ControlSystemType {
    public weak var delegate: BaseControlSystemDelegate?

    public init() {

    }

    // MARK: - Window management

    public func bringRootViewToFront(_ rootView: RootView) {
        delegate?.bringRootViewToFront(rootView)
    }

    // MARK: - Mouse Events

    open func onMouseLeave() {

    }

    open func onMouseDown(_ event: MouseEventArgs) {

    }

    open func onMouseMove(_ event: MouseEventArgs) {

    }

    open func onMouseUp(_ event: MouseEventArgs) {

    }

    open func onMouseWheel(_ event: MouseEventArgs) {

    }

    // MARK: - Keyboard Events

    open func onKeyDown(_ event: KeyEventArgs) {

    }

    open func onKeyUp(_ event: KeyEventArgs) {

    }

    open func onKeyPress(_ event: KeyPressEventArgs) {

    }

    open func onPreviewKeyDown(_ event: PreviewKeyDownEventArgs) {

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

    open func openDialog(_ view: any UIDialog, location: UIDialogInitialLocation) -> Bool {
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
