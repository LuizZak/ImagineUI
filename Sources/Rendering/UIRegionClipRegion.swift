import Geometry

/// A clipping region backed by a `UIRegion` instance.
public class UIRegionClipRegion: ClipRegionType {
    private let _bounds: UIRectangle
    private let _region: UIRegion

    public init(region: UIRegion) {
        self._region = region

        _bounds = _region.isEmpty ? .zero : UIRectangle.union(_region.allRectangles())
    }

    public func bounds() -> UIRectangle {
        _bounds
    }

    public func hitTest(_ rect: UIRectangle) -> HitTestResult {
        if _region.contains(rect) {
            return .in
        }

        if _region.intersects(rect) {
            return .partial
        }

        return .out
    }

    public func contains(_ point: UIPoint) -> Bool {
        _region.contains(point)
    }
}
