/// Specifies the type of a keyboard event represented by a `KeyboardEventRequest`.
public enum KeyboardEventType {
    /// A key down event type.
    case keyDown

    /// A key press event type. Key presses are associated with textual-type
    /// character input instead of raw key codes.
    case keyPress

    /// A key up event type.
    case keyUp

    /// A preview key down event type.
    /// Preview keys may only be available on some OS platforms.
    case previewKeyDown
}
