import ImagineUICore

/// A protocol for types that implement a complete self-contained ImagineUI
/// implementation.
public protocol ImagineUIContentType: AnyObject {
    /// Gets the current content's size, in pixels.
    var size: UIIntSize { get }

    /// The preferred render scale this content should be rendered as.
    /// Preferred render scales can be ignored by the underlying system and the
    /// actual content rendering scale is passed to the
    /// `render(renderer:renderScale:clipRegion)` method at runtime.
    var preferredRenderScale: UIVector { get }

    /// Gets or sets the delegate associated with this `ImagineUIContentType`
    var delegate: ImagineUIContentDelegate? { get set }

    /// Called to notify that the GUI window this content is in will be resized
    /// by the user.
    ///
    /// Can be used to temporarily ignore expensive internal resizing operations
    /// until `didEndLiveResize()` is called.
    func willStartLiveResize()

    /// Called to notify that the GUI window this content is in has finished
    /// a live resize operation.
    func didEndLiveResize()

    /// Called to notify that the screen space this content occupies has changed.
    func resize(_ newSize: UIIntSize)

    /// Called to request that any pending layout operations are performed.
    func performLayout()

    /// Renders this content on a given renderer, with a specified render scale
    /// associated.
    ///
    /// A redraw clipping region is specified to inform the content of areas
    /// where re-rendering is not required.
    func render(renderer: Renderer, renderScale: UIVector, clipRegion: ClipRegion)

    /// Called to notify of mouse down events.
    ///
    /// Mouse location should be specified relative to this content's bounds
    /// on screen, so content that does not fill a window can still respond
    /// to the mouse coordinates correctly.
    func mouseDown(event: MouseEventArgs)

    /// Called to notify of mouse move events.
    ///
    /// Mouse location should be specified relative to this content's bounds
    /// on screen, so content that does not fill a window can still respond
    /// to the mouse coordinates correctly.
    func mouseMoved(event: MouseEventArgs)
    
    /// Called to notify of mouse up events.
    ///
    /// Mouse location should be specified relative to this content's bounds
    /// on screen, so content that does not fill a window can still respond
    /// to the mouse coordinates correctly.
    func mouseUp(event: MouseEventArgs)
    
    /// Called to notify of mouse scroll wheel events.
    ///
    /// Mouse location should be specified relative to this content's bounds
    /// on screen, so content that does not fill a window can still respond
    /// to the mouse coordinates correctly.
    func mouseScroll(event: MouseEventArgs)

    /// Called to notify of key down events.
    func keyDown(event: KeyEventArgs)

    /// Called to notify of key up events.
    func keyUp(event: KeyEventArgs)

    /// Called to notify of key presses (character-based input) events.
    func keyPress(event: KeyPressEventArgs)

    /// Called to notify that the window associated with this ImagineUI content
    /// has been closed.
    func didCloseWindow()
}

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
    func setMouseCursor(_ content: ImagineUIContentType, _ cursor: MouseCursorKind)

    /// Called to notify that the content has requested that the mouse cursor be
    /// hidden until it is moved again by the user.
    func setMouseHiddenUntilMouseMoves(_ content: ImagineUIContentType)

    /// Called to notify that a first responder for the content wrapper has
    /// changed.
    func firstResponderChanged(_ content: ImagineUIContentType, _ newFirstResponder: KeyboardEventHandler?)

    /// Called to notify that the preferred render scale of an `ImagineUIContentType`
    /// has changed.
    func preferredRenderScaleChanged(_ content: ImagineUIContentType, renderScale: UIVector)
}
