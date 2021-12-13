/// A typealias for an event that tracks changes to a property's value, while
/// giving the opportunity for a listener to cancel the value change.
public typealias CancellableValueChangeEventWithSender<Sender, Value> = EventWithSender<Sender, CancellableValueChangedEventArgs<Value>>

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
