/// A typealias for an event that tracks actions that can be cancelled by
/// listeners.
public typealias CancellableActionEvent<Args> = Event<CancellableActionEventArgs<Args>>

/// An event argument set for an event that tracks cancellable actions, while
/// exposing a `cancel` that can be changed by clients to cancel the action.
public class CancellableActionEventArgs<Args> {
    public let value: Args
    public var cancel: Bool

    public init(value: Args) {
        self.value = value
        cancel = false
    }
}

public extension Event {
    func publishCancellableChangeEvent() -> Bool where T == CancellableActionEventArgs<Void> {
        let event = CancellableActionEventArgs(value: ())

        self.publishEvent(event)

        return event.cancel
    }

    func publishCancellableChangeEvent<Value>(value: Value) -> Bool where T == CancellableActionEventArgs<Value> {
        let event = CancellableActionEventArgs(value: value)

        self.publishEvent(event)

        return event.cancel
    }

    func callAsFunction() -> Bool where T == CancellableActionEventArgs<Void> {
        return publishCancellableChangeEvent()
    }

    func callAsFunction<Value>(value: Value) -> Bool where T == CancellableActionEventArgs<Value> {
        return publishCancellableChangeEvent(value: value)
    }
}
