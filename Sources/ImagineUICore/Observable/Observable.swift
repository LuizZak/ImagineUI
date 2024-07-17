/// An observable describes a stateful value holder that notifies listeners
/// whenever its state value has been changed.
@propertyWrapper
public final class Observable<T> {
    private let _eventPublisher: EventPublisher<T>
    private var _value: T

    /// Gets or sets the value being observed.
    ///
    /// When setting, triggers listeners updating them of the new value.
    public var wrappedValue: T {
        _value
    }

    /// Returns a publisher that can be subscribed in order to be notified of
    /// value changes.
    public var projectedValue: EventPublisher<T> {
        return _eventPublisher
    }

    public init(wrappedValue: T) {
        self._value = wrappedValue

        _eventPublisher = EventPublisher()
    }

    /// Sets the value being observed.
    ///
    /// When setting, triggers listeners updating them of the new value.
    public func callAsFunction(_ newValue: T) async {
        _value = newValue
        await _eventPublisher.publishAsync(value: newValue)
    }

    /// Sets the value being observed.
    ///
    /// When setting, triggers listeners updating them of the new value.
    public func callAsFunction(_ newValue: T) {
        _value = newValue
        _eventPublisher.publish(value: newValue)
    }
}

extension Observable: Encodable where T: Encodable {
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}

extension Observable: Decodable where T: Decodable {
    public convenience init(from decoder: Decoder) throws {
        self.init(wrappedValue: try T.init(from: decoder))
    }
}

extension Observable: Equatable where T: Equatable {
    public static func == (lhs: Observable, rhs: Observable) -> Bool {
        return lhs.wrappedValue == rhs.wrappedValue
    }
}

extension Observable: Hashable where T: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}
