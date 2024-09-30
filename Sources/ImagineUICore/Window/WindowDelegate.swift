import Geometry

public protocol WindowDelegate: AnyObject {
    /// Invoked when the user has selected to close a window.
    @ImagineActor
    func windowWantsToClose(_ window: Window)

    /// Invoked when the user has selected to maximize a window.
    @ImagineActor
    func windowWantsToMaximize(_ window: Window)

    /// Invoked when the user has selected to minimize a window.
    @ImagineActor
    func windowWantsToMinimize(_ window: Window)

    /// Returns size for fullscreen display of a window.
    @ImagineActor
    func windowSizeForFullscreen(_ window: Window) -> UISize
}
