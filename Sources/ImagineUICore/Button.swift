import Geometry
import Rendering

/// A basic control with a label around an outlined area that the user can interact
/// by clicking with the mouse, raising `ControlView.mouseClicked` events.
open class Button: ControlView {
    private var _backColor = StatedValueStore<Color>()

    /// Gets the view that forms the label of this button.
    public let label = Label(textColor: .white)

    /// Gets or sets the title label.
    /// Equivalent to `label.text`.
    open var title: String {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }

    /// The insets of the label outline relative to the bounds of this button.
    open var contentInset: UIEdgeInsets = UIEdgeInsets(left: 10, top: 4, right: 10, bottom: 4) {
        didSet {
            updateLabelConstraints()
        }
    }

    /// The background color for the button.
    ///
    /// Background color is automatically handled by a button, and if customization
    /// is required, `setBackgroundColor(_:forState:)` should be used to configure
    /// the colors for each state.
    open override var backColor: Color {
        get {
            return _backColor.getValue(controlState, defaultValue: .royalBlue)
        }
        set {
            super.backColor = newValue
        }
    }

    /// Initializes a standard button control with a given initial title label.
    public init(title: String) {
        super.init()
        label.text = title
        isEnabled = true
        mouseDownSelected = true
        strokeColor = .white
        strokeWidth = 1
        initStyle()
        cornerRadius = 4
    }

    private func initStyle() {
        _backColor.setValue(.royalBlue, forState: .normal)
        _backColor.setValue(.royalBlue.faded(towards: .white, factor: 0.1), forState: .highlighted)
        _backColor.setValue(.royalBlue.faded(towards: .black, factor: 0.1), forState: .selected)
    }

    open override func onStateChanged(_ event: ValueChangedEventArgs<ControlViewState>) async {
        await super.onStateChanged(event)

        invalidate()
    }

    open override func setupHierarchy() {
        super.setupHierarchy()

        addSubview(label)
    }

    open override func setupConstraints() {
        super.setupConstraints()

        // Label constraints
        label.layout.makeConstraints { make in
            make.edges.equalTo(self, inset: contentInset, priority: .medium)
        }
    }

    func updateLabelConstraints() {
        // Label constraints
        label.layout.updateConstraints { make in
            make.edges.equalTo(self, inset: contentInset, priority: .medium)
        }
    }

    /// Sets the appropriate background color while this button is in a given
    /// state.
    ///
    /// The color is automatically used to paint the button's background on
    /// subsequent `renderBackground(renderer:screenRegion:)` calls.
    public func setBackgroundColor(_ color: Color, forState state: ControlViewState) {
        _backColor.setValue(color, forState: state)

        if state == controlState {
            invalidate()
        }
    }

    open override func viewForFirstBaseline() -> View? {
        return label
    }
}
