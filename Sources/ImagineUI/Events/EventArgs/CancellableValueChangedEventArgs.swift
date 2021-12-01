// TODO: Separate CancellableValueChangeEvent into CancellableValueChangeEventWithSender.

/// A typealias for an event that tracks changes to a property's value, while
/// enabling the opportunity to cancel the value change
public typealias CancellableValueChangeEvent<Sender, Value> = EventWithSender<Sender, CancellableValueChangedEventArgs<Value>>

/// An event argument set for an event that tracks changes to a property, while
/// exposing a `cancel` that can be changed by clients to cancel the state change
public class CancellableValueChangedEventArgs<T> {
    public let oldValue: T
    public let newValue: T
    public var cancel: Bool

    public init(oldValue: T, newValue: T) {
        self.oldValue = oldValue
        self.newValue = newValue

        cancel = false
    }
}

public extension Event {
    func publishCancellableChangeEvent<Sender, Value>(sender: Sender, old: Value, new: Value) -> Bool where T == SenderEventArgs<Sender, CancellableValueChangedEventArgs<Value>> {

        let event = CancellableValueChangedEventArgs(oldValue: old, newValue: new)

        self.publishEvent((sender, event))

        return event.cancel
    }

    func callAsFunction<Sender, Value>(sender: Sender, old: Value, new: Value) -> Bool where T == SenderEventArgs<Sender, CancellableValueChangedEventArgs<Value>> {
        return publishCancellableChangeEvent(sender: sender, old: old, new: new)
    }
}
