import Geometry
import CassowarySwift
import Rendering

public class Window: RootView {
    /// Saves the location of the window before maximizing state
    private var _normalStateLocation: UIVector = .zero

    /// List of temporary constraints applied during window resizing to maintain
    /// one or more of the boundaries of the window area fixed while the opposite
    /// sides are resized
    private var _resizeConstraints: [LayoutConstraint] = []

    private var _maxLocationDuringDrag: UIVector = .zero
    private var _resizeStartArea: UIRectangle = .zero
    private var _resizeCorner: BorderResize?
    private var _mouseDown = false
    private var _mouseDownPoint: UIVector = .zero
    private let _titleLabel = Label(textColor: .white)
    private let _buttons = WindowButtons()
    private let _titleBarHeight = 25.0

    private var titleBarArea: UIRectangle {
        return UIRectangle(x: bounds.x, y: bounds.y, width: bounds.width, height: _titleBarHeight)
    }

    /// Specifies the desired target size for this window.
    /// During layout, the constraint system attempts to target this size, and
    /// if it conflicts with constraints, it sets it to the size closest to this
    /// target size capable of satisfying all active constraints.
    ///
    /// If `nil`, no preferred size is specified.
    ///
    /// Changing this value triggers a `setNeedsLayout` call automatically.
    public var targetSize: UISize? = nil {
        didSet {
            if targetSize != oldValue {
                setNeedsLayout()
            }
        }
    }

    public let contentsLayoutArea = LayoutGuide()
    public let titleBarLayoutArea = LayoutGuide()

    public var title: String {
        didSet {
            _titleLabel.text = title
        }
    }
    public var titleFont: Font {
        didSet {
            _titleLabel.font = titleFont
        }
    }

    public override var intrinsicSize: UISize? {
        switch windowState {
        case .maximized:
            return delegate?.windowSizeForFullscreen(self) ?? targetSize
        case .normal, .minimized:
            return targetSize
        }
    }

    private(set) public var windowState: WindowState = .normal

    public weak var delegate: WindowDelegate?

    public init(area: UIRectangle, title: String, titleFont: Font = Fonts.defaultFont(size: 12)) {
        self.title = title
        self.titleFont = titleFont

        super.init()

        initialize()

        self.area = area
        self.targetSize = area.size

        setContentHuggingPriority(.horizontal, 100)
        setContentHuggingPriority(.vertical, 100)
    }

    private func initialize() {
        _titleLabel.text = title
        _titleLabel.font = titleFont

        _buttons.close.mouseClicked.addListener(weakOwner: self) { [weak self] (_, _) in
            guard let self = self else { return }
            self.delegate?.windowWantsToClose(self)
        }
        _buttons.minimize.mouseClicked.addListener(weakOwner: self) { [weak self] (_, _) in
            guard let self = self else { return }
            self.delegate?.windowWantsToMinimize(self)
        }
        _buttons.maximize.mouseClicked.addListener(weakOwner: self) { [weak self] (_, _) in
            guard let self = self else { return }
            self.delegate?.windowWantsToMaximize(self)
        }
    }

    public func setShouldCompress(_ isOn: Bool) {
        if isOn {
            targetSize = .zero
        } else {
            targetSize = nil
        }
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

    public override func renderBackground(in renderer: Renderer, screenRegion: ClipRegionType) {
        super.renderBackground(in: renderer, screenRegion: screenRegion)

        drawWindowBackground(renderer)
    }

    public override func renderForeground(in context: Renderer, screenRegion: ClipRegionType) {
        super.renderForeground(in: context, screenRegion: screenRegion)

        if screenRegion.hitTest(titleBarArea.transformedBounds(absoluteTransform())) != .out {
            drawTitleBar(context)
        }

        drawWindowBorders(context)
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

        controlSystem?.setMouseCursor(.arrow)
    }

    public override func onMouseUp(_ event: MouseEventArgs) {
        super.onMouseUp(event)

        _mouseDown = false
        if isResizingWindow() {
            finishWindowResizing()
        }
    }

    public override func boundsForRedraw() -> UIRectangle {
        bounds.inflatedBy(3)
    }

    private func isResizingWindow() -> Bool {
        return _resizeCorner != nil
    }

    private func prepareWindowResize(_ resize: BorderResize) {
        let optimalSize = layoutSizeFitting(size: .zero)

        switch resize {
        case .left, .topLeft, .bottomLeft:
            // Limit range of left edge to avoid compressing the window too much
            let maximumLeft = area.right - optimalSize.width
            _maxLocationDuringDrag = UIVector(x: maximumLeft, y: 0)

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
            // Limit range of top edge to avoid compressing the window too much
            let maximumTop = area.bottom - optimalSize.height
            _maxLocationDuringDrag = UIVector(x: _maxLocationDuringDrag.x, y: maximumTop)

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
            _mouseDownPoint = UIVector(x: size.width / 2, y: _titleBarHeight / 2)

        case .normal, .minimized:
            break
        }

        let mouseLocation = convert(point: event.location, to: nil)

        switch _resizeCorner {
        case .top:
            let clippedY = min(mouseLocation.y - _mouseDownPoint.y, _maxLocationDuringDrag.y)
            let newArea = _resizeStartArea.stretchingTop(to: clippedY)

            targetSize?.height = newArea.height
            size = UISize(width: size.width, height: newArea.height)
            location = UIVector(x: location.x, y: newArea.y)

        case .topLeft:
            let clippedX = min(mouseLocation.x - _mouseDownPoint.x, _maxLocationDuringDrag.x)
            let clippedY = min(mouseLocation.y - _mouseDownPoint.y, _maxLocationDuringDrag.y)

            let newArea = _resizeStartArea
                .stretchingTop(to: clippedY)
                .stretchingLeft(to: clippedX)

            targetSize = newArea.size
            size = newArea.size
            location = newArea.location

        case .left:
            let clippedX = min(mouseLocation.x - _mouseDownPoint.x, _maxLocationDuringDrag.x)
            let newArea = _resizeStartArea.stretchingLeft(to: clippedX)

            targetSize?.width = newArea.width
            size = UISize(width: newArea.width, height: size.height)
            location = UIVector(x: newArea.x, y: location.y)

        case .right:
            targetSize?.width = event.location.x

        case .topRight:
            let newArea = _resizeStartArea.stretchingTop(to: mouseLocation.y - _mouseDownPoint.y)

            targetSize = UISize(width: event.location.x, height: newArea.height)
            size = UISize(width: size.width, height: newArea.height)
            location = UIVector(x: location.x, y: newArea.y)

        case .bottomRight:
            targetSize = event.location.asUISize

        case .bottom:
            targetSize?.height = event.location.y

        case .bottomLeft:
            let clippedX = min(mouseLocation.x - _mouseDownPoint.x, _maxLocationDuringDrag.x)
            let newArea = _resizeStartArea.stretchingLeft(to: clippedX)

            targetSize = UISize(width: newArea.width, height: event.location.y)
            size = UISize(width: newArea.width, height: size.height)
            location = UIVector(x: newArea.x, y: location.y)

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

    private func drawWindowBackground(_ renderer: Renderer) {
        let windowRounded = bounds.makeRoundedRectangle(radius: 4)

        renderer.setFill(.gray)
        renderer.fill(windowRounded)
    }

    private func drawWindowBorders(_ renderer: Renderer) {
        let windowRounded = bounds.makeRoundedRectangle(radius: 4)

        renderer.setStrokeWidth(1.5)

        renderer.setStroke(.lightGray)
        renderer.stroke(windowRounded)

        renderer.setStrokeWidth(0.5)

        renderer.setStroke(.black)
        renderer.stroke(windowRounded)
    }

    private func drawTitleBar(_ renderer: Renderer) {
        let windowRounded = bounds.makeRoundedRectangle(radius: 4)

        var gradient
            = Gradient.linear(start: titleBarArea.topLeft,
                              end: titleBarArea.bottomLeft + UIVector(x: 0, y: 10))

        gradient.addStop(offset: 0, color: .dimGray)
        gradient.addStop(offset: 1, color: .gray)

        renderer.clip(bounds.withSize(width: bounds.width, height: 25))

        renderer.setFill(gradient)
        renderer.fill(windowRounded)

        renderer.restoreClipping()
    }

    private func updateMouseResizeCursor(_ point: UIVector) {
        let resize = resizeAtPoint(point)
        updateMouseResizeCursor(resize)
    }

    private func updateMouseResizeCursor(_ resize: BorderResize?) {
        var cursor: MouseCursorKind?

        switch resize {
        case .top, .bottom:
            cursor = .resizeUpDown

        case .left, .right:
            cursor = .resizeLeftRight

        case .topLeft, .bottomRight:
            cursor = .resizeTopLeftBottomRight

        case .topRight, .bottomLeft:
            cursor = .resizeTopRightBottomLeft

        case .none:
            break
        }

        if let cursor = cursor {
            controlSystem?.setMouseCursor(cursor)
        } else {
            controlSystem?.setMouseCursor(.arrow)
        }
    }

    private func resizeAtPoint(_ point: UIVector) -> BorderResize? {
        let topLength = 3.0
        let length = 7.0

        // Corners
        if point.x < length && point.y < length {
            return .topLeft
        }
        if point.x > size.width - length && point.y < length {
            return .topRight
        }
        if point.x > size.width - length && point.y > size.height - length {
            return .bottomRight
        }
        if point.x < length && point.y > size.height - length {
            return .bottomLeft
        }

        // Borders
        if point.x < length {
            return .left
        }
        if point.y < topLength {
            return .top
        }
        if point.x > size.width - length {
            return .right
        }
        if point.y > size.height - length {
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

        close.tooltip = "Close"
        minimize.tooltip = "Minimize"
        maximize.tooltip = "Maximize"
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

    private func setButtonColor(_ button: Button, _ color: Color) {
        button.setBackgroundColor(color, forState: .normal)
        button.setBackgroundColor(color.faded(towards: .white, factor: 0.1), forState: .highlighted)
        button.setBackgroundColor(color.faded(towards: .black, factor: 0.1), forState: .selected)
    }

    private func configureButton(_ button: Button) {
        button.cornerRadius = 5
        button.strokeWidth = 0
        button.layout.makeConstraints { make in
            make.size == UISize(width: 10, height: 10)
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
