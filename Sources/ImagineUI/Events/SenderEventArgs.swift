/// A typealias for an event that has a sender
public typealias SenderEventArgs<Sender, EventArgs> = (sender: Sender, args: EventArgs)

public extension Event {
    func publishEvent<Sender>(sender: Sender) where T == SenderEventArgs<Sender, Void> {
        self.publishEvent((sender, ()))
    }
    
    func publishEvent<Sender, Args>(sender: Sender, _ args: Args) where T == SenderEventArgs<Sender, Args> {
        self.publishEvent((sender, args))
    }
}
