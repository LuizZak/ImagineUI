import SwiftBlend2D

open class RadioButton: ControlView {
    let label = Label(bounds: .empty)
    
    /// Gets or sets the radio button manager for this radio button.
    /// If not specified, the default radio button manager will be the first
    /// parent view that implements `RadioButtonManagerType`.
    var radioButtonManager: RadioButtonManagerType?

    public init(location: Vector2, title: String) {
        super.init(bounds: .empty)
        self.location = location
        isEnabled = true
        label.text = title
        strokeWidth = 1.5
    }

    open override func setupHierarchy() {
        super.setupHierarchy()

        addSubview(label)
    }
    
    open override func onStateChanged(_ oldState: ControlViewState, _ state: ControlViewState) {
        super.onStateChanged(oldState, state)
        
        invalidateControlGraphics()
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
            make.edges.equalTo(self, inset: EdgeInsets(top: 0, left: 16, bottom: 0, right: 0))
        }
    }

    open override func renderForeground(in context: BLContext) {
        super.renderForeground(in: context)

        drawRadioButton(context)
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

    func drawRadioButton(_ ctx: BLContext) {
        var circle = BLCircle(center: BLPoint(x: 6, y: 6), radius: 6)
        circle.center.y = label.bounds.height / 2

        if isSelected {
            ctx.setStrokeStyle(BLRgba32.lightSteelBlue)
            ctx.setStrokeWidth(strokeWidth)
            ctx.strokeCircle(circle)

            ctx.setFillStyle(BLRgba32.royalBlue)
            ctx.fillCircle(circle)

            ctx.setFillStyle(BLRgba32.white)
            ctx.fillCircle(circle.expanded(by: -3.5))
        } else {
            ctx.setStrokeStyle(BLRgba32.gray)
            ctx.setStrokeWidth(strokeWidth)
            ctx.strokeCircle(circle)

            ctx.setFillStyle(BLRgba32.white)
            ctx.fillCircle(circle)
        }
    }
}
