import Rendering

public class TreeView: ControlView {
    private let _itemViewCache: TreeViewCache = TreeViewCache()
    private let _scrollView: ScrollView = ScrollView(scrollBarsMode: .both)
    private let _content: View = View()
    private let _contentInset: UIEdgeInsets = .init(left: 0, top: 4, right: 0, bottom: 4)

    private var _expanded: Set<ItemIndex> = []
    private var _selected: Set<ItemIndex> = []
    private var _visibleItems: [ItemView] = []

    private var _lastSize: UISize? = nil

    @Event public var willExpand: CancellableActionEvent<TreeView, ItemIndex>
    @Event public var willCollapse: CancellableActionEvent<TreeView, ItemIndex>

    public weak var dataSource: TreeViewDataSource?

    public override var canBecomeFirstResponder: Bool {
        return true
    }

    public override init() {
        super.init()

        backColor = .white
        _scrollView.scrollBarsAlwaysVisible = false
    }

    public override func setupHierarchy() {
        super.setupHierarchy()

        addSubview(_scrollView)
        _scrollView.addSubview(_content)
    }

    public override func setupConstraints() {
        super.setupConstraints()

        _scrollView.layout.makeConstraints { make in
            make.edges == self
        }

        _content.layout.makeConstraints { make in
            make.left == _scrollView.contentView + _contentInset.left
            make.top == _scrollView.contentView + _contentInset.top
            make.right <= _scrollView.contentView - _contentInset.right
            make.bottom <= _scrollView.contentView - _contentInset.bottom
        }

        _content.areaIntoConstraintsMask = [.location, .size]
    }

    public override func canHandle(_ eventRequest: EventRequest) -> Bool {
        if eventRequest is KeyboardEventRequest {
            return true
        }

        return super.canHandle(eventRequest)
    }

    public override func performInternalLayout() {
        withSuspendedLayout(setNeedsLayout: false) {
            if size != _lastSize {
                _updateSize()
            }
        }
    }

    public override func onResize(_ event: ValueChangedEventArgs<UISize>) {
        super.onResize(event)

        setNeedsLayout()
    }

    public override func renderForeground(in renderer: Renderer, screenRegion: ClipRegion) {
        super.renderForeground(in: renderer, screenRegion: screenRegion)
    }

    /// Repopulates the tree view's items.
    public func reloadData() {
        suspendLayout()
        defer {
            resumeLayout(setNeedsLayout: false)
            _updateSize()
        }

        for view in _visibleItems {
            view.removeFromSuperview()
            _itemViewCache.reclaim(view: view)
        }

        _visibleItems.removeAll()

        guard let dataSource = self.dataSource else {
            _content.size = .zero
            return
        }

        _recursiveAddItems(hierarchy: .root, dataSource: dataSource, origin: .zero)
    }

    open override func onKeyDown(_ event: KeyEventArgs) {
        super.onKeyDown(event)

        guard !event.handled else { return }

        if _handleKeyDown(event.keyCode, event.modifiers) {
            event.handled = true
        }
    }

    private func _updateSize() {
        // TODO: Fix horizontal scroll bar flickering when downsizing tree views
        // TODO: horizontally.
        var totalArea: UIRectangle = .zero

        for item in _visibleItems {
            item.layoutToFit(size: UISize(width: _scrollView.visibleContentBounds.size.width - item.location.x, height: 0))
            totalArea = UIRectangle.union(totalArea, item.area)
        }

        _content.size = totalArea.size
        _lastSize = size
    }

    @discardableResult
    private func _recursiveAddItems(hierarchy: HierarchyIndex, dataSource: TreeViewDataSource, origin: UIPoint) -> Double {
        let count = dataSource.numberOfItems(at: hierarchy)
        var currentLocation = origin

        // Check first whether any item has subitems, and if so, toggle the chevron
        // area for all items.
        var reserveChevron = false
        for index in 0..<count {
            let itemIndex = hierarchy.subItem(index: index)

            if dataSource.hasItems(at: itemIndex.asHierarchyIndex) {
                reserveChevron = true
                break
            }
        }

        for index in 0..<count {
            let itemIndex = hierarchy.subItem(index: index)

            let itemView = _makeItemView(itemIndex: itemIndex, dataSource: dataSource)
            itemView.reserveChevronSpace = reserveChevron
            itemView.location = currentLocation
            itemView.layoutToFit(size: .zero)

            currentLocation.y += itemView.size.height

            _visibleItems.append(itemView)
            _content.addSubview(itemView)

            if _isExpanded(index: itemIndex) && dataSource.hasItems(at: itemIndex.asHierarchyIndex) {
                let newY = _recursiveAddItems(hierarchy: itemIndex.asHierarchyIndex, dataSource: dataSource, origin: currentLocation + UIPoint(x: 5, y: 0))

                currentLocation.y = newY
            }
        }

        return currentLocation.y
    }

    private func _makeItemView(itemIndex: ItemIndex, dataSource: TreeViewDataSource) -> ItemView {
        let itemView = _itemViewCache.dequeue(itemIndex: itemIndex) { itemView in
            itemView.mouseSelected.addListener(owner: self) { [weak self] (sender, _) in
                self?._selectItemView(sender)
            }
            itemView.mouseDownChevron.addListener(owner: self) { [weak self] (sender, _) in
                guard let self = self else { return }

                if self._isExpanded(index: sender.itemIndex) {
                    self._raiseCollapseEvent(sender.itemIndex)
                } else {
                    self._raiseExpandEvent(sender.itemIndex)
                }
            }
        }

        itemView.isChevronVisible = dataSource.hasItems(at: itemIndex.asHierarchyIndex)
        itemView.isExpanded = _isExpanded(index: itemIndex)
        itemView.isSelected = _isSelected(index: itemIndex)
        itemView.title = dataSource.titleForItem(at: itemIndex)

        return itemView
    }

    private func _handleKeyDown(_ keyCode: Keys, _ modifiers: KeyboardModifier) -> Bool {
        switch keyCode {
        case .right:
            guard _selected.count == 1, let index = _selected.first else {
                return true
            }

            if _isExpanded(index: index) {
                let next = index.asHierarchyIndex.subItem(index: 0)

                if let visible = _visibleItem(withIndex: next) {
                    _selectItemView(visible)
                    return true
                }
            } else {
                return _raiseExpandEvent(index)
            }

        case .left:
            guard _selected.count == 1, let index = _selected.first else {
                return true
            }

            if !_isExpanded(index: index) {
                let parent = index.parent

                if let visible = _visibleItem(forHierarchyIndex: parent) {
                    _selectItemView(visible)
                    return true
                }
            } else {
                return _raiseCollapseEvent(index)
            }
        default:
            break
        }

        return false
    }

    private func _expand(_ index: ItemIndex) {
        guard !_isExpanded(index: index) else {
            return
        }

        guard let dataSource = dataSource else {
            return
        }

        let hierarchyIndex = index.asHierarchyIndex

        guard dataSource.hasItems(at: hierarchyIndex) else {
            return
        }

        _expanded.insert(index)

        reloadData()
    }

    private func _collapse(_ index: ItemIndex) {
        guard _isExpanded(index: index) else {
            return
        }

        _expanded.remove(index)

        reloadData()
    }

    @discardableResult
    private func _raiseExpandEvent(_ index: ItemIndex) -> Bool {
        guard !_isExpanded(index: index) else {
            return true
        }
        guard let dataSource = dataSource else {
            return true
        }
        guard dataSource.hasItems(at: index.asHierarchyIndex) else {
            return true
        }

        let cancel = _willExpand.publishCancellableChangeEvent(sender: self, value: index)
        if !cancel {
            _expand(index)
        }

        return cancel
    }

    @discardableResult
    private func _raiseCollapseEvent(_ index: ItemIndex) -> Bool {
        guard _isExpanded(index: index) else {
            return true
        }

        let cancel = _willCollapse.publishCancellableChangeEvent(sender: self, value: index)
        if !cancel {
            _collapse(index)
        }

        return cancel
    }

    private func _selectItemView(_ itemView: ItemView) {
        if !becomeFirstResponder() {
            return
        }

        for index in _selected {
            if let view = _visibleItem(withIndex: index) {
                view.isSelected = false
            }
        }

        _selected = [itemView.itemIndex]

        itemView.isSelected = true
    }

    private func _visibleItem(forHierarchyIndex index: HierarchyIndex) -> ItemView? {
        for visible in _visibleItems {
            if visible.itemIndex.asHierarchyIndex == index {
                return visible
            }
        }

        return nil
    }

    private func _visibleItem(withIndex index: ItemIndex) -> ItemView? {
        for visible in _visibleItems {
            if visible.itemIndex == index {
                return visible
            }
        }

        return nil
    }

    private func _itemUnderPoint(_ point: UIPoint) -> ItemView? {
        return _scrollView.viewUnder(point: point) { view in
            view is ItemView
        } as? ItemView
    }

    private func _isSelected(index: ItemIndex) -> Bool {
        return _selected.contains(index)
    }

    private func _isExpanded(index: ItemIndex) -> Bool {
        return _expanded.contains(index)
    }

    private class ItemView: ControlView {
        private let _chevronView: ChevronView = ChevronView()
        private let _titleLabelView: Label = Label(textColor: .black)
        private let _contentInset: UIEdgeInsets = UIEdgeInsets(left: 4, top: 0, right: 2, bottom: 0)

        var itemIndex: ItemIndex

        @Event var mouseSelected: EventSourceWithSender<ItemView, Void>
        @Event var mouseDownChevron: EventSourceWithSender<ItemView, Void>

        @Event var selectRight: EventSourceWithSender<ItemView, Void>

        var viewToHighlight: ControlView {
            self
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

        var title: String {
            get {
                return _titleLabelView.text
            }
            set {
                _titleLabelView.text = newValue
            }
        }

        init(itemIndex: ItemIndex) {
            self.itemIndex = itemIndex

            super.init()

            _chevronView.mouseClicked.addListener(owner: self) { [weak self] (_, _) in
                self?.onMouseDownChevron()
            }

            mouseDown.addListener(owner: self) { [weak self] (_, _) in
                self?.onMouseSelected()
            }
        }

        override func setupHierarchy() {
            super.setupHierarchy()

            addSubview(_chevronView)
            addSubview(_titleLabelView)
        }

        override func performInternalLayout() {
            super.performInternalLayout()

            let properBounds = bounds.inset(_contentInset)

            _chevronView.size = .init(width: 10, height: 10)

            if !reserveChevronSpace && !isChevronVisible {
                _chevronView.size.width = 0
            }

            _chevronView.location.x = properBounds.x + 2
            _chevronView.area.centerY = properBounds.centerY

            _titleLabelView.layoutToFit(size: UISize(width: properBounds.width - _titleLabelView.location.x, height: 0))

            _titleLabelView.area = _titleLabelView.area.alignRight(of: _chevronView.area, spacing: 5, verticalAlignment: .center)
        }

        override func layoutSizeFitting(size: UISize) -> UISize {
            return withSuspendedLayout(setNeedsLayout: false) {
                let snapshot = LayoutAreaSnapshot.snapshotHierarchy(self)

                self.size = size

                performInternalLayout()
                var optimalSize = UIRectangle.union(_chevronView.area, _titleLabelView.area).size
                // Account for content inset
                optimalSize += UISize(width: _contentInset.left + _contentInset.right, height: _contentInset.top + _contentInset.bottom)

                snapshot.restore()

                return max(size, optimalSize)
            }
        }

        override func onStateChanged(_ event: ValueChangedEventArgs<ControlViewState>) {
            super.onStateChanged(event)

            if event.newValue == .selected {
                viewToHighlight.backColor = .cornflowerBlue
                _titleLabelView.textColor = .white
                _chevronView.foreColor = .white
            } else {
                viewToHighlight.backColor = .transparentBlack
                _titleLabelView.textColor = .black
                _chevronView.foreColor = .gray
            }
        }

        override func onMouseDown(_ event: MouseEventArgs) {
            super.onMouseDown(event)

            onMouseSelected()
        }

        override func boundsForFillOrStroke() -> UIRectangle {
            return bounds.inset(_contentInset)
        }

        private func onMouseDownChevron() {
            _mouseDownChevron.publishEvent(sender: self)
        }

        private func onMouseSelected() {
            _mouseSelected.publishEvent(sender: self)
        }

        private class ChevronView: ControlView {
            var isExpanded: Bool = false {
                didSet {
                    if isExpanded != oldValue {
                        setNeedsLayout()
                        invalidateControlGraphics()
                    }
                }
            }

            override var intrinsicSize: UISize? {
                return UISize(width: 10, height: 10)
            }

            override init() {
                super.init()

                foreColor = .gray
                cacheAsBitmap = false
            }

            override func renderForeground(in renderer: Renderer, screenRegion: ClipRegion) {
                let stroke = StrokeStyle(
                    color: foreColor,
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

    private class TreeViewCache {
        var reclaimed: [ItemView] = []

        func dequeue(itemIndex: TreeView.ItemIndex, initializer: (ItemView) -> Void) -> ItemView {
            // Search for a matching item index
            for (i, view) in reclaimed.enumerated() where view.itemIndex == itemIndex {
                reclaimed.remove(at: i)
                return view
            }

            // Pop any item
            if let next = reclaimed.popLast() {
                next.itemIndex = itemIndex
                return next
            }

            // Create a new view as a last resort.
            let view = ItemView(itemIndex: itemIndex)

            initializer(view)

            return view
        }

        func reclaim(view: ItemView) {
            reclaimed.append(view)
        }
    }
}
