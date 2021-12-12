import Foundation
import Geometry
import Rendering

open class ControlView: View, TooltipProvider, MouseEventHandler, KeyboardEventHandler {
    /// Whether to cache all controls' contents as a bitmap.
    ///
    /// This increases memory usage and reduces quality of controls in scaled
    /// scenarios, but reduces CPU usage when re-rendering controls that had no
    /// state change.
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

            invalidateControlGraphics()
        }
    }

    open var isFirstResponder: Bool {
        return controlSystem?.isFirstResponder(self) ?? false
    }

    open var canBecomeFirstResponder: Bool {
        return false
    }

    open var canResignFirstResponder: Bool {
        return true
    }

    open var next: EventHandler? {
        return ControlView.closestParentViewOfType(self, type: ControlView.self)
    }

    open override var bounds: UIRectangle {
        didSet {
            if bounds.size != oldValue.size {
                _updateCacheBounds()
                onResize(ValueChangedEventArgs(oldValue: oldValue.size, newValue: bounds.size))
            }
        }
    }

    // MARK: - View states

    open var isSelected: Bool {
        get { _stateManager.isSelected }
        set { _stateManager.isSelected = newValue }
    }

    open var isEnabled: Bool {
        get { _stateManager.isEnabled }
        set { _stateManager.isEnabled = newValue }
    }

    open var isHighlighted: Bool {
        get { _stateManager.isHighlighted }
        set { _stateManager.isHighlighted = newValue }
    }

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
            invalidateControlGraphics()
        }
    }

    /// This view's foreground color.
    open var foreColor: Color = .black {
        didSet {
            invalidateControlGraphics()
        }
    }

    /// Corner radius for this control's corners (does not affect clipping region).
    open var cornerRadius: Double = 0 {
        didSet {
            invalidateControlGraphics()
        }
    }

    /// Stroke color around the bounds of the control view.
    open var strokeColor: Color = .transparentBlack {
        didSet {
            invalidateControlGraphics()
        }
    }

    /// Stroke width.
    open var strokeWidth: Double = 0 {
        willSet {
            if strokeWidth != newValue {
                invalidateControlGraphics()
            }
        }
        didSet {
            if strokeWidth != oldValue {
                invalidateControlGraphics()
            }
        }
    }

    // MARK: - Events

    /// Event raised whenever a client requests that this view redraw itself on
    /// screen or to a buffer.
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

    /// Event raised whenever the user clicks this control view while enabled
    @EventWithSender<ControlView, MouseEventArgs>
    public var mouseClicked

    /// Event raised when the user scrolls the mouse wheel while on top of this
    /// control
    @EventWithSender<ControlView, MouseEventArgs>
    public var mouseWheelScrolled

    /// Event raised whenever the user holds down on this control view with any
    /// mouse button
    @EventWithSender<ControlView, MouseEventArgs>
    public var mouseDown

    /// Event raised whenever the user releases the mouse button they had held
    /// down previously on top of this control view
    @EventWithSender<ControlView, MouseEventArgs>
    public var mouseUp

    /// Event raised whenever the user moves the mouse on top of this control view's
    /// area
    @EventWithSender<ControlView, MouseEventArgs>
    public var mouseMoved

    /// Event raised whenever the user enters this control view's area with the
    /// mouse cursor
    @EventWithSender<ControlView, Void>
    public var mouseEntered

    /// Event raised whenever the user leaves this control view's area with the
    /// mouse cursor
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

    /// Preferred delay before a mouse hover event displays this control view's
    /// tooltip.
    open var tooltipDelay: TimeInterval? {
        nil
    }

    // MARK: -

    public override init() {
        super.init()

        _stateManager.stateChanged.addListener(owner: self) { [weak self] event in
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

        invalidateControlGraphics()
    }

    // MARK: - Rendering

    /// Paints this control view on a given render context
    public final override func render(in renderer: Renderer, screenRegion: ClipRegion) {
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
    open func renderBackground(in renderer: Renderer, screenRegion: ClipRegion) {
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
    open func renderForeground(in renderer: Renderer, screenRegion: ClipRegion) {

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

    open func invalidateControlGraphics() {
        _updateCacheBounds()

        invalidateControlGraphics(bounds: boundsForRedraw())
    }

    open func invalidateControlGraphics(bounds: UIRectangle) {
        invalidate(bounds: bounds)

        _bitmapCache.invalidateCache()
    }

    private func _updateCacheBounds() {
        _bitmapCache.updateBitmapBounds(boundsForRedraw())
    }

    // MARK: - Event Handling / First Responder

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

    open func canHandle(_ eventRequest: EventRequest) -> Bool {
        // Consume all mouse event requests (except mouse wheel) by default
        if let mouseEvent = eventRequest as? MouseEventRequest {
            return mouseEvent.eventType != MouseEventType.mouseWheel
        }

        return false
    }

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

    open func resignFirstResponder() {
        if controlSystem?.removeAsFirstResponder(self) == true {
            _stateManager.isFirstResponder = false
        }
    }

    // MARK: - Mouse Event Handling

    /// Raises the `mouseDown` event
    open func onMouseDown(_ event: MouseEventArgs) {
        _mouseDown(sender: self, event)

        if mouseDownSelected {
            _isMouseDown = true
            isSelected = true
        }
    }

    /// Raises the `mouseMoved` event
    open func onMouseMove(_ event: MouseEventArgs) {
        _mouseMoved(sender: self, event)

        if _isMouseDown {
            isSelected = contains(point: event.location)
        }
    }

    /// Raises the `mouseUp` event
    open func onMouseUp(_ event: MouseEventArgs) {
        _mouseUp(sender: self, event)

        if _isMouseDown {
            isSelected = false
            _isMouseDown = false
        }
    }

    /// Raises the `mouseEntered` event
    open func onMouseEnter() {
        _mouseEntered(sender: self)

        if mouseOverHighlight {
            isHighlighted = true
        }
    }

    /// Raises the `mouseExited` event
    open func onMouseLeave() {
        _mouseExited(sender: self)

        if mouseOverHighlight {
            isHighlighted = false
        }
    }

    /// Raises the `mouseClicked` event
    open func onMouseClick(_ event: MouseEventArgs) {
        _mouseClicked(sender: self, event)
    }

    /// Raises the `mouseWheelScrolled` event
    open func onMouseWheel(_ event: MouseEventArgs) {
        _mouseWheelScrolled(sender: self, event)
    }

    // MARK: - Keyboard Event Handling

    /// Raises the `keyPressed` event
    open func onKeyPress(_ event: KeyPressEventArgs) {
        _keyPressed(sender: self, event)
    }

    /// Raises the `keyDown` event
    open func onKeyDown(_ event: KeyEventArgs) {
        _keyDown(sender: self, event)
    }

    /// Raises the `keyUp` event
    open func onKeyUp(_ event: KeyEventArgs) {
        _keyUp(sender: self, event)
    }

    /// Raises the `previewKeyDown` event
    open func onPreviewKeyDown(_ event: PreviewKeyDownEventArgs) {
        _previewKeyDown(sender: self, event)
    }

    // MARK: -

    /// Returns the first control view under a given point on this control view.
    ///
    /// Returns nil, if no control was found.
    ///
    /// - Parameter point: Point to hit-test against, in local coordinates of
    /// this `ControlView`
    /// - Parameter enabledOnly: Whether to only consider views that have
    /// interactivity enabled. See `interactionEnabled`
    public func hitTestControl(_ point: UIVector, enabledOnly: Bool = true) -> ControlView? {
        let controlView = viewUnder(point: point) { view -> Bool in
            guard let control = view as? ControlView else {
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
    /// When requesting a value for a state that is not specified, the `ControlViewState.Normal`'s
    /// version of the value is returned. If that state is not present, the
    /// default type for T is finally returned instead.
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

public enum ControlViewState {
    case normal
    case highlighted
    case selected
    case disabled
    case focused
}
