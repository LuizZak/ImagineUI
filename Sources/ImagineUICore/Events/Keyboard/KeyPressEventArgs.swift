/// The event arguments for a character-based key press event.
public class KeyPressEventArgs {
    /// The textual character for the key press event.
    /// May be any valid character input from a user's keyboard.
    ///
    /// - note: Capitalization and diacritics are pre-applied to the character
    /// and don't require further inspection of `modifiers`.
    public let keyChar: Character

    /// Any modifier that was pressed along with the rest of the input described
    /// by this event.
    public let modifiers: KeyboardModifier

    /// Whether this event was handled by a responder in the first responder
    /// chain.
    ///
    /// Event handlers can set this value to `true` to indicate that upstream
    /// control systems that forwarded the event should treat the event as handled
    /// and not respond to it themselves.
    public var handled: Bool

    /// Initializes a new key event argument structure. `handled` is set to `false`
    /// by default.
    public init(keyChar: Character, modifiers: KeyboardModifier) {
        self.keyChar = keyChar
        self.modifiers = modifiers
        self.handled = false
    }
}
