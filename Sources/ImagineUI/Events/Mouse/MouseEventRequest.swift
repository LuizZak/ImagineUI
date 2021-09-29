import Geometry

/// Event requests for mouse input
public protocol MouseEventRequest: EventRequest {
    var eventType: MouseEventType { get }
    var screenLocation: UIVector { get }
    var buttons: MouseButton { get }
    var delta: UIVector { get }
    var clicks: Int { get }
}
