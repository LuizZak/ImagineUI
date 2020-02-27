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

public struct KeyboardModifier: OptionSet {
    public var rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let none = KeyboardModifier([])
    public static let shift = KeyboardModifier(rawValue: 0b1)
    public static let control = KeyboardModifier(rawValue: 0b10)
    public static let alt = KeyboardModifier(rawValue: 0b100)

    #if os(macOS)
    /// Note: Only available on macOS
    public static let command = KeyboardModifier(rawValue: 0b1000)

    /// Note: Only available on macOS
    public static let option = KeyboardModifier(rawValue: 0b10000)
    
    /// Note: Only available on macOS
    public static let numericPad = KeyboardModifier(rawValue: 0b100000)
    #endif
}
