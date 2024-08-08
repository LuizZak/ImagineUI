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

    /// Gets or sets the delegate associated with this `ImagineUIContentType`.
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
    func render(renderer: Renderer, renderScale: UIVector, clipRegion: ClipRegionType)

    /// Called to notify that the mouse left the active area this content is on.
    func mouseLeave()

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
    ///
    /// Returns `false` if no event responder responded to the event request.
    func keyPress(event: KeyPressEventArgs) -> Bool

    /// Called to notify that the window associated with this ImagineUI content
    /// has been closed.
    func didCloseWindow()
}
