import Geometry

/// Arguments for a mouse event that is forwarded to event listeners.
public struct MouseEventArgs: Sendable {
    /// The coordinates of the mouse at the time of this event. This value is
    /// in local-coordinates space, and control systems already transform the
    /// mouse location from screen-space to local view-spaced based on the handler
    /// that is going to respond to the mouse event.
    public var location: UIVector

    /// A set of mouse buttons pressed at the time of this event.
    public var buttons: MouseButton

    /// The delta, or 'scroll' of the mouse.
    /// Associated with mouse wheel events only, this value is a vector with
    /// vertical dimension representing the more common vertical scroll wheel
    /// or vertical swipe of a mousepad, and the horizontal dimension for the
    /// less common horizontal scroll button, or horizontal swipe of a mouse pad.
    public var delta: UIVector

    /// The number of clicks that where accumulated by mouse buttons associated
    /// with this event so far.
    ///
    /// Currently not implemented in `ImagineUICore`, but platform implementers
    /// may attribute this value to a sequential click counting, anyway.
    public var clicks: Int

    /// Keyboard modifiers that where pressed when this event was issued.
    public var modifiers: KeyboardModifier

    public init(
        location: UIVector,
        buttons: MouseButton,
        delta: UIVector,
        clicks: Int,
        modifiers: KeyboardModifier
    ) {

        self.location = location
        self.buttons = buttons
        self.delta = delta
        self.clicks = clicks
        self.modifiers = modifiers
    }
}
