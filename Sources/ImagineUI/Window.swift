import SwiftBlend2D
import Cassowary
import Cocoa

public protocol WindowDelegate: class {
    /// Invoked when the user has selected to close the window
    func windowWantsToClose(_ window: Window)
    
    /// Invoked when the user has selected to maximize the window
    func windowWantsToMaximize(_ window: Window)
    
    /// Invoked when the user has selected to minimize the window
    func windowWantsToMinimize(_ window: Window)
    
    /// Returns size for fullscreen
    func windowSizeForFullscreen(_ window: Window) -> Size
}

public class Window: RootView {
    /// Saves the location of the window before maximizing state
    private var _normalStateLocation: Vector2 = .zero
    
    /// List of temporary constraints applied during window resizing to mantain
    /// one or more of the boundaries of the window area fixed while the opposite
    /// sides are resized
    private var _resizeConstraints: [LayoutConstraint] = []
    
    private var _targetSize: Size? = nil
    private var _maxLocationDuringDrag: Vector2 = .zero
    private var _resizeStartArea: Rectangle = .zero
    private var _resizeCorner: BorderResize?
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
        switch windowState {
        case .maximized:
            return delegate?.windowSizeForFullscreen(self) ?? _targetSize
        case .normal, .minimized:
            return _targetSize
        }
    }
    
    private(set) public var windowState: WindowState = .normal

    public weak var delegate: WindowDelegate?

    public init(area: Rectangle, title: String, titleFont: BLFont = Fonts.defaultFont(size: 12)) {
        self.title = title
        self.titleFont = titleFont

        super.init()
        
        initialize()

        self.area = area
        self._targetSize = area.size
        strokeWidth = 5
        
        setContentHuggingPriority(.horizontal, 100)
        setContentHuggingPriority(.vertical, 100)
    }

    private func initialize() {
        _titleLabel.text = title
        _titleLabel.font = titleFont
        
        _buttons.close.mouseClicked.addListener(owner: self) { [weak self] (_, _) in
            guard let self = self else { return }
            self.delegate?.windowWantsToClose(self)
        }
        _buttons.minimize.mouseClicked.addListener(owner: self) { [weak self] (_, _) in
            guard let self = self else { return }
            self.delegate?.windowWantsToMinimize(self)
        }
        _buttons.maximize.mouseClicked.addListener(owner: self) { [weak self] (_, _) in
            guard let self = self else { return }
            self.delegate?.windowWantsToMaximize(self)
        }
    }
    
    public func setShouldCompress(_ isOn: Bool) {
        if isOn {
            _targetSize = .zero
        } else {
            _targetSize = nil
        }
        setNeedsLayout()
    }
    
    public func setTargetSize(_ size: Size) {
        _targetSize = size
        setNeedsLayout()
    }
    
    public func setWindowState(_ state: WindowState) {
        guard state != windowState else { return }
        
        // Break maximized constraints, or apply constraints for maximized state
        switch (windowState, state) {
        case (.maximized, _):
            location = _normalStateLocation
            
        case (_, .maximized):
            _normalStateLocation = location
            location = .zero
            
        default:
            break
        }
        
        isVisible = state != .minimized
        windowState = state
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
        
        _titleLabel.layout.makeConstraints { make in
            make.centerY == titleBarLayoutArea
            make.centerX.equalTo(titleBarLayoutArea, priority: 50)
            make.right <= titleBarLayoutArea - 10
            make.left >= _buttons.layout.right + 10
        }
        
        _buttons.layout.makeConstraints { make in
            make.left == titleBarLayoutArea + 10
            make.centerY == titleBarLayoutArea
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
    
    public override func layoutSizeFitting(size: Size) -> Size {
        let previousInvalidationDelegate = invalidationDelegate
        
        let result = super.layoutSizeFitting(size: size)
        
        invalidationDelegate = previousInvalidationDelegate
        return result
    }

    public override func onMouseDown(_ event: MouseEventArgs) {
        super.onMouseDown(event)

        _mouseDownPoint = event.location
        _mouseDown = true
        _resizeStartArea = area
        _resizeCorner = resizeAtPoint(event.location)
        if let resize = _resizeCorner {
            prepareWindowResize(resize)
        }
    }

    public override func onMouseMove(_ event: MouseEventArgs) {
        super.onMouseMove(event)
        
        if _mouseDown {
            performWindowResizeOrDrag(event)
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
        if isResizingWindow() {
            finishWindowResizing()
        }
    }
    
    private func isResizingWindow() -> Bool {
        return _resizeCorner != nil
    }
    
    private func prepareWindowResize(_ resize: BorderResize) {
        let optimalSize = layoutSizeFitting(size: .zero)
        
        switch resize {
        case .left, .topLeft, .bottomLeft:
            // Limit range of left edge to avoid compressin the window too much
            let maximumLeft = area.right - optimalSize.x
            _maxLocationDuringDrag = Vector2(x: maximumLeft, y: 0)
            
            _resizeConstraints.append(
                LayoutConstraint.create(first: layout.left,
                                        relationship: .lessThanOrEqual,
                                        offset: maximumLeft)
            )
            
            // Fix right edge in place
            _resizeConstraints.append(
                LayoutConstraint.create(first: layout.right,
                                        offset: area.right)
            )
        default:
            break
        }
        
        switch resize {
        case .top, .topLeft, .topRight:
            // Limit range of top edge to avoid compressin the window too much
            let maximumTop = area.bottom - optimalSize.y
            _maxLocationDuringDrag = Vector2(x: _maxLocationDuringDrag.x, y: maximumTop)
            
            _resizeConstraints.append(
                LayoutConstraint.create(first: layout.top,
                                        relationship: .lessThanOrEqual,
                                        offset: maximumTop)
            )
            
            // Fix bottom edge in place
            _resizeConstraints.append(
                LayoutConstraint.create(first: layout.bottom,
                                        offset: area.bottom)
            )
        default:
            break
        }
    }
    
    private func performWindowResizeOrDrag(_ event: MouseEventArgs) {
        switch windowState {
        case .maximized:
            setWindowState(.normal)
            performLayout()
            _mouseDownPoint = Vector2(x: size.x / 2, y: _titleBarHeight / 2)
            
        case .normal, .minimized:
            break
        }
        
        let mouseLocation = convert(point: event.location, to: nil)
        
        switch _resizeCorner {
        case .top:
            let clippedY = min(mouseLocation.y - _mouseDownPoint.y, _maxLocationDuringDrag.y)
            let newArea = _resizeStartArea.stretchingTop(to: clippedY)
            
            _targetSize?.y = newArea.height
            size = Size(x: size.x, y: newArea.height)
            location = Vector2(x: location.x, y: newArea.y)

        case .topLeft:
            let clippedX = min(mouseLocation.x - _mouseDownPoint.x, _maxLocationDuringDrag.x)
            let clippedY = min(mouseLocation.y - _mouseDownPoint.y, _maxLocationDuringDrag.y)
            
            let newArea = _resizeStartArea
                .stretchingTop(to: clippedY)
                .stretchingLeft(to: clippedX)
            
            _targetSize = newArea.size
            size = newArea.size
            location = newArea.location
            
        case .left:
            let clippedX = min(mouseLocation.x - _mouseDownPoint.x, _maxLocationDuringDrag.x)
            let newArea = _resizeStartArea.stretchingLeft(to: clippedX)
            
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
            let clippedX = min(mouseLocation.x - _mouseDownPoint.x, _maxLocationDuringDrag.x)
            let newArea = _resizeStartArea.stretchingLeft(to: clippedX)
            
            _targetSize = Vector2(x: newArea.width, y: event.location.y)
            size = Vector2(x: newArea.width, y: size.y)
            location = Vector2(x: newArea.x, y: location.y)
            
        case .none:
            location = mouseLocation - _mouseDownPoint
        }
    }
    
    private func finishWindowResizing() {
        for constraint in _resizeConstraints {
            constraint.removeConstraint()
        }
        
        _resizeConstraints.removeAll()
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
        
        switch resize {
        case .top, .bottom:
            cursor = NSCursor.resizeUpDown
        
        case .left, .right:
            cursor = NSCursor.resizeLeftRight
        
        case .topLeft, .bottomRight:
            // TODO: Remove this hardcoded image paths
            cursor = NSCursor(image: NSImage(byReferencingFile: "/System/Library/Frameworks/WebKit.framework/Versions/Current/Frameworks/WebCore.framework/Resources/northWestSouthEastResizeCursor.png")!,
                                  hotSpot: NSPoint(x: 8, y: 8))
        
        case .topRight, .bottomLeft:
            // TODO: Remove this hardcoded image paths
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
    let stackView = StackView(orientation: .horizontal)
    
    override init() {
        super.init()
        
        initializeView()
    }
    
    private func initializeView() {
        stackView.spacing = 7
        
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
            make.size == Size(x: 10, y: 10)
        }
    }
    
    override func setupHierarchy() {
        super.setupHierarchy()
        
        addSubview(stackView)
        
        stackView.addArrangedSubview(close)
        stackView.addArrangedSubview(minimize)
        stackView.addArrangedSubview(maximize)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        stackView.layout.makeConstraints { make in
            make.edges == self
        }
    }
}

public extension Window {
    enum WindowState {
        case normal
        case maximized
        case minimized
    }
}
