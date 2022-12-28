import Geometry
import Rendering

open class RadioButton: ControlView {
    public let label = Label(textColor: .white)

    /// Gets or sets the radio button manager for this radio button.
    /// If not specified, the default radio button manager will be the first
    /// parent view that implements `RadioButtonManagerType`.
    var radioButtonManager: RadioButtonManagerType?

    open var title: String {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }

    public init(title: String) {
        super.init()
        isEnabled = true
        label.text = title
        strokeWidth = 1.5
    }

    open override func setupHierarchy() {
        super.setupHierarchy()

        addSubview(label)
    }

    open override func onStateChanged(_ event: ValueChangedEventArgs<ControlViewState>) {
        super.onStateChanged(event)

        invalidate()
    }

    open override func setupConstraints() {
        super.setupConstraints()

        // Intrinsic size
        layout.makeConstraints { make in
            make.width >= 15
            make.height >= 15
        }

        // Label constraints
        label.layout.makeConstraints { make in
            make.edges.equalTo(self, inset: UIEdgeInsets(left: 16))
        }
    }

    open override func viewForFirstBaseline() -> View? {
        return label
    }

    open override func renderForeground(in renderer: Renderer, screenRegion: ClipRegionType) {
        super.renderForeground(in: renderer, screenRegion: screenRegion)

        drawRadioButton(renderer)
    }

    open override func onMouseClick(_ event: MouseEventArgs) {
        super.onMouseClick(event)

        if isEnabled && !isSelected {
            getManager()?.selectRadioButton(self)
        }
    }

    func getManager() -> RadioButtonManagerType? {
        if let manager = radioButtonManager {
            return manager
        }

        var view = superview
        while let v = view {
            if let manager = v as? RadioButtonManagerType {
                return manager
            }

            view = v.superview
        }

        return nil
    }

    func drawRadioButton(_ renderer: Renderer) {
        var circle = UICircle(center: UIVector(x: 6, y: 6), radius: 6)
        circle.center.y = label.bounds.height / 2

        if isSelected {
            renderer.setStroke(.lightSteelBlue)
            renderer.setStrokeWidth(strokeWidth)
            renderer.stroke(circle)

            renderer.setFill(.royalBlue)
            renderer.fill(circle)

            renderer.setFill(.white)
            renderer.fill(circle.expanded(by: -3.5))
        } else {
            renderer.setStroke(.gray)
            renderer.setStrokeWidth(strokeWidth)
            renderer.stroke(circle)

            renderer.setFill(.white)
            renderer.fill(circle)
        }
    }
}
