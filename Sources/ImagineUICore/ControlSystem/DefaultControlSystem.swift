import Foundation
import Geometry

// TODO: Consider making Window also a control system of its own, to enable
// TODO: window-specific interception of inputs to better support tasks like
// TODO: resizing detection with the mouse within the client area.
public class DefaultControlSystem: BaseControlSystem {
    /// A container to overlay on dialog view targets.
    private let _dialogsContainer: View = View()

    /// Indicates a currently opened dialog.
    private var _dialogState: DialogState?

    /// Wrapper for timed tooltip display operations.
    private let _tooltipWrapper: TooltipDisplayWrapper = TooltipDisplayWrapper()

    /// When mouse is down on a control, this is the control that the mouse
    /// was pressed down on
    private var _mouseDownTarget: MouseEventHandler?

    /// Last control the mouse was resting on top of on the last call to `onMouseMove`
    ///
    /// Used to handle `onMouseEnter`/`onMouseLeave` on controls
    private var _mouseHoverTarget: MouseEventHandler?

    /// Current mouse position atop _mouseHoverTarget.
    private var _mouseHoverPoint: UIVector = .zero

    /// First responder for keyboard events
    private var _firstResponder: KeyboardEventHandler?

    private var tooltipsManager: TooltipsManagerType? {
        delegate?.tooltipsManager()
    }

    /// If this control system should issue `bringRootViewToFront(_:)` calls when
    /// mouse interactions are issued to root views.
    ///
    /// Defaults to `true`.
    public var shouldReorderRootViews: Bool = true

    override public init() {

    }

    // MARK: - Mouse Events

    public override func onMouseLeave() {
        if _mouseHoverTarget != nil {
            _mouseHoverTarget?.onMouseLeave()
            _mouseHoverTarget = nil
        }
    }

    public override func onMouseDown(_ event: MouseEventArgs) {
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

        // Find control
        guard let control = delegate?.controlViewUnder(
            point: event.location,
            forEventRequest: request,
            controlKinds: .controls
        ) else {
            _firstResponder?.resignFirstResponder()
            return
        }

        hideTooltip(stopTimers: true)

        // Request that the given root view be brought to the front of the views
        // list to be rendered on top of all other views.
        if shouldReorderRootViews, let rootView = control.rootView {
            bringRootViewToFront(rootView)
        }

        control.handleOrPass(request)
    }

    public override func onMouseMove(_ event: MouseEventArgs) {
        // Fixed mouse-over on control that was pressed down
        if let mouseDownTarget = _mouseDownTarget {
            mouseDownTarget.onMouseMove(event.convertLocation(handler: mouseDownTarget))
        } else {
            updateMouseOver(event: event, eventType: .mouseMove)
        }
    }

    public override func onMouseUp(_ event: MouseEventArgs) {
        guard let handler = _mouseDownTarget else {
            return
        }

        handler.onMouseUp(event.convertLocation(handler: handler))

        // Figure out if it's a click or mouse up event
        // Click events fire when mouseDown + mouseUp occur over the same element
        let request = InnerMouseEventRequest(event: event, eventType: .mouseClick) { clickHandler in
            if clickHandler === handler {
                clickHandler.onMouseClick(event.convertLocation(handler: clickHandler))
            }
        }

        if let control = delegate?.controlViewUnder(
            point: event.location,
            forEventRequest: request,
            controlKinds: .controls
        ) {
            control.handleOrPass(request)
        }

        _mouseDownTarget = nil

        // Dispatch a mouse move, in case the mouse up event caused objects
        // on screen to shuffle.
        updateMouseOver(event: event, eventType: .mouseMove)
    }

    public override func onMouseWheel(_ event: MouseEventArgs) {
        // Make request
        let request = InnerMouseEventRequest(event: event, eventType: .mouseWheel) { handler in
            if let mouse = self._mouseDownTarget {
                mouse.onMouseWheel(event.convertLocation(handler: mouse))
            } else {
                handler.onMouseWheel(event.convertLocation(handler: handler))
            }
        }

        guard let control = delegate?.controlViewUnder(
            point: event.location,
            forEventRequest: request,
            controlKinds: .controls
        ) else {
            return
        }

        control.handleOrPass(request)

        // Dispatch a mouse move, in case the mouse wheel event caused objects
        // on screen to shuffle.
        if request.accepted {
            updateMouseOver(event: event, eventType: .mouseMove)
        }
    }

    // MARK: - Keyboard Events

    public override func onKeyDown(_ event: KeyEventArgs) {
        guard let responder = _firstResponder else {
            return
        }

        hideTooltip(stopTimers: true)

        let request = InnerKeyboardEventRequest(eventType: .keyDown) { handler in
            handler.onKeyDown(event)
        }

        responder.handleOrPass(request)
    }

    public override func onKeyUp(_ event: KeyEventArgs) {
        guard let responder = _firstResponder else {
            return
        }

        hideTooltip(stopTimers: true)

        let request = InnerKeyboardEventRequest(eventType: .keyUp) { handler in
            handler.onKeyUp(event)
        }

        responder.handleOrPass(request)
    }

    public override func onKeyPress(_ event: KeyPressEventArgs) -> Bool {
        guard let responder = _firstResponder else {
            return false
        }

        hideTooltip(stopTimers: true)

        let request = InnerKeyboardEventRequest(eventType: .keyPress) { handler in
            handler.onKeyPress(event)
        }

        responder.handleOrPass(request)

        return request.accepted
    }

    public override func onPreviewKeyDown(_ event: PreviewKeyDownEventArgs) {
        guard let responder = _firstResponder else {
            return
        }

        hideTooltip(stopTimers: true)

        let request = InnerKeyboardEventRequest(eventType: .previewKeyDown) { handler in
            handler.onPreviewKeyDown(event)
        }

        responder.handleOrPass(request)
    }

    // MARK: - Mouse Target Management

    private func updateMouseOver(event: MouseEventArgs, eventType: MouseEventType) {
        let bailOut: () -> Void = {
            self._mouseHoverTarget?.onMouseLeave()
            self._mouseHoverTarget = nil
            self._mouseHoverPoint = .zero

            self.hideTooltip(stopTimers: true)
        }

        // Make request
        let request = InnerMouseEventRequest(event: event, eventType: eventType) { handler in
            if self._mouseHoverTarget !== handler {
                self._mouseHoverTarget?.onMouseLeave()
                self.hideTooltip()
                handler.onMouseEnter()

                self._mouseHoverTarget = handler
                self._mouseHoverPoint = event.convertLocation(handler: handler).location

                if
                    event.buttons.isEmpty || self._mouseDownTarget == nil,
                    let tooltipProvider = handler as? TooltipProvider
                {
                    self.startTooltipHoverTimer(provider: tooltipProvider)
                }
            } else {
                let converted = event.convertLocation(handler: handler)

                guard converted.location != self._mouseHoverPoint else {
                    return
                }

                self._mouseHoverPoint = converted.location
                self._mouseHoverTarget?.onMouseMove(converted)

                if
                    event.buttons.isEmpty || self._mouseDownTarget == nil,
                    let tooltipProvider = handler as? TooltipProvider, !self.isTooltipVisible()
                {
                    self.startTooltipHoverTimer(provider: tooltipProvider)
                }
            }
        }

        guard let control = delegate?.controlViewUnder(
            point: event.location,
            forEventRequest: request,
            controlKinds: .controls
        ) else {
            return bailOut()
        }

        control.handleOrPass(request)

        if !request.accepted {
            bailOut()
        }
    }

    // MARK: - View hierarchy changes

    public override func viewRemovedFromHierarchy(_ view: View) {
        _=removeAsFirstResponder(anyInHierarchy: view)
        hideTooltipFor(anyInHierarchy: view)

        if let asView = _mouseHoverTarget as? View, asView.isDescendant(of: view) {
            _mouseHoverTarget = nil
            _mouseHoverPoint = .zero
        }
        if let asView = _mouseDownTarget as? View, asView.isDescendant(of: view) {
            _mouseDownTarget = nil
        }
    }

    // MARK: - First Responder Management

    public override func setAsFirstResponder(_ eventHandler: EventHandler?, force: Bool) -> Bool {
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

    public override func removeAsFirstResponder(_ eventHandler: EventHandler) -> Bool {
        if isFirstResponder(eventHandler) {
            _firstResponder = nil
            delegate?.firstResponderChanged(_firstResponder)
            return true
        }

        return false
    }

    public override func removeAsFirstResponder(anyInHierarchy view: View) -> Bool {
        guard let firstResponder = _firstResponder else {
            return false
        }
        guard let firstResponderView = firstResponder as? View, firstResponderView.isDescendant(of: view) else {
            return false
        }

        firstResponder.resignFirstResponder()

        return true
    }

    public override func isFirstResponder(_ eventHandler: EventHandler) -> Bool {
        return _firstResponder === eventHandler
    }

    // MARK: - Dialog

    public override func openDialog(_ view: UIDialog, location: UIDialogInitialLocation) -> Bool {
        return _openDialog(view, location: location)
    }

    private func _setupDialogsContainer(_ dialog: UIDialog, location: UIDialogInitialLocation) {
        guard let view = delegate?.viewForDialog(dialog, location: location) else {
            return
        }

        view.addSubview(_dialogsContainer)

        _dialogsContainer.layout.makeConstraints { make in
            make.edges == view
        }
    }

    private func _teardownDialogsContainer() {
        _dialogsContainer.removeFromSuperview()
    }

    private func _openDialog(_ dialog: UIDialog, location: UIDialogInitialLocation) -> Bool {
        if _dialogState != nil {
            return false
        }

        _setupDialogsContainer(dialog, location: location)

        let background: View
        if let suggestedBackground = dialog.customBackdrop() {
            background = suggestedBackground
        } else {
            let bg = ControlView()
            bg.backColor = .black.withTransparency(20)
            background = bg
        }

        let shadowRadius: Double = 8.0
        let dropShadowView = DropShadowView(shadowRadius: shadowRadius)

        let state = DialogState(dialog: dialog, background: background, dropShadowView: dropShadowView)

        _dialogState = state

        _dialogsContainer.withSuspendedLayout(setNeedsLayout: true) {
            _dialogsContainer.addSubview(background)
            _dialogsContainer.addSubview(dropShadowView)
            _dialogsContainer.addSubview(dialog)

            background.layout.makeConstraints { make in
                make.edges == _dialogsContainer
            }

            dropShadowView.layout.makeConstraints { make in
                make.edges.equalTo(dialog, inset: -UIEdgeInsets(shadowRadius))
            }
        }

        switch location {
        case .unspecified:
            break

        case .topLeft(let location, nil):
            dialog.location = location

        case .topLeft(let location, let reference?):
            dialog.location = reference.convert(point: location, to: nil)

        case .centered:
            // Refresh layout to acquire the proper view size
            dialog.performLayout()

            dialog.location = (_dialogsContainer.size / 2 - dialog.size / 2).asUIPoint
        }

        dialog.dialogDelegate = self

        dialog.didOpen()

        return true
    }

    private func _removeDialog() {
        guard let state = _dialogState else { return }

        _teardownDialogsContainer()

        state.background.removeFromSuperview()
        state.dropShadowView.removeFromSuperview()
        state.dialog.removeFromSuperview()

        _dialogState = nil

        state.dialog.didClose()
    }

    // MARK: - Tooltip

    public override func hideTooltipFor(anyInHierarchy view: View) {
        guard let tooltipOwnerView = _tooltipWrapper.currentProvider() as? ControlView else {
            return
        }

        if tooltipOwnerView.isDescendant(of: view) {
            hideTooltip(for: tooltipOwnerView)
        }
    }

    /// Returns `true` if a tooltip is currently visible on screen.
    public func isTooltipVisible() -> Bool {
        _tooltipWrapper.isVisible()
    }

    /// Hides any currently visible tooltip.
    public func hideTooltip(stopTimers: Bool = false) {
        if stopTimers {
            stopTooltipHoverTimer()
        }

        guard isTooltipVisible() else {
            return
        }

        tooltipsManager?.hideTooltip()

        _tooltipWrapper.setHidden()
    }

    /// Starts a custom tooltip display mode where the caller has exclusive
    /// access to the tooltip control until it is either revoked or the lifetime
    /// of the returned `CustomTooltipHandlerType` reaches its end.
    ///
    /// Method returns `nil` if another custom tooltip handler is already active.
    public func beginCustomTooltipLifetime() -> CustomTooltipHandlerType? {
        return tooltipsManager?.beginCustomTooltipLifetime()
    }

    /// Shows a tooltip from a given provider.
    ///
    /// Dismisses any currently visible tooltips in the process.
    public func showTooltip(
        for tooltipProvider: TooltipProvider,
        location: PreferredTooltipLocation? = nil
    ) {
        guard tooltipsManager?.hasCustomTooltipActive == false else { return }

        if isTooltipVisible() {
            hideTooltip()
        }

        guard matchesTooltipCondition(tooltipProvider) else {
            return
        }
        guard let tooltip = tooltipProvider.tooltip else {
            return
        }

        _tooltipWrapper.setDisplay(provider: tooltipProvider, onUpdate: { [weak self] tooltip in
            guard let self = self else { return }

            if let tooltip = tooltip {
                self.updateTooltipContents(tooltip)
            } else {
                self.hideTooltip()
            }
        })

        tooltipsManager?.showTooltip(
            tooltip,
            view: tooltipProvider.viewForTooltip,
            location: location ?? tooltipProvider.preferredTooltipLocation
        )
    }

    public func hideTooltip(for view: ControlView) {
        guard tooltipsManager?.hasCustomTooltipActive == false else { return }

        guard let current = _tooltipWrapper.currentProvider() else {
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

    private func startTooltipHoverTimer(provider: TooltipProvider) {
        guard tooltipsManager?.hasCustomTooltipActive == false else { return }

        guard !isTooltipVisible() else {
            return
        }

        guard matchesTooltipCondition(provider) else {
            return
        }

        _tooltipWrapper.setHover(provider: provider) {
            guard self.tooltipsManager?.hasCustomTooltipActive == false else { return }

            let obj = provider as AnyObject
            if self._mouseHoverTarget === obj {
                self.showTooltip(for: provider)
            } else {
                self.hideTooltip()
                self._tooltipWrapper.setHidden()
            }
        }
    }

    /// Stops any tooltip hover timer that is ongoing.
    private func stopTooltipHoverTimer() {
        guard _tooltipWrapper.isHoverTimerRunning() else {
            return
        }

        _tooltipWrapper.setHidden()
    }

    private func updateTooltipContents(_ tooltip: Tooltip) {
        guard tooltipsManager?.hasCustomTooltipActive == false else { return }

        tooltipsManager?.updateTooltip(tooltip)
    }

    private func matchesTooltipCondition(_ tooltipProvider: TooltipProvider) -> Bool {
        switch tooltipProvider.tooltipCondition {
        case .always:
            return true

        case .viewPartiallyOccluded:
            let view = tooltipProvider.viewForTooltip

            return !view.isFullyVisibleOnScreen(area: view.bounds)
        }
    }

    // MARK: - Mouse Cursor

    public override func setMouseCursor(_ cursor: MouseCursorKind) {
        delegate?.setMouseCursor(cursor)
    }

    public override func setMouseHiddenUntilMouseMoves() {
        delegate?.setMouseHiddenUntilMouseMoves()
    }

    // MARK: -

    /// Wraps the state of a displayed dialog.
    private struct DialogState {
        /// The dialog window currently opened.
        var dialog: UIDialog

        /// Background that obscures the underlying views
        var background: View

        /// View that renders the drop shadow for the dialog view.
        var dropShadowView: View
    }

    private class DropShadowView: View {
        var shadowColor: Color = .black {
            didSet {
                invalidate()
            }
        }

        var shadowRadius: Double {
            didSet {
                invalidate()
            }
        }

        /// Value between 0 - 1 that indicates how dark the shadow will be.
        /// Values of 0 render no shadow, 1 renders a fully opaque black box
        /// that graduates into a transparent color towards the corners of the
        /// view's bounds according to the shadow radius.
        var shadowFactor: Double = 0.3 {
            didSet {
                invalidate()
            }
        }

        private var effectiveShadowColor: Color {
            shadowColor.withTransparency(Int(255 * shadowFactor))
        }

        init(shadowRadius: Double) {
            self.shadowRadius = shadowRadius

            super.init()
        }

        override func render(in renderer: Renderer, screenRegion: ClipRegionType) {
            renderer.withTemporaryState {
                renderer.setFill(effectiveShadowColor)
                renderer.fill(bounds.insetBy(x: shadowRadius * 2, y: shadowRadius * 2))

                _drawCornerGradient(renderer: renderer, corner: .topLeft, radius: shadowRadius)
                _drawCornerGradient(renderer: renderer, corner: .topRight, radius: shadowRadius)
                _drawCornerGradient(renderer: renderer, corner: .bottomRight, radius: shadowRadius)
                _drawCornerGradient(renderer: renderer, corner: .bottomLeft, radius: shadowRadius)

                _drawSideGradient(renderer: renderer, side: .left, length: shadowRadius)
                _drawSideGradient(renderer: renderer, side: .top, length: shadowRadius)
                _drawSideGradient(renderer: renderer, side: .right, length: shadowRadius)
                _drawSideGradient(renderer: renderer, side: .bottom, length: shadowRadius)
            }
        }

        private func _gradientStops() -> [Gradient.Stop] {
            let baseColor = effectiveShadowColor

            return [
                .init(offset: 0, color: baseColor),
                .init(offset: 1, color: baseColor.withTransparency(0))
            ]
        }

        private func _drawCornerGradient(renderer: Renderer, corner: GradientCorner, radius: Double) {
            let radiusVector = UIVector(repeating: radius)
            var gradientCircle = UICircle(center: .zero, radius: radius)
            let arcStart: Double
            let arcSweep: Double = .pi / 2

            switch corner {
            case .topLeft:
                gradientCircle.center = bounds.topLeft + radiusVector
                arcStart = .pi

            case .topRight:
                gradientCircle.center = bounds.topRight + radiusVector * UIVector(x: -1, y: 1)
                arcStart = -.pi / 2

            case .bottomRight:
                gradientCircle.center = bounds.bottomRight - radiusVector
                arcStart = 0

            case .bottomLeft:
                gradientCircle.center = bounds.bottomLeft + radiusVector * UIVector(x: 1, y: -1)
                arcStart = .pi / 2
            }

            let pie = gradientCircle.arc(start: arcStart, sweep: arcSweep)

            let gradient = Gradient.radial(
                center: gradientCircle.center,
                radius: radius,
                stops: _gradientStops()
            )

            renderer.withTemporaryState {
                renderer.setFill(gradient)
                renderer.fill(pie: pie)
            }
        }

        private func _drawSideGradient(renderer: Renderer, side: GradientSide, length: Double) {
            let start: UIVector
            let end: UIVector
            var gradientBounds: UIRectangle

            switch side {
            case .left:
                start = bounds.topLeft + UIVector(x: length, y: 0)
                end = bounds.topLeft
                gradientBounds =
                    UIRectangle(
                        location: bounds.topLeft + UIVector(x: 0, y: length),
                        size: UISize(width: length, height: bounds.height - length * 2)
                    )

            case .top:
                start = bounds.topLeft + UIVector(x: 0, y: length)
                end = bounds.topLeft
                gradientBounds =
                    UIRectangle(
                        location: bounds.topLeft + UIVector(x: length, y: 0),
                        size: UISize(width: bounds.width - length * 2, height: length)
                    )

            case .right:
                start = bounds.topRight - UIVector(x: length, y: 0)
                end = bounds.topRight
                gradientBounds =
                    UIRectangle(
                        location: bounds.topRight - UIPoint(x: length, y: -length),
                        size: UISize(width: length, height: bounds.height - length * 2)
                    )

            case .bottom:
                start = bounds.bottomLeft - UIVector(x: 0, y: length)
                end = bounds.bottomLeft
                gradientBounds =
                    UIRectangle(
                        location: bounds.bottomLeft - UIPoint(x: -length, y: length),
                        size: UISize(width: bounds.width - length * 2, height: length)
                    )
            }

            let gradient = Gradient.linear(
                start: start,
                end: end,
                stops: _gradientStops()
            )

            renderer.withTemporaryState {
                renderer.setFill(gradient)
                renderer.fill(gradientBounds)
            }
        }

        private enum GradientCorner {
            case topLeft
            case topRight
            case bottomRight
            case bottomLeft
        }

        private enum GradientSide {
            case left
            case top
            case right
            case bottom
        }
    }

    private class TooltipDisplayWrapper {
        private var _currentUpdateEvent: EventListenerKey? {
            willSet {
                _currentUpdateEvent?.removeListener()
            }
        }
        private var state: TooltipState {
            willSet {
                state.invalidateTimer()
            }
        }

        init() {
            state = .none
        }

        func isVisible() -> Bool {
            if case .displayed = state {
                return true
            }

            return false
        }

        func isHoverTimerRunning() -> Bool {
            if case .hovered = state {
                return true
            }

            return false
        }

        func currentProvider() -> TooltipProvider? {
            state.provider
        }

        func setDisplay(provider: TooltipProvider, onUpdate: @escaping (Tooltip?) -> Void) {
            state.invalidateTimer()

            state = .displayed(provider: provider)

            _currentUpdateEvent = provider.tooltipUpdated.addListener(weakOwner: self, onUpdate)
        }

        func setHover(provider: TooltipProvider, defaultDelay: TimeInterval = 0.5, callback: @escaping () -> Void) {
            _currentUpdateEvent = nil
            state.invalidateTimer()

            let delay = provider.tooltipDelay ?? defaultDelay

            if delay <= 0.0 {
                callback()
                return
            }

            let timer = Scheduler.instance.scheduleTimer(interval: delay) {
                callback()
            }
            state = .hovered(provider: provider, timer: timer)
        }

        func setHidden() {
            _currentUpdateEvent = nil
            state.invalidateTimer()
            state = .none
        }

        private enum TooltipState {
            case none
            case hovered(provider: TooltipProvider, timer: SchedulerTimerType)
            case displayed(provider: TooltipProvider)

            var provider: TooltipProvider? {
                switch self {
                case .none:
                    return nil
                case .hovered(let provider, _), .displayed(let provider):
                    return provider
                }
            }

            func invalidateTimer() {
                switch self {
                case .hovered(_, let timer):
                    timer.invalidate()
                default:
                    break
                }
            }
        }
    }
}

extension DefaultControlSystem: UIDialogDelegate {
    public func dialogWantsToClose(_ dialog: UIDialog) {
        guard dialog === _dialogState?.dialog else { return }

        _removeDialog()
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

    private(set) var accepted: Bool = false

    init(onAccept: @escaping (THandler) -> Void) {
        self.onAccept = onAccept
    }

    func accept(handler: EventHandler) {
        guard let casted = handler as? THandler else {
            return
        }

        accepted = true
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

    convenience init(
        event: MouseEventArgs,
        eventType: MouseEventType,
        onAccept: @escaping (MouseEventHandler) -> Void
    ) {

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

    init(
        screenLocation: UIVector,
        buttons: MouseButton,
        delta: UIVector,
        clicks: Int,
        modifiers: KeyboardModifier,
        eventType: MouseEventType,
        onAccept: @escaping (MouseEventHandler) -> Void
    ) {

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

    init(
        eventType: KeyboardEventType,
        onAccept: @escaping (KeyboardEventHandler) -> Void
    ) {

        self.eventType = eventType
        super.init(onAccept: onAccept)
    }
}
