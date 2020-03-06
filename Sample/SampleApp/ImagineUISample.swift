import Foundation
import QuartzCore
import SwiftBlend2D
import ImagineUI

class ImagineUI: Blend2DSample {
    private var lastFrame: TimeInterval = 0
    weak var delegate: Blend2DSampleDelegate?
    var bounds: BLRect
    var width: Int
    var height: Int

    var sampleRenderScale = BLPoint(x: 2, y: 2)

    var controlSystem = DefaultControlSystem()

    var windows: [Window]

    var redrawRegion: BLRegion

    init(size: BLSizeI) {
        width = Int(size.w)
        height = Int(size.h)
        bounds = BLRect(location: .zero, size: BLSize(w: Double(size.w), h: Double(size.h)))
        redrawRegion = BLRegion(rectangle: BLRectI(x: 0, y: 0, w: size.w, h: size.h))
        windows = []
        controlSystem.delegate = self
        UISettings.scale = sampleRenderScale.asVector2

        initWindows()
    }

    func initWindows() {
        let window =
            Window(area: Rectangle(x: 20, y: 50, width: 240, height: 330),
                   title: "Window",
                   titleFont: Fonts.defaultFont(size: 12))
        window.rootControlSystem = controlSystem
        window.invalidationDelegate = self

        let panel = Panel(title: "A Panel")

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

        let scrollView = ScrollView(scrollBarsMode: .vertical)
        scrollView.backColor = .white
        scrollView.contentSize = Size(x: 0, y: 300)
        
        let scrollViewLabel = Label()
        scrollViewLabel.text = "A\nScroll\nView"
        scrollViewLabel.horizontalTextAlignment = .center
        scrollViewLabel.verticalTextAlignment = .center
        scrollViewLabel.textColor = .black

        window.addSubview(panel)
        window.addSubview(radioButton)
        window.addSubview(radioButton2)
        window.addSubview(checkBox1)
        window.addSubview(checkBox2)
        window.addSubview(checkBox3)
        window.addSubview(button)
        window.addSubview(label)
        window.addSubview(textField)
        window.addSubview(progressBar)
        window.addSubview(sliderView)
        window.addSubview(scrollView)
        panel.addSubview(radioButton)
        panel.addSubview(radioButton2)
        scrollView.addSubview(scrollViewLabel)

        panel.layout.makeConstraints { make in
            make.top == window + 35
            make.left == window + 10
            make.width == 100
        }

        radioButton.layout.makeConstraints { make in
            make.left == panel.containerView + 4
            make.top == panel.containerView + 4
        }
        radioButton2.layout.makeConstraints { make in
            make.left == radioButton
            make.top == radioButton.layout.bottom + 5
            make.bottom == panel.containerView - 4
        }

        checkBox1.layout.makeConstraints { make in
            make.left == panel
            make.top == panel.layout.bottom + 10
        }
        checkBox2.layout.makeConstraints { make in
            make.left == checkBox1
            make.top == checkBox1.layout.bottom + 5
        }
        checkBox3.layout.makeConstraints { make in
            make.left == checkBox2
            make.top == checkBox2.layout.bottom + 5
        }

        button.layout.makeConstraints { make in
            make.left == checkBox3
            make.top == checkBox3.layout.bottom + 15
        }
        
        progressBar.layout.makeConstraints { make in
            make.left == panel.layout.right + 15
            make.top == panel + 15
            make.width == 100
        }

        sliderView.layout.makeConstraints { make in
            make.left == progressBar
            make.top == progressBar.layout.bottom + 5
            make.width == 100
        }
        
        label.layout.makeConstraints { make in
            make.left == sliderView
            make.top == sliderView.layout.bottom + 15
            make.width == 100
            make.height == 50
        }

        textField.layout.makeConstraints { make in
            make.left == label
            make.top == label.layout.bottom + 15
            make.width == 100
            make.height == 33
        }
        
        scrollView.layout.makeConstraints { make in
            make.left == window + 10
            make.top == button.layout.bottom + 10
            make.right == window - 10
            make.bottom == window - 10
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

        windows = [window]

        lastFrame = CACurrentMediaTime()
    }

    func resize(width: Int, height: Int) {
        self.width = width
        self.height = height

        bounds = BLRect(location: .zero, size: BLSize(w: Double(width), h: Double(height)))
        redrawRegion = BLRegion(rectangle: BLRectI(x: 0, y: 0, w: Int32(width), h: Int32(height)))
    }

    func update(_ time: TimeInterval) {
        // Fixed-frame update
        let delta = time - lastFrame
        lastFrame = time
        let visitor = ClosureViewVisitor<Void> { (_, view) in
            view.onFixedFrame(interval: delta)
        }
        let traveler = ViewTraveler(visitor: visitor)

        for window in windows {
            traveler.visit(view: window)
        }

        // Layout loop
        for window in windows {
            window.performLayout()
        }
    }

    func render(context ctx: BLContext) {
        ctx.scale(by: sampleRenderScale)
        ctx.setFillStyle(BLRgba32.cornflowerBlue)

        // Reduce redraw region to a single enclosing rectangle
        var rect: Rectangle = redrawRegion.regionScans.isEmpty ? .zero : BLRect(boxI: redrawRegion.regionScans[0]).asRectangle

        for box in redrawRegion.regionScans {
            rect = rect.formUnion(BLRect(boxI: box).asRectangle)
        }

        redrawRegion.clear()
        redrawRegion.combine(box: BLBoxI(roundingRect: rect.asBLRect), operation: .or)

        ctx.fillRect(rect.asBLRect)

        // Redraw loop
        for window in windows {
            window.renderRecursive(in: ctx, region: redrawRegion)
        }

        redrawRegion.clear()
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
}

extension ImagineUI: DefaultControlSystemDelegate {
    func controlViewUnder(point: Vector2, enabledOnly: Bool) -> ControlView? {
        for window in windows.reversed() {
            let converted = window.convertFromScreen(point)
            if let view = window.hitTestControl(point: converted, enabledOnly: enabledOnly) {
                return view
            }
        }

        return nil
    }
}

extension ImagineUI: WindowRedrawInvalidationDelegate {
    func window(_ window: Window, invalidateRect rect: Rectangle) {
        let intersectedRect = rect.formIntersection(bounds.asRectangle)

        if intersectedRect.width == 0 || intersectedRect.height == 0 {
            return
        }

        let box = BLBoxI(x: Int(floor(intersectedRect.x)),
                         y: Int(floor(intersectedRect.y)),
                         w: Int(ceil(intersectedRect.width)),
                         h: Int(ceil(intersectedRect.height)))

        redrawRegion.combine(box: box, operation: .or)

        delegate?.invalidate(bounds: intersectedRect)
    }
}
