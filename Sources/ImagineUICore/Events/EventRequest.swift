/// Encapsulates an event request object that traverses responder chains looking
/// for a target for input events.
public protocol EventRequest {
    /// Accepts a given event handler for receiving input events.
    func accept(handler: EventHandler)
}
