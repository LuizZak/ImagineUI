/// A typealias for an event that tracks changes to a property's value, while
/// giving the opportunity for a listener to cancel the value change.
public typealias CancellableValueChangeEvent<Value> = Event<CancellableValueChangedEventArgs<Value>>

/// An event argument set for an event that tracks changes to a property, while
/// exposing a `cancel` that can be changed by clients to cancel the state change
public class CancellableValueChangedEventArgs<T> {
    /// A copy of the old value that was changed.
    public let oldValue: T
    
    /// A copy of the new value that is being changed into.
    public let newValue: T

    /// Variable that event handlers can use to mark this change event as
    /// 'canceled'.
    ///
    /// The semantics of a canceled value change event are handled by the event
    /// publisher, but is usually implied to cancel the change of the associated
    /// state to `newValue`.
    ///
    /// Multiple event listeners may toggle this value on and off as they take
    /// turns handling the event that this argument object accompanies, but only
    /// the last value `cancel` was attributed to is seen by event publishers
    /// upstream.
    public var cancel: Bool

    public init(oldValue: T, newValue: T) {
        self.oldValue = oldValue
        self.newValue = newValue

        cancel = false
    }
}

public extension Event {
    /// Convenience for:
    /// 
    /// ```swift
    /// let event = CancellableValueChangedEventArgs(oldValue: old, newValue: new)
    /// self.publishEvent(event)
    /// ```
    /// 
    /// Returns the final value of `event.cancel` after publishing the event to
    /// listeners.
    func publishCancellableChangeEvent<Value>(old: Value, new: Value) -> Bool where T == CancellableValueChangedEventArgs<Value> {
        let event = CancellableValueChangedEventArgs(oldValue: old, newValue: new)

        self.publishEvent(event)

        return event.cancel
    }

    /// Convenience for invoking `publishCancellableChangeEvent(old:new:)` by
    /// calling the event variable itself directly.
    func callAsFunction<Value>(old: Value, new: Value) -> Bool where T == CancellableValueChangedEventArgs<Value> {
        return publishCancellableChangeEvent(old: old, new: new)
    }
}
