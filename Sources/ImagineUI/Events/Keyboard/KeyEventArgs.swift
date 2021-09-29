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
}
