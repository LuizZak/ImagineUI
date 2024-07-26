extension TreeView {

    class ItemView: ControlView {
        private let _chevronView: ChevronView = ChevronView()
        private let _iconImageView: ImageView = ImageView(image: nil)
        private let _titleView: TitleView = TitleView()

        private let _contentInset: UIEdgeInsets = UIEdgeInsets(left: 4, right: 4)
        private let _imageHeight: Double = 16.0

        var itemIndex: ItemIndex
        var style: VisualStyle

        @EventWithSender<ItemView, Void>
        var mouseSelected

        @EventWithSender<ItemView, Void>
        var mouseClickChevron

        @EventWithSender<ItemView, Void>
        var mouseRightClicked

        var viewToHighlight: ControlView {
            self
        }

        /// Padding added to the left of the tree view item to indicate it belongs
        /// to a hierarchy.
        var leftIndentationSpace: Double = 0.0 {
            didSet {
                if oldValue != leftIndentationSpace {
                    setNeedsLayout()
                }
            }
        }

        var reserveChevronSpace: Bool = false {
            didSet {
                setNeedsLayout()
            }
        }

        var isChevronVisible: Bool {
            get {
                return _chevronView.isVisible
            }
            set {
                _chevronView.isVisible = newValue
            }
        }

        var isExpanded: Bool {
            get {
                return _chevronView.isExpanded
            }
            set {
                _chevronView.isExpanded = newValue
            }
        }

        var icon: Image? {
            get {
                return _iconImageView.image
            }
            set {
                _iconImageView.image = newValue
            }
        }

        var attributedTextTitle: AttributedText {
            get {
                return _titleView.attributedTextTitle
            }
            set {
                _titleView.attributedTextTitle = newValue
            }
        }

        init(itemIndex: ItemIndex, style: VisualStyle) {
            self.itemIndex = itemIndex
            self.style = style

            super.init()

            bitmapCacheBehavior = .noCaching
            _applyStyle(style.itemStyle.normal)

            _iconImageView.scalingMode = .centeredAsIs

            _setupMouseForward(_chevronView)
            _setupMouseForward(_titleView)

            _chevronView.mouseClicked.addListener(weakOwner: self) { [weak self] (_, _) in
                self?.onMouseClickChevron()
            }

            mouseDown.addListener(weakOwner: self) { [weak self] (_, _) in
                self?.onMouseSelected()
            }
        }

        private func _setupMouseForward(_ control: ControlView) {
            control.mouseEntered.addListener(weakOwner: self) { [weak self] (_, _) in
                self?.isHighlighted = true
            }
            control.mouseExited.addListener(weakOwner: self) { [weak self] (_, _) in
                self?.isHighlighted = false
            }
            control.mouseUp.addListener(weakOwner: self) { [weak self] (sender, event) in
                guard let self = self else { return }

                if !self.bounds.contains(self.convert(point: event.location, from: sender)) {
                    self.isHighlighted = false
                }
            }
        }

        override func setupHierarchy() {
            super.setupHierarchy()

            addSubview(_chevronView)
            addSubview(_iconImageView)
            addSubview(_titleView)
        }

        override func hasIndependentInternalLayout() -> Bool {
            return true
        }

        override func performInternalLayout() {
            super.performInternalLayout()

            _performLayout(size: size)
        }

        private func _performLayout(size: UISize) {
            _doBoxLayout(size: size)
        }

        private func _doBoxLayout(size: UISize) {
            // Pre-size objects
            _titleView.layoutToFit(size: .zero)
            _chevronView.location.x = 0
            _chevronView.size = .init(width: 0, height: _imageHeight)
            _iconImageView.location.x = 0
            _iconImageView.size = .init(width: 0, height: _imageHeight)

            let hasChevron = isChevronVisible
            let hasIcon = _iconImageView.image != nil

            var entries: [BoxLayout.Entry] = []

            // Chevron
            if hasChevron || (reserveChevronSpace && !hasIcon) {
                entries.append(
                    BoxLayout.Entry.fixed(
                        _chevronView,
                        length: _imageHeight,
                        spacingAfter: 2
                    )
                )
            }

            // Icon
            if hasIcon {
                entries.append(
                    BoxLayout.Entry.fixed(
                        _iconImageView,
                        length: _imageHeight,
                        spacingAfter: 2
                    )
                )
            }

            // Label
            entries.append(
                BoxLayout.Entry.extensible(
                    _titleView,
                    spacingAfter: 2
                )
            )

            BoxLayout.layout(
                entries,
                origin: _contentInset.topLeft + UIPoint(x: leftIndentationSpace, y: 0),
                availableLength: size.width
            )
        }

        override func layoutSizeFitting(size: UISize) -> UISize {
            return withSuspendedLayout(setNeedsLayout: false) {
                let snapshot = LayoutAreaSnapshot.snapshotHierarchy(self)

                _performLayout(size: size)

                var totalArea = UIRectangle.union(subviews.map(\.area))
                totalArea = totalArea.stretchingLeft(to: 0)
                totalArea = totalArea.inset(-_contentInset)

                snapshot.restore()

                return max(size, totalArea.size)
            }
        }

        override func onStateChanged(_ event: ValueChangedEventArgs<ControlViewState>) {
            super.onStateChanged(event)

            switch event.newValue {
            case .highlighted:
                _applyStyle(style.itemStyle.highlighted)

            case .selected:
                _applyStyle(style.itemStyle.selected)

            default:
                _applyStyle(style.itemStyle.normal)
            }
        }

        override func onMouseDown(_ event: MouseEventArgs) {
            super.onMouseDown(event)

            onMouseSelected()
        }

        override func onMouseClick(_ event: MouseEventArgs) {
            super.onMouseClick(event)

            if event.buttons == .right {
                onMouseRightClick()
            }
        }

        override func boundsForFillOrStroke() -> UIRectangle {
            return bounds
        }

        private func onMouseClickChevron() {
            _mouseClickChevron(sender: self)
        }

        private func onMouseSelected() {
            _mouseSelected(sender: self)
        }

        private func onMouseRightClick() {
            _mouseRightClicked(sender: self)
        }

        private func _applyStyle(_ style: VisualStyle.ItemStyle) {
            viewToHighlight.backColor = style.backgroundColor
            _chevronView.foreColor = style.chevronColor
            _titleView.textColor = style.textColor
        }

        private class TitleView: ControlView {
            private let _titleLabelView: Label = Label(textColor: .black)
            private let _contentInset: UIEdgeInsets = UIEdgeInsets(top: 4, bottom: 4)

            var title: String {
                get {
                    return attributedTextTitle.string
                }
                set {
                    attributedTextTitle = AttributedText(newValue)
                }
            }

            var textColor: Color {
                get {
                    return _titleLabelView.textColor
                }
                set {
                    _titleLabelView.textColor = newValue
                }
            }

            var attributedTextTitle: AttributedText {
                get {
                    return _titleLabelView.attributedText
                }
                set {
                    _titleLabelView.attributedText = newValue
                    tooltip = .init(text: newValue)
                }
            }

            override var viewForTooltip: View {
                _titleLabelView
            }

            override var tooltipCondition: TooltipDisplayCondition {
                .viewPartiallyOccluded
            }

            override var preferredTooltipLocation: PreferredTooltipLocation {
                .inPlace
            }

            override init() {
                super.init()

                _titleLabelView.cacheAsBitmap = false
                _titleLabelView.verticalTextAlignment = .near
            }

            override func setupHierarchy() {
                super.setupHierarchy()

                addSubview(_titleLabelView)
            }

            override func performInternalLayout() {
                super.performInternalLayout()

                _titleLabelView.location = _contentInset.topLeft
                _titleLabelView.layoutToFit(size: .zero)
            }

            override func layoutToFit(size: UISize) {
                withSuspendedLayout(setNeedsLayout: false) {
                    self.size = max(layoutSizeFitting(size: size), size)
                }
            }

            override func layoutSizeFitting(size: UISize) -> UISize {
                _titleLabelView.layoutSizeFitting(size: size) + UISize(width: 0, height: _contentInset.top + _contentInset.bottom)
            }

            override func canHandle(_ eventRequest: EventRequest) -> Bool {
                if let mouseEvent = eventRequest as? MouseEventRequest {
                    return mouseEvent.eventType == MouseEventType.mouseMove
                }

                return super.canHandle(eventRequest)
            }
        }

        private class ChevronView: ControlView {
            var isExpanded: Bool = false {
                didSet {
                    if isExpanded != oldValue {
                        invalidate()
                    }
                }
            }

            override var intrinsicSize: UISize? {
                return UISize(width: 10, height: 10)
            }

            override init() {
                super.init()

                foreColor = .gray
                bitmapCacheBehavior = .noCaching
                mouseDownSelected = true
            }

            override func onStateChanged(_ event: ValueChangedEventArgs<ControlViewState>) {
                super.onStateChanged(event)

                invalidate()
            }

            override func renderForeground(in renderer: Renderer, screenRegion: ClipRegionType) {
                var color = foreColor

                switch controlState {
                case .highlighted:
                    color = color.faded(towards: .white, factor: 0.1)

                case .selected:
                    color = color.faded(towards: .black, factor: 0.1)

                default:
                    break
                }

                let stroke = StrokeStyle(
                    color: color,
                    width: 2,
                    startCap: .round,
                    endCap: .round
                )
                renderer.setStroke(stroke)

                let strokePoints: UIPolygon = UIPolygon(vertices: [
                    UIVector(x: 0, y: 0),
                    UIVector(x: 5, y: 5),
                    UIVector(x: 0, y: 10),
                ]).withCenter(on: bounds.center)

                if isExpanded {
                    renderer.stroke(polyline: strokePoints.rotatedAroundCenter(by: .pi / 2).vertices)
                } else {
                    renderer.stroke(polyline: strokePoints.vertices)
                }
            }
        }
    }
}
