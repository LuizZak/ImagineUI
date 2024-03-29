/// A protocol describing a mouse event handler object.
public protocol MouseEventHandler: EventHandler {
    /// Main interface to forward mouse down events to the conforming type.
    func onMouseDown(_ event: MouseEventArgs)

    /// Main interface to forward mouse move events to the conforming type.
    func onMouseMove(_ event: MouseEventArgs)

    /// Main interface to forward mouse up events to the conforming type.
    func onMouseUp(_ event: MouseEventArgs)

    /// Main interface to forward mouse enter events to the conforming type.
    ///
    /// Mouse enter is associated with the cursor crossing to the inside of the
    /// bounds of a logical screen area occupied by the conforming type, or an
    /// object that the conforming type is associated to, as an event handler.
    func onMouseEnter()

    /// Main interface to forward mouse leave events to the conforming type.
    ///
    /// Mouse leave is associated with the cursor crossing to the outside of the
    /// bounds of a logical screen area occupied by the conforming type, or an
    /// object that the conforming type is associated to, as an event handler.
    func onMouseLeave()

    /// Main interface to forward mouse click events to the conforming type.
    ///
    /// Mouse clicks are automatically synthesized by `DefaultControlSystem` by
    /// pairing up a 'mouse up' event with a 'mouse down' event, in case both
    /// events occurred on top of the same event handler.
    func onMouseClick(_ event: MouseEventArgs)

    /// Main interface to forward mouse scroll events to the conforming type.
    func onMouseWheel(_ event: MouseEventArgs)
}
