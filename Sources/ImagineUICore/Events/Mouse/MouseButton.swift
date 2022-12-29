/// Specifies one or more mouse buttons as a set of options.
public struct MouseButton: OptionSet {
    public var rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Represents no mouse button.
    public static let none   = MouseButton([])

    /// Represents the left- or 'primary', mouse button. On platforms that
    /// automatically map left-handed mouse events to right-handed ones, this
    /// value is indistinct from either a right-handed left button click, or a
    /// left-handed right button click.
    public static let left   = MouseButton(rawValue: 0b001)

    /// Represents the right- or 'secondary', mouse button. On platforms that
    /// automatically map left-handed mouse events to right-handed ones, this
    /// value is indistinct from either a right-handed right button click, or a
    /// left-handed left button click.
    public static let right  = MouseButton(rawValue: 0b010)

    /// Represents the middle mouse button.
    public static let middle = MouseButton(rawValue: 0b100)
}
