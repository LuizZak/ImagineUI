import Foundation
import QuartzCore
import SwiftBlend2D
import ImagineUI
import CassowarySwift
import Cocoa
import Blend2DRenderer

class ImagineUISample: Blend2DSample {
    private var lastFrame: TimeInterval = 0
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
        globalTextClipboard = MacOSTextClipboard()
    
        try! UISettings.initialize(.init(fontManager: Blend2DFontManager(),
                                         defaultFontPath: Fonts.fontFilePath,
                                         timeInSecondsFunction: { CACurrentMediaTime() }))
        
        initWindows()
    }
    
    func initWindows() {
        let window =
        Window(area: UIRectangle(x: 50, y: 120, width: 320, height: 330),
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
        let label = Label(textColor: .white)
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
        scrollView.contentSize = UISize(width: 0, height: 300)
        
        let scrollViewLabel = Label(textColor: .white)
        scrollViewLabel.text = "A\nScroll\nView"
        scrollViewLabel.horizontalTextAlignment = .center
        scrollViewLabel.verticalTextAlignment = .center
        scrollViewLabel.textColor = .black
        
        let imageView = ImageView(image: createSampleImage())
        let imageViewPanel = Panel(title: "Image View")
        
        let firstColumn = StackView(orientation: .vertical)
        firstColumn.spacing = 5
        firstColumn.clipToBounds = false
        let secondColumn = StackView(orientation: .vertical)
        secondColumn.spacing = 5
        secondColumn.clipToBounds = false
        secondColumn.alignment = .fill
        let thirdColumn = StackView(orientation: .vertical)
        thirdColumn.spacing = 5
        thirdColumn.clipToBounds = false
        
        window.addSubview(firstColumn)
        window.addSubview(secondColumn)
        window.addSubview(thirdColumn)
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
        thirdColumn.addArrangedSubview(imageViewPanel)
        imageViewPanel.addSubview(imageView)
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
        
        thirdColumn.layout.makeConstraints { make in
            make.right(of: secondColumn, offset: 15)
            make.top == window.contentsLayoutArea + 4
            make.right <= window.contentsLayoutArea - 8
        }
        
        imageView.layout.makeConstraints { make in
            make.edges == imageViewPanel.containerLayoutGuide
        }
        
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
        func toggleFlag(_ sample: ImagineUISample,
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

extension ImagineUISample: DefaultControlSystemDelegate {
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

extension ImagineUISample: RootViewRedrawInvalidationDelegate {
    func rootViewInvalidatedLayout(_ rootView: RootView) {
        self.delegate?.needsLayout(rootView)
    }
    
    func rootView(_ rootView: RootView, invalidateRect rect: UIRectangle) {
        guard let intersectedRect = rect.intersection(bounds.asRectangle) else {
            return
        }
        
        if let current = currentRedrawRegion {
            currentRedrawRegion = current.union(intersectedRect)
        } else {
            currentRedrawRegion = intersectedRect
        }
        
        delegate?.invalidate(bounds: intersectedRect)
    }
}

extension ImagineUISample: WindowDelegate {
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

class MacOSTextClipboard: TextClipboard {
    func getText() -> String? {
        NSPasteboard.general.string(forType: .string)
    }
    
    func setText(_ text: String) {
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(text, forType: .string)
    }
    
    func containsText() -> Bool {
        return getText() != nil
    }
}
