import Geometry

/// Event requests for mouse input.
public protocol MouseEventRequest: EventRequest {
    /// The type of mouse event associated with this event.
    var eventType: MouseEventType { get }

    /// The screen-space location of the mouse at the time of this event.
    var screenLocation: UIVector { get }

    /// A set of mouse buttons pressed at the time of this event.
    var buttons: MouseButton { get }

    /// The delta, or 'scroll' of the mouse.
    /// Associated with mouse wheel events only, this value is a vector with
    /// vertical dimension representing the more common vertical scroll wheel
    /// or vertical swipe of a mousepad, and the horizontal dimension for the
    /// less common horizontal scroll button, or horizontal swipe of a mouse pad.
    var delta: UIVector { get }

    /// The number of clicks that where accumulated by mouse buttons associated
    /// with this event so far.
    ///
    /// Currently not implemented in `ImagineUICore`, but platform implementers
    /// may attribute this value to a sequential click counting, anyway.
    var clicks: Int { get }

    /// Keyboard modifiers that where pressed when this event was issued.
    var modifiers: KeyboardModifier { get }
}
