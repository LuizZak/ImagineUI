/// Represents an event that sends a `sender` property along with the event
/// arguments to listeners.
public typealias EventWithSender<T, U> = Event<SenderEventArgs<T, U>>
