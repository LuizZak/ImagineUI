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

        let radioButton
            = RadioButton(location: Vector2(x: 16, y: 50), title: "Unselected")
        let radioButton2
            = RadioButton(location: Vector2(x: 16, y: 70), title: "Selected")
        radioButton2.isSelected = true

        let checkBox1 = Checkbox(location: .zero,
                                 title: "Unselected")
        let checkBox2 = Checkbox(location: .zero,
                                 title: "Partial")
        checkBox2.checkboxState = .partial
        let checkBox3 = Checkbox(location: .zero,
                                 title: "Checked")
        checkBox3.checkboxState = .checked
        checkBox3.isEnabled = false

        let button = Button(location: .zero, title: "Button")
        
        var attributedText = AttributedText()
        attributedText.append("A multi\n")
        attributedText.append("line\n", attributes: [.font: Fonts.defaultFont(size: 20)])
        attributedText.append("label!")
        let label = Label(bounds: .empty)
        label.attributedText = attributedText
        label.horizontalTextAlignment = .center
        label.verticalTextAlignment = .center

        let textField = TextField(bounds: .empty)
        textField.text = "Abc"
        textField.placeholderText = "Placeholder"

        let panel = Panel(bounds: .empty, title: "A Panel")
        
        let progressBar = ProgressBar(bounds: .empty)
        progressBar.progress = 0.75

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
        panel.addSubview(radioButton)
        panel.addSubview(radioButton2)
        panel.translatesAutoresizingMaskIntoConstraints = false
        radioButton.translatesAutoresizingMaskIntoConstraints = false
        radioButton2.translatesAutoresizingMaskIntoConstraints = false
        checkBox1.translatesAutoresizingMaskIntoConstraints = false
        checkBox2.translatesAutoresizingMaskIntoConstraints = false
        checkBox3.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false

        panel.layout.makeConstraints { make in
            make.top.equalTo(window, offset: 35)
            make.left.equalTo(window, offset: 10)
            make.width.equalTo(100)
        }

        radioButton.layout.makeConstraints { make in
            make.left.equalTo(panel.containerView, offset: 4)
            make.top.equalTo(panel.containerView, offset: 4)
        }
        radioButton2.layout.makeConstraints { make in
            make.left.equalTo(radioButton)
            make.top.equalTo(radioButton.layout.bottom, offset: 5)
            make.bottom.equalTo(panel.containerView, offset: -4)
        }

        checkBox1.layout.makeConstraints { make in
            make.left.equalTo(panel)
            make.top.equalTo(panel.layout.bottom, offset: 10)
        }
        checkBox2.layout.makeConstraints { make in
            make.left.equalTo(checkBox1)
            make.top.equalTo(checkBox1.layout.bottom, offset: 5)
        }
        checkBox3.layout.makeConstraints { make in
            make.left.equalTo(checkBox2)
            make.top.equalTo(checkBox2.layout.bottom, offset: 5)
        }

        button.layout.makeConstraints { make in
            make.left.equalTo(checkBox3)
            make.top.equalTo(checkBox3.layout.bottom, offset: 15)
        }

        label.layout.makeConstraints { make in
            make.left.equalTo(button)
            make.top.equalTo(button.layout.bottom, offset: 15)
            make.width.equalTo(70)
            make.height.equalTo(50)
        }

        textField.layout.makeConstraints { make in
            make.left.equalTo(label)
            make.top.equalTo(label.layout.bottom, offset: 15)
            make.width.equalTo(100)
            make.height.equalTo(33)
        }
        
        progressBar.layout.makeConstraints { make in
            make.left.equalTo(panel.layout.right, offset: 15)
            make.top.equalTo(panel, offset: 15)
            make.width.equalTo(100)
        }

        button.mouseClicked.addListener(owner: self) { _ in
            label.isVisible.toggle()
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
        var rect: Rectangle = redrawRegion.regionScans.isEmpty ? .empty : BLRect(boxI: redrawRegion.regionScans[0]).asRectangle

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
