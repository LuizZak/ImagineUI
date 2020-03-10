import SwiftBlend2D

public typealias CheckboxStateWillChangeEventArgs = CancellableValueChangedEventArgs<Checkbox.State>

open class Checkbox: ControlView {
    open var checkboxState: State = .unchecked {
        didSet {
            invalidate()
        }
    }
    let label = Label()
    
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
    @Event public var checkboxStateWillChange: CancelablleValueChangeEvent<Checkbox, Checkbox.State>

    public init(title: String) {
        super.init()
        self.isEnabled = true
        label.text = title
        strokeWidth = 1.5
        mouseDownSelected = true
    }

    open override func onStateChanged(_ event: ValueChangedEventArgs<ControlViewState>) {
        super.onStateChanged(event)

        invalidateControlGraphics()
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
            make.edges.equalTo(self, inset: EdgeInsets(top: 0, left: 16, bottom: 0, right: 0))
        }
    }

    open override func renderForeground(in context: BLContext, screenRegion: BLRegion) {
        super.renderForeground(in: context, screenRegion: screenRegion)

        drawCheckBox(state: checkboxState, context)
    }

    open override func onMouseClick(_ event: MouseEventArgs) {
        super.onMouseClick(event)

        if isEnabled {
            let newState: State
            switch checkboxState {
            case .unchecked, .partial:
                newState = .checked
            case .checked:
                newState = .unchecked
            }

            invokeStateWillChangeEvent(newState: newState)
        }
    }

    func invokeStateWillChangeEvent(newState: State) {
        if !_checkboxStateWillChange.publishCancellableChangeEvent(sender: self, old: checkboxState, new: newState) {
            checkboxState = newState
        }
    }

    func drawCheckBox(state: State, _ ctx: BLContext) {
        func tintColorWithState(_ color: BLRgba32) -> BLRgba32 {
            var color = color
            if currentState == .selected {
                color = color.faded(towards: .black, factor: 0.1)
            } else if currentState == .disabled {
                if checkboxState == .unchecked {
                    color = color.faded(towards: .gray, factor: 0.5)
                } else {
                    color = color.faded(towards: .lightGray, factor: 0.5)
                }
            }

            return color
        }

        var rect = BLRect(x: 0, y: 0, w: 10, h: 10)
        rect.center.y = label.bounds.height / 2

        if state == .unchecked {
            ctx.setStrokeStyle(BLRgba32.gray)
            ctx.setStrokeWidth(1)
            ctx.strokeRect(rect)

            ctx.setFillStyle(tintColorWithState(BLRgba32.white))
            ctx.fillRect(rect)
        } else if state == .partial {
            let checkArea = rect.insetBy(x: 5.5, y: 5.5)

            ctx.setStrokeStyle(BLRgba32.lightSteelBlue)
            ctx.setStrokeWidth(strokeWidth)
            ctx.strokeRect(rect)

            ctx.setFillStyle(tintColorWithState(BLRgba32.royalBlue))
            ctx.fillRect(rect)

            ctx.setFillStyle(BLRgba32.white)
            ctx.fillRect(checkArea)
        } else if state == .checked {
            let checkArea = rect.insetBy(x: 3, y: 5)
            let checkAreaBottomLeftSize: Double = 3
            let checkAreaBottomLeft = BLRect(x: checkArea.x,
                                             y: checkArea.bottom - checkAreaBottomLeftSize,
                                             w: checkAreaBottomLeftSize,
                                             h: checkAreaBottomLeftSize)

            ctx.setStrokeStyle(BLRgba32.lightSteelBlue)
            ctx.setStrokeWidth(strokeWidth)
            ctx.strokeRect(rect)

            ctx.setFillStyle(tintColorWithState(BLRgba32.royalBlue))
            ctx.fillRect(rect)

            let points = [
                BLPoint(x: checkArea.left, y: checkAreaBottomLeft.top),
                BLPoint(x: checkAreaBottomLeft.right, y: checkArea.bottom),
                checkArea.topRight
            ]

            ctx.setStrokeStyle(BLRgba32.white)
            ctx.setStrokeCaps(.butt)
            ctx.setStrokeWidth(1.5)

            ctx.strokePolyline(points)
        }
    }

    public enum State {
        case unchecked
        case partial
        case checked
    }
}
