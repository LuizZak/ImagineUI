@propertyWrapper
public class Event<T> {
    private let eventPublisher: EventPublisher<T>
    public var wrappedValue: EventSource<T> {
        eventPublisher.makeEventSource()
    }

    public init() {
        eventPublisher = EventPublisher<T>()
    }

    public func publishEvent(_ event: T) {
        eventPublisher.publish(value: event)
    }
}

public extension Event where T == Void {
    func publishEvent() {
        publishEvent(())
    }
}
