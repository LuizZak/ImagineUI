import SwiftBlend2D
import Rendering

extension BLHitTest {
    var asHitTestResult: HitTestResult {
        switch self {
        case .in:
            return .in
        case .out:
            return .out
        case .partial:
            return .partial
        default:
            return .out
        }
    }
}
