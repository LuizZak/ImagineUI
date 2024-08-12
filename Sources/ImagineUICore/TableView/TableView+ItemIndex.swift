public extension TableView {
    /// An index of an item in a table view.
    struct ItemIndex: Hashable, Comparable {
        /// The section for the item.
        public var section: Int

        /// The index of the item.
        public var index: Int

        public static func < (lhs: TableView.ItemIndex, rhs: TableView.ItemIndex) -> Bool {
            if lhs.section < rhs.section {
                return true
            }

            if lhs.section == rhs.section {
                return lhs.index < rhs.index
            }

            return false
        }
    }
}
