import Geometry

/// A delegate for a root view that handles display and layout invalidations
public protocol RootViewRedrawInvalidationDelegate: AnyObject {
    /// Signals the delegate that a given root view has invalidated its layout
    /// and needs to update it.
    func rootViewInvalidatedLayout(_ rootView: RootView)

    /// Signals the delegate that a given root view has invalidated a display
    /// area and needs to repaint it.
    func rootView(_ rootView: RootView, invalidateRect rect: UIRectangle)
}
