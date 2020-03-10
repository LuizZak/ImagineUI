import SwiftBlend2D
import Cassowary
import Cocoa

public protocol WindowRedrawInvalidationDelegate: class {
    func window(_ window: Window, invalidateRect rect: Rectangle)
}

public class Window: ControlView {
    private var _targetSize: Size? = nil
    private var _resizeStartArea: Rectangle = .zero
    private var _resizeCorner: BorderResize?
    private var _constraintCache = LayoutConstraintSolverCache()
    private var _mouseDown = false
    private var _mouseDownPoint: Vector2 = .zero
    private let _titleLabel = Label()
    private let _buttons = WindowButtons()
    private let _titleBarHeight = 25.0
    
    private var titleBarArea: Rectangle {
        return Rectangle(x: bounds.x, y: bounds.y, width: bounds.width, height: _titleBarHeight)
    }
    
    public let contentsLayoutArea = LayoutGuide()
    public let titleBarLayoutArea = LayoutGuide()

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
    
    public override var intrinsicSize: Size? {
        return _targetSize
    }

    public weak var invalidationDelegate: WindowRedrawInvalidationDelegate?

    public init(area: Rectangle, title: String, titleFont: BLFont = Fonts.defaultFont(size: 12)) {
        self.title = title
        self.titleFont = titleFont

        super.init()
        
        initialize()

        self.area = area
        self._targetSize = area.size
        strokeWidth = 5
    }

    private func initialize() {
        _titleLabel.text = title
        _titleLabel.font = titleFont
    }
    
    public func setShouldCompress(_ isOn: Bool) {
        if isOn {
            _targetSize = .zero
        } else {
            _targetSize = nil
        }
        setNeedsLayout()
    }
    
    public override func setupHierarchy() {
        super.setupHierarchy()
        
        addSubview(_buttons)
        addSubview(_titleLabel)
        addLayoutGuide(titleBarLayoutArea)
        addLayoutGuide(contentsLayoutArea)
    }
    
    public override func setupConstraints() {
        super.setupConstraints()
        
        titleBarLayoutArea.layout.makeConstraints { make in
            make.left == self + 2
            make.top == self + 2
            make.right == self - 2
            make.height == _titleBarHeight - 2
        }
        
        contentsLayoutArea.layout.makeConstraints { make in
            make.top == titleBarLayoutArea.layout.bottom
            make.left == self + 2
            make.bottom == self - 2
            make.right == self - 2
        }
        
        _titleLabel.setContentHuggingPriority(.horizontal, 999)
        _titleLabel.setContentCompressionResistance(.horizontal, 900)
        _titleLabel.layout.makeConstraints { make in
            make.centerY == titleBarLayoutArea
            (make.centerX == titleBarLayoutArea).priority = Strength.WEAK
            make.right <= titleBarLayoutArea - 10
        }
        
        _buttons.layout.makeConstraints { make in
            make.left == titleBarLayoutArea + 10
            make.centerY == titleBarLayoutArea
            make.right <= _titleLabel.layout.left - 10
        }
    }

    public override func renderBackground(in context: BLContext, screenRegion: BLRegion) {
        super.renderBackground(in: context, screenRegion: screenRegion)

        drawWindowBackground(context)
    }

    public override func renderForeground(in context: BLContext, screenRegion: BLRegion) {
        super.renderForeground(in: context, screenRegion: screenRegion)

        if screenRegion.hitTest(BLBoxI(roundingRect: titleBarArea.transformedBounds(absoluteTransform()).asBLRect)) != .out {
            drawTitleBar(context)
        }
        
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
        _resizeCorner = resizeAtPoint(event.location)
        _resizeStartArea = area
    }

    public override func onMouseMove(_ event: MouseEventArgs) {
        super.onMouseMove(event)
        
        if _mouseDown {
            let mouseLocation = convert(point: event.location, to: nil)
            
            switch _resizeCorner {
            case .top:
                let newArea = _resizeStartArea.stretchingTop(to: mouseLocation.y - _mouseDownPoint.y)
                
                _targetSize?.y = newArea.height
                size.y = newArea.height
                location = Vector2(x: location.x, y: newArea.y)

            case .topLeft:
                let newArea = _resizeStartArea
                    .stretchingTop(to: mouseLocation.y - _mouseDownPoint.y)
                    .stretchingLeft(to: mouseLocation.x - _mouseDownPoint.x)
                
                _targetSize = newArea.size
                size = newArea.size
                location = newArea.location
                
            case .left:
                let newArea = _resizeStartArea.stretchingLeft(to: mouseLocation.x - _mouseDownPoint.x)
                
                _targetSize?.x = newArea.width
                size = Vector2(x: newArea.width, y: size.y)
                location = Vector2(x: newArea.x, y: location.y)
                
            case .right:
                _targetSize?.x = event.location.x
                setNeedsLayout()
                
            case .topRight:
                let newArea = _resizeStartArea.stretchingTop(to: mouseLocation.y - _mouseDownPoint.y)
                
                _targetSize = Vector2(x: event.location.x, y: newArea.height)
                size = Vector2(x: size.x, y: newArea.height)
                location = Vector2(x: location.x, y: newArea.y)

            case .bottomRight:
                _targetSize = event.location
                setNeedsLayout()
                
            case .bottom:
                _targetSize?.y = event.location.y
                setNeedsLayout()
                
            case .bottomLeft:
                let newArea = _resizeStartArea.stretchingLeft(to: mouseLocation.x - _mouseDownPoint.x)
                
                _targetSize = Vector2(x: newArea.width, y: event.location.y)
                size = Vector2(x: newArea.width, y: size.y)
                location = Vector2(x: newArea.x, y: location.y)
                
            case .none:
                location = mouseLocation - _mouseDownPoint
            }
            
            performLayout()
            setNeedsLayout()
        } else {
            updateMouseResizeCursor(event.location)
        }
    }
    
    public override func onMouseLeave() {
        super.onMouseLeave()
        
        NSCursor.arrow.set()
    }

    public override func onMouseUp(_ event: MouseEventArgs) {
        super.onMouseUp(event)

        _mouseDown = false
        _resizeCorner = nil
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
        let windowRounded = BLRoundRect(rect: bounds.asBLRect, radius: BLPoint(x: 4, y: 4))

        let linearGradient
            = BLLinearGradientValues(start: titleBarArea.topLeft.asBLPoint,
                                     end: titleBarArea.bottomLeft.asBLPoint + BLPoint(x: 0, y: 10))

        var gradient = BLGradient(linear: linearGradient)
        gradient.addStop(0, BLRgba32.dimGray)
        gradient.addStop(1, BLRgba32.gray)

        ctx.clipToRect(BLRect(x: bounds.x, y: bounds.y, w: bounds.width, h: 25))

        ctx.setFillStyle(gradient)
        ctx.fillRoundRect(windowRounded)

        ctx.restoreClipping()
    }
    
    private func updateMouseResizeCursor(_ point: Vector2) {
        let resize = resizeAtPoint(point)
        updateMouseResizeCursor(resize)
    }
    
    private func updateMouseResizeCursor(_ resize: BorderResize?) {
        var cursor: NSCursor?
        
        // TODO: Remove the hardcoded image paths
        switch resize {
        case .top, .bottom:
            cursor = NSCursor.resizeUpDown
        
        case .left, .right:
            cursor = NSCursor.resizeLeftRight
        
        case .topLeft, .bottomRight:
            cursor = NSCursor(image: NSImage(byReferencingFile: "/System/Library/Frameworks/WebKit.framework/Versions/Current/Frameworks/WebCore.framework/Resources/northWestSouthEastResizeCursor.png")!,
                                  hotSpot: NSPoint(x: 8, y: 8))
        
        case .topRight, .bottomLeft:
            cursor = NSCursor(image: NSImage(byReferencingFile: "/System/Library/Frameworks/WebKit.framework/Versions/Current/Frameworks/WebCore.framework/Resources/northEastSouthWestResizeCursor.png")!,
            hotSpot: NSPoint(x: 8, y: 8))
            
        case .none:
            break
        }
        
        if let cursor = cursor {
            cursor.set()
        } else {
            NSCursor.arrow.set()
        }
    }
    
    private func resizeAtPoint(_ point: Vector2) -> BorderResize? {
        let topLength = 3.0
        let length = 7.0
        
        // Corners
        if point.x < length && point.y < length {
            return .topLeft
        }
        if point.x > size.x - length && point.y < length {
            return .topRight
        }
        if point.x > size.x - length && point.y > size.y - length {
            return .bottomRight
        }
        if point.x < length && point.y > size.y - length {
            return .bottomLeft
        }
        
        // Borders
        if point.x < length {
            return .left
        }
        if point.y < topLength {
            return .top
        }
        if point.x > size.x - length {
            return .right
        }
        if point.y > size.y - length {
            return .bottom
        }
        
        return nil
    }
    
    enum BorderResize {
        case top
        case topLeft
        case left
        case bottomLeft
        case bottom
        case bottomRight
        case right
        case topRight
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
