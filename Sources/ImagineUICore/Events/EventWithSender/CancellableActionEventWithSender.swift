/// A typealias for an event that tracks actions that can be cancelled by
/// listeners.
public typealias CancellableActionEventWithSender<Sender, Args> = EventWithSender<Sender, CancellableActionEventArgs<Args>>

public extension Event {
    func publishCancellableChangeEvent<Sender>(sender: Sender) -> Bool where T == SenderEventArgs<Sender, CancellableActionEventArgs<Void>> {
        let event = CancellableActionEventArgs(value: ())

        self.publishEvent((sender, event))

        return event.cancel
    }

    func publishCancellableChangeEvent<Sender, Value>(sender: Sender, value: Value) -> Bool where T == SenderEventArgs<Sender, CancellableActionEventArgs<Value>> {
        let event = CancellableActionEventArgs(value: value)

        self.publishEvent((sender, event))

        return event.cancel
    }

    func callAsFunction<Sender>(sender: Sender) -> Bool where T == SenderEventArgs<Sender, CancellableActionEventArgs<Void>> {
        return publishCancellableChangeEvent(sender: sender)
    }

    func callAsFunction<Sender, Value>(sender: Sender, value: Value) -> Bool where T == SenderEventArgs<Sender, CancellableActionEventArgs<Value>> {
        return publishCancellableChangeEvent(sender: sender, value: value)
    }
}
