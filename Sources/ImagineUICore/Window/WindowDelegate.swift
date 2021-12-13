import Geometry

public protocol WindowDelegate: AnyObject {
    /// Invoked when the user has selected to close a window.
    func windowWantsToClose(_ window: Window)

    /// Invoked when the user has selected to maximize a window.
    func windowWantsToMaximize(_ window: Window)

    /// Invoked when the user has selected to minimize a window.
    func windowWantsToMinimize(_ window: Window)

    /// Returns size for fullscreen display of a window.
    func windowSizeForFullscreen(_ window: Window) -> UISize
}
