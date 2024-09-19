import Text

/// A view for displaying tabulated data with columns and rows.
public class TableView: ControlView {
    /// Set of currently selected items.
    var selectedItems: Set<ItemIndex> = []

    /// Called to notify that the user is making a new selection.
    @CancellableValueChangeEventWithSender<TableView, Set<ItemIndex>>
    var willSelect

    /// Called to notify that a new item has been selected on this table view.
    @EventWithSender<TableView, Set<ItemIndex>>
    var didSelect

    /// The data source queried to generate the items within this table view.
    ///
    /// Changing the data source property clears all selection and expansion state,
    /// and triggers an immediate data reload.
    public weak var dataSource: DataSource? {
        didSet {
            guard oldValue !== dataSource else { return }

            selectedItems.removeAll()

            reloadData()
        }
    }

    /// Reloads the data of this table view.
    public func reloadData() {

    }

    private func _populateColumns() {

    }

    private func _populateRows() {

    }
}
