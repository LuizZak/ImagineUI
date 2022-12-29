/// Specifies the type of a mouse event request represented by `MouseEventRequest`.
public enum MouseEventType {
    /// A mouse down event type.
    case mouseDown

    /// A mouse move event type.
    case mouseMove

    /// A mouse up event type.
    case mouseUp

    /// A mouse click event type.
    /// Mouse clicks are automatically synthesized by a pair of 'mouse down' and
    /// 'mouse up' events that occur on top of the same event handler, and replace
    /// the associated 'mouse up' event.
    case mouseClick

    /// A mouse double click event.
    case mouseDoubleClick

    /// A mouse scroll event.
    case mouseWheel
}
