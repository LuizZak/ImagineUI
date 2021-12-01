/// A typealias for an event that has a sender
public typealias SenderEventArgs<Sender, EventArgs> = (sender: Sender, args: EventArgs)

public extension Event {
    func publishEvent<Sender>(sender: Sender) where T == SenderEventArgs<Sender, Void> {
        publishEvent((sender, ()))
    }

    func publishEvent<Sender, Args>(sender: Sender, _ args: Args) where T == SenderEventArgs<Sender, Args> {
        publishEvent((sender, args))
    }

    func callAsFunction<Sender>(sender: Sender) where T == SenderEventArgs<Sender, Void> {
        publishEvent(sender: sender)
    }

    func callAsFunction<Sender, Args>(sender: Sender, _ args: Args) where T == SenderEventArgs<Sender, Args> {
        publishEvent(sender: sender, args)
    }
}
