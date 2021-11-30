extension TreeView {
    /// Specifies the hierarchical index for a sub-tree.
    public struct HierarchyIndex: Hashable, Comparable {
        /// The hierarchical reference for the root item of a tree.
        public static let root: HierarchyIndex = HierarchyIndex(indices: [])

        /// The list of indices that represent the hierarchical relationships
        /// for this hierarchy index.
        /// Is an empty list for items at the root of the tree view.
        public var indices: [Int]

        /// The hierarchy index for the parent of this index.
        ///
        /// If this hierarchy index is the root hierarchy, `nil` is returned.
        public var parent: HierarchyIndex? {
            if indices.count == 0 {
                return nil
            }

            return HierarchyIndex(indices: indices.dropLast())
        }

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

        /// Creates an item index with a given index with this hierarchy index
        /// as a parent.
        public func subItem(index: Int) -> ItemIndex {
            return .init(parent: self, index: index)
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
        /// A hierarchy item comes before another if any index in `indices`
        /// compares lower to another hierarchy item.
        ///
        /// In case the indices have different depths, `true` is returned if
        /// `rhs` is of a deeper hierarchy (`lhs.indices.count < rhs.indices.count`).
        public static func < (lhs: Self, rhs: Self) -> Bool {
            for (l, r) in zip(lhs.indices, rhs.indices) {
                if l < r {
                    return true
                }
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

        public init(parent: HierarchyIndex, index: Int) {
            self.parent = parent
            self.index = index
        }

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
            return lhs.asHierarchyIndex < rhs.asHierarchyIndex
        }
    }
}
