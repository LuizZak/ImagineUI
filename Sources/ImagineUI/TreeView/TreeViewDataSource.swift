public protocol TreeViewDataSource: AnyObject {
    /// If `true`, this signals the tree view that the item should be rendered
    /// with a UI hint that it can be expanded.
    func hasSubItems(at index: TreeView.ItemIndex) -> Bool

    /// Returns the total number of sub-items at a given hierarchical index.
    func numberOfItems(at hierarchyIndex: TreeView.HierarchyIndex) -> Int

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
