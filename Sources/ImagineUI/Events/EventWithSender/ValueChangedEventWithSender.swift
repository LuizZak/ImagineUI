/// A typealias for an event that tracks changes to a property's value
public typealias ValueChangedEventWithSender<Sender, Value> = EventWithSender<Sender, ValueChangedEventArgs<Value>>

public extension Event {
    func publishChangeEvent<Sender, Value>(sender: Sender, old: Value, new: Value) where T == SenderEventArgs<Sender, ValueChangedEventArgs<Value>> {
        self.publishEvent((sender, ValueChangedEventArgs(oldValue: old, newValue: new)))
    }

    func callAsFunction<Sender, Value>(sender: Sender, old: Value, new: Value) where T == SenderEventArgs<Sender, ValueChangedEventArgs<Value>> {
        self.publishChangeEvent(sender: sender, old: old, new: new)
    }
}
