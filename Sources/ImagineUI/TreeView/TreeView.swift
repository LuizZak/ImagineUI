import Rendering

public class TreeView: ControlView {
    /// Set of items that are currently in an expanded state.
    private var expanded: Set<ItemIndex> = []

    private let scrollView: ScrollView = ScrollView(scrollBarsMode: .both)
    private let stackView: StackView = StackView(orientation: .vertical)

    public weak var dataSource: TreeViewDataSource?

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

    private func populateItems() {
        for subview in stackView.subviews {
            subview.removeFromSuperview()
        }

        guard let dataSource = self.dataSource else {
            return
        }

        for index in 0..<dataSource.numberOfItems(self, at: .root) {
            let view = _makeViewForItem(at: ItemIndex(parent: .root, index: index),
                                        dataSource: dataSource)
            stackView.addArrangedSubview(view)
        }
    }

    private func _makeViewForItem(at index: ItemIndex, dataSource: TreeViewDataSource) -> View {
        let item = ItemView()
        item.label.text = dataSource.titleForItem(at: index)

        return item
    }

    private class ItemView: ControlView {
        let icon: ImageView = ImageView(image: nil)
        let label: Label = Label()

        override init() {
            super.init()

            label.textColor = .black
        }

        override func setupHierarchy() {
            super.setupHierarchy()

            addSubview(label)
        }

        override func setupConstraints() {
            super.setupConstraints()

            setContentCompressionResistance(.vertical, .required)
            label.setContentCompressionResistance(.vertical, .required)

            label.layout.makeConstraints { make in
                make.left == self + 10
                make.top == self
                make.right == self
                make.bottom == self
            }
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
