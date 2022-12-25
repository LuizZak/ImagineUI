/// An observable describes a stateful value holder that notifies listeners
/// whenever its state value has been changed.
@propertyWrapper
public final class Observable<T> {
    private let eventPublisher: EventPublisher<T>
    
    /// Gets or sets the value being observed.
    ///
    /// When setting, triggers listeners updating them of the new value.
    public var wrappedValue: T {
        didSet {
            eventPublisher.publish(value: wrappedValue)
        }
    }
    
    /// Returns a publisher that can be subscribed in order to be notified of
    /// value changes.
    public var projectedValue: EventPublisher<T> {
        return eventPublisher
    }
    
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue

        eventPublisher = EventPublisher()
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
