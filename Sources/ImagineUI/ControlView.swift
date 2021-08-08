import Geometry
import SwiftBlend2D

open class ControlView: View, MouseEventHandler, KeyboardEventHandler {
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

    open var cacheAsBitmap: Bool {
        get { _bitmapCache.isCachingEnabled }
        set { _bitmapCache.isCachingEnabled = newValue }
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

    open override var bounds: Rectangle {
        didSet {
            if bounds.size != oldValue.size {
                _bitmapCache.updateBitmapBounds(boundsForRedraw())
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

    open var currentState: ControlViewState {
        return _stateManager.state
    }

    /// If `true`, `highlighted` is automatically toggled on and off whenever
    /// the user enters and exits this control with the mouse.
    open var mouseOverHighlight: Bool = true

    /// If `true`, `selected` is automatically toggled on and off whenever the
    /// user holds down the mouse button on this control with the mouse.
    open var mouseDownSelected: Bool = false

    // MARK: - Visual Style / Colors

    /// This view's neutral background color
    open var backColor: BLRgba32 = .transparentBlack { // TODO: Should be KnownColor.Control
        didSet {
            invalidate()
        }
    }

    /// This view's foreground color
    open var foreColor: BLRgba32 = .black {
        didSet {
            invalidate()
        }
    }

    /// Corner radius for this control's corners
    /// (does not affect clipping region)
    open var cornerRadius: Double = 0 {
        didSet {
            invalidate()
        }
    }

    /// Stroke color around the bounds of the control view
    open var strokeColor: BLRgba32 = .transparentBlack {
        didSet {
            invalidate()
        }
    }

    /// Stroke width
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
    /// This event is raised after the view's contents have been painted.
    @Event public var painted: EventSourceWithSender<ControlView, PaintEventArgs>
    
    /// Event raised whenever this control view's `currentState` value is changed
    @Event public var stateChanged: ValueChangeEvent<ControlView, ControlViewState>
    
    /// Event raised whenever this control view's bounds have been updated to a
    /// different value
    @Event public var resized: ValueChangeEvent<ControlView, Size>
    
    // MARK: Mouse events
    
    /// Event raised whenever the user clicks this control view while enabled
    @Event public var mouseClicked: EventSourceWithSender<ControlView, MouseEventArgs>
    
    /// Event raised when the user scrolls the mouse wheel while on top of this
    /// control
    @Event public var mouseWheelScrolled: EventSourceWithSender<ControlView, MouseEventArgs>
    
    /// Event raised whenever the user holds down on this control view with any
    /// mouse button
    @Event public var mouseDown: EventSourceWithSender<ControlView, MouseEventArgs>
    
    /// Event raised whenever the user releases the mouse button they had held
    /// down previously on top of this control view
    @Event public var mouseUp: EventSourceWithSender<ControlView, MouseEventArgs>
    
    /// Event raised whenever the user moves the mouse on top of this control view's
    /// area
    @Event public var mouseMoved: EventSourceWithSender<ControlView, MouseEventArgs>
    
    /// Event raised whenever the user enters this control view's area with the
    /// mouse cursor
    @Event public var mouseEntered: EventSourceWithSender<ControlView, Void>
    
    /// Event raised whenever the user leaves this control view's area with the
    /// mouse cursor
    @Event public var mouseExited: EventSourceWithSender<ControlView, Void>
    
    // MARK: Keyboard events
    
    /// Event raised whenever the user presses a keyboard key while this view is
    /// the currently active first responder
    @Event public var keyPressed: EventSourceWithSender<ControlView, KeyPressEventArgs>
    
    /// Event raised whenever the user presses a keyboard key while this view is
    /// the currently active first responder
    @Event public var keyDown: EventSourceWithSender<ControlView, KeyEventArgs>
    
    /// Event raised whenever the user depresses a keyboard key while this view
    /// is the currently active first responder
    @Event public var keyUp: EventSourceWithSender<ControlView, KeyEventArgs>
    
    /// Event raised whenever the user presses a keyboard key while this view is
    /// the currently active first responder
    @Event public var previewKeyDown: EventSourceWithSender<ControlView, PreviewKeyDownEventArgs>
    
    // MARK: -

    public override init() {
        super.init()
        
        _stateManager.onStateChanged = { [weak self] old, new in
            self?.onStateChanged(ValueChangedEventArgs(oldValue: old, newValue: new))
        }
    }
    
    /// Raises the `resized` event
    open func onResize(_ event: ValueChangedEventArgs<Size>) {
        _resized.publishEvent(sender: self, event)
    }

    /// Raises the `stateChanged` event
    open func onStateChanged(_ event: ValueChangedEventArgs<ControlViewState>) {
        _stateChanged.publishEvent(sender: self, event)
    }

    // MARK: - Rendering

    /// Paints this control view on a given render context
    public final override func render(in context: BLContext, screenRegion: BLRegion) {
        super.render(in: context, screenRegion: screenRegion)
        
        let cookie = context.saveWithCookie()

        _bitmapCache.cachingOrRendering(context) { ctx in
            renderBackground(in: ctx, screenRegion: screenRegion)
            renderForeground(in: ctx, screenRegion: screenRegion)
        }
        
        context.restore(from: cookie)
        
        _painted.publishEvent(sender: self, context)
    }

    /// Renders this view's background
    open func renderBackground(in context: BLContext, screenRegion: BLRegion) {
        // Fill
        if backColor.a > 0 {
            context.setFillStyle(backColor)

            if cornerRadius <= 0 {
                context.fillRect(bounds.asBLRect)
            } else {
                context.fillRoundRect(BLRoundRect(rect: bounds.asBLRect,
                                                  radius: BLPoint(x: cornerRadius, y: cornerRadius)))
            }
        }

        // Stroke
        if strokeColor.a > 0 && strokeWidth > 0 {
            context.setStrokeStyle(strokeColor)
            context.setStrokeWidth(strokeWidth)

            if cornerRadius <= 0 {
                context.strokeRect(bounds.asBLRect)
            } else {
                context.strokeRoundRect(BLRoundRect(rect: bounds.asBLRect,
                                                    radius: BLPoint(x: cornerRadius, y: cornerRadius)))
            }
        }
    }

    /// Renders this view's foreground content (not drawn on top of child views)
    open func renderForeground(in context: BLContext, screenRegion: BLRegion) {

    }

    override func boundsForRedraw() -> Rectangle {
        return bounds.inflatedBy(x: strokeWidth, y: strokeWidth)
    }

    open func invalidateControlGraphics() {
        invalidate()
        
        _bitmapCache.invalidateCache()
    }
    
    open func invalidateControlGraphics(bounds: Rectangle) {
        invalidate(bounds: bounds)
        
        _bitmapCache.invalidateCache()
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
        _mouseDown.publishEvent(sender: self, event)
        
        if mouseDownSelected {
            _isMouseDown = true
            isSelected = true
        }
    }
    
    /// Raises the `mouseMoved` event
    open func onMouseMove(_ event: MouseEventArgs) {
        _mouseMoved.publishEvent(sender: self, event)
        
        if _isMouseDown {
            isSelected = contains(point: event.location)
        }
    }
    
    /// Raises the `mouseUp` event
    open func onMouseUp(_ event: MouseEventArgs) {
        _mouseUp.publishEvent(sender: self, event)
        
        if _isMouseDown {
            isSelected = false
            _isMouseDown = false
        }
    }

    /// Raises the `mouseEntered` event
    open func onMouseEnter() {
        _mouseEntered.publishEvent(sender: self)
        
        if mouseOverHighlight {
            isHighlighted = true
        }
    }

    /// Raises the `mouseExited` event
    open func onMouseLeave() {
        _mouseExited.publishEvent(sender: self)
        
        if mouseOverHighlight {
            isHighlighted = false
        }
    }

    /// Raises the `mouseClicked` event
    open func onMouseClick(_ event: MouseEventArgs) {
        _mouseClicked.publishEvent(sender: self, event)
    }
    
    /// Raises the `mouseWheelScrolled` event
    open func onMouseWheel(_ event: MouseEventArgs) {
        _mouseWheelScrolled.publishEvent(sender: self, event)
    }
    
    // MARK: - Keyboard Event Handling
    
    /// Raises the `keyPressed` event
    open func onKeyPress(_ event: KeyPressEventArgs) {
        _keyPressed.publishEvent(sender: self, event)
    }
    
    /// Raises the `keyDown` event
    open func onKeyDown(_ event: KeyEventArgs) {
        _keyDown.publishEvent(sender: self, event)
    }
    
    /// Raises the `keyUp` event
    open func onKeyUp(_ event: KeyEventArgs) {
        _keyUp.publishEvent(sender: self, event)
    }
    
    /// Raises the `previewKeyDown` event
    open func onPreviewKeyDown(_ event: PreviewKeyDownEventArgs) {
        _previewKeyDown.publishEvent(sender: self, event)
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
    public func hitTestControl(_ point: Vector2, enabledOnly: Bool = true) -> ControlView? {
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
        public var isEnabled: Bool = true {
            didSet {
                deriveNewState()
            }
        }
        public var isSelected: Bool = false {
            didSet {
                deriveNewState()
            }
        }
        public var isHighlighted: Bool = false {
            didSet {
                deriveNewState()
            }
        }
        public var isFirstResponder: Bool = false {
            didSet {
                deriveNewState()
            }
        }

        public var state: ControlViewState = .normal

        public var onStateChanged: ((ControlViewState, ControlViewState) -> Void)?

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

            onStateChanged?(oldState, state)
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
