import Cassowary

public enum LayoutConstraintHelpers {
    /// Returns a Double-value priority fit to Cassowary based on a priority
    /// value ranging from [0 - 1000].
    ///
    /// A value of 1000 always converts to `Strength.REQUIRED`, 750 to
    /// `Strength.STRONG`, 500 to `Strength.MEDIUM`, and 250 `Strength.WEAK`.
    /// Values in between return priorities in between, accordingly, growing in
    /// linear fashion.
    ///
    /// - Parameter priority: A value ranging from 0 through 1000
    public static func strengthFromPriority(_ priority: Int) -> Double {
        if priority >= 1000 {
            return Strength.REQUIRED
        }
        if priority == 750 {
            return Strength.STRONG
        }
        if priority == 500 {
            return Strength.MEDIUM
        }
        if priority == 250 {
            return Strength.WEAK
        }

        let doublePriority = Double(priority)

        let upper = min(1.0, max(0.0, (doublePriority - 500.0) / 250.0))
        let mid = min(1.0, max(0.0, ((doublePriority - 250.0) / 250.0).truncatingRemainder(dividingBy: 1)))
        let lower = min(1.0, max(0.0, (doublePriority / 250.0).truncatingRemainder(dividingBy: 1)))

        return Strength.create(upper, mid, lower)
    }
}
