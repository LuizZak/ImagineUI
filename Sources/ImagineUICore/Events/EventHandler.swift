import Geometry

/// Base event handler interface
public protocol EventHandler: AnyObject {
    /// Returns whether this event handler is the first responder in the
    /// responder chain.
    var isFirstResponder: Bool { get }

    /// Returns whether this event handler can become the first responder of
    /// targeted events.
    var canBecomeFirstResponder: Bool { get }

    /// If this event handler is the first responder, returns whether it can
    /// currently resign the state.
    var canResignFirstResponder: Bool { get }

    /// Next target to direct an event to, in case this handler has not handled
    /// the event.
    var next: EventHandler? { get }

    /// Asks this event handler to become the first responder on the event
    /// responder chain.
    ///
    /// Returns a value specifying whether this event handler successfully became
    /// the first responder.
    /// If another event handler in the hierarchy is the first responder and it
    /// denies resigning it, or this event handler returns `canBecomeFirstResponder`
    /// as false, false is returned and this event handler does not become the
    /// first responder.
    ///
    /// If this handler is already the first responder (see `isFirstResponder`),
    /// the method returns true immediately.
    @ImagineActor
    func becomeFirstResponder() -> Bool

    /// Asks this event handler to dismiss its first responder status.
    @ImagineActor
    func resignFirstResponder()

    /// Asks this event handler to convert a screen-coordinate space point into
    /// its own local coordinates when synthesizing location events (e.g. mouse
    /// events) into this event handler.
    @ImagineActor
    func convertFromScreen(_ point: UIVector) -> UIVector

    /// Requests that this event handler analyze an event request, and potentially
    /// accept the event via `EventRequest.accept(handler:)`, or forward to a
    /// next event handler in a responder chain or other custom sequence of
    /// potential event handlers.
    ///
    /// Event handlers are not required to interact with an event request and may
    /// simply ignore it, but they may not accept it more than once.
    @ImagineActor
    func handleOrPass(_ eventRequest: EventRequest) async
}
