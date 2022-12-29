/// A typealias for an event source for an event with a sender.
///
/// The sender is by convention the object responsible for the issuing of the
/// event, if the event is a property, the sender is the property's type, and
/// may be used by event listeners as a filter to selectively respond to
/// events.
public typealias EventSourceWithSender<T, U> = EventSource<SenderEventArgs<T, U>>
