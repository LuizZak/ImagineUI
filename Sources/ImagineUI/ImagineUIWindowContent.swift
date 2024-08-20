import Foundation
import ImagineUICore

/// A base class containing the required boilerplate for implementing an ImagineUI
/// user interface.
open class ImagineUIWindowContent: ImagineUIContentType, BaseControlSystemDelegate, RootViewRedrawInvalidationDelegate, WindowDelegate {
    private var _lastFrame: TimeInterval = 0
    private var _bounds: UIRectangle

    private var _rootViews: [RootView]

    /// The root view where dialogs are presented to.
    private let _dialogContainer: RootView = RootView()

    /// The root view where tooltips are presented to.
    private let _tooltipContainer: RootView = RootView()

    /// The active tooltip manager for this instance.
    private let _tooltipsManager: ImagineUITooltipsManager

    /// The main view for this window content.
    public let rootView = RootView()

    /// Gets or sets the layout mode of this root view, affecting all future
    /// `setNeedsLayout` calls.
    public var layoutMode: LayoutMode = .immediate

    /// Control system for this instance.
    public var controlSystem = DefaultControlSystem()

    /// Gets the current display size.
    private(set) public var size: UIIntSize

    /// Convenience for `self.size.width`.
    public var width: Int { size.width }

    /// Convenience for `self.size.height`.
    public var height: Int { size.height }

    /// Gets or sets the preferred render scale for this instance.
    open var preferredRenderScale: UIVector = .init(repeating: 1)

    /// Gets or sets the debug draw flags.
    ///
    /// Changing this value invalidates the screen.
    open var debugDrawFlags: Set<DebugDraw.DebugDrawFlags> = [] {
        didSet {
            if debugDrawFlags != oldValue {
                invalidateScreen()
            }
        }
    }

    /// The default refresh color for this window content.
    /// If `nil`, no region clear is done before render calls and the last
    /// refresh's pixels will remain on the backbuffer.
    ///
    /// Changing this value invalidates the screen.
    open var backgroundColor: Color? = .cornflowerBlue {
        didSet {
            invalidateScreen()
        }
    }

    /// The delegate for this window content.
    public weak var delegate: ImagineUIContentDelegate?

    public init(size: UIIntSize) {
        _tooltipsManager = ImagineUITooltipsManager(container: _tooltipContainer)

        self.size = size
        _bounds = .init(location: .zero, size: UISize(size))
        _rootViews = []
        controlSystem.delegate = self

        initialize()
    }

    open func initialize() {
        addRootView(rootView)
        addRootView(_dialogContainer)
        addRootView(_tooltipContainer)

        rootView.passthroughMouseCapture = true
        _dialogContainer.passthroughMouseCapture = true
        _tooltipContainer.passthroughMouseCapture = true
    }

    // MARK: -

    open func didCloseWindow() {

    }

    /// Adds an extra root view in this content.
    ///
    /// - precondition: `view.superview == nil`
    open func addRootView(_ view: RootView) {
        precondition(view.superview == nil)

        view.invalidationDelegate = self
        view.rootControlSystem = controlSystem
        _rootViews.append(view)

        if view !== _dialogContainer && _rootViews.contains(_dialogContainer) {
            // Keep the dialog container above all other views
            bringRootViewToFront(_dialogContainer)
        }
        if view !== _tooltipContainer && _rootViews.contains(_tooltipContainer) {
            // Keep the tooltip container above all other views
            bringRootViewToFront(_tooltipContainer)
        }
    }

    open func removeRootView(_ view: RootView) {
        view.invalidationDelegate = nil
        view.rootControlSystem = nil
        _rootViews.removeAll { $0 === view }
    }

    open func willStartLiveResize() {

    }

    open func didEndLiveResize() {

    }

    open func resize(_ newSize: UIIntSize) {
        self.size = newSize

        rootView.location = .zero
        rootView.size = .init(width: Double(width), height: Double(height))

        _dialogContainer.area = .init(x: 0, y: 0, width: Double(width), height: Double(height))
        _tooltipContainer.area = .init(x: 0, y: 0, width: Double(width), height: Double(height))

        _bounds = .init(location: .zero, size: UISize(size))

        for case let window as Window in _rootViews where window.windowState == .maximized {
            window.setNeedsLayout()
        }

        invalidateScreen()
    }

    open func invalidateScreen() {
        delegate?.invalidate(self, bounds: _bounds)
    }

    open func update(_ time: TimeInterval) {
        // Fixed-frame update
        let delta = time - _lastFrame
        _lastFrame = time
        Scheduler.instance.onFixedFrame(delta)

        performLayout()
    }

    open func performLayout() {
        // Layout loop
        for rootView in _rootViews {
            rootView.performLayout()
        }
    }

    open func render(renderer: Renderer, renderScale: UIVector, clipRegion: ClipRegionType) {
        renderer.resetTransform()
        renderer.setCompositionMode(.sourceOver)
        renderer.scale(by: renderScale)

        if let backgroundColor = backgroundColor {
            renderer.setFill(backgroundColor)
            renderer.fill(clipRegion.bounds())
        }

        // Redraw loop
        for rootView in _rootViews {
            rootView.renderRecursive(in: renderer, screenRegion: clipRegion)
        }

        // Debug render
        for rootView in _rootViews {
            DebugDraw.debugDrawRecursive(rootView, flags: debugDrawFlags, in: renderer)
        }
    }

    open func mouseLeave() {
        controlSystem.onMouseLeave()
    }

    open func mouseDown(event: MouseEventArgs) {
        controlSystem.onMouseDown(event)
    }

    open func mouseMoved(event: MouseEventArgs) {
        _tooltipsManager.updateTooltipCursorLocation(event.location)

        controlSystem.onMouseMove(event)
    }

    open func mouseUp(event: MouseEventArgs) {
        controlSystem.onMouseUp(event)
    }

    open func mouseScroll(event: MouseEventArgs) {
        controlSystem.onMouseWheel(event)
    }

    open func keyDown(event: KeyEventArgs) {
        controlSystem.onKeyDown(event)
    }

    open func keyUp(event: KeyEventArgs) {
        controlSystem.onKeyUp(event)
    }

    open func keyPress(event: KeyPressEventArgs) -> Bool {
        controlSystem.onKeyPress(event)
    }

    // MARK: - BaseControlSystemDelegate

    open func bringRootViewToFront(_ rootView: RootView) {
        func ensureViewOnTop(_ rootViewOver: RootView) {
            _rootViews.removeAll(where: { $0 === rootViewOver })
            _rootViews.append(rootViewOver)
        }

        if !_rootViews.contains(rootView) {
            return
        }

        _rootViews.removeAll(where: { $0 == rootView })
        _rootViews.append(rootView)

        // Keep the dialog container above most other views, except for the tooltip
        // container
        ensureViewOnTop(_dialogContainer)
        // Keep the tooltip container above all other views
        ensureViewOnTop(_tooltipContainer)

        rootView.invalidate()
    }

    open func controlViewUnder(point: UIVector, controlKinds: ControlKinds) -> ControlView? {
        let enabledOnly = !controlKinds.contains(.disabledFlag)

        if controlKinds.contains(.tooltips) {
            let converted = _tooltipContainer.convertFromScreen(point)
            if let view = _tooltipContainer.hitTestControl(converted, enabledOnly: enabledOnly) {
                return view
            }
        }

        if controlKinds.contains(.controls) {
            for rootView in _rootViews.reversed() where rootView != _tooltipContainer {
                let converted = rootView.convertFromScreen(point)
                if let view = rootView.hitTestControl(converted, enabledOnly: enabledOnly) {
                    return view
                }
            }
        }

        return nil
    }

    open func controlViewUnder(
        point: UIVector,
        forEventRequest eventRequest: EventRequest,
        controlKinds: ControlKinds
    ) -> ControlView? {

        let enabledOnly = !controlKinds.contains(.disabledFlag)

        if controlKinds.contains(.tooltips) {
            let converted = _tooltipContainer.convertFromScreen(point)

            if let view = _tooltipContainer.hitTestControl(
                converted,
                forEventRequest: eventRequest,
                enabledOnly: enabledOnly
            ) {
                return view
            }
        }

        if controlKinds.contains(.controls) {
            for rootView in _rootViews.reversed() where rootView != _tooltipContainer {
                let converted = rootView.convertFromScreen(point)

                if let view = rootView.hitTestControl(
                    converted,
                    forEventRequest: eventRequest,
                    enabledOnly: enabledOnly
                ) {
                    return view
                }
            }
        }

        return nil
    }

    open func setMouseCursor(_ cursor: MouseCursorKind) {
        delegate?.setMouseCursor(self, cursor: cursor)
    }

    open func setMouseHiddenUntilMouseMoves() {
        delegate?.setMouseHiddenUntilMouseMoves(self)
    }

    open func firstResponderChanged(_ newFirstResponder: KeyboardEventHandler?) {
        delegate?.firstResponderChanged(self, newFirstResponder)
    }

    open func viewForDialog(_ dialog: any UIDialog, location: UIDialogInitialLocation) -> View {
        _dialogContainer
    }

    open func tooltipsManager() -> TooltipsManagerType? {
        _tooltipsManager
    }

    // MARK: - RootViewRedrawInvalidationDelegate

    /// Signals the delegate that a given root view has invalidated its layout
    /// and needs to update it.
    open func rootViewInvalidatedLayout(_ rootView: RootView) {
        switch layoutMode {
        case .immediate:
            performLayout()

        case .deferred:
            delegate?.needsLayout(self, rootView)
        }
    }

    open func rootView(_ rootView: RootView, invalidateRect rect: UIRectangle) {
        delegate?.invalidate(self, bounds: rect)
    }

    // MARK: - WindowDelegate

    open func windowWantsToClose(_ window: Window) {
        if let index = _rootViews.firstIndex(of: window) {
            _rootViews.remove(at: index)
            invalidateScreen()
        }
    }

    open func windowWantsToMaximize(_ window: Window) {
        switch window.windowState {
        case .maximized:
            window.setWindowState(.normal)

        case .normal, .minimized:
            window.setWindowState(.maximized)
        }
    }

    open func windowWantsToMinimize(_ window: Window) {
        window.setWindowState(.minimized)
    }

    open func windowSizeForFullscreen(_ window: Window) -> UISize {
        return _bounds.size
    }

    /// Controls the layout mode of this window content.
    public enum LayoutMode {
        /// Calls to `setNeedsLayout` immediately layouts all root views without
        /// invoking the content's delegate.
        case immediate

        /// Layout is deferred via delegate to be performed later.
        case deferred
    }
}
