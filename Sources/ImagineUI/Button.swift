import SwiftBlend2D

open class Button: ControlView {
    public let label = Label()

    open var title: String {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }

    open var contentInset: EdgeInsets = EdgeInsets(top: 4, left: 10, bottom: 4, right: 10) {
        didSet {
            updateLabelConstraints()
        }
    }

    public init(title: String) {
        super.init()
        label.text = title
        isEnabled = true
        mouseDownSelected = true
        strokeWidth = 1
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

        label.translatesAutoresizingMaskIntoConstraints = false

        // Intrinsic size
        layout.makeConstraints { make in
            make.width.greaterThanOrEqualTo(15)
            make.height.greaterThanOrEqualTo(15)
        }

        // Label constraints
        label.layout.makeConstraints { make in
            make.edges.equalTo(self, inset: contentInset)
        }
    }

    func updateLabelConstraints() {
        // Label constraints
        label.layout.updateConstraints { make in
            make.edges.equalTo(self, inset: contentInset)
        }
    }

    open override func renderForeground(in ctx: BLContext) {
        super.renderForeground(in: ctx)

        let roundRect = BLRoundRect(rect: bounds.asBLRect, radius: BLPoint(x: 4, y: 4))

        var color = BLRgba32.royalBlue

        if currentState == .highlighted {
            color = color.faded(towards: .white, factor: 0.1)
        } else if currentState == .selected {
            color = color.faded(towards: .black, factor: 0.1)
        }

        ctx.setFillStyle(color)
        ctx.setStrokeStyle(BLRgba32.white)
        ctx.setStrokeWidth(1)
        ctx.strokeRoundRect(roundRect)
        ctx.fillRoundRect(roundRect)
    }
    
    open override func viewForFirstBaseline() -> View? {
        return label
    }
}
