/// Represents an event that sends a `sender` property along with the event
/// arguments to listeners.
///
/// The sender is by convention the object responsible for the issuing of the
/// event, if the event is a property, the sender is the property's type, and
/// may be used by event listeners as a filter to selectively respond to
/// events based on the sender.
public typealias EventWithSender<T, U> = Event<SenderEventArgs<T, U>>

/// Represents an event that sends a `sender` property along with the event
/// arguments to listeners.
///
/// The sender is by convention the object responsible for the issuing of the
/// event, if the event is a property, the sender is the property's type, and
/// may be used by event listeners as a filter to selectively respond to
/// events based on the sender.
///
/// Evens published by this event source must be handled synchronously.
public typealias SynchronousEventWithSender<T, U> = SynchronousEvent<SenderEventArgs<T, U>>
