import Geometry

/// Represents a region composed of rectangles that can be queried with
/// intersection tests against other rectangles.
public protocol ClipRegionType {
    /// Returns the minimal rectangle capable of containing this clip region's
    /// contents.
    ///
    /// If this clip region is empty, `UIRectangle.zero` is returned, instead.
    func bounds() -> UIRectangle

    /// Performs a hit test of a rectangle against this clip region.
    func hitTest(_ rect: UIRectangle) -> HitTestResult

    /// Returns `true` if a given point is contained within this clip region.
    func contains(_ point: UIPoint) -> Bool
}
