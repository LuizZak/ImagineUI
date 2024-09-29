public struct KeyboardModifier: OptionSet, Sendable {
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

public extension KeyboardModifier {
    #if os(macOS)

    /// OS-equivalent to 'control', for keyboard modifiers.
    /// On macOS, this property is the same as ``command``, and on windows and
    /// Linux, ``control``.
    static let osControlKey = KeyboardModifier.command

    #else

    /// OS-equivalent to 'control', for keyboard modifiers.
    /// On macOS, this property is the same as ``command``, and on windows and
    /// Linux, ``control``.
    static let osControlKey = KeyboardModifier.control

    #endif
}
