/// Property wrapper that forces all Comparable values to be represented between
/// a minimum and maximum value.
///
/// Clamping occurs at initialization/updating, and behavior might be inconsistent
/// if values are allowed to mutate by reference.
@propertyWrapper
public struct Clamped<T: Comparable> {
    private var _value: T
    public let minimum: T
    public let maximum: T

    public var wrappedValue: T {
        get {
            return _value
        }
        set {
            _value = newValue.clamp(min: minimum, max: maximum)
        }
    }

    public init(wrappedValue: T, min: T, max: T) {
        precondition(wrappedValue >= min, "wrappedValue must be >= min")
        precondition(wrappedValue <= max, "wrappedValue must be <= max")

        self._value = wrappedValue
        self.minimum = min
        self.maximum = max
    }
}

extension Clamped: Equatable where T: Equatable { }
extension Clamped: Hashable where T: Hashable { }
extension Clamped: Encodable where T: Encodable { }
extension Clamped: Decodable where T: Decodable { }

public extension Comparable {
    func clamp(min: Self, max: Self) -> Self {
        if self < min {
            return min
        }
        if self > max {
            return max
        }

        return self
    }
}
