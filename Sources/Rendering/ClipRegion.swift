import Geometry

/// Represents a region composed of rectangles that can be queried with hit tests
/// against rectangles
public protocol ClipRegion {
    /// Performs a hit test of a rectangle against this clip region 
    func hitTest(_ rect: UIRectangle) -> HitTestResult
}
