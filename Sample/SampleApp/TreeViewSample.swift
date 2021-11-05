import Foundation
import CassowarySwift
import SwiftBlend2D
import Blend2DRenderer
import MinWin32
import ImagineUI_Win

private class DataSource: TreeViewDataSource {
    func hasItems(_ treeView: TreeView, at hierarchyIndex: TreeView.HierarchyIndex) -> Bool {
        if hierarchyIndex.indices == [2] {
            return true
        }

        return false
    }

    func numberOfItems(_ treeView: TreeView, at hierarchyIndex: TreeView.HierarchyIndex) -> Int {
        if hierarchyIndex.isRoot {
            return 10
        }
        if hierarchyIndex.indices == [2] {
            return 2
        }

        return 0
    }

    func titleForItem(at index: TreeView.ItemIndex) -> String {
        return "Item \(index.index)"
    }
}

class TreeSampleWindow: Blend2DWindowContentType {
    private var lastFrame: TimeInterval = 0
    private var timer: Timer?
    private let data: DataSource = DataSource()

    weak var delegate: Blend2DWindowContentDelegate?
    var bounds: BLRect

    var size: UIIntSize

    var width: Int { size.width }
    var height: Int { size.height }

    let rendererContext = Blend2DRendererContext()

    var preferredRenderScale: UIVector = UIVector(repeating: 1)

    var controlSystem = DefaultControlSystem()

    var rootViews: [RootView]

    var debugDrawFlags: Set<DebugDraw.DebugDrawFlags> = []

    init(size: UIIntSize = .init(width: 600, height: 500)) {
        self.size = size
        bounds = BLRect(location: .zero, size: BLSize(w: Double(size.width), h: Double(size.height)))
        rootViews = []
        controlSystem.delegate = self

        initializeWindows()
        initializeTimer()
    }

    deinit {
        timer?.invalidate()
    }

    func initializeWindows() {
        let window =
            Window(area: UIRectangle(x: 50, y: 120, width: 320, height: 330),
                   title: "Window")
        window.delegate = self
        window.areaIntoConstraintsMask = [.location]
        window.rootControlSystem = controlSystem
        window.invalidationDelegate = self

        let tree = TreeView()
        tree.dataSource = data
        tree.reloadData()

        window.addSubview(tree)

        LayoutConstraint.create(first: window.layout.height,
                                relationship: .greaterThanOrEqual,
                                offset: 100)

        tree.layout.makeConstraints { make in
            make.edges == window.contentsLayoutArea - 12
        }

        window.performLayout()

        createRenderSettingsWindow()

        rootViews.append(window)

        lastFrame = Stopwatch.global.timeIntervalSinceStart()
    }

    private func initializeTimer() {
        let timer = Timer(timeInterval: 1 / 60.0, repeats: true) { [weak self] _ in
            self?.update(Stopwatch.global.timeIntervalSinceStart())
        }

        RunLoop.main.add(timer, forMode: .default)

        self.timer = timer
    }

    func willStartLiveResize() {

    }

    func didEndLiveResize() {

    }

    func didClose() {
        WinLogger.info("\(self): Closed")
        app.requestQuit()
    }

    func resize(_ newSize: UIIntSize) {
        self.size = newSize

        bounds = BLRect(location: .zero, size: BLSize(w: Double(width), h: Double(height)))

        for view in rootViews {
            view.setNeedsLayout()
        }
    }

    func invalidateScreen() {
        delegate?.invalidate(bounds: bounds.asRectangle)
    }

    func update(_ time: TimeInterval) {
        // Fixed-frame update
        let delta = time - lastFrame
        lastFrame = time

        Scheduler.instance.onFixedFrame(delta)
    }

    func performLayout() {
        // Layout loop
        for rootView in rootViews {
            rootView.performLayout()
        }
    }

    func render(context ctx: BLContext, renderScale: UIVector, clipRegion: ClipRegion) {
        let renderer = Blend2DRenderer(context: ctx)
        renderer.scale(by: renderScale)

        renderer.setFill(.cornflowerBlue)
        renderer.fill(clipRegion.bounds())

        ctx.clipToRect(clipRegion.bounds().asBLRect)

        // Redraw loop
        for rootView in rootViews {
            rootView.renderRecursive(in: renderer, screenRegion: clipRegion)
        }

        // Debug render
        for rootView in rootViews {
            DebugDraw.debugDrawRecursive(rootView, flags: debugDrawFlags, in: renderer)
        }
    }

    func mouseDown(event: MouseEventArgs) {
        controlSystem.onMouseDown(event)
    }

    func mouseMoved(event: MouseEventArgs) {
        controlSystem.onMouseMove(event)
    }

    func mouseUp(event: MouseEventArgs) {
        controlSystem.onMouseUp(event)
    }

    func mouseScroll(event: MouseEventArgs) {
        controlSystem.onMouseWheel(event)
    }

    func keyDown(event: KeyEventArgs) {
        controlSystem.onKeyDown(event)
    }

    func keyUp(event: KeyEventArgs) {
        controlSystem.onKeyUp(event)
    }

    func keyPress(event: KeyPressEventArgs) {
        controlSystem.onKeyPress(event)
    }

    func createRenderSettingsWindow() {
        func toggleFlag(_ sample: TreeSampleWindow,
                        _ flag: DebugDraw.DebugDrawFlags,
                        _ event: CancellableValueChangedEventArgs<Checkbox.State>) {

            if event.newValue == .checked {
                sample.debugDrawFlags.insert(flag)
            } else {
                sample.debugDrawFlags.remove(flag)
            }

            sample.invalidateScreen()
        }

        let window = Window(area: .zero, title: "Debug render settings")
        window.delegate = self
        window.areaIntoConstraintsMask = [.location]
        window.setShouldCompress(true)
        window.rootControlSystem = controlSystem
        window.invalidationDelegate = self

        let boundsCheckbox = Checkbox(title: "View Bounds")
        let layoutCheckbox = Checkbox(title: "Layout Guides")
        let constrCheckbox = Checkbox(title: "Constraints")
        let stackView = StackView(orientation: .vertical)
        stackView.spacing = 4

        stackView.addArrangedSubview(boundsCheckbox)
        stackView.addArrangedSubview(layoutCheckbox)
        stackView.addArrangedSubview(constrCheckbox)

        window.addSubview(stackView)

        stackView.layout.makeConstraints { make in
            make.left == window.contentsLayoutArea + 12
            make.top == window.contentsLayoutArea + 12
            make.bottom <= window.contentsLayoutArea - 12
            make.right <= window.contentsLayoutArea - 12
        }

        boundsCheckbox.checkboxStateWillChange.addListener(owner: self) { [weak self] (_, event) in
            guard let self = self else { return }

            toggleFlag(self, .viewBounds, event)
        }
        layoutCheckbox.checkboxStateWillChange.addListener(owner: self) { [weak self] (_, event) in
            guard let self = self else { return }

            toggleFlag(self, .layoutGuideBounds, event)
        }
        constrCheckbox.checkboxStateWillChange.addListener(owner: self) { [weak self] (_, event) in
            guard let self = self else { return }

            toggleFlag(self, .constraints, event)
        }

        rootViews.append(window)
    }

    func createSampleImage() -> Image {
        let imgRenderer = rendererContext.createImageRenderer(width: 64, height: 64)

        let ctx = imgRenderer.renderer

        ctx.clear()
        ctx.setFill(Color.skyBlue)
        ctx.fill(UIRectangle(x: 0, y: 0, width: 64, height: 64))

        // Render two mountains
        ctx.setFill(Color.forestGreen)
        ctx.translate(x: 15, y: 40)
        let mount1 = BLTriangle.unitEquilateral.scaledBy(x: 35, y: 35)
        let mount2 = BLTriangle.unitEquilateral.scaledBy(x: 30, y: 30)

        ctx.fill(
            UIPolygon(vertices: [
                mount1.p0.asVector2,
                mount1.p1.asVector2,
                mount1.p2.asVector2
            ])
        )
        ctx.translate(x: 15, y: 4)
        ctx.fill(
            UIPolygon(vertices: [
                mount2.p0.asVector2,
                mount2.p1.asVector2,
                mount2.p2.asVector2
            ])
        )

        // Render ground
        ctx.resetTransform()
        ctx.fill(UIRectangle(x: 0, y: 45, width: 64, height: 64))

        // Render sun
        ctx.setFill(Color.yellow)
        ctx.fill(UICircle(x: 50, y: 20, radius: 10))

        return imgRenderer.renderedImage()
    }
}

extension TreeSampleWindow: DefaultControlSystemDelegate {
    func bringRootViewToFront(_ rootView: RootView) {
        rootViews.removeAll(where: { $0 == rootView })
        rootViews.append(rootView)

        rootView.invalidate()
    }

    func controlViewUnder(point: UIVector, enabledOnly: Bool) -> ControlView? {
        for window in rootViews.reversed() {
            let converted = window.convertFromScreen(point)
            if let view = window.hitTestControl(converted, enabledOnly: enabledOnly) {
                return view
            }
        }

        return nil
    }

    func setMouseCursor(_ cursor: MouseCursorKind) {
        delegate?.setMouseCursor(cursor)
    }

    func setMouseHiddenUntilMouseMoves() {
        delegate?.setMouseHiddenUntilMouseMoves()
    }

    func firstResponderChanged(_ newFirstResponder: KeyboardEventHandler?) {
        delegate?.firstResponderChanged(newFirstResponder)
    }
}

extension TreeSampleWindow: RootViewRedrawInvalidationDelegate {
    func rootViewInvalidatedLayout(_ rootView: RootView) {
        delegate?.needsLayout(rootView)
    }

    func rootView(_ rootView: RootView, invalidateRect rect: UIRectangle) {
        delegate?.invalidate(bounds: rect)
    }
}

extension TreeSampleWindow: WindowDelegate {
    func windowWantsToClose(_ window: Window) {
        if let index = rootViews.firstIndex(of: window) {
            rootViews.remove(at: index)
            invalidateScreen()
        }
    }

    func windowWantsToMaximize(_ window: Window) {
        switch window.windowState {
        case .maximized:
            window.setWindowState(.normal)

        case .normal, .minimized:
            window.setWindowState(.maximized)
        }
    }

    func windowWantsToMinimize(_ window: Window) {
        window.setWindowState(.minimized)
    }

    func windowSizeForFullscreen(_ window: Window) -> UISize {
        return bounds.asRectangle.size
    }
}
