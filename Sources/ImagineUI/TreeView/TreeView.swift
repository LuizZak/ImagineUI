import Rendering

public class TreeView: ControlView {
    private let viewCache: TreeViewCache = TreeViewCache()

    /// Set of items that are currently in an expanded state.
    private var expanded: Set<ItemIndex> = []
    private var selected: Set<ItemIndex> = []
    private var visibleItems: [ItemView] = []

    private let scrollView: ScrollView = ScrollView(scrollBarsMode: .both)

    private let rootStackView: StackView = StackView(orientation: .vertical)

    public weak var dataSource: TreeViewDataSource?

    @Event public var willExpand: CancellableActionEvent<TreeView, ItemIndex>
    @Event public var willCollapse: CancellableActionEvent<TreeView, ItemIndex>

    public override init() {
        super.init()

        backColor = .white
        scrollView.scrollBarsAlwaysVisible = false
    }

    public override func setupHierarchy() {
        super.setupHierarchy()

        addSubview(scrollView)
        scrollView.addSubview(rootStackView)
    }

    public override func setupConstraints() {
        super.setupConstraints()

        scrollView.layout.makeConstraints { make in
            make.edges == self
        }

        rootStackView.contentInset = 4
        rootStackView.alignment = .fill
        rootStackView.setContentCompressionResistance(.horizontal, .required)
        rootStackView.setContentCompressionResistance(.vertical, .required)
        rootStackView.layout.makeConstraints { make in
            make.left == scrollView.contentView
            make.top == scrollView.contentView + 4
            make.right == scrollView.contentView
            make.bottom <= scrollView.contentView
        }
    }

    public func reloadData() {
        populateItems()
    }

    private func selectItem(_ itemView: ItemView) {
        for index in selected {
            if let view = visibleItem(withIndex: index) {
                view.isSelected = false
            }
        }

        selected.remove(itemView.itemIndex)
        selected = [itemView.itemIndex]

        itemView.isSelected = true
    }

    private func itemUnderPoint(_ point: UIPoint) -> ItemView? {
        return scrollView.viewUnder(point: point) { view in
            view is ItemView
        } as? ItemView
    }

    private func visibleItem(withIndex index: ItemIndex) -> ItemView? {
        return visibleItems.first(where: { $0.itemIndex == index })
    }

    private func populateItems() {
        suspendLayout()
        defer {
            resumeLayout(setNeedsLayout: true)
        }

        for view in visibleItems {
            view.removeFromSuperview()
            _reclaim(view: view)
        }

        visibleItems.removeAll(keepingCapacity: true)

        guard let dataSource = self.dataSource else {
            return
        }

        _recursiveCreateViews(.root, into: rootStackView, dataSource: dataSource)
    }

    private func _recursiveCreateViews(_ hierarchy: HierarchyIndex, into stackView: StackView, dataSource: TreeViewDataSource) {
        // Detect items with sub-items and reserve a chevron space for the entire
        // column.
        var reserveChevronSpace = false
        for index in 0..<dataSource.numberOfItems(self, at: hierarchy) {
            let itemIndex = ItemIndex(parent: hierarchy, index: index)
            if dataSource.hasItems(self, at: itemIndex.asHierarchyIndex) {
                reserveChevronSpace = true
                break
            }
        }

        for index in 0..<dataSource.numberOfItems(self, at: hierarchy) {
            let itemIndex = ItemIndex(parent: hierarchy, index: index)
            let view = _makeViewForItem(at: itemIndex, dataSource: dataSource)
            view.reserveChevronSpace = reserveChevronSpace

            stackView.addArrangedSubview(view)
            visibleItems.append(view)

            if _isExpanded(index: itemIndex) {
                _recursiveCreateViews(itemIndex.asHierarchyIndex, into: view.itemsStackView, dataSource: dataSource)
            }
        }
    }

    private func _visibleItem(withIndex index: ItemIndex) -> ItemView? {
        for visible in visibleItems {
            if visible.itemIndex == index {
                return visible
            }
        }

        return nil
    }

    private func _isExpanded(index: ItemIndex) -> Bool {
        return expanded.contains(index)
    }

    private func _makeViewForItem(at index: ItemIndex, dataSource: TreeViewDataSource) -> ItemView {
        let isExpanded = self.expanded.contains(index)

        let item = viewCache.dequeue(itemIndex: index, isExpanded: isExpanded) { item in
            item.mouseSelected.addListener(owner: self) { [weak self] (sender, _) in
                self?.selectItem(sender)
            }
            item.willExpand.addListener(owner: self) { [weak self] (sender, event) in
                guard let self = self else { return }

                event.cancel = self.raiseExpandEvent(sender.itemIndex)
            }
            item.willCollapse.addListener(owner: self) { [weak self] (sender, event) in
                guard let self = self else { return }

                event.cancel = self.raiseCollapseEvent(sender.itemIndex)
            }
        }

        item.label = dataSource.titleForItem(at: index)
        item.isChevronVisible = dataSource.hasItems(self, at: index.asHierarchyIndex)
        item.isSelected = selected.contains(index)
        item.removeSubItems()

        return item
    }

    private func _reclaim(view: ItemView) {
        viewCache.reclaim(view: view)
    }

    private func _expand(_ index: ItemIndex) {
        expanded.insert(index)

        guard let dataSource = dataSource else {
            return
        }

        let hierarchyIndex = index.asHierarchyIndex

        guard dataSource.hasItems(self, at: hierarchyIndex) else {
            return
        }

        if let visible = _visibleItem(withIndex: index) {
            _recursiveCreateViews(hierarchyIndex, into: visible.itemsStackView, dataSource: dataSource)
        } else {
            reloadData()
        }
    }

    private func _collapse(_ index: ItemIndex) {
        expanded.remove(index)

        if let visible = _visibleItem(withIndex: index) {
            visibleItems = visibleItems.filter {
                !$0.itemIndex.isChild(of: index.asHierarchyIndex)
            }

            visible.removeSubItems()
        } else {
            reloadData()
        }
    }

    private func raiseExpandEvent(_ index: ItemIndex) -> Bool {
        let cancel = _willExpand.publishCancellableChangeEvent(sender: self, value: index)
        if !cancel {
            _expand(index)
        }

        return cancel
    }

    private func raiseCollapseEvent(_ index: ItemIndex) -> Bool {
        let cancel = _willCollapse.publishCancellableChangeEvent(sender: self, value: index)
        if !cancel {
            _collapse(index)
        }

        return cancel
    }

    private class ItemView: ControlView {
        private let _chevronView: ChevronView = ChevronView()
        private let _iconView: ImageView = ImageView(image: nil)
        private let _labelView: Label = Label()

        private let _horizontalContainer: StackView = StackView(orientation: .horizontal)
        private let _subItemsContainer: StackView = StackView(orientation: .vertical)

        private let _titleHolder: ControlView = ControlView()

        private var viewToHighlight: ControlView {
            return _titleHolder
        }

        @Event var mouseSelected: EventSourceWithSender<ItemView, Void>
        @Event var willExpand: CancellableActionEvent<ItemView, Void>
        @Event var willCollapse: CancellableActionEvent<ItemView, Void>

        var itemsStackView: StackView {
            return _subItemsContainer
        }

        var itemIndex: ItemIndex

        var isExpanded: Bool {
            didSet {
                _chevronView.isExpanded = isExpanded
            }
        }

        var isChevronVisible: Bool = false {
            didSet {
                if isChevronVisible != oldValue {
                    _chevronView.isVisible = isChevronVisible
                    _updateChevronConstraints()
                }
            }
        }

        var reserveChevronSpace: Bool = true {
            didSet {
                if reserveChevronSpace != oldValue {
                    _updateChevronConstraints()
                }
            }
        }

        var label: String {
            get {
                return _labelView.text
            }
            set {
                _labelView.text = newValue
            }
        }

        init(itemIndex: ItemIndex, isExpanded: Bool) {
            self.itemIndex = itemIndex
            self.isExpanded = isExpanded

            super.init()

            _chevronView.isVisible = false
            _labelView.textColor = .black
            _horizontalContainer.alignment = .centered
            _horizontalContainer.spacing = 5

            _chevronView.isExpanded = isExpanded
            _chevronView.mouseClicked.addListener(owner: self) { [weak self] (_, _) in
                self?.raiseToggleEvent()
            }

            _titleHolder.mouseDown.addListener(owner: self) { [weak self] (_, _) in
                self?.raiseMouseDownEvent()
            }
        }

        override func setupHierarchy() {
            super.setupHierarchy()

            addSubview(_subItemsContainer)
            addSubview(_titleHolder)

            _titleHolder.addSubview(_horizontalContainer)
            _horizontalContainer.addArrangedSubview(_chevronView)
            _horizontalContainer.addArrangedSubview(_labelView)
        }

        override func setupConstraints() {
            super.setupConstraints()

            _labelView.setContentHuggingPriority(.horizontal, .lowest)
            _labelView.setContentCompressionResistance(.horizontal, .required)
            _labelView.setContentCompressionResistance(.vertical, .required)

            _titleHolder.layout.makeConstraints { make in
                make.left == self
                make.top == self
                make.right == self
            }
            _subItemsContainer.alignment = .fill
            _subItemsContainer.setContentHuggingPriority(.vertical, .veryLow)
            _subItemsContainer.setContentCompressionResistance(.horizontal, .required)
            _subItemsContainer.setContentCompressionResistance(.vertical, .required)
            _subItemsContainer.layout.makeConstraints { make in
                make.under(_horizontalContainer)
                make.left == self + 10
                make.right == self
                make.bottom == self
            }

            _horizontalContainer.setContentCompressionResistance(.horizontal, .required)
            _horizontalContainer.setContentCompressionResistance(.vertical, .required)
            _horizontalContainer.layout.makeConstraints { make in
                make.top == _titleHolder
                make.left == _titleHolder + 4
                make.right == _titleHolder
                make.bottom == _titleHolder
            }
        }

        override func onStateChanged(_ event: ValueChangedEventArgs<ControlViewState>) {
            super.onStateChanged(event)

            if event.newValue == .selected {
                viewToHighlight.backColor = .cornflowerBlue
                _labelView.textColor = .white
                _chevronView.foreColor = .white
            } else {
                viewToHighlight.backColor = .transparentBlack
                _labelView.textColor = .black
                _chevronView.foreColor = .gray
            }
        }

        func removeSubItems() {
            for view in _subItemsContainer.arrangedSubviews {
                view.removeFromSuperview()
            }
        }

        private func _updateChevronConstraints() {
            if !reserveChevronSpace && !isChevronVisible {
                (_chevronView.layout.width == 5).create()
            } else {
                (_chevronView.layout.width == 5).remove()
            }
        }

        private func raiseToggleEvent() {
            if isExpanded {
                raiseCollapseEvent()
            } else {
                raiseExpandEvent()
            }
        }

        private func raiseMouseDownEvent() {
            _mouseSelected.publishEvent(sender: self)
        }

        private func raiseExpandEvent() {
            if !_willExpand.publishCancellableChangeEvent(sender: self) {
                isExpanded = true
            }
        }

        private func raiseCollapseEvent() {
            if !_willCollapse.publishCancellableChangeEvent(sender: self) {
                isExpanded = false
            }
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

        func dequeue(itemIndex: TreeView.ItemIndex, isExpanded: Bool, initializer: (ItemView) -> Void) -> ItemView {
            // Search for a matching item index
            for (i, view) in reclaimed.enumerated() where view.itemIndex == itemIndex {
                reclaimed.remove(at: i)
                view.isExpanded = isExpanded
                return view
            }

            // Pop any item
            if let next = reclaimed.popLast() {
                next.itemIndex = itemIndex
                next.isExpanded = isExpanded
                return next
            }

            // Create a new view as a last resort.
            let view = ItemView(itemIndex: itemIndex, isExpanded: isExpanded)

            initializer(view)

            return view
        }

        func reclaim(view: ItemView) {
            reclaimed.append(view)
        }
    }
}

extension TreeView {
    /// Specifies the hierarchical index for a sub-tree.
    public struct HierarchyIndex: Hashable, Comparable {
        /// The hierarchical reference for the root item of a tree.
        public static let root: HierarchyIndex = HierarchyIndex(indices: [])

        /// The list of indices that represent the hierarchical relationships
        /// for this hierarchy index.
        /// Is an empty list for items at the root of the tree view.
        public var indices: [Int]

        /// Returns `true` if this hierarchy index points to the root of the
        /// tree.
        ///
        /// Convenience for `indices.isEmpty`.
        public var isRoot: Bool {
            return indices.isEmpty
        }

        /// Returns the depth of this hierarchy index.
        public var depth: Int {
            return indices.count
        }

        public init(indices: [Int]) {
            self.indices = indices
        }

        /// Returns `true` if this hierarchy is contained within another
        /// hierarchy.
        ///
        /// Returns `true` for `self.isSubHierarchy(of: self)`.
        public func isSubHierarchy(of other: HierarchyIndex) -> Bool {
            if other.isRoot {
                return true
            }
            if other.indices.count > indices.count {
                return false
            }

            return indices[0..<other.indices.count] == other.indices[...]
        }

        /// Returns `true` if `lhs` comes before in a hierarchy compared to
        /// `rhs`.
        ///
        /// A hierarchy item comes before another if every index in `indices`
        /// compares lower to another hierarchy item.
        ///
        /// In case all indices are the same between the two parameters, `true`
        /// is returned if `rhs` is of a deeper hierarchy (`rhs.indices.count > lhs.indices.count`).
        public static func < (lhs: Self, rhs: Self) -> Bool {
            for (l, r) in zip(lhs.indices, rhs.indices) {
                if l > r {
                    return false
                }
            }

            return lhs.depth < rhs.depth
        }
    }

    public struct ItemIndex: Hashable, Comparable {
        /// The hierarchy index for the parent of this index reference.
        public var parent: HierarchyIndex

        /// The index of the item.
        public var index: Int

        /// Gets this item index as a hierarchy index.
        @_transparent
        public var asHierarchyIndex: HierarchyIndex {
            return HierarchyIndex(indices: parent.indices + [index])
        }

        /// Returns `true` if this item belongs to a given hierarchy index.
        public func isChild(of hierarchy: HierarchyIndex) -> Bool {
            return parent.isSubHierarchy(of: hierarchy)
        }

        /// Returns `true` if `lhs` comes before in a hierarchy compared to
        /// `rhs`.
        ///
        /// An item index comes before another if its hierarchical parent compares
        /// lower to the other item's, or if the hierarchical parent is the same,
        /// if the `index` compares lower.
        public static func < (lhs: Self, rhs: Self) -> Bool {
            return lhs.parent < rhs.parent || lhs.index < rhs.index
        }
    }
}

public protocol TreeViewDataSource: AnyObject {
    /// If `true`, this signals the tree view that the item should be rendered
    /// with a UI hint that it can be expanded.
    func hasItems(_ treeView: TreeView, at hierarchyIndex: TreeView.HierarchyIndex) -> Bool

    /// Returns the total number of sub-items at a given hierarchical index.
    func numberOfItems(_ treeView: TreeView, at hierarchyIndex: TreeView.HierarchyIndex) -> Int

    /// Gets the display label for the item at a given index.
    func titleForItem(at index: TreeView.ItemIndex) -> String

    /// Gets the optional icon for the item at a given index.
    /// If `nil`, the item is rendered without a label.
    func iconForItem(at index: TreeView.ItemIndex) -> Image?
}

public extension TreeViewDataSource {
    func iconForItem(at index: TreeView.ItemIndex) -> Image? {
        return nil
    }
}
