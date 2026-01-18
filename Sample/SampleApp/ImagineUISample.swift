import Foundation
import QuartzCore
import SwiftBlend2D
import ImagineUI
import CassowarySwift
import Cocoa
import Blend2DRenderer

class ImagineUISample: ImagineUIWindowContent {
    let rendererContext = Blend2DRendererContext()
    
    var sampleRenderScale = BLPoint(x: 2, y: 2)
    
    init(size: BLSizeI) {
        super.init(size: UIIntSize(width: Int(size.w), height: Int(size.h)))
        
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
        
        button.mouseClicked.addWeakListener(self) { (_, _) in
            label.isVisible.toggle()
        }
        
        sliderView.valueChanged.addWeakListener(self) { (_, event) in
            progressBar.progress = event.args.newValue
        }
        
        window.performLayout()
        
        createRenderSettingsWindow()
        
        addRootView(window)
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
        
        boundsCheckbox.checkboxStateWillChange.addWeakListener(self) { [weak self] (_, event) in
            guard let self = self else { return }
            
            toggleFlag(self, .viewBounds, event.args)
        }
        layoutCheckbox.checkboxStateWillChange.addWeakListener(self) { [weak self] (_, event) in
            guard let self = self else { return }
            
            toggleFlag(self, .layoutGuideBounds, event.args)
        }
        constrCheckbox.checkboxStateWillChange.addWeakListener(self) { [weak self] (_, event) in
            guard let self = self else { return }
            
            toggleFlag(self, .constraints, event.args)
        }
        
        addRootView(window)
    }
    
    func createSampleImage() -> Image {
        let imgRenderer = rendererContext.createImageRenderer(width: 64, height: 64)
        
        return imgRenderer.withRenderer { ctx in
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
                    mount1.p0.asUIVector,
                    mount1.p1.asUIVector,
                    mount1.p2.asUIVector
                ])
            )
            ctx.translate(x: 15, y: 4)
            ctx.fill(
                UIPolygon(vertices: [
                    mount2.p0.asUIVector,
                    mount2.p1.asUIVector,
                    mount2.p2.asUIVector
                ])
            )
            
            // Render ground
            ctx.resetTransform()
            ctx.fill(UIRectangle(x: 0, y: 45, width: 64, height: 64))
            
            // Render sun
            ctx.setFill(Color.yellow)
            ctx.fill(UICircle(x: 50, y: 20, radius: 10))
        }
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
