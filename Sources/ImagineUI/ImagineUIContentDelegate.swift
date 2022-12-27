/// Protocol for delegates of `ImagineUIContentType` instances.
public protocol ImagineUIContentDelegate: AnyObject {
    /// Called to notify that a layout invalidation request has been raised by
    /// the controls on screen.
    func needsLayout(_ content: ImagineUIContentType, _ view: View)

    /// Called to notify that the contents needs redrawing in a specified portion
    /// of the relative area that a content occupies on its parent window.
    func invalidate(_ content: ImagineUIContentType, bounds: UIRectangle)

    /// Called to notify that the content has requested a specified mouse cursor
    /// to be displayed.
    func setMouseCursor(_ content: ImagineUIContentType, cursor: MouseCursorKind)

    /// Called to notify that the content has requested that the mouse cursor be
    /// hidden until it is moved again by the user.
    func setMouseHiddenUntilMouseMoves(_ content: ImagineUIContentType)

    /// Called to notify that a first responder for the content wrapper has
    /// changed.
    func firstResponderChanged(_ content: ImagineUIContentType, _ newFirstResponder: KeyboardEventHandler?)

    /// Called to notify that the preferred render scale of an `ImagineUIContentType`
    /// has changed.
    func preferredRenderScaleChanged(_ content: ImagineUIContentType, renderScale: UIVector)

    /// Called to request the relative DPI scaling factor for the window this
    /// content is on.
    ///
    /// Scales differ from 1.0 when the DPI of the display associated with a
    /// window changes.
    func windowDpiScalingFactor(_ content: ImagineUIContentType) -> Double
}
