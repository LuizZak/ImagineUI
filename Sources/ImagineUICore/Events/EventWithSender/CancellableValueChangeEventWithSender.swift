/// A typealias for an event that tracks changes to a property's value, while
/// giving the opportunity for a listener to cancel the value change.
public typealias CancellableValueChangeEventWithSender<Sender, Value> = EventWithSender<Sender, CancellableValueChangedEventArgs<Value>>

public extension Event {
    /// Convenience for:
    /// 
    /// ```swift
    /// let event = CancellableValueChangedEventArgs(oldValue: old, newValue: new)
    /// self.publishEvent((sender, event))
    /// ```
    /// 
    /// Returns the final value of `event.cancel` after publishing the event to
    /// listeners.
    func publishCancellableChangeEvent<Sender, Value>(
        sender: Sender,
        old: Value,
        new: Value
    ) -> Bool where T == SenderEventArgs<Sender, CancellableValueChangedEventArgs<Value>> {

        let event = CancellableValueChangedEventArgs(oldValue: old, newValue: new)

        self.publishEvent((sender, event))

        return event.cancel
    }

    /// Convenience for invoking `publishCancellableChangeEvent(sender:old:new:)`
    /// by calling the event variable itself directly.
    func callAsFunction<Sender, Value>(
        sender: Sender,
        old: Value,
        new: Value
    ) -> Bool where T == SenderEventArgs<Sender, CancellableValueChangedEventArgs<Value>> {

        return publishCancellableChangeEvent(sender: sender, old: old, new: new)
    }
}
