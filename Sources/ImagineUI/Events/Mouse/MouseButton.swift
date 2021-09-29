public struct MouseButton: OptionSet {
    public var rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let none = MouseButton([])
    public static let left = MouseButton(rawValue: 0b1)
    public static let right = MouseButton(rawValue: 0b01)
    public static let middle = MouseButton(rawValue: 0b001)
}
