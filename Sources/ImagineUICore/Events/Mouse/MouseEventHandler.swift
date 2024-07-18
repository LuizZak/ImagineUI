/// A protocol describing a mouse event handler object.
public protocol MouseEventHandler: EventHandler {
    /// Main interface to forward mouse down events to the conforming type.
    @ImagineActor
    func onMouseDown(_ event: MouseEventArgs) async

    /// Main interface to forward mouse move events to the conforming type.
    @ImagineActor
    func onMouseMove(_ event: MouseEventArgs) async

    /// Main interface to forward mouse up events to the conforming type.
    @ImagineActor
    func onMouseUp(_ event: MouseEventArgs) async

    /// Main interface to forward mouse enter events to the conforming type.
    ///
    /// Mouse enter is associated with the cursor crossing to the inside of the
    /// bounds of a logical screen area occupied by the conforming type, or an
    /// object that the conforming type is associated to, as an event handler.
    @ImagineActor
    func onMouseEnter() async

    /// Main interface to forward mouse leave events to the conforming type.
    ///
    /// Mouse leave is associated with the cursor crossing to the outside of the
    /// bounds of a logical screen area occupied by the conforming type, or an
    /// object that the conforming type is associated to, as an event handler.
    @ImagineActor
    func onMouseLeave() async

    /// Main interface to forward mouse click events to the conforming type.
    ///
    /// Mouse clicks are automatically synthesized by `DefaultControlSystem` by
    /// pairing up a 'mouse up' event with a 'mouse down' event, in case both
    /// events occurred on top of the same event handler.
    @ImagineActor
    func onMouseClick(_ event: MouseEventArgs) async

    /// Main interface to forward mouse scroll events to the conforming type.
    @ImagineActor
    func onMouseWheel(_ event: MouseEventArgs) async
}
