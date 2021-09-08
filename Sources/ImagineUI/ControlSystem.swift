import Geometry

/// Base for a control system which handles views and controls from a full
/// hierarchy
public protocol ControlSystem {
    /// Sets an event handler as first responder
    ///
    /// - Parameter eventHandler: An event handler, or nil, in case of an attempt
    /// to resign the current first responder.
    /// - Parameter force: Whether to force resignation of first responder, even
    /// if `eventHandler.canResignFirstResponder` returns false.
    /// - Returns: Whether the attempt to set the given event handler as first
    /// responder was successful.
    func setAsFirstResponder(_ eventHandler: EventHandler?, force: Bool) -> Bool

    /// Removes the given event handler as first responder.
    ///
    /// - Returns: Whether the attempt to remove the given event handler as first
    /// responder was successful.
    func removeAsFirstResponder(_ eventHandler: EventHandler) -> Bool

    /// Returns whether a given event handler is the current first responder.
    func isFirstResponder(_ eventHandler: EventHandler) -> Bool
    
    /// Changes the current mouse cursor.
    func setMouseCursor(_ cursor: MouseCursorKind)
    
    /// Hides the mouse until it is moved by the user.
    func setMouseHiddenUntilMouseMoves()
}

public enum MouseCursorKind {
    case arrow
    case iBeam
    case resizeUpDown
    case resizeLeftRight
    case custom(imagePath: String, hotspot: UIVector)
}
