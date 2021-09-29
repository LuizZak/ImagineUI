public class KeyEventArgs {
    public let keyCode: Keys
    public let keyChar: String?
    public let modifiers: KeyboardModifier
    public var handled: Bool

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
