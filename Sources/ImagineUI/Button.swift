import SwiftBlend2D
import Cassowary

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
    
    open override var backColor: BLRgba32 {
        get {
            return _backColor.getValue(currentState, defaultValue: .royalBlue)
        }
        set {
            super.backColor = newValue
        }
    }

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

        // Label constraints
        label.layout.makeConstraints { make in
            make.edges.equalTo(self, inset: contentInset).setPriority(Strength.MEDIUM)
        }
    }

    func updateLabelConstraints() {
        // Label constraints
        label.layout.updateConstraints { make in
            make.edges.equalTo(self, inset: contentInset).setPriority(Strength.MEDIUM)
        }
    }
    
    /// Sets the appropriate background color while this button is in a given
    /// state
    func setBackgroundColor(_ color: BLRgba32, forState state: ControlViewState) {
        _backColor.setValue(color, forState: state)
        
        if state == currentState {
            invalidateControlGraphics()
        }
    }
    
    open override func viewForFirstBaseline() -> View? {
        return label
    }
}
