/// A typealias for an event that tracks changes to a property's value
public typealias ValueChangeEvent<Sender, Value> = EventWithSender<Sender, ValueChangedEventArgs<Value>>

/// An event argument set for an event that tracks changes to a property
public struct ValueChangedEventArgs<T> {
    public var oldValue: T
    public var newValue: T

    public init(oldValue: T, newValue: T) {
        self.oldValue = oldValue
        self.newValue = newValue
    }
}

public extension Event {
    func publishChangeEvent<Sender, Value>(sender: Sender, old: Value, new: Value) where T == SenderEventArgs<Sender, ValueChangedEventArgs<Value>> {
        self.publishEvent((sender, ValueChangedEventArgs(oldValue: old, newValue: new)))
    }

    func callAsFunction<Sender, Value>(sender: Sender, old: Value, new: Value) where T == SenderEventArgs<Sender, ValueChangedEventArgs<Value>> {
        self.publishChangeEvent(sender: sender, old: old, new: new)
    }
}
