import Geometry

// TODO: Consider making Window also a control system of its own, to enable
// TODO: window-specific interception of inputs to better support tasks like
// TODO: resizing detection with the mouse within the client area.
public class DefaultControlSystem: ControlSystemType {
    /// Reference to the current tooltip provider being displayed.
    ///
    /// Is `nil` if no tooltip is currently displayed.
    private var _currentTooltipProvider: TooltipProvider?

    /// When mouse is down on a control, this is the control that the mouse
    /// was pressed down on
    private var _mouseDownTarget: MouseEventHandler?

    /// Last control the mouse was resting on top of on the last call to `onMouseMove`
    ///
    /// Used to handle `onMouseEnter`/`onMouseLeave` on controls
    private var _mouseHoverTarget: MouseEventHandler?

    /// First responder for keyboard events
    private var _firstResponder: KeyboardEventHandler?

    public weak var delegate: DefaultControlSystemDelegate?

    public init() {

    }

    // MARK: - Window management

    public func bringRootViewToFront(_ rootView: RootView) {
        delegate?.bringRootViewToFront(rootView)
    }

    // MARK: - Mouse Events

    public func onMouseLeave(_ event: MouseEventArgs) {
        if _mouseHoverTarget != nil {
            _mouseHoverTarget?.onMouseLeave()
            _mouseHoverTarget = nil
        }
    }

    public func onMouseDown(_ event: MouseEventArgs) {
        // Find control
        guard let control = delegate?.controlViewUnder(point: event.location, enabledOnly: true) else {
            _firstResponder?.resignFirstResponder()
            return
        }

        // Request that the given root view be brought to the front of the views
        // list to be rendered on top of all other views.
        if let rootView = control.rootView {
            bringRootViewToFront(rootView)
        }

        // TODO: Consider registering double clicks on mouse down on Windows
        // TODO: as a response to events WM_LBUTTONDOWN, WM_LBUTTONUP,
        // TODO: WM_LBUTTONDBLCLK, and WM_LBUTTONUP, as per Win32 documentation:
        // TODO: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-lbuttondblclk#remarks

        // Make request
        let request = InnerMouseEventRequest(event: event, eventType: .mouseDown) { handler in
            handler.onMouseDown(event.convertLocation(handler: handler))

            self._mouseDownTarget = handler

            if handler !== self._firstResponder && handler.canBecomeFirstResponder {
                self._firstResponder?.resignFirstResponder()
            }
        }

        control.handleOrPass(request)
    }

    public func onMouseMove(_ event: MouseEventArgs) {
        delegate?.updateTooltipCursorLocation(event.location)

        // Fixed mouse-over on control that was pressed down
        if let mouseDownTarget = _mouseDownTarget {
            mouseDownTarget.onMouseMove(event.convertLocation(handler: mouseDownTarget))
        } else {
            updateMouseOver(event: event, eventType: .mouseMove)
        }
    }

    public func onMouseUp(_ event: MouseEventArgs) {
        if let control = _mouseDownTarget {
            control.onMouseUp(event.convertLocation(handler: control))

            // Figure out if it's a click or mouse up event
            // Click events fire when mouseDown + mouseUp occur over the same element
            if let upControl = delegate?.controlViewUnder(point: event.location, enabledOnly: true), upControl === control {
                upControl.onMouseClick(event.convertLocation(handler: upControl))
            }

            _mouseDownTarget = nil

            updateMouseOver(event: event, eventType: .mouseMove)
        }
    }

    public func onMouseWheel(_ event: MouseEventArgs) {
        if let control = delegate?.controlViewUnder(point: event.location, enabledOnly: true) {
            // Make request
            let request = InnerMouseEventRequest(event: event, eventType: .mouseWheel) { handler in
                if let mouse = self._mouseDownTarget {
                    mouse.onMouseWheel(event.convertLocation(handler: mouse))
                } else {
                    handler.onMouseWheel(event.convertLocation(handler: handler))
                }
            }

            control.handleOrPass(request)
        }
    }

    // MARK: - Keyboard Events

    public func onKeyDown(_ event: KeyEventArgs) {
        guard let responder = _firstResponder else {
            return
        }

        let request = InnerKeyboardEventRequest(eventType: .keyDown) { handler in
            handler.onKeyDown(event)
        }

        responder.handleOrPass(request)
    }

    public func onKeyUp(_ event: KeyEventArgs) {
        guard let responder = _firstResponder else {
            return
        }

        let request = InnerKeyboardEventRequest(eventType: .keyUp) { handler in
            handler.onKeyUp(event)
        }

        responder.handleOrPass(request)
    }

    public func onKeyPress(_ event: KeyPressEventArgs) {
        guard let responder = _firstResponder else {
            return
        }

        let request = InnerKeyboardEventRequest(eventType: .keyPress) { handler in
            handler.onKeyPress(event)
        }

        responder.handleOrPass(request)
    }

    public func onPreviewKeyDown(_ event: PreviewKeyDownEventArgs) {
        guard let responder = _firstResponder else {
            return
        }

        let request = InnerKeyboardEventRequest(eventType: .previewKeyDown) { handler in
            handler.onPreviewKeyDown(event)
        }

        responder.handleOrPass(request)
    }

    // MARK: - Mouse Target Management

    private func updateMouseOver(event: MouseEventArgs, eventType: MouseEventType) {
        guard let control = delegate?.controlViewUnder(point: event.location, enabledOnly: true) else {
            hideTooltip()

            _mouseHoverTarget?.onMouseLeave()
            _mouseHoverTarget = nil
            return
        }

        // Make request
        let request = InnerMouseEventRequest(event: event, eventType: eventType) { handler in
            if self._mouseHoverTarget !== handler {
                self._mouseHoverTarget?.onMouseLeave()
                handler.onMouseEnter()

                if let tooltipProvider = handler as? TooltipProvider {
                    self.showTooltip(for: tooltipProvider)
                }

                self._mouseHoverTarget = handler
            }
            else
            {
                self._mouseHoverTarget?.onMouseMove(event.convertLocation(handler: handler))
            }
        }

        control.handleOrPass(request)

        if request.notAccepted {
            _mouseHoverTarget?.onMouseLeave()
            _mouseHoverTarget = nil
        }
    }

    // MARK: - First Responder Management

    public func setAsFirstResponder(_ eventHandler: EventHandler?, force: Bool) -> Bool {
        guard let firstResponder = eventHandler as? KeyboardEventHandler else {
            return false
        }

        if let oldFirstResponder = _firstResponder {
            if !oldFirstResponder.canResignFirstResponder && !force {
                return false
            }

            oldFirstResponder.resignFirstResponder()
        }

        _firstResponder = firstResponder
        delegate?.firstResponderChanged(_firstResponder)

        return true
    }

    public func removeAsFirstResponder(_ eventHandler: EventHandler) -> Bool {
        if isFirstResponder(eventHandler) {
            _firstResponder = nil
            delegate?.firstResponderChanged(_firstResponder)
            return true
        }

        return false
    }

    public func removeAsFirstResponder(anyInHierarchy view: View) -> Bool {
        guard let firstResponder = _firstResponder else {
            return false
        }
        guard let firstResponderView = firstResponder as? View, firstResponderView.isDescendant(of: view) else {
            return false
        }

        firstResponder.resignFirstResponder()

        return true
    }

    public func isFirstResponder(_ eventHandler: EventHandler) -> Bool {
        return _firstResponder === eventHandler
    }

    // MARK: - Tooltip

    /// Returns `true` if a tooltip is currently visible on screen.
    public func isTooltipVisible() -> Bool {
        _currentTooltipProvider != nil
    }

    /// Hides any currently visible tooltip.
    public func hideTooltip() {
        guard isTooltipVisible() else {
            return
        }

        delegate?.hideTooltip()

        _currentTooltipProvider = nil
    }

    public func showTooltip(for tooltipProvider: TooltipProvider) {
        if isTooltipVisible() {
            hideTooltip()
        }

        guard let tooltip = tooltipProvider.tooltip else {
            return
        }

        _currentTooltipProvider = tooltipProvider

        delegate?.showTooltip(tooltip, view: tooltipProvider.viewForTooltip, location: tooltipProvider.preferredTooltipLocation)
    }

    public func hideTooltip(for view: ControlView) {
        guard let current = _currentTooltipProvider else {
            return
        }
        guard let asView = current as? View else {
            return
        }
        guard asView == view else {
            return
        }

        hideTooltip()
    }

    public func hideTooltipFor(anyInHierarchy view: View) {
        guard let tooltipView = _currentTooltipProvider as? ControlView else {
            return
        }

        if tooltipView.isDescendant(of: view) {
            hideTooltip(for: tooltipView)
        }
    }

    // MARK: - Mouse Cursor

    public func setMouseCursor(_ cursor: MouseCursorKind) {
        delegate?.setMouseCursor(cursor)
    }

    public func setMouseHiddenUntilMouseMoves() {
        delegate?.setMouseHiddenUntilMouseMoves()
    }
}

private extension MouseEventArgs {
    func convertLocation(handler: EventHandler) -> MouseEventArgs {
        var mouseEvent = self
        mouseEvent.location = handler.convertFromScreen(mouseEvent.location)
        return mouseEvent
    }
}

private class InnerEventRequest<THandler> : EventRequest {
    private var onAccept: (THandler) -> Void
    private(set) var notAccepted = true

    init(onAccept: @escaping (THandler) -> Void) {
        self.onAccept = onAccept
    }

    func accept(handler: EventHandler) {
        guard let casted = handler as? THandler else {
            return
        }

        notAccepted = false
        onAccept(casted)
    }
}

private class InnerMouseEventRequest: InnerEventRequest<MouseEventHandler>, MouseEventRequest {
    var screenLocation: UIVector
    var buttons: MouseButton
    var delta: UIVector
    var clicks: Int
    var eventType: MouseEventType
    var modifiers: KeyboardModifier

    convenience init(event: MouseEventArgs, eventType: MouseEventType, onAccept: @escaping (MouseEventHandler) -> Void) {
        self.init(
            screenLocation: event.location,
            buttons: event.buttons,
            delta: event.delta,
            clicks: event.clicks,
            modifiers: event.modifiers,
            eventType: eventType,
            onAccept: onAccept
        )
    }

    init(screenLocation: UIVector,
         buttons: MouseButton,
         delta: UIVector,
         clicks: Int,
         modifiers: KeyboardModifier,
         eventType: MouseEventType,
         onAccept: @escaping (MouseEventHandler) -> Void) {

        self.screenLocation = screenLocation
        self.buttons = buttons
        self.delta = delta
        self.clicks = clicks
        self.modifiers = modifiers
        self.eventType = eventType

        super.init(onAccept: onAccept)
    }
}

private class InnerKeyboardEventRequest: InnerEventRequest<KeyboardEventHandler>, KeyboardEventRequest {
    var eventType: KeyboardEventType

    init(eventType: KeyboardEventType, onAccept: @escaping (KeyboardEventHandler) -> Void) {
        self.eventType = eventType
        super.init(onAccept: onAccept)
    }
}
