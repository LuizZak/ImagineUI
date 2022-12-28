import Foundation
import Geometry
import Rendering

/// A view that is augmented with the ability to be interacted as a UI element
/// by an user with mouse and keyboard input.
open class ControlView: View, TooltipProvider, MouseEventHandler, KeyboardEventHandler {
    /// Whether to cache all controls' contents as a bitmap.
    ///
    /// This increases memory usage and reduces quality of controls in scaled
    /// scenarios, but reduces CPU usage when re-rendering controls that had no
    /// state change.
    ///
    /// Can be overridden on a per-instance basis with `ControlView.cacheAsBitmap`.
    public static var globallyCacheAsBitmap: Bool = true

    private let _stateManager = StateManager()
    private var _isMouseDown: Bool = false
    private var _bitmapCache = ViewBitmapCache(isCachingEnabled: true)

    private var isRecursivelyVisible: Bool {
        var view: View? = self
        while let v = view {
            if !v.isVisible {
                return false
            }
            view = v.superview
        }

        return true
    }

    /// Overrides the default `ControlView.globallyCacheAsBitmap` value with a
    /// specified boolean value. If `nil`, the global value is used, instead.
    ///
    /// Defaults to `nil` on creation.
    open var cacheAsBitmap: Bool? = nil {
        didSet {
            guard cacheAsBitmap != oldValue else { return }

            invalidate()
        }
    }

    /// Returns whether this control is the first responder on the responder
    /// chain associated with the current control system.
    ///
    /// If no control system can be found for this view, this property should
    /// always returns `false`.
    open var isFirstResponder: Bool {
        return controlSystem?.isFirstResponder(self) ?? false
    }

    /// Returns whether this control view can become first responder, if requested.
    ///
    /// Assigning first responder status to controls make it so that they are
    /// the first event handler for keyboard inputs.
    open var canBecomeFirstResponder: Bool {
        return false
    }

    /// Returns whether this control view can resign its first responder status.
    ///
    /// Resigning first responder status resets the first responder chain back to
    /// the default state, and this control no longer receives keyboard events
    /// first.
    open var canResignFirstResponder: Bool {
        return true
    }

    /// Returns the next event handler on this control's view hierarchy.
    /// By default, returns the first superview of `ControlView` type that is
    /// found, recursively.
    open var next: EventHandler? {
        return ControlView.closestParentViewOfType(self, type: ControlView.self)
    }

    /// Overrides default bounds handling to respond to resize events by
    /// issuing a resize event and clearing bitmap caches, if available.
    open override var bounds: UIRectangle {
        didSet {
            if bounds.size != oldValue.size {
                _updateCacheBounds()
                onResize(ValueChangedEventArgs(oldValue: oldValue.size, newValue: bounds.size))
            }
        }
    }

    // MARK: - View states

    /// Gets or sets whether this control is in a "selected" state.
    open var isSelected: Bool {
        get { _stateManager.isSelected }
        set { _stateManager.isSelected = newValue }
    }

    /// Gets or sets whether this control is enabled.
    ///
    /// The semantics of what happens when a control is enabled or disabled is
    /// implemented in a per-control basis, but control systems may use this
    /// property to decide whether to ignore this control when handling user
    /// interface events.
    open var isEnabled: Bool {
        get { _stateManager.isEnabled }
        set { _stateManager.isEnabled = newValue }
    }

    /// Gets or sets whether this control is in a highlighted state.
    ///
    /// The semantics of a control that is highlighted is implemented on a
    /// per-control basis. For example, buttons and sliders might respond to mouse
    /// over events by enabling highlighting to change their display state to
    /// indicate they are responsive to mouse events.
    open var isHighlighted: Bool {
        get { _stateManager.isHighlighted }
        set { _stateManager.isHighlighted = newValue }
    }

    /// Gets the internally computed control view state.
    ///
    /// Control view states are calculated automatically based on
    /// `self.isHighlighted`, `self.isEnabled`, `self.isHighlighted`, and
    /// `self.isFirstResponder`, and the final state is computed by a priority
    /// checklist of states, setting the state based on the first condition on
    /// the following list that matches, and ignoring subsequent states:
    ///
    /// 1. If `isEnabled == false`, returns `.disabled`;
    /// 2. If `isFirstResponder == true`, returns `.focused`;
    /// 3. If `isSelected == true`, returns `.selected`;
    /// 4. If `isHighlighted == true`, returns `.highlighted`;
    /// 5. Otherwise, returns `.normal`.
    open var controlState: ControlViewState {
        return _stateManager.state
    }

    /// If `true`, `highlighted` is automatically toggled on and off whenever
    /// the user enters and exits this control with the mouse.
    ///
    /// Defaults to `true`.
    open var mouseOverHighlight: Bool = true

    /// If `true`, `selected` is automatically toggled on and off whenever the
    /// user holds down the mouse button on this control with the mouse.
    ///
    /// Defaults to `false`.
    open var mouseDownSelected: Bool = false

    // MARK: - Visual Style / Colors

    /// This view's neutral background color.
    open var backColor: Color = .transparentBlack { // TODO: Should be KnownColor.Control
        didSet {
            invalidate()
        }
    }

    /// This view's foreground color.
    open var foreColor: Color = .black {
        didSet {
            invalidate()
        }
    }

    /// Corner radius for this control's corners (does not affect clipping region).
    open var cornerRadius: Double = 0 {
        didSet {
            invalidate()
        }
    }

    /// Stroke color around the bounds of the control view.
    open var strokeColor: Color = .transparentBlack {
        didSet {
            invalidate()
        }
    }

    /// Stroke width.
    open var strokeWidth: Double = 0 {
        willSet {
            if strokeWidth != newValue {
                invalidate()
            }
        }
        didSet {
            if strokeWidth != oldValue {
                invalidate()
            }
        }
    }

    // MARK: - Events

    /// Event raised whenever a client requests that this view redraw itself on
    /// screen or to a buffer.
    ///
    /// This event is raised after the view's contents have been painted.
    @EventWithSender<ControlView, PaintEventArgs>
    public var painted

    /// Event raised whenever this control view's `currentState` value is changed
    @ValueChangedEventWithSender<ControlView, ControlViewState>
    public var stateChanged

    /// Event raised whenever this control view's bounds have been updated to a
    /// different value
    @ValueChangedEventWithSender<ControlView, UISize>
    public var resized

    // MARK: Mouse events

    /// Event raised whenever the user clicks this control view while enabled.
    ///
    /// Mouse location in event args is relative to the control view's bounds.
    @EventWithSender<ControlView, MouseEventArgs>
    public var mouseClicked

    /// Event raised whenever the user holds down on this control view with any
    /// mouse button.
    ///
    /// Mouse location in event args is relative to the control view's bounds.
    @EventWithSender<ControlView, MouseEventArgs>
    public var mouseDown

    /// Event raised whenever the user releases the mouse button they had held
    /// down previously on top of this control view.
    ///
    /// Mouse location in event args is relative to the control view's bounds.
    @EventWithSender<ControlView, MouseEventArgs>
    public var mouseUp

    /// Event raised whenever the user moves the mouse on top of this control view's
    /// area.
    ///
    /// Mouse location in event args is relative to the control view's bounds.
    @EventWithSender<ControlView, MouseEventArgs>
    public var mouseMoved

    /// Event raised when the user scrolls the mouse wheel while on top of this
    /// control.
    ///
    /// Mouse location in event args is relative to the control view's bounds.
    @EventWithSender<ControlView, MouseEventArgs>
    public var mouseWheelScrolled

    /// Event raised whenever the user enters this control view's area with the
    /// mouse cursor.
    ///
    /// Event may be delayed by a control system if the mouse cursor is entered
    /// after a mouse button was held down while on top of a different control,
    /// being raised instantly as soon as the mouse button is released while on
    /// top of this control.
    @EventWithSender<ControlView, Void>
    public var mouseEntered

    /// Event raised whenever the user leaves this control view's area with the
    /// mouse cursor.
    ///
    /// Event may be delayed by a control system if the mouse cursor exits after
    /// pressing a mouse button on top of this control, being raised instantly
    /// as soon as the mouse button is released while not on top of this control
    /// anymore.
    @EventWithSender<ControlView, Void>
    public var mouseExited

    // MARK: Keyboard events

    /// Event raised whenever the user presses a keyboard key while this view is
    /// the currently active first responder
    @EventWithSender<ControlView, KeyPressEventArgs>
    public var keyPressed

    /// Event raised whenever the user presses a keyboard key while this view is
    /// the currently active first responder
    @EventWithSender<ControlView, KeyEventArgs>
    public var keyDown

    /// Event raised whenever the user depresses a keyboard key while this view
    /// is the currently active first responder
    @EventWithSender<ControlView, KeyEventArgs>
    public var keyUp

    /// Event raised whenever the user presses a keyboard key while this view is
    /// the currently active first responder
    @EventWithSender<ControlView, PreviewKeyDownEventArgs>
    public var previewKeyDown

    // MARK: - Tooltip

    /// Controls whether the view should display a tooltip on mouse hover.
    public var showTooltip: Bool = true {
        didSet {
            _tooltipUpdated(showTooltip ? tooltip : nil)
        }
    }

    /// Gets the current tooltip value.
    public var tooltip: Tooltip? = nil {
        didSet {
            _tooltipUpdated(showTooltip ? tooltip : nil)
        }
    }

    /// Gets a reference for the view that a tooltip should be located next to.
    ///
    /// `ControlView` returns `self` by default.
    open var viewForTooltip: View {
        self
    }

    /// Event called whenever the contents of the tooltip have been updated.
    @Event<Tooltip?>
    public var tooltipUpdated

    /// The preferred location to display tooltips from this control.
    ///
    /// Defaults to `PreferredTooltipLocation.systemDefined`.
    open var preferredTooltipLocation: PreferredTooltipLocation {
        .systemDefined
    }

    /// Gets the conditions under which a tooltip from this tooltip provider
    /// should be displayed.
    ///
    /// Defaults to `.always`.
    open var tooltipCondition: TooltipDisplayCondition {
        .always
    }

    /// Preferred delay before a mouse hover event displays this control view's
    /// tooltip.
    open var tooltipDelay: TimeInterval? {
        nil
    }

    // MARK: -

    public override init() {
        super.init()

        _stateManager.stateChanged.addListener(weakOwner: self) { [weak self] event in
            self?.onStateChanged(event)
        }
    }

    /// Raises the `resized` event
    open func onResize(_ event: ValueChangedEventArgs<UISize>) {
        _resized(sender: self, event)
    }

    /// Raises the `stateChanged` event
    open func onStateChanged(_ event: ValueChangedEventArgs<ControlViewState>) {
        _stateChanged(sender: self, event)
    }

    // MARK: - Subviews

    open override func bringToFrontOfSuperview() {
        super.bringToFrontOfSuperview()

        invalidate()
    }

    // MARK: - Rendering

    /// Paints this control view on a given render context
    public final override func render(in renderer: Renderer, screenRegion: ClipRegionType) {
        super.render(in: renderer, screenRegion: screenRegion)

        renderer.withTemporaryState {
            _bitmapCache.isCachingEnabled = cacheAsBitmap ?? ControlView.globallyCacheAsBitmap

            _updateCacheBounds()
            _bitmapCache.cachingOrRendering(renderer) { ctx in
                renderBackground(in: ctx, screenRegion: screenRegion)
                renderForeground(in: ctx, screenRegion: screenRegion)
            }
        }

        _painted(sender: self, renderer)
    }

    /// Renders this view's background
    open func renderBackground(in renderer: Renderer, screenRegion: ClipRegionType) {
        let bounds = boundsForFillOrStroke()

        // Fill
        if backColor.alpha > 0 {
            renderer.setFill(backColor)

            if cornerRadius <= 0 {
                renderer.fill(bounds)
            } else {
                renderer.fill(bounds.makeRoundedRectangle(radius: cornerRadius))
            }
        }

        // Stroke
        if strokeColor.alpha > 0 && strokeWidth > 0 {
            renderer.setStroke(strokeColor)
            renderer.setStrokeWidth(strokeWidth)

            if cornerRadius <= 0 {
                renderer.stroke(bounds)
            } else {
                renderer.stroke(bounds.makeRoundedRectangle(radius: cornerRadius))
            }
        }
    }

    /// Renders this view's foreground content (not drawn on top of child views)
    open func renderForeground(in renderer: Renderer, screenRegion: ClipRegionType) {

    }

    /// Returns a rectangle on this control view's coordinate system that should
    /// be used for fill/stroke operations in `renderBackground`.
    ///
    /// Defaults to `self.bounds`.
    open func boundsForFillOrStroke() -> UIRectangle {
        bounds
    }

    /// The bounds that this control view renders into, taking into account the
    /// current back/fore/stroke color configuration, `self.strokerWidth` and
    /// `self.boundsForFillOrStroke()` values.
    open override func boundsForRedraw() -> UIRectangle {
        var result = bounds

        // Back color area
        if backColor.alpha > 0 {
            result = result.union(boundsForFillOrStroke())
        }

        // Stroke area
        if strokeColor.alpha > 0 && strokeWidth > 0 {
            let strokeArea = boundsForFillOrStroke().inflatedBy(x: strokeWidth * 2, y: strokeWidth * 2)

            result = result.union(strokeArea)
        }

        return result
    }

    internal override func invalidate(bounds: UIRectangle, spatialReference: SpatialReferenceType) {
        _updateCacheBounds()
        _bitmapCache.invalidateCache()

        super.invalidate(bounds: bounds, spatialReference: spatialReference)
    }

    private func _updateCacheBounds() {
        _bitmapCache.updateBitmapBounds(boundsForRedraw())
    }

    // MARK: - Event Handling / First Responder

    /// Queries whether this control view can handle a given event request, passing
    /// the event request to `self.next` if it wishes not to handle the event.
    ///
    /// This method is called initially by a control system while examining a
    /// control to respond to an event, and is passed along to `self.next` until
    /// either a control accepts the event via `eventRequest.accept(handler:)`,
    /// or the end of the responder chain is reached (`self.next == nil`).
    open func handleOrPass(_ eventRequest: EventRequest) {
        if !isVisible || !isRecursivelyInteractiveEnabled {
            next?.handleOrPass(eventRequest)
            return
        }

        if canHandle(eventRequest) {
            eventRequest.accept(handler: self)
        } else {
            next?.handleOrPass(eventRequest)
        }
    }

    /// Returns whether this control can handle a specified event request.
    ///
    /// By default, controls only respond to mouse events, except for mouse wheel,
    /// and ignore any other event type.
    ///
    /// Can be overridden by a subclass to customize event handling behaviour.
    open func canHandle(_ eventRequest: EventRequest) -> Bool {
        // Consume all mouse event requests (except mouse wheel) by default
        if let mouseEvent = eventRequest as? MouseEventRequest {
            return mouseEvent.eventType != MouseEventType.mouseWheel
        }

        return false
    }

    /// Requests that this control view become first responder on the responder
    /// chain, returning whether the control is successfully a first responder
    /// after the method returns.
    ///
    /// The control checks `self.canBecomeFirstResponder` and later requests
    /// that it be set as a first responder by an associated control system,
    /// returning `false` if it fails either query.
    @discardableResult
    open func becomeFirstResponder() -> Bool {
        if isFirstResponder {
            return true
        }
        if !canBecomeFirstResponder {
            return false
        }

        if controlSystem?.setAsFirstResponder(self, force: false) == true {
            _stateManager.isFirstResponder = true
            return true
        }

        return false
    }

    /// Requests that this control system resign its first responder status by
    /// requesting resignation from an associated control system.
    open func resignFirstResponder() {
        if controlSystem?.removeAsFirstResponder(self) == true {
            _stateManager.isFirstResponder = false
        }
    }

    // MARK: - Mouse Event Handling

    /// Raises the `mouseDown` event.
    open func onMouseDown(_ event: MouseEventArgs) {
        _mouseDown(sender: self, event)

        if mouseDownSelected {
            _isMouseDown = true
            isSelected = true
        }
    }

    /// Raises the `mouseMoved` event.
    open func onMouseMove(_ event: MouseEventArgs) {
        _mouseMoved(sender: self, event)

        if _isMouseDown {
            isSelected = contains(point: event.location)
        }
    }

    /// Raises the `mouseUp` event.
    open func onMouseUp(_ event: MouseEventArgs) {
        _mouseUp(sender: self, event)

        if _isMouseDown {
            isSelected = false
            _isMouseDown = false
        }
    }

    /// Raises the `mouseEntered` event.
    open func onMouseEnter() {
        _mouseEntered(sender: self)

        if mouseOverHighlight {
            isHighlighted = true
        }
    }

    /// Raises the `mouseExited` event.
    open func onMouseLeave() {
        _mouseExited(sender: self)

        if mouseOverHighlight {
            isHighlighted = false
        }
    }

    /// Raises the `mouseClicked` event.
    open func onMouseClick(_ event: MouseEventArgs) {
        _mouseClicked(sender: self, event)
    }

    /// Raises the `mouseWheelScrolled` event.
    open func onMouseWheel(_ event: MouseEventArgs) {
        _mouseWheelScrolled(sender: self, event)
    }

    // MARK: - Keyboard Event Handling

    /// Raises the `keyPressed` event.
    open func onKeyPress(_ event: KeyPressEventArgs) {
        _keyPressed(sender: self, event)
    }

    /// Raises the `keyDown` event.
    open func onKeyDown(_ event: KeyEventArgs) {
        _keyDown(sender: self, event)
    }

    /// Raises the `keyUp` event
    open func onKeyUp(_ event: KeyEventArgs) {
        _keyUp(sender: self, event)
    }

    /// Raises the `previewKeyDown` event.
    open func onPreviewKeyDown(_ event: PreviewKeyDownEventArgs) {
        _previewKeyDown(sender: self, event)
    }

    // MARK: -

    /// Returns the first control view under a given point on this control view.
    ///
    /// Returns nil, if no control was found.
    ///
    /// - Parameter point: Point to hit-test against, in local coordinates of
    /// this `ControlView`.
    /// - Parameter enabledOnly: Whether to only consider views that have
    /// interactivity enabled. See `interactionEnabled`.
    public func hitTestControl(_ point: UIVector, enabledOnly: Bool = true) -> ControlView? {
        let controlView = viewUnder(point: point) { view -> Bool in
            guard let control = view as? ControlView else {
                return false
            }

            return control.isRecursivelyVisible && (!enabledOnly || control.isRecursivelyInteractiveEnabled)
        }

        return controlView as? ControlView
    }

    /// Returns the first control view under a given point on this control view
    /// which is willing to respond to a given event request.
    ///
    /// Controls found are queried with `ControlView.canHandle` before being
    /// accepted.
    ///
    /// Note: Controls should not accept the passed event request at the point
    /// of this query, as this is handled by the control system after que hit
    /// test query is completed.
    ///
    /// Returns nil, if no control was found.
    ///
    /// - Parameter point: Point to hit-test against, in local coordinates of
    /// this `ControlView`.
    /// - Parameter eventRequest: The event request associated with this hit test.
    /// Usually associated with a mouse event request.
    /// - Parameter enabledOnly: Whether to only consider views that have
    /// interactivity enabled. See `interactionEnabled`.
    public func hitTestControl(
        _ point: UIVector,
        forEventRequest eventRequest: EventRequest,
        enabledOnly: Bool = true
    ) -> ControlView? {

        let controlView = viewUnder(point: point) { view -> Bool in
            guard let control = view as? ControlView else {
                return false
            }
            guard control.canHandle(eventRequest) else {
                return false
            }

            return control.isRecursivelyVisible && (!enabledOnly || control.isRecursivelyInteractiveEnabled)
        }

        return controlView as? ControlView
    }

    /// Traverses the hierarchy of a given view, returning the first `T`-based
    /// view that the method finds.
    ///
    /// The method ignores `view` itself.
    private static func closestParentViewOfType<T: View>(_ view: View, type: T.Type = T.self) -> T? {
        var next = view.superview
        while let n = next {
            if let nView = n as? T {
                return nView
            }

            next = n.superview
        }

        return nil
    }

    // MARK: - StateManager
    private class StateManager {
        var isEnabled: Bool = true {
            didSet {
                deriveNewState()
            }
        }
        var isSelected: Bool = false {
            didSet {
                deriveNewState()
            }
        }
        var isHighlighted: Bool = false {
            didSet {
                deriveNewState()
            }
        }
        var isFirstResponder: Bool = false {
            didSet {
                deriveNewState()
            }
        }

        var state: ControlViewState = .normal

        @ValueChangedEvent<ControlViewState>
        var stateChanged

        init() {

        }

        private func deriveNewState() {
            if !isEnabled {
                setState(.disabled)
                return
            }
            if isFirstResponder {
                setState(.focused)
                return
            }
            if isSelected {
                setState(.selected)
                return
            }
            if isHighlighted {
                setState(.highlighted)
                return
            }
            setState(.normal)
        }

        private func setState(_ state: ControlViewState) {
            if self.state == state {
                return
            }

            let oldState = state

            self.state = state

            _stateChanged(old: oldState, new: state)
        }
    }

    /// A value store that can store different values depending on the state of
    /// the control.
    ///
    /// When requesting a value for a state that is not specified, the
    /// `ControlViewState.normal`'s version of the value is returned. If that
    /// state is not present, the default type for `T` is finally returned,
    /// instead.
    public class StatedValueStore<T> {
        private var _statesMap: [ControlViewState: T] = [:]

        public func getValue(_ state: ControlViewState, defaultValue: T) -> T {
            if let value = _statesMap[state] {
                return value
            }

            if let normalValue = _statesMap[.normal] {
                return normalValue
            }

            return defaultValue
        }

        public func setValue(_ value: T, forState state: ControlViewState) {
            _statesMap[state] = value
        }

        public func removeValueForState(_ state: ControlViewState) {
            _statesMap[state] = nil
        }
    }
}

/// Specifies the state of a control view.
public enum ControlViewState {
    /// Default control view state.
    case normal

    /// Specifies control view is highlighted, e.g. by being hovered over by the
    /// mouse cursor.
    case highlighted

    /// Specifies control view is selected, e.g. by pressing down on the mouse
    /// within the control's bounds.
    case selected

    /// Specifies control view is disabled, and should not respond to normal
    /// UI interaction events.
    case disabled
    
    /// Specifies control view is focused and receives keyboard events, i.e. it
    /// is the first responder in the responder chain.
    case focused
}
