public extension TextField {
    /// Defines the keys and modifiers to listen, based on OS-settings.
    enum KeyMap {
        
    }
}

public extension TextField.KeyMap {
    /// The keyboard modifier that is checked against to do text selecion while
    /// moving the caret.
    /// Is ``KeyboardModifier/shift`` on all OSs.
    static let selectModifier = KeyboardModifier.shift

    #if os(macOS)

    /// The keyboard modifier that is checked against to do whole word moving.
    /// Is ``KeyboardModifier/option`` on macOS and ``KeyboardModifier/control`` otherwise.
    static let wordMoveModifier = KeyboardModifier.option

    #else

    /// The keyboard modifier that is checked against to do whole word moving.
    /// Is ``KeyboardModifier/option`` on macOS and ``KeyboardModifier/control`` otherwise.
    static let wordMoveModifier = KeyboardModifier.control

    #endif
}