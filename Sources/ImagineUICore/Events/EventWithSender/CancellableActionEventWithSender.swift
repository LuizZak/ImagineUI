/// A typealias for an event that tracks actions that can be cancelled by
/// listeners.
public typealias CancellableActionEventWithSender<Sender, Args> = EventWithSender<Sender, CancellableActionEventArgs<Args>>

/// A typealias for an event that tracks actions that can be cancelled by
/// listeners.
///
/// Evens published by this event source must be handled synchronously.
public typealias SynchronousCancellableActionEventWithSender<Sender, Args> = SynchronousEventWithSender<Sender, CancellableActionEventArgs<Args>>

public extension Event {
    /// Convenience for:
    ///
    /// ```swift
    /// let event = CancellableActionEventArgs(value: ())
    /// self.publishEvent((sender, event))
    /// ```
    ///
    /// Returns the final value of `event.cancel` after publishing the event to
    /// listeners.
    func publishCancellableChangeEvent<Sender>(
        sender: Sender
    ) async -> Bool where T == SenderEventArgs<Sender, CancellableActionEventArgs<Void>> {

        let event = CancellableActionEventArgs(value: ())

        await self.publishEventAsync((sender, event))

        return event.cancel
    }

    /// Convenience for:
    ///
    /// ```swift
    /// let event = CancellableActionEventArgs(value: value)
    /// self.publishEvent((sender, event))
    /// ```
    ///
    /// Returns the final value of `event.cancel` after publishing the event to
    /// listeners.
    func publishCancellableChangeEvent<Sender, Value>(
        sender: Sender,
        value: Value
    ) async -> Bool where T == SenderEventArgs<Sender, CancellableActionEventArgs<Value>> {

        let event = CancellableActionEventArgs(value: value)

        await self.publishEventAsync((sender, event))

        return event.cancel
    }

    /// Convenience for invoking `publishCancellableChangeEvent(sender:)` by
    /// calling the event variable itself directly.
    func callAsFunction<Sender>(
        sender: Sender
    ) async -> Bool where T == SenderEventArgs<Sender, CancellableActionEventArgs<Void>> {

        return await publishCancellableChangeEvent(sender: sender)
    }

    /// Convenience for invoking `publishCancellableChangeEvent(sender:value:)`
    /// by calling the event variable itself directly.
    func callAsFunction<Sender, Value>(
        sender: Sender,
        value: Value
    ) async -> Bool where T == SenderEventArgs<Sender, CancellableActionEventArgs<Value>> {

        return await publishCancellableChangeEvent(sender: sender, value: value)
    }
}

public extension SynchronousEvent {
    /// Convenience for:
    ///
    /// ```swift
    /// let event = SynchronousCancellableActionEventArgs(value: ())
    /// self.publishEvent((sender, event))
    /// ```
    ///
    /// Returns the final value of `event.cancel` after publishing the event to
    /// listeners.
    func publishCancellableChangeEvent<Sender>(
        sender: Sender
    ) -> Bool where T == SenderEventArgs<Sender, CancellableActionEventArgs<Void>> {

        let event = CancellableActionEventArgs(value: ())

        self.publishEvent((sender, event))

        return event.cancel
    }

    /// Convenience for:
    ///
    /// ```swift
    /// let event = CancellableActionEventArgs(value: value)
    /// self.publishEvent((sender, event))
    /// ```
    ///
    /// Returns the final value of `event.cancel` after publishing the event to
    /// listeners.
    func publishCancellableChangeEvent<Sender, Value>(
        sender: Sender,
        value: Value
    ) -> Bool where T == SenderEventArgs<Sender, CancellableActionEventArgs<Value>> {

        let event = CancellableActionEventArgs(value: value)

        self.publishEvent((sender, event))

        return event.cancel
    }

    /// Convenience for invoking `publishCancellableChangeEvent(sender:)` by
    /// calling the event variable itself directly.
    func callAsFunction<Sender>(
        sender: Sender
    ) -> Bool where T == SenderEventArgs<Sender, CancellableActionEventArgs<Void>> {

        return publishCancellableChangeEvent(sender: sender)
    }

    /// Convenience for invoking `publishCancellableChangeEvent(sender:value:)`
    /// by calling the event variable itself directly.
    func callAsFunction<Sender, Value>(
        sender: Sender,
        value: Value
    ) -> Bool where T == SenderEventArgs<Sender, CancellableActionEventArgs<Value>> {

        return publishCancellableChangeEvent(sender: sender, value: value)
    }
}
