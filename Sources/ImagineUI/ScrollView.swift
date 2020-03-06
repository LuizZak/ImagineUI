import Foundation

open class ScrollView: ControlView {
    private let scrollBarSize: Double = 10

    internal var contentOffset: Vector2 = .zero
    internal var targetContentOffset: Vector2 = .zero
    
    public let contentView = View()
    
    /// If enabled, overscrolling results in an elastic effect which bounces the
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

    open var contentSize: Size = .zero {
        didSet {
            layoutContentView()
        }
    }

    open var contentBounds: Rectangle {
        return Rectangle(location: contentOffset, size: effectiveContentSize())
    }

    open override var bounds: Rectangle {
        didSet {
            if bounds.size != oldValue.size {
                layoutContentView()
            }
        }
    }

    /// Gets the visible content area of the `containerView` which is not
    /// occluded by scroll bars.
    ///
    /// If no scroll bars are visible, `bisibleContentBounds` is the same as
    /// `View.bounds`.
    open var visibleContentBounds: Rectangle {
        var final = bounds
        if scrollBarsMode.contains(.vertical) {
            final = final.inset(EdgeInsets(top: 0, left: 0, bottom: 0, right: scrollBarSize))
        }
        if scrollBarsMode.contains(.horizontal) {
            final = final.inset(EdgeInsets(top: 0, left: 0, bottom: scrollBarSize, right: 0))
        }

        return final
    }

    public let horizontalBar = ScrollBarControl(orientation: .horizontal)
    public let verticalBar = ScrollBarControl(orientation: .vertical)

    public init(scrollBarsMode: ScrollBarsVisibility) {
        self.scrollBarsMode = scrollBarsMode
        super.init()
        initialize()
    }

    func initialize() {
        super.addSubview(contentView)
        super.addSubview(horizontalBar)
        super.addSubview(verticalBar)

        updateScrollBarVisibility()
        
        horizontalBar.scrollChanged.addListener(owner: self) { [weak self] (_, scroll) in
            self?.horizontalScrollChanged(scroll)
        }
        
        verticalBar.scrollChanged.addListener(owner: self) { [weak self] (_, scroll) in
            self?.verticalScrollChanged(scroll)
        }

        updateScrollBarConstraints()
    }
    
    private func horizontalScrollChanged(_ scroll: Double) {
        targetContentOffset = Vector2(x: -horizontalBar.scroll, y: targetContentOffset.y)
        contentOffset = Vector2(x: -horizontalBar.scroll, y: contentOffset.y)
    }
    
    private func verticalScrollChanged(_ scroll: Double) {
        targetContentOffset = Vector2(x: targetContentOffset.x, y: -verticalBar.scroll)
        contentOffset = Vector2(x: contentOffset.x, y: -verticalBar.scroll)
    }
    
    open override func addSubview(_ view: View) {
        contentView.addSubview(view)
    }
    
    open override func onFixedFrame(interval: TimeInterval) {
        super.onFixedFrame(interval: interval)
        
        if contentOffset.distance(to: targetContentOffset) > 0.1 {
            contentOffset += (targetContentOffset - contentOffset) * 0.7
        } else {
            contentOffset = targetContentOffset
        }
        
        // Handle overscrolling
        targetContentOffset += (limitOffsetVector(targetContentOffset) - targetContentOffset) * 0.97
        
        if contentView.location != contentOffset {
            contentView.location = contentOffset
        }
        if contentView.bounds.size != effectiveContentSize() {
           contentView.bounds.size = effectiveContentSize()
        }
        
        horizontalBar.scroll = -contentOffset.x
        verticalBar.scroll = -contentOffset.y
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

    private func incrementContentOffset(_ offset: Vector2) {
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
    private func limitOffsetVector(_ offset: Vector2) -> Vector2 {
        // Limit content offset within a maximum visible bounds
        var contentOffsetClip = Rectangle(min: -(effectiveContentSize() - bounds.size), max: .zero)
        
        if contentSize.x == 0 {
            contentOffsetClip.x = 0
        }
        if contentSize.y == 0 {
            contentOffsetClip.y = 0
        }
        
        var outVector = offset

        if contentBounds.width <= bounds.width {
            outVector.x = 0
        }
        if contentBounds.height <= bounds.height {
            outVector.y = 0
        }

        if contentBounds.width > bounds.width || contentBounds.height > bounds.height {
            outVector = max(contentOffsetClip.minimum, min(contentOffsetClip.maximum, outVector))
        }

        return outVector
    }

    func updateScrollBarVisibility() {
        if scrollBarsAlwaysVisible {
            horizontalBar.isVisible = scrollBarsMode.contains(.horizontal)
            verticalBar.isVisible = scrollBarsMode.contains(.vertical)
            return
        }

        let horizontalBarVisible = contentSize.x > (bounds.width - verticalBar.bounds.width)
        let verticalBarVisible = contentSize.y > (bounds.height - verticalBar.bounds.height)

        horizontalBar.isVisible = horizontalBarVisible && scrollBarsMode.contains(.horizontal)
        verticalBar.isVisible = verticalBarVisible && scrollBarsMode.contains(.vertical)
    }
    
    func updateScrollBarConstraints() {
        if scrollBarsMode.contains(.horizontal) {
            verticalBar.layout.remakeConstraints { make in
                make.top == self
                make.right == self
                make.bottom == horizontalBar.layout.top
                make.width == scrollBarSize
            }
        } else {
            verticalBar.layout.remakeConstraints { make in
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
    }

    func effectiveContentSize() -> Size {
        let bounds = visibleContentBounds

        let width = contentSize.x == 0 ? bounds.width : contentSize.x
        let height = contentSize.y == 0 ? bounds.height : contentSize.y

        return Size(x: width, y: height)
    }

    func layoutContentView() {
        contentView.bounds.size = effectiveContentSize()
    }
    
    open override func onResize(_ event: ValueChangedEventArgs<Size>) {
        super.onResize(event)
        
        contentView.location = contentOffset
        contentView.bounds.size = effectiveContentSize()

        horizontalBar.visibleSize = bounds.width
        verticalBar.visibleSize = bounds.height
        
        updateScrollBarVisibility()
        limitTargetContentOffset()

        horizontalBar.contentSize = contentSize.x
        verticalBar.contentSize = contentSize.y
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
}

public class ScrollBarControl: ControlView {
    private let scrollBarKnob = ControlView()
    
    public let orientation: Orientation
    
    /// Size of content to scroll through
    public var contentSize: Double = 0 {
        didSet {
            updateScrollBarPosition()
        }
    }
    
    /// The size of the content which is visible when scrolled
    public var visibleSize: Double = 0 {
        didSet {
            updateScrollBarPosition()
        }
    }
    
    /// Gets or sets the scroll value.
    ///
    /// Scroll value must be between 0 and `contentSize - visibleSize`.
    public var scroll: Double = 0 {
        didSet {
            updateScrollBarPosition()
        }
    }
    
    /// Event called when the user scrolls the scroll bar.
    ///
    /// This is not called when `scroll` value is programatically set.
    @Event public var scrollChanged: EventSourceWithSender<ScrollBarControl, Double>

    public init(orientation: Orientation) {
        self.orientation = orientation
        super.init()
        backColor = .lightGray
        addSubview(scrollBarKnob)
        scrollBarKnob.suspendLayout()
        initStyle()
        updateScrollBarPosition()
    }
    
    private func initStyle() {
        scrollBarKnob.backColor = .gray
    }
    
    open override func onResize(_ event: ValueChangedEventArgs<Size>) {
        super.onResize(event)
        
        let size = event.newValue
        
        cornerRadius = min(size.x, size.y) / 2
        scrollBarKnob.cornerRadius = cornerRadius
        
        updateScrollBarPosition()
    }
    
    private func updateScrollBarPosition() {
        var barArea = bounds
        barArea = barArea.inset(EdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
        
        if orientation == .vertical {
            let ratio = visibleSize / contentSize
            if contentSize == 0 || ratio >= 1 {
                scrollBarKnob.location = barArea.minimum
                scrollBarKnob.bounds.size = barArea.size

                return
            }
            
            let barSize = barArea.height * ratio

            var start = barArea.top + barArea.height * min(1, scroll / contentSize)
            var end = start + barSize
            
            start = max(barArea.top, min(barArea.bottom, start))
            end = max(barArea.top, min(barArea.bottom, end))

            scrollBarKnob.location = Vector2(x: barArea.left, y: start)
            scrollBarKnob.bounds.size = Size(x: barArea.width, y: end - start)
        } else {
            let ratio = visibleSize / contentSize
            if contentSize == 0 || ratio >= 1 {
                scrollBarKnob.location = barArea.minimum
                scrollBarKnob.bounds.size = barArea.size

                return
            }

            let barSize = barArea.width * ratio

            var start = barArea.left + barArea.width * min(1, scroll / contentSize)
            var end = start + barSize

            start = max(barArea.left, min(barArea.right, start))
            end = max(barArea.left, min(barArea.right, end))

            scrollBarKnob.location = Vector2(x: start, y: barArea.top)
            scrollBarKnob.bounds.size = Vector2(x: end - start, y: barArea.height)
        }
    }

    public enum Orientation {
        case horizontal
        case vertical
    }
}
