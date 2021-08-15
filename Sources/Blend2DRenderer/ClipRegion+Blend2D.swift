import SwiftBlend2D
import Geometry
import Rendering

public struct Blend2DClipRegion: ClipRegion {
    public var region: BLRegion
    
    public init(region: BLRegion) {
        self.region = region
    }
    
    public func hitTest(_ rect: Rectangle) -> HitTestResult {
        switch region.hitTest(BLBoxI(roundingRect: rect.asBLRect)) {
        case .in:
            return .in
        case .partial:
            return .partial
        case .out:
            return .out
        default:
            return .out
        }
    }
}
