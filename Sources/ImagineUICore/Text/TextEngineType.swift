/// A minimal interface for a text engine.
///
/// Mainly implemented by `TextEngine`.
public protocol TextEngineType: AnyObject {
    /// Gets the caret range.
    ///
    /// To change the caret range, use `setCaret()`.
    var caret: Caret { get }

    /// Inserts the specified text on top of the current caret position.
    ///
    /// Replaces text if caret's range is > 0.
    func insertText(_ text: String)

    /// Deletes the text before the starting position of the caret.
    func backspaceText()

    /// Deletes the text exactly on top of the caret.
    func deleteText()

    /// Sets the caret range for the text.
    ///
    /// If `caret.Length > 0`, the caret is treated as a selection range.
    func setCaret(_ caret: Caret)
}
