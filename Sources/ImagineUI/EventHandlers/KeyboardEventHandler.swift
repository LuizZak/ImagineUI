public protocol KeyboardEventHandler: EventHandler {
    func onKeyPress(_ event: KeyPressEventArgs)
    func onKeyDown(_ event: KeyEventArgs)
    func onKeyUp(_ event: KeyEventArgs)
    func onPreviewKeyDown(_ event: PreviewKeyDownEventArgs)
}

public extension KeyboardEventHandler {
    func onKeyPress(_ event: KeyPressEventArgs) { }
    func onKeyDown(_ event: KeyEventArgs) { }
    func onKeyUp(_ event: KeyEventArgs) { }
    func onPreviewKeyDown(_ event: PreviewKeyDownEventArgs) { }
}

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

public struct PreviewKeyDownEventArgs {
    public var modifiers: KeyboardModifier
}

public protocol KeyboardEventRequest: EventRequest {
    var eventType: KeyboardEventType { get }
}

public enum KeyboardEventType {
    case keyDown
    case keyPress
    case keyUp
    case previewKeyDown
}
