import Text

public extension TableView {
    /// Data source for a `TableView`.
    protocol DataSource: AnyObject {
        /// Called to request the number of columns on a table view.
        func tableViewColumnCount(
            _ tableView: TableView
        ) -> Int

        /// Called to request the number of sections on a table view.
        func tableViewSectionCount(
            _ tableView: TableView
        ) -> Int

        /// Called to request the number of items in a section of the table view.
        func tableView(
            _ tableView: TableView,
            sectionItemCount section: Int
        ) -> Int

        /// Called to request the title of a table view's column.
        func tableView(
            _ tableView: TableView,
            titleForColumn column: Int
        ) -> AttributedText

        /// Called to request the contents of a table view's item at a given
        /// column.
        func tableView(
            _ tableView: TableView,
            contentsOfItemIndex itemIndex: ItemIndex,
            column: Int
        ) -> AttributedText
    }
}
