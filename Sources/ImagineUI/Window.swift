import SwiftBlend2D

public protocol WindowRedrawInvalidationDelegate: class {
    func window(_ window: Window, invalidateRect rect: Rectangle)
}

public class Window: ControlView {
    private var _constraintCache = LayoutConstraintSolverCache()
    private var _mouseDown = false
    private var _mouseDownPoint: Vector2 = .zero
    private let _titleLabel = Label(bounds: .empty)

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

    public init(area: Rectangle, title: String, titleFont: BLFont) {
        self.title = title
        self.titleFont = titleFont

        super.init(bounds: Rectangle(x: 0, y: 0, width: area.width, height: area.height))
        initialize()

        self.area = area
        strokeWidth = 1.5
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

    public override func renderBackground(in context: BLContext) {
        super.renderBackground(in: context)

        drawWindowBackground(context)
    }

    public override func renderForeground(in context: BLContext) {
        super.renderForeground(in: context)

        drawTitleBar(context)
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

    /// Returns the first control view under a given point on this window.
    ///
    /// Returns nil, if no control was found.
    ///
    /// - Parameter point: Point to hit-test against, in local coordinates of
    /// this `Window`
    /// - Parameter enabledOnly: Whether to only consider views that have
    /// interactivity enabled. See `ControlView.interactionEnabled`
    public func hitTestControl(point: Vector2, enabledOnly: Bool = true) -> ControlView? {
        for case let controlView as ControlView in subviews {
            let local = controlView.convert(point: point, from: self)

            if let control = controlView.hitTestControl(local, enabledOnly: enabledOnly) {
                return control
            }
        }

        if bounds.contains(point) {
            return self
        }

        return nil
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
        let titleBarArea = BLRect(x: bounds.x, y: bounds.y, w: bounds.width, h: 25)
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

        drawTitleBarButtons(ctx)
    }

    private func drawTitleBarButtons(_ ctx: BLContext) {
        let titleBarArea = BLRect(x: bounds.x, y: bounds.y, w: bounds.width, h: 25)

        let close = BLCircle(cx: titleBarArea.x + 15, cy: titleBarArea.center.y, r: 5)
        let minimize = BLCircle(cx: titleBarArea.x + 32, cy: titleBarArea.center.y, r: 5)
        let expand = BLCircle(cx: titleBarArea.x + 49, cy: titleBarArea.center.y, r: 5)

        ctx.setFillStyle(BLRgba32.indianRed)
        ctx.fillCircle(close)
        ctx.setFillStyle(BLRgba32.gold)
        ctx.fillCircle(minimize)
        ctx.setFillStyle(BLRgba32.limeGreen)
        ctx.fillCircle(expand)
    }
}

extension Window: RadioButtonManagerType { }
