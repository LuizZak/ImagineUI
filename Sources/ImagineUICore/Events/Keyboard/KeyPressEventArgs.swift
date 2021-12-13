public class KeyPressEventArgs {
    public let keyChar: Character
    public let modifiers: KeyboardModifier
    public var handled: Bool

    public init(keyChar: Character, modifiers: KeyboardModifier) {
        self.keyChar = keyChar
        self.modifiers = modifiers
        self.handled = false
    }
}
