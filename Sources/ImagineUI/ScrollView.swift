import Foundation
import Geometry
import SwiftBlend2D
import Rendering

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
    /// If no scroll bars are visible, `visibleContentBounds` is the same as
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
        
        Scheduler.instance.fixedFrameEvent.addListener(owner: self) { [weak self] interval in
            self?.onFixedFrame(interval: interval)
        }
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
    
    internal func onFixedFrame(interval: TimeInterval) {
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
    private var isMouseDown = false
    private var mouseDownPoint: Vector2 = .zero
    public let orientation: Orientation
    
    /// Size of content to scroll through
    public var contentSize: Double = 0 {
        didSet {
            guard contentSize != oldValue else { return }
            
            invalidateControlGraphics()
        }
    }
    
    /// The size of the content which is visible when scrolled
    public var visibleSize: Double = 0 {
        didSet {
            guard visibleSize != oldValue else { return }
            
            invalidateControlGraphics()
        }
    }
    
    /// Gets or sets the scroll value.
    ///
    /// Scroll value must be between 0 and `contentSize - visibleSize`.
    public var scroll: Double = 0 {
        didSet {
            guard scroll != oldValue else { return }
            
            invalidateControlGraphics()
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
    }
    
    public override func onStateChanged(_ event: ValueChangedEventArgs<ControlViewState>) {
        super.onStateChanged(event)
        
        invalidateControlGraphics()
    }
    
    open override func onResize(_ event: ValueChangedEventArgs<Size>) {
        super.onResize(event)
        
        let size = event.newValue
        
        cornerRadius = min(size.x, size.y) / 2
    }
    
    public override func onMouseDown(_ event: MouseEventArgs) {
        super.onMouseDown(event)
        
        if scrollBarBounds().contains(event.location) {
            isMouseDown = true
            isSelected = true
            mouseDownPoint = event.location - scrollBarBounds().location
        }
    }
    
    public override func onMouseMove(_ event: MouseEventArgs) {
        super.onMouseMove(event)
        
        isHighlighted = scrollBarBounds().contains(event.location)
        if isMouseDown {
            let mouse = event.location - mouseDownPoint
            let total = contentSize - visibleSize
            let scrollBarArea = scrollBarMouseArea()
            let clippedMouse = max(.zero, min(scrollBarArea, mouse))
            
            let previousScroll = scroll
            switch orientation {
            case .horizontal:
                scroll = clippedMouse.x / scrollBarArea.x * total
                
            case .vertical:
                scroll = clippedMouse.y / scrollBarArea.y * total
            }
            
            if previousScroll != scroll {
                _scrollChanged.publishEvent(sender: self, scroll)
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
        let roundRect = barArea.rounded(radius: radius)
        
        let color: Color
        switch currentState {
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
    
    private func scrollBarMouseArea() -> Vector2 {
        let barArea = bounds
        let ratio = visibleSize / contentSize
        
        let barSizeX = barArea.width * ratio
        let x = barArea.left + barArea.width - barSizeX
        
        let barSizeY = barArea.height * ratio
        let y = barArea.top + barArea.height - barSizeY
        
        return Vector2(x: x, y: y)
    }
    
    private func scrollBarBounds() -> Rectangle {
        var barArea = bounds
        barArea = barArea.inset(EdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
        
        let ratio = visibleSize / contentSize
        
        if orientation == .vertical {
            if contentSize == 0 || ratio >= 1 {
                return barArea
            }
            
            let barSize = barArea.height * ratio

            var start = barArea.top + barArea.height * min(1, scroll / contentSize)
            var end = start + barSize
            
            start = max(barArea.top, min(barArea.bottom, start))
            end = max(barArea.top, min(barArea.bottom, end))

            return Rectangle(x: barArea.x, y: start, width: barArea.width, height: end - start)
        } else {
            if contentSize == 0 || ratio >= 1 {
                return barArea
            }

            let barSize = barArea.width * ratio

            var start = barArea.left + barArea.width * min(1, scroll / contentSize)
            var end = start + barSize

            start = max(barArea.left, min(barArea.right, start))
            end = max(barArea.left, min(barArea.right, end))

            return Rectangle(x: start, y: barArea.top, width: end - start, height: barArea.height)
        }
    }

    public enum Orientation {
        case horizontal
        case vertical
    }
}
