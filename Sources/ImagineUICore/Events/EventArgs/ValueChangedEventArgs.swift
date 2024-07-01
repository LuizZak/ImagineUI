/// A typealias for an event that tracks changes to a property's value
public typealias ValueChangedEvent<Value> = Event<ValueChangedEventArgs<Value>>

/// An event argument set for an event that tracks changes to a property or state.
public struct ValueChangedEventArgs<T> {
    /// A copy of the old value that was changed.
    public let oldValue: T
    
    /// A copy of the new value that is being changed into.
    public let newValue: T

    public init(oldValue: T, newValue: T) {
        self.oldValue = oldValue
        self.newValue = newValue
    }
}

public extension Event {
    /// Convenience for:
    /// 
    /// ```swift
    /// self.publishEvent(ValueChangedEventArgs(oldValue: old, newValue: new))
    /// ```
    func publishChangeEvent<Value>(
        old: Value,
        new: Value
    ) where T == ValueChangedEventArgs<Value> {

        self.publishEvent(ValueChangedEventArgs(oldValue: old, newValue: new))
    }

    
    /// Convenience for invoking `publishChangeEvent(old:new:)` by calling the
    /// event variable itself directly.
    func callAsFunction<Value>(
        old: Value,
        new: Value
    ) where T == ValueChangedEventArgs<Value> {
        
        self.publishChangeEvent(old: old, new: new)
    }
}
