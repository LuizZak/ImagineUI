import SwiftBlend2D
import Rendering

public class Blend2DRegion: Region {
    var _region: BLRegion
    
    public init() {
        _region = BLRegion()
    }
    
    public func combine(with other: Region, operation: RegionOperator) {
        guard let other = other as? Blend2DRegion else {
            fatalError("Unknown region type \(type(of: other))")
        }
        
        _region.combine(other._region, operation: operation.asBLBooleanOp)
    }
    
    public func combine(_ rect: UIRectangle, operation: RegionOperator) {
        _region.combine(box: BLBoxI(roundingRect: rect.asBLRect), operation: operation.asBLBooleanOp)
    }
    
    public func scans() -> [UIRectangle] {
        return _region.regionScans.map(\.asRectangle)
    }
}

extension RegionOperator {
    var asBLBooleanOp: BLBooleanOp {
        switch self {
        case .subtract:
            return .sub
        case .and:
            return .and
        case .or:
            return .or
        case .xor:
            return .xor
        }
    }
}
