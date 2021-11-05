/// A typealias for an event that tracks actions that can be cancelled by
/// listeners.
public typealias CancellableActionEvent<Sender, Value> = EventSourceWithSender<Sender, CancellableActionEventArgs<Value>>

/// An event argument set for an event that tracks cancellable actions, while
/// exposing a `cancel` that can be changed by clients to cancel the action.
public class CancellableActionEventArgs<Value> {
    public let value: Value
    public var cancel: Bool

    public init(value: Value) {
        self.value = value
        cancel = false
    }
}

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
}