import SwiftBlend2D
import Cassowary

public protocol WindowRedrawInvalidationDelegate: class {
    func window(_ window: Window, invalidateRect rect: Rectangle)
}

public class Window: ControlView {
    private var _constraintCache = LayoutConstraintSolverCache()
    private var _mouseDown = false
    private var _mouseDownPoint: Vector2 = .zero
    private let _titleLabel = Label()
    private let _buttons = WindowButtons()
    private let _titleBarHeight = 25.0
    
    public let contentsLayoutArea = LayoutGuide()

    public var rootControlSystem: ControlSystem?

    public var title: String {
        didSet {
            _titleLabel.text = title
        }
    }
    public var titleFont: BLFont {
        didSet {
            _titleLabel.font = titleFont
        }
    }

    public override var controlSystem: ControlSystem? {
        return rootControlSystem
    }

    public weak var invalidationDelegate: WindowRedrawInvalidationDelegate?

    public init(area: Rectangle, title: String, titleFont: BLFont = Fonts.defaultFont(size: 12)) {
        self.title = title
        self.titleFont = titleFont

        super.init()
        
        initialize()

        self.area = area
        strokeWidth = 5
    }

    private func initialize() {
        _titleLabel.text = title
        _titleLabel.font = titleFont
        _titleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(_titleLabel)

        LayoutConstraint.create(first: _titleLabel.layout.centerX,
                                second: layout.centerX)

        LayoutConstraint.create(first: _titleLabel.layout.top,
                                second: layout.top,
                                offset: 3)
    }
    
    public override func setupHierarchy() {
        super.setupHierarchy()
        
        addSubview(_buttons)
        addLayoutGuide(contentsLayoutArea)
    }
    
    public override func setupConstraints() {
        super.setupConstraints()
        
        contentsLayoutArea.layout.makeConstraints { make in
            make.edges.equalTo(self, inset: EdgeInsets(top: _titleBarHeight, left: 2, bottom: 2, right: 2))
        }
        
        _buttons.layout.makeConstraints { make in
            make.left == self + 10
            make.centerY == self.layout.top + _titleBarHeight / 2
        }
    }

    public override func renderBackground(in context: BLContext) {
        super.renderBackground(in: context)

        drawWindowBackground(context)
    }

    public override func renderForeground(in context: BLContext) {
        super.renderForeground(in: context)

        drawTitleBar(context)
        drawWindowBorders(context)
    }
    
    internal override func performConstraintsLayout() {
        let solver = LayoutConstraintSolver()
        solver.solve(viewHierarchy: self, cache: _constraintCache)
    }
    
    override func invalidate(bounds: Rectangle, spatialReference: SpatialReferenceType) {
        let rect = spatialReference.convert(bounds: bounds, to: nil)
        invalidationDelegate?.window(self, invalidateRect: rect)
    }

    public override func onMouseDown(_ event: MouseEventArgs) {
        super.onMouseDown(event)

        _mouseDownPoint = event.location
        _mouseDown = true
    }

    public override func onMouseMove(_ event: MouseEventArgs) {
        super.onMouseMove(event)

        if _mouseDown {
            let mouseLocation = convert(point: event.location, to: nil)

            location = mouseLocation - _mouseDownPoint
        }
    }

    public override func onMouseUp(_ event: MouseEventArgs) {
        super.onMouseUp(event)

        _mouseDown = false
    }

    private func drawWindowBackground(_ ctx: BLContext) {
        let windowRounded = BLRoundRect(rect: bounds.asBLRect, radius: BLPoint(x: 4, y: 4))

        ctx.setFillStyle(BLRgba32.gray)
        ctx.fillRoundRect(windowRounded)
    }

    private func drawWindowBorders(_ ctx: BLContext) {
        let windowRounded = BLRoundRect(rect: bounds.asBLRect, radius: BLPoint(x: 4, y: 4))

        ctx.setStrokeWidth(1.5)

        ctx.setStrokeStyle(BLRgba32.lightGray)
        ctx.strokeRoundRect(windowRounded)

        ctx.setStrokeWidth(0.5)

        ctx.setStrokeStyle(BLRgba32.black)
        ctx.strokeRoundRect(windowRounded)
    }

    private func drawTitleBar(_ ctx: BLContext) {
        let titleBarArea = BLRect(x: bounds.x, y: bounds.y, w: bounds.width, h: _titleBarHeight)
        let windowRounded = BLRoundRect(rect: bounds.asBLRect, radius: BLPoint(x: 4, y: 4))

        let linearGradient
            = BLLinearGradientValues(start: titleBarArea.topLeft,
                                     end: titleBarArea.bottomLeft + BLPoint(x: 0, y: 10))

        var gradient = BLGradient(linear: linearGradient)
        gradient.addStop(0, BLRgba32.dimGray)
        gradient.addStop(1, BLRgba32.gray)

        ctx.clipToRect(BLRect(x: bounds.x, y: bounds.y, w: bounds.width, h: 25))

        ctx.setFillStyle(gradient)
        ctx.fillRoundRect(windowRounded)

        ctx.restoreClipping()
    }
}

extension Window: RadioButtonManagerType { }

class WindowButtons: View {
    let close = Button(title: "")
    let minimize = Button(title: "")
    let maximize = Button(title: "")
    
    override init() {
        super.init()
        
        initializeView()
    }
    
    private func initializeView() {
        configureButton(close)
        configureButton(minimize)
        configureButton(maximize)
        
        setButtonColor(close, .indianRed)
        setButtonColor(minimize, .gold)
        setButtonColor(maximize, .limeGreen)
    }
    
    private func setButtonColor(_ button: Button, _ color: BLRgba32) {
        button.setBackgroundColor(color, forState: .normal)
        button.setBackgroundColor(color.faded(towards: .white, factor: 0.1), forState: .highlighted)
        button.setBackgroundColor(color.faded(towards: .black, factor: 0.1), forState: .selected)
    }
    
    private func configureButton(_ button: Button) {
        button.cornerRadius = 5
        button.strokeWidth = 0
        button.layout.makeConstraints { make in
            (make.size == Size(x: 10, y: 10)).setPriority(Strength.REQUIRED)
        }
    }
    
    override func setupHierarchy() {
        super.setupHierarchy()
        
        addSubview(close)
        addSubview(minimize)
        addSubview(maximize)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        close.layout.makeConstraints { make in
            make.left == self
            make.bottom == self
            make.top == self
        }
        minimize.layout.makeConstraints { make in
            make.top == close
            make.bottom == self
            make.right(of: close, offset: 7)
        }
        maximize.layout.makeConstraints { make in
            make.top == close
            make.bottom == self
            make.right(of: minimize, offset: 7)
            make.right == self
        }
    }
}
