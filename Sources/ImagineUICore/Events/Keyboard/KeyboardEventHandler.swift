public protocol KeyboardEventHandler: EventHandler {
    func onKeyPress(_ event: KeyPressEventArgs)
    func onKeyDown(_ event: KeyEventArgs)
    func onKeyUp(_ event: KeyEventArgs)
    func onPreviewKeyDown(_ event: PreviewKeyDownEventArgs)
}

public extension KeyboardEventHandler {
    func onKeyPress(_ event: KeyPressEventArgs) { }
    func onKeyDown(_ event: KeyEventArgs) { }
    func onKeyUp(_ event: KeyEventArgs) { }
    func onPreviewKeyDown(_ event: PreviewKeyDownEventArgs) { }
}
