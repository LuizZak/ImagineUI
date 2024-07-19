/// A typealias for an event that tracks actions that can be cancelled by
/// listeners.
public typealias CancellableActionEvent<Args> = Event<CancellableActionEventArgs<Args>>

/// An event argument set for an event that tracks cancellable actions, while
/// exposing a `cancel` that can be changed by clients to cancel the action.
public class CancellableActionEventArgs<Args> {
    /// The associated event arguments for this event object.
    public let value: Args

    /// Variable that event handlers can use to mark this event as 'canceled'.
    ///
    /// The semantics of a canceled event are handled by the event publisher,
    /// and can be used to monitor and cancel UI events such as a tree view
    /// expansion or check box toggle.
    ///
    /// Multiple event listeners may toggle this value on and off as they take
    /// turns handling the event that this argument object accompanies, but only
    /// the last value `cancel` was attributed to is seen by event publishers
    /// upstream.
    public var cancel: Bool

    public init(value: Args) {
        self.value = value
        cancel = false
    }
}

public extension Event {
    /// Convenience for:
    ///
    /// ```swift
    /// let event = CancellableActionEventArgs(value: ())
    /// self.publishEventAsync(event)
    /// ```
    ///
    /// Returns the final value of `CancellableActionEventArgs<Args>.cancel`
    /// after publishing the event to listeners.
    func publishCancellableChangeEvent() async -> Bool where T == CancellableActionEventArgs<Void> {
        let event = CancellableActionEventArgs(value: ())

        await self.publishEventAsync(event)

        return event.cancel
    }

    /// Convenience for:
    ///
    /// ```swift
    /// let event = CancellableActionEventArgs(value: value)
    /// self.publishEventAsync(event)
    /// ```
    ///
    /// Returns the final value of `CancellableActionEventArgs<Args>.cancel`
    /// after publishing the event to listeners.
    func publishCancellableChangeEvent<Value>(value: Value) async -> Bool where T == CancellableActionEventArgs<Value> {
        let event = CancellableActionEventArgs(value: value)

        await self.publishEventAsync(event)

        return event.cancel
    }

    /// Convenience for invoking `publishCancellableChangeEvent()` by calling
    /// the event variable itself directly.
    func callAsFunction() async -> Bool where T == CancellableActionEventArgs<Void> {
        return await publishCancellableChangeEvent()
    }

    /// Convenience for invoking `publishCancellableChangeEvent(value:)` by
    /// calling the event variable itself directly.
    func callAsFunction<Value>(value: Value) async -> Bool where T == CancellableActionEventArgs<Value> {
        return await publishCancellableChangeEvent(value: value)
    }
}
