import Geometry

/// A clipping region backed by a `UIRegion` instance.
public class UIRegionClipRegion: ClipRegionType {
    private let _region: UIRegion

    public init(region: UIRegion) {
        self._region = region
    }

    public func bounds() -> UIRectangle {
        if _region.isEmpty {
            return .zero
        }

        return UIRectangle.union(_region.allRectangles())
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
}
