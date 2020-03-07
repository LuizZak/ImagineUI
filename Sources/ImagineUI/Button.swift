import SwiftBlend2D

open class Button: ControlView {
    private var _backColor = StatedValueStore<BLRgba32>()
    
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
        initStyle()
    }
    
    private func initStyle() {
        _backColor.setValue(.royalBlue, forState: .normal)
        _backColor.setValue(BLRgba32.royalBlue.faded(towards: .white, factor: 0.1), forState: .highlighted)
        _backColor.setValue(BLRgba32.royalBlue.faded(towards: .black, factor: 0.1), forState: .selected)
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
            make.edges.equalTo(self, inset: contentInset).setPriority(500)
        }
    }

    func updateLabelConstraints() {
        // Label constraints
        label.layout.updateConstraints { make in
            make.edges.equalTo(self, inset: contentInset).setPriority(500)
        }
    }
    
    func setBackgroundColor(_ color: BLRgba32, forState state: ControlViewState) {
        _backColor.setValue(color, forState: state)
    }
    
    open override func renderBackground(in ctx: BLContext) {
        let roundRect = BLRoundRect(rect: bounds.asBLRect, radius: BLPoint(x: 4, y: 4))

        let color = _backColor.getValue(currentState, defaultValue: BLRgba32.royalBlue)

        ctx.setFillStyle(color)
        ctx.setStrokeStyle(strokeColor)
        ctx.setStrokeWidth(strokeWidth)
        ctx.strokeRoundRect(roundRect)
        ctx.fillRoundRect(roundRect)
    }
    
    open override func viewForFirstBaseline() -> View? {
        return label
    }
}
