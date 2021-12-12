/// Property wrapper that can be used to define an event publisher/source pair
/// using a single property.
///
/// Events can be registered to with `someEvent.addListener()`, and published
/// with `_someEvent(<eventValue>)`.
///
/// Warning: Not thread-safe.
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

    public func callAsFunction(_ event: T) {
        publishEvent(event)
    }
}

public extension Event where T == Void {
    func publishEvent() {
        publishEvent(())
    }

    func callAsFunction() {
        publishEvent()
    }
}
