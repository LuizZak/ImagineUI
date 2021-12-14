import Foundation
import Geometry
import Rendering

open class ScrollView: ControlView {
    private let _contentView: ContentView = ContentView()
    private var _contentWidthConstraint: LayoutConstraint?
    private var _contentHeightConstraint: LayoutConstraint?

    private let _widthView: View = View()
    private let _heightView: View = View()

    private let scrollBarSize: Double = 10

    internal var contentOffset: UIVector = .zero
    internal var targetContentOffset: UIVector = .zero

    public var contentView: View {
        return _contentView
    }

    /// If enabled, over-scrolling results in an elastic effect which bounces the
    /// scroll back to the scroll limits when the user lets go of the view
    public var bounceEnabled: Bool = false

    public var scrollBarsMode: ScrollBarsVisibility {
        didSet {
            updateScrollBarVisibility()
            updateScrollBarConstraints()
        }
    }
    public var scrollBarsAlwaysVisible: Bool = true {
        didSet {
            updateScrollBarVisibility()
        }
    }

    /// A fixed content size to use for this scroll view's bounds.
    ///
    /// If `nil`, the content size is computed from the constraints affecting
    /// the `contentView`.
    ///
    /// When setting to a non-nil value, the constraints for each dimension are
    /// only created if the dimension is `>= 0`.
    public var contentSize: UISize? {
        didSet {
            if contentSize != oldValue {
                didUpdateContentSize(oldValue: oldValue)
            }
        }
    }

    open var contentBounds: UIRectangle {
        return UIRectangle(location: contentOffset, size: contentView.bounds.size)
    }

    /// Gets the visible content area of the `containerView` which is not
    /// occluded by scroll bars.
    ///
    /// If no scroll bars are visible, `visibleContentBounds` is the same as
    /// `View.bounds`.
    open var visibleContentBounds: UIRectangle {
        var size = bounds
        if scrollBarsMode.contains(.vertical) {
            size = size.inset(UIEdgeInsets(right: scrollBarSize))
        }
        if scrollBarsMode.contains(.horizontal) {
            size = size.inset(UIEdgeInsets(bottom: scrollBarSize))
        }

        size.width = max(1, size.width)
        size.height = max(1, size.height)

        return size
    }

    public let horizontalBar = ScrollBarControl(orientation: .horizontal)
    public let verticalBar = ScrollBarControl(orientation: .vertical)

    public init(scrollBarsMode: ScrollBarsVisibility) {
        self.scrollBarsMode = scrollBarsMode
        super.init()
        initialize()
    }

    func initialize() {
        cacheAsBitmap = false
        _contentView.areaIntoConstraintsMask = [.location]
        _contentView.onResizeEvent.addListener(weakOwner: self) { [weak self] (_, _) in
            self?.updateScrollBarSizes()
            self?.updateScrollBarVisibility()
        }

        updateScrollBarVisibility()

        horizontalBar.scrollChanged.addListener(weakOwner: self) { [weak self] (_, scroll) in
            self?.horizontalScrollChanged(scroll)
        }

        verticalBar.scrollChanged.addListener(weakOwner: self) { [weak self] (_, scroll) in
            self?.verticalScrollChanged(scroll)
        }

        updateScrollBarConstraints()
        didUpdateContentSize(oldValue: nil)

        Scheduler.instance.fixedFrameEvent.addListener(weakOwner: self) { [weak self] interval in
            self?.onFixedFrame(interval: interval)
        }
    }

    open override func setupHierarchy() {
        super.setupHierarchy()

        super.addSubview(_widthView)
        super.addSubview(_heightView)
        super.addSubview(contentView)
        super.addSubview(horizontalBar)
        super.addSubview(verticalBar)
    }

    open override func setupConstraints() {
        super.setupConstraints()

        _widthView.layout.makeConstraints { make in
            make.left == self
            make.top == self
            make.height == 1
        }
        _heightView.layout.makeConstraints { make in
            make.left == self
            make.top == self
            make.width == 1
        }

        //recreateSizeViewConstraints()
    }

    open override func addSubview(_ view: View) {
        contentView.addSubview(view)
    }

    private func horizontalScrollChanged(_ scroll: Double) {
        targetContentOffset = UIVector(x: -horizontalBar.scroll, y: targetContentOffset.y)
        contentOffset = UIVector(x: -horizontalBar.scroll, y: contentOffset.y)

        contentView.location = contentOffset
    }

    private func verticalScrollChanged(_ scroll: Double) {
        targetContentOffset = UIVector(x: targetContentOffset.x, y: -verticalBar.scroll)
        contentOffset = UIVector(x: contentOffset.x, y: -verticalBar.scroll)

        contentView.location = contentOffset
    }

    internal func onFixedFrame(interval: TimeInterval) {
        if contentOffset.distance(to: targetContentOffset) > 0.1 {
            contentOffset += (targetContentOffset - contentOffset) * 0.7
        } else {
            contentOffset = targetContentOffset
        }

        // Handle over-scrolling
        targetContentOffset += (limitOffsetVector(targetContentOffset) - targetContentOffset) * 0.97

        if contentView.location != contentOffset {
            contentView.location = contentOffset
        }

        horizontalBar.scroll = -contentOffset.x
        verticalBar.scroll = -contentOffset.y
    }

    public override func performInternalLayout() {
        super.performInternalLayout()

        contentView.location = contentOffset
        horizontalBar.visibleSize = bounds.width
        verticalBar.visibleSize = bounds.height

        updateScrollBarVisibility()
        limitTargetContentOffset()
        updateScrollBarSizes()
    }

    open override func onResize(_ event: ValueChangedEventArgs<UISize>) {
        super.onResize(event)

        contentView.location = contentOffset
        horizontalBar.visibleSize = bounds.width
        verticalBar.visibleSize = bounds.height

        updateScrollBarVisibility()
        limitTargetContentOffset()
        updateScrollBarSizes()

        setNeedsLayout()
    }

    open override func canHandle(_ eventRequest: EventRequest) -> Bool {
        if let mouseEvent = eventRequest as? MouseEventRequest, mouseEvent.eventType == .mouseWheel {
            return true
        }

        return super.canHandle(eventRequest)
    }

    open override func onMouseWheel(_ event: MouseEventArgs) {
        super.onMouseWheel(event)

        if event.delta == .zero {
            return
        }

        // Scroll contents a fixed amount
        incrementContentOffset(event.delta)
    }

    private func didUpdateContentSize(oldValue: UISize?) {
        // TODO: Avoid removing constraints when content size remains the same
        // TODO: across value changes.

        // Width
        _contentWidthConstraint?.removeConstraint()
        _contentWidthConstraint = nil

        if let width = contentSize?.width, width > 0 {
            _contentWidthConstraint =
            LayoutConstraint.create(first: _contentView.layout.width,
                                    relationship: .equal,
                                    offset: width)
        } else {
            _contentWidthConstraint =
            LayoutConstraint.create(first: _contentView.layout.width,
                                    second: _widthView.layout.width,
                                    relationship: .greaterThanOrEqual,
                                    priority: .high)
        }

        // Height
        _contentHeightConstraint?.removeConstraint()
        _contentHeightConstraint = nil

        if let height = contentSize?.height, height > 0 {
            _contentHeightConstraint =
            LayoutConstraint.create(first: _contentView.layout.height,
                                    relationship: .equal,
                                    offset: height)
        } else {
            _contentHeightConstraint =
            LayoutConstraint.create(first: _contentView.layout.height,
                                    second: _heightView.layout.height,
                                    relationship: .greaterThanOrEqual,
                                    priority: .high)
        }
    }

    private func incrementContentOffset(_ offset: UIVector) {
        if offset == .zero {
            return
        }

        targetContentOffset += offset

        if !bounceEnabled {
            limitTargetContentOffset()
        }
    }

    private func limitTargetContentOffset() {
        targetContentOffset = limitOffsetVector(targetContentOffset)
    }

    private func limitContentOffset() {
        contentOffset = limitOffsetVector(contentOffset)
    }

    /// Limits an offset vector (like `contentOffset` or `targetContentOffset`)
    /// to always be within the scrollable limits of this scroll view.
    private func limitOffsetVector(_ offset: UIVector) -> UIVector {
        let contentOffsetClip = UIRectangle(minimum: -(effectiveContentSize().asUIPoint - visibleContentBounds.size.asUIPoint), maximum: .zero)

        return min(contentOffsetClip.maximum, max(contentOffsetClip.minimum, offset))
    }

    func updateScrollBarVisibility() {
        updateScrollBarSizes()

        if scrollBarsAlwaysVisible {
            horizontalBar.isVisible = scrollBarsMode.contains(.horizontal)
            verticalBar.isVisible = scrollBarsMode.contains(.vertical)
            return
        }

        let horizontalBarVisible = horizontalBar.contentSize >= horizontalBar.visibleSize
        let verticalBarVisible = verticalBar.contentSize >= verticalBar.visibleSize

        horizontalBar.isVisible = horizontalBarVisible && scrollBarsMode.contains(.horizontal)
        verticalBar.isVisible = verticalBarVisible && scrollBarsMode.contains(.vertical)
    }

    func updateScrollBarConstraints() {
        verticalBar.removeAffectingConstraints()
        horizontalBar.removeAffectingConstraints()

        if scrollBarsMode.contains(.horizontal) {
            verticalBar.layout.makeConstraints { make in
                make.top == self
                make.right == self
                make.bottom == horizontalBar.layout.top
                make.width == scrollBarSize
            }
        } else {
            verticalBar.layout.makeConstraints { make in
                make.top == self
                make.right == self
                make.bottom == self
                make.width == scrollBarSize
            }
        }

        if scrollBarsMode.contains(.vertical) {
            horizontalBar.layout.makeConstraints { make in
                make.left == self
                make.bottom == self
                make.right == verticalBar.layout.left
                make.height == scrollBarSize
            }
        } else {
            horizontalBar.layout.makeConstraints { make in
                make.left == self
                make.bottom == self
                make.right == self
                make.height == scrollBarSize
            }
        }

        recreateSizeViewConstraints()
    }

    private func recreateSizeViewConstraints() {
        _widthView.layout.makeConstraints { make in
            make.left(of: verticalBar, offset: -1)
        }
        _heightView.layout.makeConstraints { make in
            make.over(horizontalBar, offset: -1)
        }
    }

    func updateScrollBarSizes() {
        let visibleSize = visibleContentBounds.size
        let contentSize = effectiveContentSize()

        horizontalBar.visibleSize = visibleSize.width
        verticalBar.visibleSize = visibleSize.height

        horizontalBar.contentSize = contentSize.width
        verticalBar.contentSize = contentSize.height
    }

    /// Gets the effective content size.
    /// Takes in consideration the size of the `contentView` but prioritizes any
    /// non-nil, greater than zero value assigned to `contentSize``.
    func effectiveContentSize() -> UISize {
        var size = contentView.bounds.size

        if let contentSize = contentSize {
            size.width  = contentSize.width  > 0 ? contentSize.width  : size.width
            size.height = contentSize.height > 0 ? contentSize.height : size.height
        }

        return max(.one, size)
    }

    public struct ScrollBarsVisibility: OptionSet {
        public var rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let none = ScrollBarsVisibility([])
        public static let horizontal = ScrollBarsVisibility(rawValue: 0b1)
        public static let vertical = ScrollBarsVisibility(rawValue: 0b10)
        public static let both: ScrollBarsVisibility = [.horizontal, .vertical]
    }

    private class ContentView: View {
        @EventWithSender<ContentView, Void> var onResizeEvent

        override var bounds: UIRectangle {
            didSet {
                if oldValue != bounds {
                    _onResizeEvent(sender: self)
                }
            }
        }
    }
}

public class ScrollBarControl: ControlView {
    private var isMouseDown = false
    private var mouseDownPoint: UIVector = .zero
    public let orientation: Orientation

    /// Size of content to scroll through.
    ///
    /// Should always be greater than zero.
    public var contentSize: Double = 1 {
        didSet {
            assert(!contentSize.isNaN)
            assert(contentSize > 0)

            guard contentSize != oldValue else { return }

            invalidateControlGraphics()
        }
    }

    /// The size of the content which is visible when scrolled
    public var visibleSize: Double = 1 {
        didSet {
            assert(!visibleSize.isNaN)

            guard visibleSize != oldValue else { return }

            invalidateControlGraphics()
        }
    }

    /// Gets or sets the scroll value.
    ///
    /// Scroll value must be between 0 and `contentSize - visibleSize`.
    public var scroll: Double = 0 {
        didSet {
            assert(!scroll.isNaN)

            guard scroll != oldValue else { return }

            invalidateControlGraphics()
        }
    }

    /// Event called when the user scrolls the scroll bar.
    ///
    /// This is not called when `scroll` value is programmatically set.
    @EventWithSender<ScrollBarControl, Double> public var scrollChanged

    public init(orientation: Orientation) {
        self.orientation = orientation
        super.init()
        backColor = .lightGray
    }

    public override func onStateChanged(_ event: ValueChangedEventArgs<ControlViewState>) {
        super.onStateChanged(event)

        invalidateControlGraphics()
    }

    open override func onResize(_ event: ValueChangedEventArgs<UISize>) {
        super.onResize(event)

        let size = event.newValue

        cornerRadius = min(size.width, size.height) / 2
    }

    public override func onMouseDown(_ event: MouseEventArgs) {
        super.onMouseDown(event)

        let barBounds = scrollBarBounds()
        assert(!barBounds.x.isNaN)
        assert(!barBounds.y.isNaN)
        assert(!barBounds.width.isNaN)
        assert(!barBounds.height.isNaN)

        if barBounds.contains(event.location) {
            isMouseDown = true
            isSelected = true
            mouseDownPoint = event.location - barBounds.location
        }
    }

    public override func onMouseMove(_ event: MouseEventArgs) {
        super.onMouseMove(event)

        isHighlighted = scrollBarBounds().contains(event.location)

        if isMouseDown {
            let mouse = event.location - mouseDownPoint
            var total = contentSize - visibleSize
            if total == 0 {
                total = 0.1
            }

            let scrollBarArea = scrollBarMouseArea()
            let clippedMouse = max(.zero, min(scrollBarArea.asUIPoint, mouse))

            let previousScroll = scroll
            switch orientation {
            case .horizontal:
                scroll = clippedMouse.x / scrollBarArea.width * total

            case .vertical:
                scroll = clippedMouse.y / scrollBarArea.height * total
            }

            if previousScroll != scroll {
                _scrollChanged(sender: self, scroll)
            }
        }
    }

    public override func onMouseUp(_ event: MouseEventArgs) {
        super.onMouseUp(event)

        isSelected = false
        isMouseDown = false
    }

    public override func onMouseLeave() {
        super.onMouseLeave()

        isHighlighted = false
    }

    public override func renderForeground(in context: Renderer, screenRegion: ClipRegion) {
        super.renderForeground(in: context, screenRegion: screenRegion)

        let barArea = scrollBarBounds()
        let radius = min(barArea.width, barArea.height) / 2
        let roundRect = barArea.makeRoundedRectangle(radius: radius)

        let color: Color
        switch controlState {
        case .highlighted:
            color = .gray.faded(towards: .white, factor: 0.2)
        case .selected:
            color = .gray.faded(towards: .black, factor: 0.2)
        default:
            color = .gray
        }

        context.setFill(color)
        context.fill(roundRect)
    }

    private func scrollBarMouseArea() -> UISize {
        assert(!bounds.width.isNaN)
        assert(!bounds.height.isNaN)

        let barArea = bounds
        let ratio = visibleSize / contentSize

        let barSizeX = barArea.width * ratio
        let w = barArea.left + barArea.width - barSizeX

        let barSizeY = barArea.height * ratio
        let h = barArea.top + barArea.height - barSizeY

        return max(.one, UISize(width: w, height: h))
    }

    private func scrollBarBounds() -> UIRectangle {
        var barArea = bounds
        barArea = barArea.inset(UIEdgeInsets(left: 2, top: 2, right: 2, bottom: 2))

        let ratio = visibleSize / contentSize

        if orientation == .vertical {
            if contentSize <= 1 || ratio >= 1 {
                return barArea
            }

            let barSize = barArea.height * ratio

            var start = barArea.top + barArea.height * min(1, scroll / contentSize)
            var end = start + barSize

            start = max(barArea.top, min(barArea.bottom, start))
            end = max(barArea.top, min(barArea.bottom, end))

            return UIRectangle(x: barArea.x, y: start, width: barArea.width, height: end - start)
        } else {
            if contentSize <= 1 || ratio >= 1 {
                return barArea
            }

            let barSize = barArea.width * ratio

            var start = barArea.left + barArea.width * min(1, scroll / contentSize)
            var end = start + barSize

            start = max(barArea.left, min(barArea.right, start))
            end = max(barArea.left, min(barArea.right, end))

            return UIRectangle(x: start, y: barArea.top, width: end - start, height: barArea.height)
        }
    }

    public enum Orientation {
        case horizontal
        case vertical
    }
}
