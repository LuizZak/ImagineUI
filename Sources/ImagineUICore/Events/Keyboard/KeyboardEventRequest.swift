/// A event request for a keyboard event that is forwarded to potential event
/// handlers to accept.
public protocol KeyboardEventRequest: EventRequest {
    /// The keyboard event this event request represents.
    var eventType: KeyboardEventType { get }
}
