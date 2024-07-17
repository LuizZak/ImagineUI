/// A protocol describing a keyboard event handler object.
public protocol KeyboardEventHandler: EventHandler {
    /// Main interface to forward key press events to the conforming type.
    /// Key presses are associated with textual-type
    /// character input instead of raw key codes.
    @MainActor
    func onKeyPress(_ event: KeyPressEventArgs) async

    /// Main interface to forward key down events to the conforming type.
    @MainActor
    func onKeyDown(_ event: KeyEventArgs) async

    /// Main interface to forward key up events to the conforming type.
    @MainActor
    func onKeyUp(_ event: KeyEventArgs) async

    /// Main interface to forward key preview events to the conforming type.
    ///
    /// Preview keys may only be available on some OS platforms.
    @MainActor
    func onPreviewKeyDown(_ event: PreviewKeyDownEventArgs) async
}

public extension KeyboardEventHandler {
    func onKeyPress(_ event: KeyPressEventArgs) { }
    func onKeyDown(_ event: KeyEventArgs) { }
    func onKeyUp(_ event: KeyEventArgs) { }
    func onPreviewKeyDown(_ event: PreviewKeyDownEventArgs) { }
}