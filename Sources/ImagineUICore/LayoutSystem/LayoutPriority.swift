import CassowarySwift

/// Priority for layout constraints
public struct LayoutPriority: Hashable {
    public static let required = LayoutPriority(1000)
    public static let high = LayoutPriority(750)
    public static let medium = LayoutPriority(500)
    public static let low = LayoutPriority(250)
    public static let veryLow = LayoutPriority(150)
    public static let lowest = LayoutPriority(1)

    var value: Int

    public init(_ value: Int) {
        self.value = min(1000, max(1, value))
    }
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
        case .veryLow:
            return "very low (\(value))"
        case .lowest:
            return "lowest (\(value))"
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
    /// `Strength.STRONG`, 500 to `Strength.MEDIUM`, and 1 to `Strength.WEAK`.
    /// Values in between return priorities in between, accordingly, growing in
    /// linear fashion.
    var cassowaryStrength: Double {
        func _toStrength(_ value: Int) -> Double {
            let doublePriority = Double(value)

            if doublePriority < 500 {
                return Strength.create(0, 0, doublePriority * 2)
            }
            if doublePriority < 750 {
                return Strength.create(0, max(1, (doublePriority - 500) * 2), 0)
            }

            return Strength.create((doublePriority - 750) * 2, 0, 0)
        }

        switch self {
        case .required:
            return Strength.REQUIRED
        case .high:
            return Strength.STRONG
        case .medium:
            return Strength.MEDIUM
        case .low:
            return _toStrength(250)
        case .veryLow:
            return _toStrength(150)
        case .lowest:
            return Strength.WEAK
        default:
            return _toStrength(value)
        }
    }
}
