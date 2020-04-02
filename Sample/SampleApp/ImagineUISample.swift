import Foundation
import QuartzCore
import SwiftBlend2D
import ImagineUI
import Cassowary
import Cocoa

class ImagineUI: Blend2DSample {
    private var lastFrame: TimeInterval = 0
    weak var delegate: Blend2DSampleDelegate?
    var bounds: BLRect
    var width: Int
    var height: Int

    var sampleRenderScale = BLPoint(x: 2, y: 2)

    var controlSystem = DefaultControlSystem()

    var rootViews: [RootView]

    var currentRedrawRegion: Rectangle? = nil
    
    var debugDrawFlags: Set<DebugDraw.DebugDrawFlags> = []

    init(size: BLSizeI) {
        width = Int(size.w)
        height = Int(size.h)
        bounds = BLRect(location: .zero, size: BLSize(w: Double(size.w), h: Double(size.h)))
        rootViews = []
        controlSystem.delegate = self
        UISettings.scale = sampleRenderScale.asVector2

        initWindows()
    }

    func initWindows() {
        let window =
            Window(area: Rectangle(x: 50, y: 120, width: 320, height: 330),
                   title: "Window")
        window.delegate = self
        window.areaIntoConstraintsMask = [.location]
        window.rootControlSystem = controlSystem
        window.invalidationDelegate = self

        let panel = Panel(title: "A Panel")
        let panelContents = StackView(orientation: .vertical)
        panelContents.spacing = 5
        panelContents.clipToBounds = false

        let radioButton = RadioButton(title: "Unselected")
        let radioButton2 = RadioButton(title: "Selected")
        radioButton2.isSelected = true

        let checkBox1 = Checkbox(title: "Unselected")
        let checkBox2 = Checkbox(title: "Partial")
        checkBox2.checkboxState = .partial
        
        let checkBox3 = Checkbox(title: "Checked")
        checkBox3.checkboxState = .checked
        checkBox3.isEnabled = false

        let button = Button(title: "Button")
        
        var attributedText = AttributedText()
        attributedText.append("A multi\n")
        attributedText.append("line\n", attributes: [.font: Fonts.defaultFont(size: 20)])
        attributedText.append("label!")
        let label = Label()
        label.attributedText = attributedText
        label.horizontalTextAlignment = .center
        label.verticalTextAlignment = .center

        let textField = TextField()
        textField.text = "Abc"
        textField.placeholderText = "Placeholder"

        let progressBar = ProgressBar()
        progressBar.progress = 0.75
        
        let sliderView = SliderView()
        sliderView.minimumValue = 0
        sliderView.maximumValue = 1
        sliderView.value = 0.75
        sliderView.stepValue = 0.05
        sliderView.showLabels = true

        let scrollView = ScrollView(scrollBarsMode: .vertical)
        scrollView.backColor = .white
        scrollView.contentSize = Size(x: 0, y: 300)
        
        let scrollViewLabel = Label()
        scrollViewLabel.text = "A\nScroll\nView"
        scrollViewLabel.horizontalTextAlignment = .center
        scrollViewLabel.verticalTextAlignment = .center
        scrollViewLabel.textColor = .black
        
        let imageView = ImageView(image: createSampleImage())

        let firstColumn = StackView(orientation: .vertical)
        firstColumn.spacing = 5
        firstColumn.clipToBounds = false
        let secondColumn = StackView(orientation: .vertical)
        secondColumn.spacing = 5
        secondColumn.clipToBounds = false
        secondColumn.alignment = .fill
        
        window.addSubview(firstColumn)
        window.addSubview(secondColumn)
        firstColumn.addArrangedSubview(panel)
        firstColumn.addArrangedSubview(radioButton)
        firstColumn.addArrangedSubview(radioButton2)
        firstColumn.addArrangedSubview(checkBox1)
        firstColumn.addArrangedSubview(checkBox2)
        firstColumn.addArrangedSubview(checkBox3)
        firstColumn.addArrangedSubview(button)
        secondColumn.addArrangedSubview(progressBar)
        secondColumn.addArrangedSubview(sliderView)
        secondColumn.addArrangedSubview(label)
        secondColumn.addArrangedSubview(textField)
        window.addSubview(imageView)
        window.addSubview(scrollView)
        panel.addSubview(panelContents)
        panelContents.addArrangedSubview(radioButton)
        panelContents.addArrangedSubview(radioButton2)
        scrollView.addSubview(scrollViewLabel)
        
        LayoutConstraint.create(first: window.layout.height,
                                relationship: .greaterThanOrEqual,
                                offset: 330)
        
        firstColumn.layout.makeConstraints { make in
            make.top == window.contentsLayoutArea + 4
            make.left == window.contentsLayoutArea + 10
        }
        firstColumn.setCustomSpacing(after: panel, 10)
        firstColumn.setCustomSpacing(after: checkBox3, 15)
        
        panelContents.layout.makeConstraints { make in
            make.edges == panel.containerLayoutGuide
        }
        
        secondColumn.layout.makeConstraints { make in
            make.right(of: firstColumn, offset: 15)
            make.top == window.contentsLayoutArea + 19
        }
        secondColumn.setCustomSpacing(after: label, 15)
        
        progressBar.layout.makeConstraints { make in
            make.width == 100
        }
        label.layout.makeConstraints { make in
            make.height == 60
        }
        textField.layout.makeConstraints { make in
            make.height == 24
        }
        
        scrollView.layout.makeConstraints { make in
            make.left == window.contentsLayoutArea + 8
            make.under(button, offset: 10)
            make.right == window.contentsLayoutArea - 8
            make.bottom == window.contentsLayoutArea - 8
        }
        
        scrollViewLabel.setContentHuggingPriority(.horizontal, 50)
        scrollViewLabel.setContentHuggingPriority(.vertical, 50)
        scrollViewLabel.layout.makeConstraints { make in
            make.edges == scrollView.contentView
        }
        
        imageView.layout.makeConstraints { make in
            make.right(of: progressBar, offset: 15)
            make.top == progressBar
            make.right <= window.contentsLayoutArea - 8
        }

        button.mouseClicked.addListener(owner: self) { _ in
            label.isVisible.toggle()
        }
        
        sliderView.valueChanged.addListener(owner: self) { (_, event) in
            progressBar.progress = event.newValue
        }
        
        window.performLayout()
        
        createRenderSettingsWindow()

        rootViews.append(window)

        lastFrame = CACurrentMediaTime()
    }

    func resize(width: Int, height: Int) {
        self.width = width
        self.height = height

        bounds = BLRect(location: .zero, size: BLSize(w: Double(width), h: Double(height)))
        currentRedrawRegion = bounds.asRectangle
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

        performLayout()
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

        // Redraw loop
        for rootView in rootViews {
            rootView.renderRecursive(in: ctx, screenRegion: redrawRegion)
        }
        
        // Debug render
        for rootView in rootViews {
            DebugDraw.debugDrawRecursive(rootView, flags: debugDrawFlags, to: ctx)
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
        func toggleFlag(_ sample: ImagineUI,
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
    
    func createSampleImage() -> BLImage {
        let img = BLImage(width: 64, height: 64, format: .prgb32)
        let ctx = BLContext(image: img)!
        
        ctx.clearAll()
        ctx.setFillStyle(BLRgba32.skyBlue)
        ctx.fillRect(BLRect(x: 0, y: 0, w: 64, h: 64))
        
        // Render two mountains
        ctx.setFillStyle(BLRgba32.forestGreen)
        ctx.translate(x: 15, y: 40)
        ctx.fillTriangle(BLTriangle.unitEquilateral.scaledBy(x: 35, y: 35))
        ctx.translate(x: 15, y: 4)
        ctx.fillTriangle(BLTriangle.unitEquilateral.scaledBy(x: 30, y: 30))
        
        // Render ground
        ctx.resetMatrix()
        ctx.fillRect(BLRect(x: 0, y: 45, w: 64, h: 64))
        
        // Render sun
        ctx.setFillStyle(BLRgba32.yellow)
        ctx.fillCircle(x: 50, y: 20, radius: 10)
        
        ctx.end()
        
        return img
    }
}

extension ImagineUI: DefaultControlSystemDelegate {
    func bringRootViewToFront(_ rootView: RootView) {
        rootViews.removeAll(where: { $0 == rootView })
        rootViews.append(rootView)
        
        rootView.invalidate()
    }
    
    func controlViewUnder(point: Vector2, enabledOnly: Bool) -> ControlView? {
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
        }
    }
    
    func setMouseHiddenUntilMouseMoves() {
        NSCursor.setHiddenUntilMouseMoves(true)
    }
}

extension ImagineUI: RootViewRedrawInvalidationDelegate {
    func rootView(_ rootView: RootView, invalidateRect rect: Rectangle) {
        let intersectedRect = rect.formIntersection(bounds.asRectangle)
        
        if intersectedRect.width == 0 || intersectedRect.height == 0 {
            return
        }
        
        if let current = currentRedrawRegion {
            currentRedrawRegion = current.formUnion(intersectedRect)
        } else {
            currentRedrawRegion = intersectedRect
        }
        
        delegate?.invalidate(bounds: intersectedRect)
    }
}

extension ImagineUI: WindowDelegate {
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
    
    func windowSizeForFullscreen(_ window: Window) -> Size {
        return bounds.asRectangle.size
    }
}
