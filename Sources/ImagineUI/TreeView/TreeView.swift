import Rendering

public class TreeView: ControlView {
    private let viewCache: TreeViewCache = TreeViewCache()

    /// Set of items that are currently in an expanded state.
    private var expanded: Set<ItemIndex> = []
    private var selected: Set<ItemIndex> = []
    private var visibleItems: [ItemView] = []

    private let scrollView: ScrollView = ScrollView(scrollBarsMode: .both)
    private let stackView: StackView = StackView(orientation: .vertical)

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
        scrollView.addSubview(stackView)
    }

    public override func setupConstraints() {
        super.setupConstraints()

        scrollView.layout.makeConstraints { make in
            make.edges == self
        }

        stackView.contentInset = 4
        stackView.alignment = .fill
        stackView.setContentCompressionResistance(.horizontal, .required)
        stackView.setContentCompressionResistance(.vertical, .required)
        stackView.layout.makeConstraints { make in
            make.left == scrollView.contentView
            make.top == scrollView.contentView
            make.right == scrollView.contentView

            make.bottom <= scrollView.contentView
        }
    }

    public func reloadData() {
        populateItems()
    }

    public override func onMouseDown(_ event: MouseEventArgs) {
        super.onMouseDown(event)

        if let item = itemUnderPoint(event.location) {
            selectItem(item)
        }
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

        for index in 0..<dataSource.numberOfItems(self, at: .root) {
            let view = _makeViewForItem(at: ItemIndex(parent: .root, index: index),
                                        dataSource: dataSource)

            visibleItems.append(view)
        }

        stackView.addArrangedSubviews(visibleItems)
    }

    private func _makeViewForItem(at index: ItemIndex, dataSource: TreeViewDataSource) -> ItemView {
        let isExpanded = self.expanded.contains(index)

        let item = viewCache.dequeue(itemIndex: index, isExpanded: isExpanded) { item in
            item.mouseDown.addListener(owner: self) { [weak self] (sender, _) in
                if let sender = sender as? ItemView {
                    self?.selectItem(sender)
                }
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

        return item
    }

    private func _reclaim(view: ItemView) {
        viewCache.reclaim(view: view)
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

    private func _expand(_ index: ItemIndex) {
        expanded.insert(index)

        reloadData()
    }

    private func _collapse(_ index: ItemIndex) {
        expanded.remove(index)

        reloadData()
    }

    private class ItemView: ControlView {
        private let _chevronView: ChevronView = ChevronView()
        private let _iconView: ImageView = ImageView(image: nil)
        private let _labelView: Label = Label()

        private let _container = StackView(orientation: .horizontal)

        @Event var willExpand: CancellableActionEvent<ItemView, Void>
        @Event var willCollapse: CancellableActionEvent<ItemView, Void>

        var itemIndex: ItemIndex

        var isExpanded: Bool {
            didSet {
                _chevronView.isExpanded = isExpanded
            }
        }

        var isChevronVisible: Bool = false {
            didSet {
                _chevronView.isVisible = isChevronVisible
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

            _labelView.textColor = .black
            _container.alignment = .centered
            _container.spacing = 5

            _chevronView.isExpanded = isExpanded
            _chevronView.mouseClicked.addListener(owner: self) { [weak self] (sender, _) in
                self?.raiseToggleEvent()
            }
        }

        override func setupHierarchy() {
            super.setupHierarchy()

            addSubview(_container)
            _container.addArrangedSubview(_chevronView)
            _container.addArrangedSubview(_labelView)
        }

        override func setupConstraints() {
            super.setupConstraints()

            _labelView.setContentHuggingPriority(.horizontal, .lowest)
            _labelView.setContentCompressionResistance(.horizontal, .required)
            _labelView.setContentCompressionResistance(.vertical, .required)

            _container.setContentCompressionResistance(.horizontal, .required)
            _container.setContentCompressionResistance(.vertical, .required)
            _container.layout.makeConstraints { make in
                make.left == self + 5
                make.top == self
                make.right == self
                make.bottom == self
            }
        }

        override func onStateChanged(_ event: ValueChangedEventArgs<ControlViewState>) {
            super.onStateChanged(event)

            if event.newValue == .selected {
                backColor = .cornflowerBlue
                _labelView.textColor = .white
                _chevronView.foreColor = .white
            } else {
                backColor = .transparentBlack
                _labelView.textColor = .black
                _chevronView.foreColor = .gray
            }
        }

        private func raiseToggleEvent() {
            if isExpanded {
                raiseCollapseEvent()
            } else {
                raiseExpandEvent()
            }
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
    public struct HierarchyIndex: Hashable {
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

        public init(indices: [Int]) {
            self.indices = indices
        }
    }

    public struct ItemIndex: Hashable {
        /// The hierarchy index for the parent of this index reference.
        public var parent: HierarchyIndex

        /// The index of the item.
        public var index: Int

        /// Gets this item index as a hierarchy index.
        @_transparent
        public var asHierarchyIndex: HierarchyIndex {
            return HierarchyIndex(indices: parent.indices + [index])
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
