import Foundation
import QuartzCore
import SwiftBlend2D
import ImagineUI
import CassowarySwift
import Cocoa
import Blend2DRenderer

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
        if !index.parent.isRoot {
            return "Item \(index.parent.indices.map(\.description).joined(separator: " -> ")) -> \(index.index)"
        }
        
        return "Item \(index.index)"
    }
}

class TreeSampleWindow: Blend2DSample {
    private var lastFrame: TimeInterval = 0
    private let data: DataSource = DataSource()

    weak var delegate: Blend2DSampleDelegate?
    var bounds: BLRect
    var width: Int
    var height: Int

    let rendererContext = Blend2DRendererContext()

    var sampleRenderScale = BLPoint(x: 2, y: 2)

    var controlSystem = DefaultControlSystem()

    var rootViews: [RootView]
    
    var currentRedrawRegion: UIRectangle? = nil

    var debugDrawFlags: Set<DebugDraw.DebugDrawFlags> = []
    
    init(size: BLSizeI) {
        width = Int(size.w)
        height = Int(size.h)
        bounds = BLRect(location: .zero, size: BLSize(w: Double(size.w), h: Double(size.h)))
        rootViews = []
        controlSystem.delegate = self

        initializeWindows()
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
    }
    
    func resize(width: Int, height: Int) {
        self.width = width
        self.height = height
        
        bounds = BLRect(location: .zero, size: BLSize(w: Double(width), h: Double(height)))
        currentRedrawRegion = bounds.asRectangle
        
        for case let window as Window in rootViews where window.windowState == .maximized {
            window.setNeedsLayout()
        }
    }
    
    func invalidateScreen() {
        currentRedrawRegion = bounds.asRectangle
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
    
    func render(context ctx: BLContext) {
        guard let rect = currentRedrawRegion else {
            return
        }
        
        ctx.scale(by: sampleRenderScale)
        ctx.setFillStyle(BLRgba32.cornflowerBlue)
        
        let redrawRegion = BLRegion(rectangle: BLRectI(rounding: rect.asBLRect))
        
        ctx.fillRect(rect.asBLRect)
        
        let renderer = Blend2DRenderer(context: ctx)
        
        // Redraw loop
        for rootView in rootViews {
            rootView.renderRecursive(in: renderer, screenRegion: Blend2DClipRegion(region: redrawRegion))
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
    func firstResponderChanged(_ newFirstResponder: KeyboardEventHandler?) {
        
    }
    
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
        switch cursor {
        case .iBeam:
            NSCursor.iBeam.set()
        case .arrow:
            NSCursor.arrow.set()
        case .resizeLeftRight:
            NSCursor.resizeLeftRight.set()
        case .resizeUpDown:
            NSCursor.resizeUpDown.set()
        case let .custom(imagePath, hotspot):
            let cursor = NSCursor(image: NSImage(byReferencingFile: imagePath)!,
                                  hotSpot: NSPoint(x: hotspot.x, y: hotspot.y))
            
            cursor.set()
        case .resizeTopLeftBottomRight:
            // TODO: Add support to this cursor type.
            break
        case .resizeTopRightBottomLeft:
            // TODO: Add support to this cursor type.
            break
        case .resizeAll:
            // TODO: Add support to this cursor type.
            break
        }
    }
    
    func setMouseHiddenUntilMouseMoves() {
        NSCursor.setHiddenUntilMouseMoves(true)
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
