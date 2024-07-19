/// Property wrapper that can be used to define an event publisher/source pair
/// using a single property.
///
/// When used as a property wrapper, events can be registered to with
/// `SynchronousEventPublisher<T>.addListener(weakOwner:_:)`, and published with
/// `SynchronousEventPublisher<T>.publishEvent(_:)`.
///
/// Evens published by this event must be handled synchronously.
///
/// Warning: Not thread-safe.
@propertyWrapper
public class SynchronousEvent<T> {
    private let eventPublisher: SynchronousEventPublisher<T>

    /// Gets the event source interface that clients can register event listeners
    /// on.
    public var wrappedValue: SynchronousEventSource<T> {
        eventPublisher.makeEventSource()
    }

    public init() {
        eventPublisher = SynchronousEventPublisher<T>()
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

public extension SynchronousEvent where T == Void {
    /// Convenience for `publishEvent(())`.
    func publishEvent() {
        publishEvent(())
    }

    /// Convenience for `publishEvent(())`.
    func callAsFunction() {
        publishEvent()
    }
}
