import Foundation
import ImagineUICore

/// A base class containing the required boilerplate for implementing an ImagineUI
/// user interface.
open class ImagineUIWindowContent: ImagineUIContentType, DefaultControlSystemDelegate, RootViewRedrawInvalidationDelegate, WindowDelegate {
    private var lastFrame: TimeInterval = 0
    private var bounds: UIRectangle
    private var controlSystem = DefaultControlSystem()
    private var rootViews: [RootView]
    private var currentRedrawRegion: UIRectangle? = nil
    private let _tooltipContainer: RootView = RootView()
    private let _tooltipsManager: TooltipsManager

    private(set) public var size: UIIntSize

    public var width: Int { size.width }
    public var height: Int { size.height }

    public var preferredRenderScale: UIVector = .init(repeating: 1)

    public var debugDrawFlags: Set<DebugDraw.DebugDrawFlags> = []

    /// The default refresh color for this window content.
    /// If `nil`, no region clear is done before render calls and the last
    /// refresh's pixels will remain on the backbuffer.
    public var backgroundColor: Color? = .cornflowerBlue {
        didSet {
            invalidateScreen()
        }
    }

    /// The main view for this window content.
    public let rootView = RootView()

    public weak var delegate: ImagineUIContentDelegate?

    public init(size: UIIntSize) {
        _tooltipsManager = TooltipsManager(container: _tooltipContainer)

        self.size = size
        bounds = .init(location: .zero, size: UISize(size))
        rootViews = []
        controlSystem.delegate = self

        initialize()
    }

    open func initialize() {
        addRootView(rootView)
        addRootView(_tooltipContainer)

        rootView.passthroughMouseCapture = true
        _tooltipContainer.passthroughMouseCapture = true
    }

    open func didCloseWindow() {

    }

    open func addRootView(_ view: RootView) {
        view.invalidationDelegate = self
        view.rootControlSystem = controlSystem
        rootViews.append(view)

        if view !== _tooltipContainer && rootViews.contains(_tooltipContainer) {
            // Keep the tooltip container above all other views
            bringRootViewToFront(_tooltipContainer)
        }
    }

    open func removeRootView(_ view: RootView) {
        view.invalidationDelegate = nil
        view.rootControlSystem = nil
        rootViews.removeAll { $0 === view }
    }

    open func willStartLiveResize() {

    }

    open func didEndLiveResize() {

    }

    open func resize(_ newSize: UIIntSize) {
        self.size = newSize

        rootView.location = .zero
        rootView.size = .init(width: Double(width), height: Double(height))

        _tooltipContainer.area = .init(x: 0, y: 0, width: Double(width), height: Double(height))

        bounds = .init(location: .zero, size: UISize(size))
        currentRedrawRegion = bounds

        for case let window as Window in rootViews where window.windowState == .maximized {
            window.setNeedsLayout()
        }
    }

    open func invalidateScreen() {
        currentRedrawRegion = bounds
        delegate?.invalidate(self, bounds: bounds)
    }

    open func update(_ time: TimeInterval) {
        // Fixed-frame update
        let delta = time - lastFrame
        lastFrame = time
        Scheduler.instance.onFixedFrame(delta)

        performLayout()
    }

    open func performLayout() {
        // Layout loop
        for rootView in rootViews {
            rootView.performLayout()
        }
    }

    open func render(renderer: Renderer, renderScale: UIVector, clipRegion: ClipRegion) {
        renderer.scale(by: renderScale)

        if let backgroundColor = backgroundColor {
            renderer.setFill(backgroundColor)
            renderer.fill(clipRegion.bounds())
        }

        // Redraw loop
        for rootView in rootViews {
            rootView.renderRecursive(in: renderer, screenRegion: clipRegion)
        }

        // Debug render
        for rootView in rootViews {
            DebugDraw.debugDrawRecursive(rootView, flags: debugDrawFlags, in: renderer)
        }
    }

    open func mouseDown(event: MouseEventArgs) {
        controlSystem.onMouseDown(event)
    }

    open func mouseMoved(event: MouseEventArgs) {
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

    open func keyPress(event: KeyPressEventArgs) {
        controlSystem.onKeyPress(event)
    }

    // MARK: - DefaultControlSystemDelegate

    open func bringRootViewToFront(_ rootView: RootView) {
        rootViews.removeAll(where: { $0 == rootView })

        // Keep the tooltip container above all other views
        if rootView !== _tooltipContainer, let index = rootViews.firstIndex(of: _tooltipContainer) {
            rootViews.insert(rootView, at: index)
        } else {
            rootViews.append(rootView)
        }

        rootView.invalidate()
    }

    open func controlViewUnder(point: UIVector, enabledOnly: Bool) -> ControlView? {
        for rootView in rootViews.reversed() {
            let converted = rootView.convertFromScreen(point)
            if let view = rootView.hitTestControl(converted, enabledOnly: enabledOnly) {
                return view
            }
        }

        return nil
    }

    open func setMouseCursor(_ cursor: MouseCursorKind) {
        delegate?.setMouseCursor(self, cursor)
    }

    open func setMouseHiddenUntilMouseMoves() {
        delegate?.setMouseHiddenUntilMouseMoves(self)
    }

    open func firstResponderChanged(_ newFirstResponder: KeyboardEventHandler?) {
        delegate?.firstResponderChanged(self, newFirstResponder)
    }

    open func showTooltip(_ tooltip: Tooltip, view: View, location: PreferredTooltipLocation) {
        _tooltipsManager.showTooltip(tooltip, view: view, location: location)
    }

    open func updateTooltip(_ tooltip: Tooltip) {
        _tooltipsManager.updateTooltip(tooltip)
    }

    open func hideTooltip() {
        _tooltipsManager.hideTooltip()
    }

    open func updateTooltipCursorLocation(_ location: UIPoint) {
        _tooltipsManager.updateTooltipCursorLocation(location)
    }

    // MARK: - RootViewRedrawInvalidationDelegate

    /// Signals the delegate that a given root view has invalidated its layout
    /// and needs to update it.
    open func rootViewInvalidatedLayout(_ rootView: RootView) {
        delegate?.needsLayout(self, rootView)
    }

    open func rootView(_ rootView: RootView, invalidateRect rect: UIRectangle) {
        delegate?.invalidate(self, bounds: rect)
    }

    // MARK: - WindowDelegate

    open func windowWantsToClose(_ window: Window) {
        if let index = rootViews.firstIndex(of: window) {
            rootViews.remove(at: index)
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
        return bounds.size
    }
}
