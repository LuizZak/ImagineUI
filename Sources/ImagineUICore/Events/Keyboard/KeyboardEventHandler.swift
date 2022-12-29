/// A protocol describing a keyboard event handler object.
public protocol KeyboardEventHandler: EventHandler {
    /// Main interface to forward key press events to the conforming type.
    /// Key presses are associated with textual-type
    /// character input instead of raw key codes.
    func onKeyPress(_ event: KeyPressEventArgs)

    /// Main interface to forward key down events to the conforming type.
    func onKeyDown(_ event: KeyEventArgs)

    /// Main interface to forward key up events to the conforming type.
    func onKeyUp(_ event: KeyEventArgs)

    /// Main interface to forward key preview events to the conforming type.
    ///
    /// Preview keys may only be available on some OS platforms.
    func onPreviewKeyDown(_ event: PreviewKeyDownEventArgs)
}

public extension KeyboardEventHandler {
    func onKeyPress(_ event: KeyPressEventArgs) { }
    func onKeyDown(_ event: KeyEventArgs) { }
    func onKeyUp(_ event: KeyEventArgs) { }
    func onPreviewKeyDown(_ event: PreviewKeyDownEventArgs) { }
}
