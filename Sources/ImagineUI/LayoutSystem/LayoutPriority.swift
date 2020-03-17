import Cassowary

/// Priority for layout constraints
public struct LayoutPriority {
    public static let required = LayoutPriority(1000)
    public static let high = LayoutPriority(750)
    public static let medium = LayoutPriority(500)
    public static let low = LayoutPriority(250)
    
    var value: Int
    
    public init(_ value: Int) {
        self.value = min(1000, max(0, value))
    }
}

extension LayoutPriority: Hashable {
    
}

extension LayoutPriority: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}

extension LayoutPriority: CustomStringConvertible {
    public var description: String {
        switch self {
        case .required:
            return "required (\(value))"
        case .high:
            return "high (\(value))"
        case .medium:
            return "medium (\(value))"
        case .low:
            return "low (\(value))"
        default:
            return value.description
        }
    }
}

extension LayoutPriority {
    /// Returns a Double-value priority fit to Cassowary based on this priority's
    /// value ranging from [0 - 1000].
    ///
    /// A value of 1000 always converts to `Strength.REQUIRED`, 750 to
    /// `Strength.STRONG`, 500 to `Strength.MEDIUM`, and 250 `Strength.WEAK`.
    /// Values in between return priorities in between, accordingly, growing in
    /// linear fashion.
    var cassowaryStrength: Double {
        if self == .required {
            return Strength.REQUIRED
        }
        if self == .high {
            return Strength.STRONG
        }
        if self == .medium {
            return Strength.MEDIUM
        }
        if self == .low {
            return Strength.WEAK
        }

        let doublePriority = Double(value)

        let upper = min(1.0, max(0.0, (doublePriority - 500.0) / 250.0))
        let mid = min(1.0, max(0.0, ((doublePriority - 250.0) / 250.0).truncatingRemainder(dividingBy: 1)))
        let lower = min(1.0, max(0.0, (doublePriority / 250.0).truncatingRemainder(dividingBy: 1)))

        return Strength.create(upper, mid, lower)
    }
}
