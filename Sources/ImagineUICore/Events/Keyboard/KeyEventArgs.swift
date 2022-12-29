/// The arguments for a keyboard event that is forwarded to event listeners.
public class KeyEventArgs {
    /// The actual realized key code of the key press.
    public let keyCode: Keys

    /// If the key event has an associated textual character, such as an
    /// alphabetical letter of digit, this value is set to that textual
    /// representation.
    public let keyChar: String?

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
    public init(keyCode: Keys, keyChar: String?, modifiers: KeyboardModifier) {
        self.keyCode = keyCode
        self.keyChar = keyChar
        self.modifiers = modifiers
        self.handled = false
    }

    /// Creates a copy of this event, modifying the return value's `keyCode` 
    /// to a specified value.
    public func withKeyCode(_ keyCode: Keys) -> KeyEventArgs {
        let result = KeyEventArgs(keyCode: keyCode, keyChar: keyChar, modifiers: modifiers)
        result.handled = handled

        return result
    }

    /// Creates a copy of this event, modifying the return value's `keyChar` 
    /// to a specified value.
    public func withKeyChar(_ keyChar: String?) -> KeyEventArgs {
        let result = KeyEventArgs(keyCode: keyCode, keyChar: keyChar, modifiers: modifiers)
        result.handled = handled

        return result
    }

    /// Creates a copy of this event, modifying the return value's `modifiers` 
    /// to a specified value.
    public func withModifiers(_ modifiers: KeyboardModifier) -> KeyEventArgs {
        let result = KeyEventArgs(keyCode: keyCode, keyChar: keyChar, modifiers: modifiers)
        result.handled = handled

        return result
    }
}
