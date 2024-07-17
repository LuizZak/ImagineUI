public protocol UIDialogDelegate: AnyObject {
    /// Called to indicate that a dialog has requested to be closed.
    func dialogWantsToClose(_ dialog: UIDialog)
}
