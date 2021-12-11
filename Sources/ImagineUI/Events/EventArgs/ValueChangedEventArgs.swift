/// A typealias for an event that tracks changes to a property's value
public typealias ValueChangedEvent<Value> = Event<ValueChangedEventArgs<Value>>

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
    func publishChangeEvent<Value>(old: Value, new: Value) where T == ValueChangedEventArgs<Value> {
        self.publishEvent(ValueChangedEventArgs(oldValue: old, newValue: new))
    }

    func callAsFunction<Value>(old: Value, new: Value) where T == ValueChangedEventArgs<Value> {
        self.publishChangeEvent(old: old, new: new)
    }
}
