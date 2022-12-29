/// Property wrapper that can be used to define an event publisher/source pair
/// using a single property.
///
/// When used as a property wrapper, events can be registered to with
/// `someEvent.addListener()`, and published with
/// `_someEvent.publishEvent(<eventValue>)` or `_someEvent(<eventValue>)`.
///
/// Warning: Not thread-safe.
@propertyWrapper
public class Event<T> {
    private let eventPublisher: EventPublisher<T>

    /// Gets the event source interface that clients can register event listeners
    /// on.
    public var wrappedValue: EventSource<T> {
        eventPublisher.makeEventSource()
    }

    public init() {
        eventPublisher = EventPublisher<T>()
    }

    /// Synchronously publishes an event with a given value to all event listeners
    /// currently active.
    public func publishEvent(_ event: T) {
        eventPublisher.publish(value: event)
    }

    /// Convenience for invoking `publishEvent(_:)` by calling the event variable
    /// itself directly.
    public func callAsFunction(_ event: T) {
        publishEvent(event)
    }
}

public extension Event where T == Void {
    /// Convenience for `publishEvent(())`.
    func publishEvent() {
        publishEvent(())
    }

    /// Convenience for `publishEvent(())`.
    func callAsFunction() {
        publishEvent()
    }
}
