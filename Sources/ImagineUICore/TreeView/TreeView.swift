import Rendering

public class TreeView: ControlView {
    private let _itemViewCache: TreeViewCache = TreeViewCache()
    private let _scrollView: ScrollView = ScrollView(scrollBarsMode: .both)
    private let _content: View = View()
    private let _contentInset: UIEdgeInsets = .init(top: 4, bottom: 4)
    private let _subItemInset: Double = 5.0

    private var _expanded: Set<ItemIndex> = []
    private var _selected: Set<ItemIndex> = []
    private var _visibleItems: [ItemView] = []

    private var _lastSize: UISize? = nil

    /// Event raised when an item within this tree view is about to be expanded.
    @CancellableActionEventWithSender<TreeView, ItemIndex>
    public var willExpand
    
    /// Event raised when an item within this tree view is about to be collapsed.
    @CancellableActionEventWithSender<TreeView, ItemIndex>
    public var willCollapse

    /// Event raised when an item within this tree view is about to be selected.
    @CancellableActionEventWithSender<TreeView, ItemIndex>
    public var willSelect

    /// Event raised when one or more items within this tree view are about to
    /// be deselected.
    @CancellableActionEventWithSender<TreeView, Set<ItemIndex>>
    public var willDeselect

    @EventWithSender<TreeView, ItemIndex>
    public var mouseRightClickedItem

    public weak var dataSource: TreeViewDataSource?

    public override var canBecomeFirstResponder: Bool {
        return true
    }

    /// If `true`, items can be deselected by clicking on empty spaces with no
    /// tree view items within the bounds of this tree view control.
    ///
    /// Defaults to `false`.
    public var canDeselectItemsOnEmptySpaces: Bool = true

    /// A percentage of the display height of the tree view that the scroll view
    /// is padded at the bottom in order to create an empty space past the end
    /// of the list of items.
    ///
    /// - seealso: ``ScrollView.overScrollFactor``
    public var overScrollFactor: Double {
        get { _scrollView.overScrollFactor }
        set { _scrollView.overScrollFactor = newValue }
    }

    /// Specifies the visual style of this tree view.
    public var style: VisualStyle = VisualStyle.defaultDarkStyle() {
        didSet {
            _applyStyle()
        }
    }

    public override init() {
        super.init()

        cacheAsBitmap = false
        _scrollView.scrollBarsAlwaysVisible = false
        _applyStyle()
    }

    // MARK: - Hierarchy

    public override func setupHierarchy() {
        super.setupHierarchy()

        addSubview(_scrollView)
        _scrollView.addSubview(_content)

        _configureView()
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

    public override func performInternalLayout() {
        withSuspendedLayout(setNeedsLayout: false) {
            if size != _lastSize {
                _layoutItemViews()
            }
        }
    }

    private func _configureView() {
        _scrollView.mouseClicked.addListener(weakOwner: self) { [weak self] (_, _) in
            guard let self = self else { return }

            self._raiseDeselectEvent(self._selected)
        }
    }

    // MARK: - Events

    public override func canHandle(_ eventRequest: EventRequest) -> Bool {
        if eventRequest is KeyboardEventRequest {
            return true
        }

        return super.canHandle(eventRequest)
    }

    public override func onKeyDown(_ event: KeyEventArgs) {
        super.onKeyDown(event)

        guard !event.handled else { return }

        if _handleKeyDown(event.keyCode, event.modifiers) {
            event.handled = true
        }
    }

    public override func onMouseClick(_ event: MouseEventArgs) {
        super.onMouseClick(event)

        if canDeselectItemsOnEmptySpaces {
            _raiseDeselectEvent(_selected)
        }
    }

    // MARK: - Data/display management

    /// Repopulates the tree view's items.
    public func reloadData() {
        suspendLayout()
        defer {
            _layoutItemViews()
            resumeLayout(setNeedsLayout: true)
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

        _recursiveAddItems(hierarchy: .root, dataSource: dataSource)
    }

    /// Requests that the TreeView collapse all currently expanded items.
    public func collapseAll() {
        for index in _expanded {
            _collapse(index)
        }
    }

    /// Requests that the TreeView collapse a given item index.
    public func collapse(index: ItemIndex) {
        _collapse(index)
    }

    /// Requests that the TreeView collapse a given item index.
    public func expand(index: ItemIndex) {
        _expand(index)
    }

    // MARK: - Internals

    private func _applyStyle() {
        backColor = style.backgroundColor

        for visible in _visibleItems {
            visible.style = style
        }
    }

    private func _layoutItemViews() {
        withSuspendedLayout(setNeedsLayout: true) {
            var totalArea: UIRectangle = .zero
            var currentY: Double = 0.0

            for item in _visibleItems.sorted(by: { $0.itemIndex < $1.itemIndex }) {
                item.location.y = currentY
                item.layoutToFit(size: UISize(width: _scrollView.visibleContentBounds.size.width, height: 0))
                currentY += item.area.height

                totalArea = UIRectangle.union(totalArea, item.area)
            }

            // Do a second pass to assign the largest width to all visible items
            for item in _visibleItems {
                item.layoutToFit(size: UISize(width: totalArea.width, height: 0))
            }

            _content.size = totalArea.size
            _lastSize = size
        }
    }

    private func _handleKeyDown(_ keyCode: Keys, _ modifiers: KeyboardModifier) -> Bool {
        switch keyCode {
        case .up:
            guard _selected.count == 1, let selectedIndex = _selected.first else {
                return true
            }

            var candidateView: ItemView?
            for itemView in _visibleItems {
                guard let current = candidateView else {
                    if itemView.itemIndex < selectedIndex {
                        candidateView = itemView
                    }
                    continue
                }

                if itemView.itemIndex > current.itemIndex && itemView.itemIndex < selectedIndex {
                    candidateView = itemView
                }
            }

            if let candidateView = candidateView {
                _selectItemView(candidateView)
                return true
            }

        case .down:
            guard _selected.count == 1, let selectedIndex = _selected.first else {
                return true
            }

            var candidateView: ItemView?
            for itemView in _visibleItems {
                guard let current = candidateView else {
                    if itemView.itemIndex > selectedIndex {
                        candidateView = itemView
                    }
                    continue
                }

                if itemView.itemIndex < current.itemIndex && itemView.itemIndex > selectedIndex {
                    candidateView = itemView
                }
            }

            if let candidateView = candidateView {
                _selectItemView(candidateView)
                return true
            }

        case .down:
            break

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

        guard dataSource.hasSubItems(at: index) else {
            return
        }

        _expanded.insert(index)

        if let visible = _visibleItem(withIndex: index) {
            visible.isExpanded = true
        }

        _recursiveAddItems(hierarchy: index.asHierarchyIndex, dataSource: dataSource)
        _layoutItemViews()
    }

    private func _collapse(_ index: ItemIndex) {
        guard _isExpanded(index: index) else {
            return
        }

        _expanded.remove(index)

        guard let visible = _visibleItem(withIndex: index) else {
            return
        }

        visible.isExpanded = false

        let hierarchyIndex = index.asHierarchyIndex
        for (i, itemView) in _visibleItems.enumerated().reversed() where itemView.itemIndex.isChild(of: hierarchyIndex) {
            itemView.removeFromSuperview()
            _visibleItems.remove(at: i)

            _selected.remove(itemView.itemIndex)

            _reclaim(itemView: itemView)
        }

        _layoutItemViews()
    }

    @discardableResult
    private func _raiseExpandEvent(_ index: ItemIndex) -> Bool {
        guard !_isExpanded(index: index) else {
            return true
        }
        guard let dataSource = dataSource else {
            return true
        }
        guard dataSource.hasSubItems(at: index) else {
            return true
        }

        let cancel = _willExpand(sender: self, value: index)
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

        let cancel = _willCollapse(sender: self, value: index)
        if !cancel {
            _collapse(index)
        }

        return cancel
    }

    @discardableResult
    private func _raiseSelectEvent(_ itemView: ItemView) -> Bool {
        guard !_isSelected(index: itemView.itemIndex) else {
            return true
        }

        if !canBecomeFirstResponder {
            return true
        }

        let cancel = _willSelect(sender: self, value: itemView.itemIndex)
        if !cancel {
            _selectItemView(itemView)
        }

        return cancel
    }

    @discardableResult
    private func _raiseDeselectEvent(_ items: Set<ItemIndex>) -> Bool {
        let filtered = items.filter(self._isSelected(index:))

        if filtered.isEmpty {
            return true
        }

        let cancel = _willDeselect(sender: self, value: filtered)
        if !cancel {
            _deselectItemViews(filtered)
        }

        return cancel
    }

    private func _raiseRightMouseClick(_ index: ItemIndex) {
        _mouseRightClickedItem(sender: self, index)
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

    /// Deselects all item views currently selected.
    private func _deselectItemViews(_ items: Set<ItemIndex>) {
        for index in items {
            if let view = _visibleItem(withIndex: index) {
                view.isSelected = false
            }
        }

        _selected.subtract(items)
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
        let pointOnScrollView = _scrollView.convert(point: point, from: self)

        return _scrollView.viewUnder(point: pointOnScrollView) { view in
            view is ItemView
        } as? ItemView
    }

    private func _isSelected(index: ItemIndex) -> Bool {
        return _selected.contains(index)
    }

    private func _isExpanded(index: ItemIndex) -> Bool {
        return _expanded.contains(index)
    }

    private func _recursiveAddItems(hierarchy: HierarchyIndex, dataSource: TreeViewDataSource) {
        let count = dataSource.numberOfItems(at: hierarchy)

        // TODO: Replace chevron spacing with a visual indicator taking the same
        // TODO: space, instead.
        /*
        // Check first whether any item has subitems, and if so, toggle the chevron
        // area for all items.
        var reserveChevron = false
        for index in 0..<count {
            let itemIndex = hierarchy.subItem(index: index)

            if dataSource.hasSubItems(at: itemIndex) {
                reserveChevron = true
                break
            }
        }
        */

        for index in 0..<count {
            let itemIndex = hierarchy.subItem(index: index)

            let itemView = _makeItemView(itemIndex: itemIndex, dataSource: dataSource)
            itemView.reserveChevronSpace = true
            itemView.layoutToFit(size: .zero)

            _visibleItems.append(itemView)
            _content.addSubview(itemView)

            // NOTE: Debug change
            //_expanded.insert(itemIndex)

            if _isExpanded(index: itemIndex) && dataSource.hasSubItems(at: itemIndex) {
                _recursiveAddItems(
                    hierarchy: itemIndex.asHierarchyIndex,
                    dataSource: dataSource
                )
            }
        }
    }

    private func _reclaim(itemView: ItemView) {
        _itemViewCache.reclaim(view: itemView)
    }

    private func _makeItemView(itemIndex: ItemIndex, dataSource: TreeViewDataSource) -> ItemView {
        let itemView = _itemViewCache.dequeue(itemIndex: itemIndex, style: style) { itemView in
            itemView.mouseSelected.addListener(weakOwner: self) { [weak self] (sender, _) in
                self?._raiseSelectEvent(sender)
            }
            itemView.mouseClickChevron.addListener(weakOwner: self) { [weak self] (sender, _) in
                guard let self = self else { return }

                if self._isExpanded(index: sender.itemIndex) {
                    self._raiseCollapseEvent(sender.itemIndex)
                } else {
                    self._raiseExpandEvent(sender.itemIndex)
                }
            }
            itemView.mouseRightClicked.addListener(weakOwner: self) { [weak self] (sender, _) in
                guard let self = self else { return }

                self._raiseRightMouseClick(sender.itemIndex)
            }
        }

        itemView.isChevronVisible = dataSource.hasSubItems(at: itemIndex)
        itemView.isExpanded = _isExpanded(index: itemIndex)
        itemView.isSelected = _isSelected(index: itemIndex)
        itemView.attributedTextTitle = dataSource.titleForItem(at: itemIndex)
        itemView.icon = dataSource.iconForItem(at: itemIndex)
        itemView.leftIndentationSpace = _subItemInset * Double(itemIndex.parent.depth)

        return itemView
    }

    private class TreeViewCache {
        var reclaimed: [ItemView] = []

        func dequeue(itemIndex: TreeView.ItemIndex, style: VisualStyle, initializer: (ItemView) -> Void) -> ItemView {
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
            let view = ItemView(itemIndex: itemIndex, style: style)

            initializer(view)

            return view
        }

        func reclaim(view: ItemView) {
            reclaimed.append(view)
        }
    }
}
