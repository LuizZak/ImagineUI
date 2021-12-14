/// Specifies a type of control to hit test against on a request from a
/// `DefaultControlSystemDelegate`.
public struct ControlKinds: OptionSet {
    public var rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

public extension ControlKinds {
    /// Queries for all enabled control kinds.
    static let allEnabled: Self = [controls, tooltips]

    /// Queries for all control kinds, including disabled controls.
    static let all: Self = [allEnabled, disabledFlag]

    /// Requests general UI controls.
    static let controls: Self = Self(rawValue: 0b0001)

    /// Requests tooltip controls.
    static let tooltips: Self = Self(rawValue: 0b0010)

    /// Flag for querying against disabled controls.
    static let disabledFlag: Self = Self(rawValue: 0b0001_0000_0000_0000)
}
