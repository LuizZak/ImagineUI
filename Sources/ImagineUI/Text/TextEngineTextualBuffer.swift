protocol TextEngineTextualBuffer {
    /// Gets the textual length on this text buffer
    var textLength: Int { get }

    /// Gets the string contents of a text at a given range on this text buffer.
    ///
    /// If `range` is outside range 0 to `textLength`, a runtime error is thrown.
    func textInRange(_ range: TextRange) -> Substring

    /// Gets the character at a given offset.
    func character(at offset: Int) -> Character

    /// Deletes `length` number of sequential characters starting at `index`
    ///
    /// - Parameters:
    ///   - index: 0-based string index.
    ///   - length: Length of text to remove. Passing 1 removes a single character
    ///   at `index`, passing 0 removes no text.
    func delete(at index: Int, length: Int)

    /// Inserts a given string at `index` on the text buffer.
    ///
    /// - Parameters:
    ///   - index: Index to add text to
    ///   - text: Text to insert
    func insert(at index: Int, _ text: String)

    /// Appends a given string at the end of this text buffer.
    ///
    /// - Parameter text: Text to append
    func append(_ text: String)

    /// Replaces a run of text of `length`-count of characters on a given `index`
    /// with a given `text` value.
    ///
    /// - Parameters:
    ///   - index: 0-based string index.
    ///   - length: Length of text to replace. Passing 0 makes this method act
    ///   as `Insert`, and no text removal is made.
    ///   - text: Text to replace slice of text under index + length. Can be
    /// shorter or longer than `length`. Passing an empty string
    /// makes this method act as `delete(index:length:)`.
    func replace(at index: Int, length: Int, _ text: String)
}
