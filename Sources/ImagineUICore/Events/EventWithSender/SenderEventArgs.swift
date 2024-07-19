/// A typealias for an event that has a sender.
public typealias SenderEventArgs<Sender, EventArgs> = (sender: Sender, args: EventArgs)

public extension Event {
    /// Convenience for `publishEventAsync((sender, ()))`.
    func publishEvent<Sender>(sender: Sender) async where T == SenderEventArgs<Sender, Void> {
        await publishEventAsync((sender, ()))
    }

    /// Convenience for `publishEvent((sender, ()))`.
    func publishEvent<Sender>(sender: Sender) where T == SenderEventArgs<Sender, Void> {
        publishEvent((sender, ()))
    }

    /// Convenience for `publishEventAsync((sender, args))`.
    func publishEvent<Sender, Args>(
        sender: Sender,
        _ args: Args
    ) async where T == SenderEventArgs<Sender, Args> {

        await publishEventAsync((sender, args))
    }

    /// Convenience for `publishEvent((sender, args))`.
    func publishEvent<Sender, Args>(
        sender: Sender,
        _ args: Args
    ) where T == SenderEventArgs<Sender, Args> {

        publishEvent((sender, args))
    }

    /// Convenience for invoking `publishEvent(sender:)` by calling the event
    /// variable itself directly.
    func callAsFunction<Sender>(sender: Sender) async where T == SenderEventArgs<Sender, Void> {
        await publishEvent(sender: sender)
    }

    /// Convenience for invoking `publishEvent(sender:)` by calling the event
    /// variable itself directly.
    func callAsFunction<Sender>(sender: Sender) where T == SenderEventArgs<Sender, Void> {
        publishEvent(sender: sender)
    }

    /// Convenience for invoking `publishEvent(sender:_:)` by calling the event
    /// variable itself directly.
    func callAsFunction<Sender, Args>(
        sender: Sender,
        _ args: Args
    ) async where T == SenderEventArgs<Sender, Args> {

        await publishEvent(sender: sender, args)
    }

    /// Convenience for invoking `publishEvent(sender:_:)` by calling the event
    /// variable itself directly.
    func callAsFunction<Sender, Args>(
        sender: Sender,
        _ args: Args
    ) where T == SenderEventArgs<Sender, Args> {

        publishEvent(sender: sender, args)
    }
}

public extension SynchronousEvent {
    /// Convenience for `publishEvent((sender, ()))`.
    func publishEvent<Sender>(sender: Sender) where T == SenderEventArgs<Sender, Void> {
        publishEvent((sender, ()))
    }

    /// Convenience for `publishEvent((sender, args))`.
    func publishEvent<Sender, Args>(
        sender: Sender,
        _ args: Args
    ) where T == SenderEventArgs<Sender, Args> {

        publishEvent((sender, args))
    }

    /// Convenience for invoking `publishEvent(sender:)` by calling the event
    /// variable itself directly.
    func callAsFunction<Sender>(sender: Sender) where T == SenderEventArgs<Sender, Void> {
        publishEvent(sender: sender)
    }

    /// Convenience for invoking `publishEvent(sender:_:)` by calling the event
    /// variable itself directly.
    func callAsFunction<Sender, Args>(
        sender: Sender,
        _ args: Args
    ) where T == SenderEventArgs<Sender, Args> {

        publishEvent(sender: sender, args)
    }
}
