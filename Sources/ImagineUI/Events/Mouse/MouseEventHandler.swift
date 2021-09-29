public protocol MouseEventHandler: EventHandler {
    func onMouseDown(_ event: MouseEventArgs)
    func onMouseMove(_ event: MouseEventArgs)
    func onMouseUp(_ event: MouseEventArgs)

    func onMouseLeave()
    func onMouseEnter()

    func onMouseClick(_ event: MouseEventArgs)
    func onMouseWheel(_ event: MouseEventArgs)
}
