import Geometry
import Rendering

public typealias CheckboxStateWillChangeEventArgs = CancellableValueChangedEventArgs<Checkbox.State>

open class Checkbox: ControlView {
    private let textStates = StatedValueStore<String>()
    public let label = Label(textColor: .white)

    open var checkboxState: State = .unchecked {
        didSet {
            invalidate()
        }
    }

    open var title: String {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }

    /// Invoked by the checkbox when the user changes its state, before the new
    /// state is applied.
    ///
    /// Event listeners have a chance to cancel the event by switching `cancel`
    /// to `true` during the event dispatch round.
    @CancellableValueChangeEventWithSender<Checkbox, Checkbox.State>
    public var checkboxStateWillChange

    public init(title: String) {
        super.init()
        self.isEnabled = true
        label.text = title
        strokeWidth = 1.5
        mouseDownSelected = true
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

        drawCheckBox(state: checkboxState, renderer)
    }

    open override func onMouseClick(_ event: MouseEventArgs) async {
        await super.onMouseClick(event)

        if isEnabled {
            let newState: State
            switch checkboxState {
            case .unchecked, .partial:
                newState = .checked
            case .checked:
                newState = .unchecked
            }

            await invokeStateWillChangeEvent(newState: newState)
        }
    }

    func invokeStateWillChangeEvent(newState: State) async {
        if await !_checkboxStateWillChange(sender: self, old: checkboxState, new: newState) {
            checkboxState = newState
        }
    }

    func drawCheckBox(state: State, _ renderer: Renderer) {
        func tintColorWithState(_ color: Color) -> Color {
            var color = color
            if controlState == .selected {
                color = color.faded(towards: .black, factor: 0.1)
            } else if controlState == .disabled {
                if checkboxState == .unchecked {
                    color = color.faded(towards: .gray, factor: 0.5)
                } else {
                    color = color.faded(towards: .lightGray, factor: 0.5)
                }
            }

            return color
        }

        var rect = UIRectangle(x: 0, y: 0, width: 10, height: 10)
        rect.center.y = label.bounds.height / 2

        if state == .unchecked {
            renderer.setStroke(.gray)
            renderer.setStrokeWidth(1)
            renderer.stroke(rect)

            renderer.setFill(tintColorWithState(.white))
            renderer.fill(rect)
        } else if state == .partial {
            let checkArea = rect.insetBy(x: 5.5, y: 5.5)

            renderer.setStroke(.lightSteelBlue)
            renderer.setStrokeWidth(strokeWidth)
            renderer.stroke(rect)

            renderer.setFill(tintColorWithState(.royalBlue))
            renderer.fill(rect)

            renderer.setFill(.white)
            renderer.fill(checkArea)
        } else if state == .checked {
            let checkArea = rect.insetBy(x: 3, y: 5)
            let checkAreaBottomLeftSize: Double = 3
            let checkAreaBottomLeft = UIRectangle(x: checkArea.x,
                                                y: checkArea.bottom - checkAreaBottomLeftSize,
                                                width: checkAreaBottomLeftSize,
                                                height: checkAreaBottomLeftSize)

            renderer.setStroke(.lightSteelBlue)
            renderer.setStrokeWidth(strokeWidth)
            renderer.stroke(rect)

            renderer.setFill(tintColorWithState(.royalBlue))
            renderer.fill(rect)

            let points = [
                UIVector(x: checkArea.left, y: checkAreaBottomLeft.top),
                UIVector(x: checkAreaBottomLeft.right, y: checkArea.bottom),
                checkArea.topRight
            ]

            let stroke = StrokeStyle(color: .white,
                                     width: 1.5,
                                     startCap: .butt,
                                     endCap: .butt)

            renderer.setStroke(stroke)

            renderer.stroke(polyline: points)
        }
    }

    public enum State {
        case unchecked
        case partial
        case checked
    }
}
